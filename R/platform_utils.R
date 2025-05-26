#' Platform-specific utility functions
#'
#' These are internal helper functions to ensure cross-platform compatibility.
#' They handle differences between operating systems for file paths, encodings,
#' and other platform-specific behaviors.
#'
#' @keywords internal

#' Normalize a file path for cross-platform compatibility
#'
#' @param path Character string containing the path to normalize
#' @param must_work Logical indicating whether the path must exist
#' @return Normalized absolute path
#' @keywords internal
normalize_path <- function(path, must_work = FALSE) {
  # Convert to absolute path with consistent separators
  # For cross-platform compatibility, always use forward slashes
  # (R functions work with forward slashes even on Windows)
  tryCatch({
    path_normalized <- normalizePath(path, mustWork = must_work)
    
    # If we're on Windows, convert backslashes to forward slashes for consistency
    if (.Platform$OS.type == "windows") {
      path_normalized <- gsub("\\\\", "/", path_normalized)
    }
    
    return(path_normalized)
  }, error = function(e) {
    # If normalization fails and path doesn't have to work, return original
    if (!must_work) return(path)
    stop(e)
  })
}

#' Safely create a directory with proper checks
#'
#' @param dir Character string containing the directory path to create
#' @param recursive Logical indicating whether to create parent directories
#' @param verbose Logical indicating whether to show messages
#' @return TRUE if successful, error message if not
#' @keywords internal
safe_dir_create <- function(dir, recursive = TRUE, verbose = TRUE) {
  if (is.null(dir) || dir == "") {
    stop("Directory path cannot be NULL or empty")
  }
  
  # Normalize path
  dir <- normalize_path(dir, must_work = FALSE)
  
  if (dir.exists(dir)) {
    if (verbose) message("Directory already exists: ", dir)
    return(TRUE)
  }
  
  # Create directory with proper error handling
  tryCatch({
    dir.create(dir, recursive = recursive, showWarnings = FALSE)
    if (verbose) message("Created directory: ", dir)
    return(TRUE)
  }, error = function(e) {
    stop("Failed to create directory: ", dir, "\nError: ", e$message)
  })
}

#' Get default download directory that works across platforms
#'
#' @return Path to the default download directory
#' @keywords internal
get_download_dir <- function() {
  # First try to use platform-specific download directory
  if (.Platform$OS.type == "windows") {
    # Windows
    downloads <- file.path(Sys.getenv("USERPROFILE"), "Downloads")
  } else if (Sys.info()["sysname"] == "Darwin") {
    # macOS
    downloads <- file.path(Sys.getenv("HOME"), "Downloads")
  } else {
    # Linux and others
    downloads <- file.path(Sys.getenv("HOME"), "Downloads")
  }
  
  # If the Downloads directory doesn't exist, use temporary directory
  if (!dir.exists(downloads)) {
    downloads <- tempdir()
  }
  
  return(downloads)
}

#' Safe file download with platform-specific handling
#'
#' @param url URL to download from
#' @param destfile Destination file path
#' @param mode "wb" for binary, "w" for text
#' @param quiet Logical indicating whether to show progress
#' @param timeout Timeout in seconds
#' @return 0 if successful, error code otherwise
#' @keywords internal
safe_download <- function(url, destfile, mode = "wb", quiet = FALSE, timeout = 600) {
  # Normalize the destination path
  destfile <- normalize_path(destfile, must_work = FALSE)
  
  # Ensure parent directory exists
  parent_dir <- dirname(destfile)
  if (!dir.exists(parent_dir)) {
    safe_dir_create(parent_dir, recursive = TRUE, verbose = !quiet)
  }
  
  # Set timeout options
  old_timeout <- options("timeout")
  on.exit(options(timeout = old_timeout))
  options(timeout = timeout)
  
  # Download with proper error handling
  result <- tryCatch({
    utils::download.file(
      url = url,
      destfile = destfile,
      mode = mode,
      quiet = quiet,
      method = NULL  # Let R choose the best method for the platform
    )
  }, error = function(e) {
    # Handle common errors with helpful messages
    if (grepl("timed out", e$message, ignore.case = TRUE)) {
      stop("Download timed out. Try increasing the timeout or check your internet connection.")
    } else if (grepl("could not resolve host", e$message, ignore.case = TRUE)) {
      stop("Could not resolve host. Check your internet connection and URL.")
    } else {
      stop("Download failed: ", e$message)
    }
  })
  
  # Verify download
  if (!file.exists(destfile) || file.size(destfile) == 0) {
    stop("Download completed but the file is empty or does not exist.")
  }
  
  return(result)
}

#' Check if file exists and handle overwrite safely
#'
#' @param file_path Path to the file to check
#' @param overwrite Whether to allow overwriting
#' @return TRUE if file can be written, FALSE or error otherwise
#' @keywords internal
check_file_conflict <- function(file_path, overwrite = FALSE) {
  if (file.exists(file_path)) {
    if (!overwrite) {
      stop("File already exists: ", file_path, 
           "\nUse overwrite = TRUE to overwrite the existing file.")
    }
    # Try to ensure file is writable
    if (file.access(file_path, 2) != 0) {
      stop("File exists but is not writable: ", file_path)
    }
    return(TRUE)
  }
  return(TRUE)
}