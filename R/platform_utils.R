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
#' @param max_retries Maximum number of retry attempts
#' @return 0 if successful, error code otherwise
#' @keywords internal
safe_download <- function(url, destfile, mode = "wb", quiet = FALSE, timeout = 600, max_retries = 3) {
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
  
  # Try download with retries
  for (attempt in 1:max_retries) {
    result <- tryCatch({
      if (attempt > 1 && !quiet) {
        message("Retry attempt ", attempt, " of ", max_retries)
      }
      
      utils::download.file(
        url = url,
        destfile = destfile,
        mode = mode,
        quiet = quiet,
        method = NULL  # Let R choose the best method for the platform
      )
    }, error = function(e) {
      if (attempt == max_retries) {
        # Handle common errors with helpful messages on final attempt
        if (grepl("timed out", e$message, ignore.case = TRUE)) {
          stop("Download timed out after ", max_retries, " attempts. Try increasing the timeout or check your internet connection.")
        } else if (grepl("could not resolve host", e$message, ignore.case = TRUE)) {
          stop("Could not resolve host. Check your internet connection and URL.")
        } else {
          stop("Download failed after ", max_retries, " attempts: ", e$message)
        }
      } else {
        # Return error for retry logic
        return(1)
      }
    })
    
    # If successful (result == 0), break out of retry loop
    if (is.numeric(result) && result == 0) {
      break
    } else if (attempt < max_retries) {
      # Wait before retry (exponential backoff)
      Sys.sleep(2^attempt)
    }
  }
  
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

#' Extract data file from ZIP archive
#'
#' This function downloads a ZIP file, extracts only the data file (.dta or .sav),
#' and cleans up the ZIP file and any non-data files (PDFs, etc.).
#'
#' @param url URL to download the ZIP file from
#' @param destfile Final destination path for the extracted data file
#' @param expected_format Expected format of the data file ("spss" or "stata")
#' @param quiet Logical indicating whether to show progress
#' @return Path to the extracted data file
#' @keywords internal
extract_data_from_zip <- function(url, destfile, expected_format, quiet = FALSE) {
  msg <- function(text) {
    if (!quiet) message(text)
  }
  
  # Create a temporary file for the ZIP download
  temp_zip <- tempfile(fileext = ".zip")
  temp_extract_dir <- tempfile(pattern = "ces_extract_")
  
  # Ensure cleanup on exit
  on.exit({
    # Clean up temporary files
    if (file.exists(temp_zip)) unlink(temp_zip)
    if (dir.exists(temp_extract_dir)) unlink(temp_extract_dir, recursive = TRUE)
  }, add = TRUE)
  
  # Download the ZIP file
  msg("Downloading ZIP file...")
  safe_download(url = url, destfile = temp_zip, mode = "wb", quiet = quiet)
  
  # Create extraction directory
  dir.create(temp_extract_dir, recursive = TRUE)
  
  # Extract the ZIP file
  msg("Extracting ZIP file...")
  tryCatch({
    utils::unzip(temp_zip, exdir = temp_extract_dir, junkpaths = TRUE)
  }, error = function(e) {
    stop("Failed to extract ZIP file: ", e$message)
  })
  
  # Find the data file based on expected format
  extracted_files <- list.files(temp_extract_dir, full.names = TRUE, recursive = TRUE)
  
  if (expected_format == "spss") {
    data_files <- extracted_files[grepl("\\.sav$", extracted_files, ignore.case = TRUE)]
  } else if (expected_format == "stata") {
    data_files <- extracted_files[grepl("\\.dta$", extracted_files, ignore.case = TRUE)]
  } else {
    stop("Unknown format: ", expected_format)
  }
  
  if (length(data_files) == 0) {
    stop("No ", toupper(expected_format), " data file found in ZIP archive")
  }
  
  if (length(data_files) > 1) {
    # If multiple files, try to find the main one (usually the largest)
    file_sizes <- file.size(data_files)
    data_file <- data_files[which.max(file_sizes)]
    msg(paste("Multiple data files found, using largest:", basename(data_file)))
  } else {
    data_file <- data_files[1]
  }
  
  # Ensure destination directory exists
  dest_dir <- dirname(destfile)
  if (!dir.exists(dest_dir)) {
    safe_dir_create(dest_dir, recursive = TRUE, verbose = !quiet)
  }
  
  # Copy the data file to final destination
  msg(paste("Copying data file to:", destfile))
  file.copy(data_file, destfile, overwrite = TRUE)
  
  # Verify the file was copied successfully
  if (!file.exists(destfile) || file.size(destfile) == 0) {
    stop("Failed to copy extracted data file to destination")
  }
  
  msg("ZIP extraction complete, temporary files cleaned up")
  return(destfile)
}

#' Show variant information message when multiple variants are available
#'
#' This helper function displays an informative message when a user accesses 
#' a year with multiple variants without specifying a variant parameter.
#'
#' @param year Character string indicating the year
#' @param selected_variant Character string indicating the variant that was selected
#' @param is_variant_null Logical indicating if variant parameter was NULL
#' @param verbose Logical indicating whether to show messages
#' @return NULL (invisible), message shown as side effect
#' @keywords internal
show_variant_message <- function(year, selected_variant, is_variant_null, verbose = TRUE) {
  # Only show message if verbose=TRUE and variant was not explicitly specified
  if (!verbose || !is_variant_null) {
    return(invisible(NULL))
  }
  
  # Get all variants for this year
  year_datasets <- ces_datasets[ces_datasets$year == year, ]
  
  # Only show message if there are multiple variants
  if (nrow(year_datasets) <= 1) {
    return(invisible(NULL))
  }
  
  # Get other available variants (excluding the selected one)
  all_variants <- year_datasets$variant
  other_variants <- all_variants[all_variants != selected_variant]
  
  if (length(other_variants) > 0) {
    other_variants_text <- paste(other_variants, collapse = ", ")
    message("You have accessed the '", selected_variant, "' variant by default. ",
            "Other variants available: ", other_variants_text, ". ",
            "Use the variant argument to select a specific variant.")
  }
  
  return(invisible(NULL))
}