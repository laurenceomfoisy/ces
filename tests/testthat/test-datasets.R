test_that("list_ces_datasets returns expected structure with variants", {
  # Test the function returns a data frame with variants
  datasets <- list_ces_datasets()
  expect_true(is.data.frame(datasets))
  expect_true("year" %in% names(datasets))
  expect_true("variant" %in% names(datasets))
  expect_true("type" %in% names(datasets))
  expect_true("description" %in% names(datasets))
  
  # Test that important years are present
  years <- unique(datasets$year)
  expect_true("2019" %in% years)
  expect_true("2015" %in% years)
  expect_true("2021" %in% years)
  expect_true("1972" %in% years)
  expect_true("1974" %in% years)
  
  # Test that variants exist for 2015 and 2019
  datasets_2015 <- datasets[datasets$year == "2015", ]
  expect_true("web" %in% datasets_2015$variant)
  expect_true("phone" %in% datasets_2015$variant)
  expect_true("combo" %in% datasets_2015$variant)
  
  datasets_2019 <- datasets[datasets$year == "2019", ]
  expect_true("web" %in% datasets_2019$variant)
  expect_true("phone" %in% datasets_2019$variant)
  
  # Test that 1972 has multiple variants
  datasets_1972 <- datasets[datasets$year == "1972", ]
  expect_true(nrow(datasets_1972) == 3) # jnjl, sep, nov
  expect_true("jnjl" %in% datasets_1972$variant)
  expect_true("sep" %in% datasets_1972$variant)
  expect_true("nov" %in% datasets_1972$variant)
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