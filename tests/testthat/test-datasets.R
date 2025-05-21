test_that("list_ces_datasets returns expected formats", {
  # Test that list_ces_datasets returns a character vector by default
  years <- list_ces_datasets()
  expect_type(years, "character")
  expect_gt(length(years), 0)
  
  # Skip detailed test if tibble not available
  skip_if_not_installed("tibble")
  
  # Test that list_ces_datasets(details = TRUE) returns a tibble with expected columns
  details <- list_ces_datasets(details = TRUE)
  expect_s3_class(details, "tbl_df")
  expect_named(details, c("year", "type", "description"))
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