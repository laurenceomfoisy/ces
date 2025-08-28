test_that("download_pdf_codebook validates inputs correctly", {
  # Test that invalid year throws error
  expect_error(download_pdf_codebook("9999"), "Invalid year")
})

test_that("create_codebook handles normal datasets correctly", {
  # Create a simple test dataset
  test_data <- data.frame(
    var1 = c(1, 2, 3),
    var2 = c("A", "B", "C"),
    var3 = factor(c("low", "med", "high"))
  )
  
  # Add some metadata
  attr(test_data$var1, "label") <- "Test variable 1"
  attr(test_data$var2, "label") <- "Test variable 2" 
  attr(test_data$var3, "label") <- "Test variable 3"
  
  # Test basic functionality
  codebook <- create_codebook(test_data)
  
  expect_s3_class(codebook, "tbl_df")
  expect_equal(nrow(codebook), 3)
  expect_equal(ncol(codebook), 3)
  expect_equal(names(codebook), c("variable", "question", "responses"))
  expect_equal(codebook$variable, c("var1", "var2", "var3"))
  expect_equal(codebook$question, c("Test variable 1", "Test variable 2", "Test variable 3"))
})

test_that("create_codebook handles multi-value labels correctly", {
  # Create a test dataset with multi-value labels (the bug scenario)
  test_data <- data.frame(
    normal_var = c(1, 2, 3),
    multi_label_var = c(1, 2, 1)
  )
  
  # Add normal label
  attr(test_data$normal_var, "label") <- "Normal label"
  
  # Add multi-value label (this caused the original bug)
  attr(test_data$multi_label_var, "label") <- c("Value 1", "Value 2")
  
  # This should not throw an error
  codebook <- create_codebook(test_data)
  
  expect_s3_class(codebook, "tbl_df")
  expect_equal(nrow(codebook), 2)
  expect_equal(codebook$variable, c("normal_var", "multi_label_var"))
  expect_equal(codebook$question[1], "Normal label")
  expect_equal(codebook$question[2], "Value 1 | Value 2")  # Should be collapsed
})

test_that("create_codebook handles missing labels correctly", {
  # Test dataset with some missing labels
  test_data <- data.frame(
    labeled_var = c(1, 2, 3),
    unlabeled_var = c(4, 5, 6)
  )
  
  attr(test_data$labeled_var, "label") <- "Has label"
  # unlabeled_var has no label attribute
  
  codebook <- create_codebook(test_data)
  
  expect_equal(nrow(codebook), 2)
  expect_equal(codebook$question[1], "Has label")
  expect_true(is.na(codebook$question[2]))  # Should be NA for missing label
})

test_that("create_codebook works with different output formats", {
  test_data <- data.frame(var1 = c(1, 2, 3))
  attr(test_data$var1, "label") <- "Test variable"
  
  # Test tibble format (default)
  codebook_tibble <- create_codebook(test_data, format = "tibble")
  expect_s3_class(codebook_tibble, "tbl_df")
  
  # Test data.frame format
  codebook_df <- create_codebook(test_data, format = "data.frame")
  expect_s3_class(codebook_df, "data.frame")
  expect_false(inherits(codebook_df, "tbl_df"))
})

# Integration tests for the specific datasets that were failing
test_that("create_codebook works with problematic datasets", {
  skip_on_cran()  # Skip on CRAN to avoid long download times
  
  # Test the datasets that were previously failing
  problematic_years <- list(
    c("2015", "web"),
    c("2015", "phone"), 
    c("2021", "web")
  )
  
  for (dataset_info in problematic_years) {
    year <- dataset_info[1]
    variant <- if (length(dataset_info) > 1) dataset_info[2] else NULL
    
    # Try to load dataset and create codebook - skip gracefully if no internet
    tryCatch({
      if (is.null(variant)) {
        data <- get_ces(year, verbose = FALSE)
      } else {
        data <- get_ces(year, variant = variant, verbose = FALSE)
      }
      codebook <- create_codebook(data)
      
      # If we get here, the test passed
      expect_true(nrow(codebook) > 0)
      
    }, error = function(e) {
      # Skip if it's a network-related error
      if (grepl("download|connection|internet|resolve|timeout", e$message, ignore.case = TRUE)) {
        skip(paste("Network unavailable for", year, variant))
      } else {
        # Re-throw non-network errors (these are real test failures)
        stop(e)
      }
    })
  }
})