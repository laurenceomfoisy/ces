test_that("download_pdf_codebook validates inputs correctly", {
  # Test that invalid year throws error
  expect_error(download_pdf_codebook("9999"), "Invalid year")
})