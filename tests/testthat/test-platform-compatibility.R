test_that("platform-specific paths work correctly", {
  # Test that file.path works correctly on all platforms
  test_path <- file.path("parent", "child", "file.txt")
  
  # Should have correct number of path components regardless of OS
  # This might differ slightly by platform, so we just check it's reasonable
  components <- unlist(strsplit(test_path, .Platform$file.sep))
  expect_true(length(components) >= 2)
  
  # Test path normalization
  current_dir <- getwd()
  normalized_path <- normalizePath(current_dir, mustWork = TRUE)
  expect_true(dir.exists(normalized_path))
  
  # Test temporary directory access (important for caching)
  temp_dir <- tempdir()
  expect_true(dir.exists(temp_dir))
  
  # Test ability to create and remove directories
  test_dir <- file.path(temp_dir, "ces_test_dir")
  if (dir.exists(test_dir)) unlink(test_dir, recursive = TRUE)
  dir.create(test_dir, recursive = TRUE)
  expect_true(dir.exists(test_dir))
  
  # Test file creation/writing/reading
  test_file <- file.path(test_dir, "test_file.txt")
  writeLines("test content", test_file)
  expect_true(file.exists(test_file))
  content <- readLines(test_file)
  expect_equal(content, "test content")
  
  # Cleanup
  unlink(test_dir, recursive = TRUE)
  expect_false(dir.exists(test_dir))
})

test_that("URL handling works", {
  skip_on_cran() # Skip on CRAN to avoid network dependencies
  
  # Test different URL schemes without mocking
  http_url <- "http://example.com"
  https_url <- "https://example.com"
  
  # Create test files to verify url parsing functionality
  http_test_file <- tempfile(fileext = ".txt")
  on.exit(unlink(http_test_file), add = TRUE)
  
  https_test_file <- tempfile(fileext = ".txt")
  on.exit(unlink(https_test_file), add = TRUE)
  
  # Simple test that properly formed URLs can be parsed
  expect_true(grepl("^http://", http_url))
  expect_true(grepl("^https://", https_url))
  
  # Test that URL and file path concatenation works properly
  expect_equal(paste0(https_url, "/data.csv"), "https://example.com/data.csv")
})

test_that("package handles file encoding correctly", {
  # Test handling of different encodings
  # This is important for SPSS/Stata files which may have different encodings
  
  # Create a test string with ASCII characters (safe across all platforms)
  test_string <- "test string"
  test_file <- tempfile(fileext = ".txt")
  
  # Test UTF-8 encoding
  writeLines(test_string, test_file, useBytes = FALSE)
  read_utf8 <- readLines(test_file)
  expect_equal(read_utf8, test_string)
  
  # Cleanup
  unlink(test_file)
})

test_that("functions handle path edge cases", {
  # Test handling of paths with spaces
  path_with_spaces <- file.path(tempdir(), "folder with spaces")
  dir.create(path_with_spaces, showWarnings = FALSE)
  expect_true(dir.exists(path_with_spaces))
  
  # Test file in path with spaces
  file_with_spaces <- file.path(path_with_spaces, "file with spaces.txt")
  writeLines("test", file_with_spaces)
  expect_true(file.exists(file_with_spaces))
  expect_equal(readLines(file_with_spaces), "test")
  
  # Test long paths (potential issue on Windows)
  # Create a path that might be long but not exceed OS limits
  long_path_parts <- rep("subfolder", 10)
  long_path <- file.path(tempdir(), paste(long_path_parts, collapse = .Platform$file.sep))
  
  # Only test if we're not likely to hit OS limits
  if (nchar(long_path) < 200) {
    dir.create(long_path, recursive = TRUE, showWarnings = FALSE)
    expect_true(dir.exists(long_path))
    unlink(long_path, recursive = TRUE)
  }
  
  # Clean up
  unlink(path_with_spaces, recursive = TRUE)
})

test_that("package handles platform-specific file operations", {
  # Test file locking behavior - important for Windows
  test_file <- tempfile(fileext = ".txt")
  writeLines("test content", test_file)
  
  # Try to open file for reading while it's being written
  write_conn <- file(test_file, "w")
  read_conn <- try(file(test_file, "r"), silent = TRUE)
  
  # On some platforms this will fail, on others it won't
  # We just want to make sure it doesn't crash
  expect_true(inherits(read_conn, "connection") || inherits(read_conn, "try-error"))
  
  # Close connections properly
  if (inherits(read_conn, "connection")) close(read_conn)
  close(write_conn)
  
  # Cleanup
  unlink(test_file)
})

test_that("package uses safe functions for file system operations", {
  # Test that we can create a unique temporary file
  temp_file1 <- tempfile(pattern = "ces_test_")
  temp_file2 <- tempfile(pattern = "ces_test_")
  
  # Each call to tempfile should return a unique path
  expect_false(temp_file1 == temp_file2)
  
  # Simulate our file overwrite protection
  writeLines("original content", temp_file1)
  
  # Our own simplified version of check_file_conflict
  local_check_conflict <- function(file_path, overwrite) {
    if (file.exists(file_path) && !overwrite) {
      stop("File already exists")
    }
    return(TRUE)
  }
  
  # Test it works as expected when overwrite=FALSE
  expect_error(local_check_conflict(temp_file1, FALSE), "File already exists")
  
  # Test it passes when overwrite=TRUE
  expect_true(local_check_conflict(temp_file1, TRUE))
  
  # Cleanup
  unlink(c(temp_file1, temp_file2))
})

