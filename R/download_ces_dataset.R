#' Download a Canadian Election Study Dataset
#'
#' This function downloads a single Canadian Election Study dataset for a specified year.
#' The dataset is saved with a standardized filename in the format of `ces_<year>_<variant>.<format>`,
#' where the format extension corresponds to the original dataset format (e.g., .sav for SPSS, 
#' .dta for Stata).
#'
#' @param year A character string indicating the year of the CES data to download. 
#'   Available years include "1965", "1968", "1972", "1974", "1984", "1988", "1993", 
#'   "1997", "2000", "2004", "2006", "2008", "2011", "2015", "2019", "2021".
#' @param variant A character string indicating the survey variant to download.
#'   Options depend on the year: "single_survey" (default for most years), "web" (default for 2015, 2019), 
#'   "phone", "combo", "1974_1980", "jnjl", "sep", "nov". Use \code{\link{list_ces_datasets}} to see 
#'   available variants for each year.
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
#' # Download the 2019 CES web survey dataset to a temporary directory
#' download_ces_dataset("2019", path = tempdir())
#'
#' # Download the 2019 phone survey to a specific directory
#' download_ces_dataset("2019", variant = "phone", path = tempdir())
#' 
#' # Download 1972 September survey
#' download_ces_dataset("1972", variant = "sep", path = tempdir())
#' 
#' # Overwrite existing file
#' download_ces_dataset("2021", path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
download_ces_dataset <- function(year, variant = NULL, path = NULL, overwrite = FALSE, verbose = TRUE) {
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  # Input validation
  valid_years <- unique(ces_datasets$year)
  if (!year %in% valid_years) {
    stop("Invalid year. Available years are: ", paste(sort(valid_years), collapse = ", "))
  }
  
  # Track if variant was originally NULL for message purposes
  is_variant_null <- is.null(variant)
  
  # Determine default variant based on year
  if (is_variant_null) {
    if (year %in% c("2015", "2019")) {
      variant <- "web"
    } else if (year == "1974") {
      variant <- "1974_1980"
    } else {
      # For years with multiple variants, get the first one (usually the main one)
      available_variants <- ces_datasets$variant[ces_datasets$year == year]
      variant <- available_variants[1]
    }
  }
  
  # Validate variant for the given year
  available_variants <- ces_datasets$variant[ces_datasets$year == year]
  if (!variant %in% available_variants) {
    stop("Invalid variant '", variant, "' for year ", year, 
         ". Available variants are: ", paste(available_variants, collapse = ", "))
  }
  
  # Show variant information message if applicable
  show_variant_message(year, variant, is_variant_null, verbose)
  
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
  dataset_info <- ces_datasets[ces_datasets$year == year & ces_datasets$variant == variant, ]
  
  if (nrow(dataset_info) == 0) {
    stop("Could not find information for year: ", year, " and variant: ", variant)
  }
  
  # Get the dataset URL and format
  url <- dataset_info$url
  format <- dataset_info$format
  
  # Determine file extension based on format
  file_ext <- switch(format,
                     "spss" = "sav",
                     "stata" = "dta",
                     "unknown")
  
  # Define the full file path with variant in filename
  file_name <- paste0("ces_", year, "_", variant, ".", file_ext)
  file_path <- file.path(path, file_name)
  
  # Check if file already exists and handle overwrite settings
  check_file_conflict(file_path, overwrite)
  
  # Download the dataset
  msg(paste0("Downloading CES ", year, " (", variant, ") dataset from ", url))
  msg(paste0("Saving to: ", file_path))
  
  # Use our safe download function with proper error handling
  tryCatch({
    if (dataset_info$is_zip) {
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