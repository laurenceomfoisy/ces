#' Download All Canadian Election Study Datasets
#'
#' This function downloads all available Canadian Election Study datasets to a specified directory.
#' Each dataset is saved with a standardized filename in the format of `ces_<year>_<variant>.<format>`,
#' where the format extension corresponds to the original dataset format (e.g., .sav for SPSS, 
#' .dta for Stata). For ZIP archives, only the data files are extracted and saved, with all other 
#' files (PDFs, etc.) discarded.
#'
#' @param path A character string indicating the directory where the datasets should
#'   be saved. If NULL (default), the datasets will be saved to the Downloads
#'   directory if available, otherwise to a temporary directory.
#' @param years Optional character vector specifying which years to download. 
#'   If NULL (default), all available years will be downloaded.
#' @param variants Optional character vector specifying which variants to download.
#'   If NULL (default), all available variants will be downloaded.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'   Default is FALSE.
#' @param verbose Logical indicating whether to display detailed progress messages
#'   during download. Default is TRUE.
#'
#' @return Invisibly returns a character vector with the file paths of the downloaded datasets.
#'
#' @examples
#' \donttest{
#' # Download all CES datasets to a temporary directory
#' download_all_ces_datasets(path = tempdir())
#'
#' # Download only specific years (all variants for those years)
#' download_all_ces_datasets(years = c("2015", "2019", "2021"), path = tempdir())
#'
#' # Download only web surveys for 2015 and 2019
#' download_all_ces_datasets(years = c("2015", "2019"), variants = "web", path = tempdir())
#'
#' # Download to a temporary directory with overwrite
#' download_all_ces_datasets(path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
download_all_ces_datasets <- function(path = NULL, years = NULL, variants = NULL, overwrite = FALSE, verbose = TRUE) {
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  # If path is NULL, use Downloads directory if available, otherwise tempdir
  if (is.null(path)) {
    path <- get_download_dir()
  }
  
  # Normalize the path and create directory if needed
  path <- normalize_path(path, must_work = FALSE)
  
  # Create the directory if it doesn't exist
  if (!dir.exists(path)) {
    safe_dir_create(path, recursive = TRUE, verbose = verbose)
  }
  
  # Get dataset information from internal data
  available_years <- unique(ces_datasets$year)
  available_variants <- unique(ces_datasets$variant)
  
  # Start with all datasets
  datasets_to_download <- ces_datasets
  
  # Filter by years if requested
  if (!is.null(years)) {
    invalid_years <- years[!years %in% available_years]
    if (length(invalid_years) > 0) {
      stop("Invalid year(s): ", paste(invalid_years, collapse = ", "), 
           "\nAvailable years are: ", paste(sort(available_years), collapse = ", "))
    }
    
    # Filter to requested years
    datasets_to_download <- datasets_to_download[datasets_to_download$year %in% years, ]
  }
  
  # Filter by variants if requested
  if (!is.null(variants)) {
    invalid_variants <- variants[!variants %in% available_variants]
    if (length(invalid_variants) > 0) {
      stop("Invalid variant(s): ", paste(invalid_variants, collapse = ", "), 
           "\nAvailable variants are: ", paste(sort(available_variants), collapse = ", "))
    }
    
    # Filter to requested variants
    datasets_to_download <- datasets_to_download[datasets_to_download$variant %in% variants, ]
  }
  
  if (nrow(datasets_to_download) == 0) {
    stop("No datasets to download. Please check your 'years' and 'variants' parameters.")
  }
  
  # Prepare to collect file paths
  downloaded_files <- character(nrow(datasets_to_download))
  
  # Download each dataset
  for (i in 1:nrow(datasets_to_download)) {
    year <- datasets_to_download$year[i]
    variant <- datasets_to_download$variant[i]
    url <- datasets_to_download$url[i]
    format <- datasets_to_download$format[i]
    is_zip <- datasets_to_download$is_zip[i]
    
    # Determine file extension based on format
    file_ext <- switch(format,
                       "spss" = "sav",
                       "stata" = "dta",
                       "unknown")
    
    # Define the full file path with variant
    file_name <- paste0("ces_", year, "_", variant, ".", file_ext)
    file_path <- file.path(path, file_name)
    downloaded_files[i] <- file_path
    
    # Check if file already exists - with special handling for batch downloads
    if (file.exists(file_path) && !overwrite) {
      msg(paste0("File already exists: ", file_path, 
                 "\nSkipping download (use overwrite = TRUE to overwrite)"))
      next
    }
    
    # Download the dataset
    msg(paste0("Downloading CES ", year, " (", variant, ") dataset from ", url))
    msg(paste0("Saving to: ", file_path))
    
    # Use our safe download function with proper error handling
    tryCatch({
      if (is_zip) {
        # Extract data file from ZIP
        extract_data_from_zip(
          url = url,
          destfile = file_path,
          expected_format = format,
          quiet = !verbose
        )
      } else {
        # Direct download (non-ZIP)
        safe_download(
          url = url,
          destfile = file_path,
          mode = "wb",       # Binary mode for data files
          quiet = !verbose   # Show progress based on verbose setting
        )
      }
      
      # Check that the file exists and has content
      if (file.exists(file_path) && file.size(file_path) > 0) {
        msg(paste0("Successfully downloaded CES ", year, " (", variant, ") dataset"))
      } else {
        warning("Downloaded file has no content or does not exist: ", file_path)
      }
    },
    error = function(e) {
      warning("Failed to download CES ", year, " (", variant, ") dataset: ", e$message)
    })
  }
  
  # Summary message
  if (verbose) {
    msg(paste0("\nDownload summary:"))
    msg(paste0("- Total datasets available: ", nrow(ces_datasets)))
    msg(paste0("- Datasets attempted: ", nrow(datasets_to_download)))
    
    # Count successful downloads (files that exist and have content)
    successful <- sum(sapply(downloaded_files, function(f) file.exists(f) && file.size(f) > 0))
    msg(paste0("- Successfully downloaded: ", successful))
    
    if (successful < nrow(datasets_to_download)) {
      msg(paste0("- Some downloads were not successful. Check the warnings for details."))
    } else {
      msg(paste0("- All downloads completed successfully!"))
    }
    
    msg(paste0("\nDownloaded datasets are available at: ", path))
  }
  
  # Return the file paths invisibly
  return(invisible(downloaded_files))
}