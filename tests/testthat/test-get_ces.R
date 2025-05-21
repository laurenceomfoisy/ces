test_that("get_ces validates inputs correctly", {
  # Test that invalid year throws error
  expect_error(get_ces("9999"), "Invalid year")
  
  # Test that invalid format throws error
  expect_error(get_ces("2019", format = "invalid"), "Invalid format")
  
  # Test that invalid language throws error
  expect_error(get_ces("2019", language = "invalid"), "Invalid language")
})

# To test actual data retrieval, we need a mock
# This will avoid actual downloads during testing
test_that("get_ces handles data retrieval properly", {
  skip("Skipping download test")
  
  # This test would require downloading real data or mocking
  # We'll skip it for now, but it could be implemented later
  # when we have a proper test environment
  
  # Example of what to test:
  # - Data retrieval works for different years
  # - Different format options work correctly
  # - Cache mechanism works as expected
  # - Encoding is handled correctly
})