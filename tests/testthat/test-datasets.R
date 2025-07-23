test_that("list_ces_datasets returns expected structure with variants", {
  # Test the function returns a data frame with year and variants columns
  datasets <- list_ces_datasets()
  expect_true(is.data.frame(datasets))
  expect_true("year" %in% names(datasets))
  expect_true("variants" %in% names(datasets))
  
  # Test that important years are present
  years <- datasets$year
  expect_true("2019" %in% years)
  expect_true("2015" %in% years)
  expect_true("2021" %in% years)
  expect_true("1972" %in% years)
  expect_true("1974" %in% years)
  
  # Test that variants exist for 2015 and 2019 (comma-separated format)
  variants_2015 <- datasets[datasets$year == "2015", "variants"]
  expect_true(grepl("web", variants_2015))
  expect_true(grepl("phone", variants_2015))
  expect_true(grepl("combo", variants_2015))
  
  variants_2019 <- datasets[datasets$year == "2019", "variants"]
  expect_true(grepl("web", variants_2019))
  expect_true(grepl("phone", variants_2019))
  
  # Test that 1972 has multiple variants (comma-separated)
  variants_1972 <- datasets[datasets$year == "1972", "variants"]
  expect_true(grepl("jnjl", variants_1972))
  expect_true(grepl("sep", variants_1972))
  expect_true(grepl("nov", variants_1972))
  
  # Test that 1974 has both single_survey and 1974_1980 variants
  variants_1974 <- datasets[datasets$year == "1974", "variants"]
  expect_true(grepl("single_survey", variants_1974))
  expect_true(grepl("1974_1980", variants_1974))
})

test_that("get_ces_subset validates inputs correctly", {
  skip("Skip download-dependent tests for now")
  
  # Test that invalid year throws error
  expect_error(get_ces("9999"), "Invalid year")
  
  # Test that invalid format throws error
  expect_error(get_ces("2019", format = "invalid"), "Invalid format")
  
  # Test that invalid language throws error
  expect_error(get_ces("2019", language = "invalid"), "Invalid language")
})

test_that("get_ces_subset handles regex correctly", {
  skip("Skip download-dependent tests for now")
  
  # This test would require either a mock dataset or downloading real data
  # We'll skip it for now to avoid dependencies in testing
  
  # Example of what to test:
  # - Subsetting works with exact variable names
  # - Regex matching works as expected
  # - Warning is shown for non-existent variables
  # - Different format options work correctly
})