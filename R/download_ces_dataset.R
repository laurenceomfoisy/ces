#' Download a Canadian Election Study Dataset
#'
#' This function downloads a single Canadian Election Study dataset for a specified year.
#' The dataset is saved with a standardized filename in the format of `ces_<year>.<format>`,
#' where the format extension corresponds to the original dataset format (e.g., .sav for SPSS, 
#' .dta for Stata).
#'
#' @param year A character string indicating the year of the CES data to download. 
#'   Available years include "1965", "1968", "1974-1980", "1984", "1988", "1993", 
#'   "1997", "2000", "2004", "2006", "2008", "2011", "2015", "2019", "2021".
#' @param path A character string indicating the directory where the dataset should
#'   be saved. If NULL (default), the dataset will be saved to the Downloads
#'   directory if available, otherwise to a temporary directory.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'   Default is FALSE.
#' @param verbose Logical indicating whether to display detailed progress messages
#'   during download. Default is TRUE.
#'
#' @return Invisibly returns the file path of the downloaded dataset.
#'
#' @examples
#' \donttest{
#' # Download the 2019 CES dataset to a temporary directory
#' download_ces_dataset("2019", path = tempdir())
#'
#' # Download to a specific directory
#' download_ces_dataset("2015", path = tempdir())
#' 
#' # Overwrite existing file
#' download_ces_dataset("2021", path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
download_ces_dataset <- function(year, path = NULL, overwrite = FALSE, verbose = TRUE) {
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  # Input validation
  valid_years <- ces_datasets$year
  if (!year %in% valid_years) {
    stop("Invalid year. Available years are: ", paste(valid_years, collapse = ", "))
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
  dataset_info <- ces_datasets[ces_datasets$year == year, ]
  
  if (nrow(dataset_info) == 0) {
    stop("Could not find information for year: ", year)
  }
  
  # Get the dataset URL and format
  url <- dataset_info$url
  format <- dataset_info$format
  
  # Determine file extension based on format
  file_ext <- switch(format,
                     "spss" = "sav",
                     "stata" = "dta",
                     "unknown")
  
  # Define the full file path
  file_name <- paste0("ces_", year, ".", file_ext)
  file_path <- file.path(path, file_name)
  
  # Check if file already exists and handle overwrite settings
  check_file_conflict(file_path, overwrite)
  
  # Download the dataset
  msg(paste0("Downloading CES ", year, " dataset from ", url))
  msg(paste0("Saving to: ", file_path))
  
  # Use our safe download function with proper error handling
  tryCatch({
    safe_download(
      url = url,
      destfile = file_path,
      mode = "wb",       # Binary mode for data files
      quiet = !verbose   # Show progress based on verbose setting
    )
    
    msg(paste0("Successfully downloaded dataset to: ", file_path))
    
    # Check that the file exists and has content
    if (file.exists(file_path) && file.size(file_path) > 0) {
      msg("Dataset download completed successfully.")
    } else {
      stop("Downloaded file has no content or does not exist.")
    }
  },
  error = function(e) {
    # If download fails, provide a helpful error message
    stop("Failed to download dataset: ", e$message, 
         "\nPlease check your internet connection and try again.")
  })
  
  # Return the file path invisibly
  return(invisible(file_path))
}