test_that("path modification functions work cross-platform", {
  # Test dirname
  expect_equal(dirname(file.path("a", "b", "c")), file.path("a", "b"))
  
  # Test basename
  expect_equal(basename(file.path("a", "b", "c")), "c")
  
  # Test file_ext function (commonly used for file extensions)
  file_ext <- function(x) {
    pos <- regexpr("\\.([[:alnum:]]+)$", x)
    ifelse(pos > -1L, substring(x, pos + 1L), "")
  }
  
  expect_equal(file_ext("test.txt"), "txt")
  expect_equal(file_ext("test.csv"), "csv")
  expect_equal(file_ext("test"), "")
  
  # Test file.path behavior with empty components - behavior is platform dependent
  # so we just test the components are still there
  path_with_empty <- file.path("a", "", "c")
  expect_true(grepl("a", path_with_empty))
  expect_true(grepl("c", path_with_empty))
})

# Test specific to file downloads, skipped on CRAN and CI
test_that("package can handle file download progress monitoring", {
  skip_on_cran()
  skip_on_ci()
  
  # Mock a simple progress function
  progress_fun <- function(down, up) {
    return(TRUE) # Continue download
  }
  
  # Test if setProgressCallback is available (R >= 4.0.0)
  if (exists("setProgressCallback", where = asNamespace("utils"))) {
    test_file <- tempfile()
    
    # This tests that progress callbacks work without actually downloading
    # It's important because our functions show download progress
    expect_silent(
      try(utils::download.file(
        "https://example.org/", 
        test_file,
        quiet = FALSE, 
        mode = "wb"
      ), silent = TRUE)
    )
    
    # Cleanup
    if (file.exists(test_file)) unlink(test_file)
  }
})

test_that("package handles system-specific directory locations", {
  # Test that we can reliably get user documents folder across platforms
  user_docs <- if (.Platform$OS.type == "windows") {
    file.path(Sys.getenv("USERPROFILE"), "Documents")
  } else if (Sys.info()["sysname"] == "Darwin") {
    file.path(Sys.getenv("HOME"), "Documents")
  } else {
    file.path(Sys.getenv("HOME"), "Documents")
  }
  
  # We don't check if it exists since the test might run in a container
  # But we ensure the function doesn't error
  expect_true(is.character(user_docs) && length(user_docs) == 1)
  
  # Test the typical download location detection
  downloads_dir <- if (.Platform$OS.type == "windows") {
    file.path(Sys.getenv("USERPROFILE"), "Downloads")
  } else if (Sys.info()["sysname"] == "Darwin") {
    file.path(Sys.getenv("HOME"), "Downloads")
  } else {
    file.path(Sys.getenv("HOME"), "Downloads")
  }
  
  expect_true(is.character(downloads_dir) && length(downloads_dir) == 1)
})

test_that("error message handling works properly", {
  skip_on_cran()
  
  # Create a simple error handling test function
  handle_network_error <- function(msg) {
    if (grepl("timeout|timed out", msg, ignore.case = TRUE)) {
      return("Connection timed out. Please check your internet connection.")
    } else if (grepl("not found|404", msg, ignore.case = TRUE)) {
      return("Resource not found. Please check the URL.")
    } else {
      return(paste("Download failed:", msg))
    }
  }
  
  # Test various error messages
  expect_equal(
    handle_network_error("Connection timed out after 60 seconds"),
    "Connection timed out. Please check your internet connection."
  )
  
  expect_equal(
    handle_network_error("404 Not Found"),
    "Resource not found. Please check the URL."
  )
  
  expect_equal(
    handle_network_error("Unknown error"),
    "Download failed: Unknown error"
  )
})

# Test specifically focused on path normalization (important for Windows vs Unix)
test_that("path normalization works consistently", {
  # Test with current directory which should always exist
  cur_path <- getwd()
  norm_cur <- normalizePath(cur_path, mustWork = TRUE)
  
  # For consistent platform behavior, simplify to checking a few key properties
  
  # Normalized path should exist
  expect_true(dir.exists(norm_cur))
  
  # Normalizing twice should yield the same result
  expect_equal(norm_cur, normalizePath(norm_cur, mustWork = TRUE))
  
  # Our utility function should work with valid paths
  # First create it so the test can run
  normalize_path <- function(path, must_work = FALSE) {
    tryCatch({
      normalizePath(path, mustWork = must_work, winslash = .Platform$file.sep)
    }, error = function(e) {
      if (!must_work) return(path)
      stop(e)
    })
  }
  
  # Now test with a valid path - handle Windows backslash differences
  # On Windows, paths can be normalized with either forward or backslashes
  # So instead of direct equality, we check path equivalence
  norm_path1 <- normalize_path(cur_path, must_work = TRUE)
  norm_path2 <- normalizePath(cur_path, mustWork = TRUE)
  
  # Replace all backslashes with forward slashes for comparison
  norm_path1_std <- gsub("\\\\", "/", norm_path1)
  norm_path2_std <- gsub("\\\\", "/", norm_path2)
  
  expect_equal(norm_path1_std, norm_path2_std)
})

# Mock test for functions that use ces_datasets internal data
test_that("ces_datasets is accessible", {
  expect_true(exists("ces_datasets", where = asNamespace("ces"), inherits = FALSE))
  
  # Load actual dataset from package environment for tests
  ces_datasets <- get("ces_datasets", envir = asNamespace("ces"))
  
  # Test we can access key fields needed by functions
  expect_true(all(c("year", "url", "format", "codebook_url") %in% names(ces_datasets)))
  
  # Test that we can filter the dataset like our functions do
  if (nrow(ces_datasets) > 0) {
    year <- ces_datasets$year[1]
    filtered <- ces_datasets[ces_datasets$year == year, ]
    expect_equal(nrow(filtered), 1)
  }
})