#' Download Canadian Election Study PDF Codebook
#'
#' This function downloads the official PDF codebook for a specified year of the Canadian
#' Election Study. The codebook contains detailed information about all variables,
#' question wording, response codes, and methodological details.
#'
#' @param year A character string indicating the year of the CES data. 
#'   Available years include "1965", "1968", "1972", "1974", "1984", "1988", "1993", 
#'   "1997", "2000", "2004", "2006", "2008", "2011", "2015", "2019", "2021".
#' @param variant A character string indicating the survey variant to download.
#'   For years with multiple variants (1972, 2015, 2019), this specifies which one to use.
#'   If NULL (default), uses the first available variant for the year.
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
#' # Download the 2019 CES codebook to a temporary directory (defaults to web variant)
#' download_pdf_codebook("2019", path = tempdir(), overwrite = TRUE)
#'
#' # Download the 2019 phone survey codebook
#' download_pdf_codebook("2019", variant = "phone", path = tempdir(), overwrite = TRUE)
#'
#' # Download the 1972 September survey codebook
#' download_pdf_codebook("1972", variant = "sep", path = tempdir(), overwrite = TRUE)
#' 
#' # Overwrite existing file
#' download_pdf_codebook("2021", path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
download_pdf_codebook <- function(year, variant = NULL, path = NULL, overwrite = FALSE, verbose = TRUE) {
  # Input validation
  valid_years <- unique(ces_datasets$year)
  
  if (!year %in% valid_years) {
    stop("Invalid year. Available years are: ", paste(sort(valid_years), collapse = ", "))
  }
  
  # Track if variant was originally NULL for message purposes
  is_variant_null <- is.null(variant)
  
  # Get dataset information from internal data
  year_datasets <- ces_datasets[ces_datasets$year == year, ]
  
  if (nrow(year_datasets) == 0) {
    stop("Could not find information for year: ", year)
  }
  
  # Determine default variant based on year if not specified
  if (is.null(variant)) {
    if (year %in% c("2015", "2019")) {
      variant <- "web"
    } else if (year == "1974") {
      variant <- "1974_1980"
    } else {
      # For years with multiple variants, get the first one (usually the main one)
      variant <- year_datasets$variant[1]
    }
  }
  
  # Filter by the selected variant
  variant_datasets <- year_datasets[year_datasets$variant == variant, ]
  if (nrow(variant_datasets) == 0) {
    available_variants <- paste(year_datasets$variant, collapse = ", ")
    stop("Variant '", variant, "' not available for year ", year, 
         ". Available variants: ", available_variants)
  }
  year_datasets <- variant_datasets
  
  # Show variant information message if applicable
  show_variant_message(year, variant, is_variant_null, verbose)
  
  # Find the first dataset with a non-empty codebook URL
  codebook_urls <- year_datasets$codebook_url
  non_empty_urls <- codebook_urls[codebook_urls != "" & !is.na(codebook_urls)]
  
  if (length(non_empty_urls) == 0) {
    if (!is.null(variant)) {
      stop("No codebook is available for year ", year, " variant '", variant, "'")
    } else {
      stop("No codebook is available for year: ", year)
    }
  }
  
  # Use the first available codebook URL
  codebook_url <- non_empty_urls[1]
  
  # Get the variant for filename (use the actual variant from the selected dataset)
  selected_variant <- year_datasets$variant[year_datasets$codebook_url == codebook_url][1]
  
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
  if (!is.null(variant) && length(year_datasets) > 1) {
    file_name <- paste0("CES_", year, "_", selected_variant, "_codebook.pdf")
  } else if (nrow(ces_datasets[ces_datasets$year == year, ]) > 1) {
    file_name <- paste0("CES_", year, "_", selected_variant, "_codebook.pdf")
  } else {
    file_name <- paste0("CES_", year, "_codebook.pdf")
  }
  file_path <- file.path(path, file_name)
  
  # Check if file already exists and handle overwrite settings
  check_file_conflict(file_path, overwrite)
  
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  # Download the codebook
  if (!is.null(variant) || nrow(ces_datasets[ces_datasets$year == year, ]) > 1) {
    msg(paste0("Downloading CES ", year, " (", selected_variant, ") codebook from ", codebook_url))
  } else {
    msg(paste0("Downloading CES ", year, " codebook from ", codebook_url))
  }
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