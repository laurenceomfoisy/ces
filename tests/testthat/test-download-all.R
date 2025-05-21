test_that("download_all_ces_datasets validates inputs correctly", {
  # Test that invalid year throws error
  expect_error(download_all_ces_datasets(years = c("9999")), "Invalid year")
  
  # Test that a non-existent combination of years is detected
  expect_error(download_all_ces_datasets(years = c("2022", "2023")), "Invalid year")
})