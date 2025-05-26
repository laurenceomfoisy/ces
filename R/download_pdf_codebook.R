#' Download Canadian Election Study PDF Codebook
#'
#' This function downloads the official PDF codebook for a specified year of the Canadian
#' Election Study. The codebook contains detailed information about all variables,
#' question wording, response codes, and methodological details.
#'
#' @param year A character string indicating the year of the CES data. 
#'   Available years include "1965", "1968", "1974-1980", "1984", "1988", "1993", 
#'   "1997", "2000", "2004", "2006", "2008", "2011", "2015", "2019", "2021".
#' @param path A character string indicating the directory where the codebook should
#'   be saved. If NULL (default), the codebook will be saved to the Downloads
#'   directory if available, otherwise to a temporary directory.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'   Default is FALSE.
#' @param verbose Logical indicating whether to display detailed progress messages
#'   during download. Default is TRUE.
#'
#' @return Invisibly returns the file path of the downloaded codebook.
#'
#' @examples
#' \donttest{
#' # Download the 2019 CES codebook to a temporary directory
#' download_pdf_codebook("2019", path = tempdir())
#'
#' # Download to a temporary directory
#' download_pdf_codebook("2015", path = tempdir())
#' 
#' # Overwrite existing file
#' download_pdf_codebook("2021", path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
download_pdf_codebook <- function(year, path = NULL, overwrite = FALSE, verbose = TRUE) {
  # Input validation
  valid_years <- c("1965", "1968", "1974-1980", "1984", "1988", "1993", 
                   "1997", "2000", "2004", "2006", "2008", "2011", 
                   "2015", "2019", "2021")
  
  if (!year %in% valid_years) {
    stop("Invalid year. Available years are: ", paste(valid_years, collapse = ", "))
  }
  
  # Get dataset information from internal data
  dataset_info <- ces_datasets[ces_datasets$year == year, ]
  
  if (nrow(dataset_info) == 0) {
    stop("Could not find information for year: ", year)
  }
  
  # Get the codebook URL for the requested year
  codebook_url <- dataset_info$codebook_url
  
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
  
  # Define the full file path
  file_name <- paste0("CES_", year, "_codebook.pdf")
  file_path <- file.path(path, file_name)
  
  # Check if file already exists and handle overwrite settings
  check_file_conflict(file_path, overwrite)
  
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  # Download the codebook
  msg(paste0("Downloading CES ", year, " codebook from ", codebook_url))
  msg(paste0("Saving to: ", file_path))
  
  # Use our safe download function with proper error handling
  tryCatch({
    safe_download(
      url = codebook_url,
      destfile = file_path,
      mode = "wb",       # Binary mode for PDF files
      quiet = !verbose   # Show progress based on verbose setting
    )
    
    msg(paste0("Successfully downloaded codebook to: ", file_path))
    
    # Check that the file exists and has content
    if (file.exists(file_path) && file.size(file_path) > 0) {
      msg("Codebook download completed successfully.")
    } else {
      stop("Downloaded file has no content or does not exist.")
    }
  },
  error = function(e) {
    # If download fails, provide a helpful error message
    stop("Failed to download codebook: ", e$message, 
         "\nPlease check your internet connection and try again.")
  })
  
  # Return the file path invisibly
  return(invisible(file_path))
}