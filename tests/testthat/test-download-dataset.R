test_that("download_ces_dataset validates inputs correctly", {
  # Test that invalid year throws error
  expect_error(download_ces_dataset("9999"), "Invalid year")
  
  # Test that a non-existent year is detected
  expect_error(download_ces_dataset("2022"), "Invalid year")
})