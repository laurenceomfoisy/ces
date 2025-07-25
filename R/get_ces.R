#' Get Canadian Election Study Dataset
#'
#' This function downloads and processes a Canadian Election Study dataset for the specified year.
#'
#' @param year A character string indicating the year of the CES data. 
#'   Available years include "1965", "1968", "1972", "1974", "1984", "1988", "1993", 
#'   "1997", "2000", "2004", "2006", "2008", "2011", "2015", "2019", "2021".
#' @param variant A character string indicating the survey variant to download.
#'   Options depend on the year: "single_survey" (default for most years), "web" (default for 2015, 2019), 
#'   "phone", "combo", "1974_1980", "jnjl", "sep", "nov". Use \code{\link{list_ces_datasets}} to see 
#'   available variants for each year.
#' @param format A character string indicating the format to return the data in. 
#'   Default is "tibble". Options include "tibble", "data.frame", or "raw".
#' @param language A character string indicating the language of the survey questions.
#'   Default is "en" (English). Alternative is "fr" (French).
#' @param clean Logical indicating whether to clean the data (recode variables,
#'   convert factors, etc.). Default is TRUE.
#' @param preserve_metadata Logical indicating whether to prioritize preserving all
#'   variable metadata (labels, attributes) over standardization. Default is TRUE.
#'   This ensures all original question labels and value labels are maintained.
#' @param use_cache Logical indicating whether to use cached data if available.
#'   Default is TRUE.
#' @param verbose Logical indicating whether to display detailed progress messages
#'   during data retrieval and processing. Default is TRUE.
#'
#' @return A tibble or data.frame containing the requested CES data.
#'
#' @note Official PDF codebooks for each CES year are available via the
#'   \code{\link{download_pdf_codebook}} function, which provides detailed information
#'   about variables, question wording, and methodology.
#'
#' @examples
#' \donttest{
#' # Get the 2019 CES web survey data (default)
#' ces_2019_web <- get_ces("2019")
#' 
#' # Get the 2019 CES phone survey data
#' ces_2019_phone <- get_ces("2019", variant = "phone")
#'
#' # Get the 1993 CES data, unprocessed
#' ces_1993_raw <- get_ces("1993", clean = FALSE)
#'
#' # Get 1972 September survey
#' ces_1972_sep <- get_ces("1972", variant = "sep")
#'
#' # Download the official codebook to temporary directory
#' download_pdf_codebook("2019", path = tempdir(), overwrite = TRUE)
#' }
#'
#' @export
get_ces <- function(year, variant = NULL, format = "tibble", language = "en", clean = TRUE, preserve_metadata = TRUE, use_cache = TRUE, verbose = TRUE) {
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
  
  valid_formats <- c("tibble", "data.frame", "raw")
  if (!format %in% valid_formats) {
    stop("Invalid format. Available formats are: ", paste(valid_formats, collapse = ", "))
  }
  
  if (!language %in% c("en", "fr")) {
    stop("Invalid language. Available languages are: en, fr")
  }
  
  # Get dataset information
  dataset_info <- ces_datasets[ces_datasets$year == year & ces_datasets$variant == variant, ]
  
  if (nrow(dataset_info) == 0) {
    stop("Could not find information for year: ", year, " and variant: ", variant)
  }
  
  # Check if data is already cached
  cache_dir <- file.path(tempdir(), "ces")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  # Include variant in cache filename to handle multiple variants per year
  cache_file <- file.path(cache_dir, paste0("ces_", year, "_", variant, ".rds"))
  
  # Create a helper function for conditional messaging
  msg <- function(text) {
    if (verbose) message(text)
  }
  
  if (use_cache && file.exists(cache_file)) {
    msg(paste0("Using cached version of CES ", year, " (", variant, ") data"))
    data <- readRDS(cache_file)
    msg("Cached data loaded successfully")
  } else {
    # Download the data with optional verbosity
    msg(paste0("Downloading CES ", year, " (", variant, ") data from ", dataset_info$url))
    
    # Handle ZIP files vs direct files
    if (dataset_info$is_zip) {
      # Determine file extension based on format
      file_ext <- switch(dataset_info$format,
                         "spss" = "sav",
                         "stata" = "dta",
                         "unknown")
      
      temp_file <- tempfile(fileext = paste0(".", file_ext))
      
      # Extract data file from ZIP
      extract_data_from_zip(
        url = dataset_info$url,
        destfile = temp_file,
        expected_format = dataset_info$format,
        quiet = !verbose
      )
    } else {
      # Direct download (non-ZIP)
      temp_file <- tempfile(fileext = ".dat")
      
      # Show download progress based on verbose setting
      utils::download.file(
        url = dataset_info$url, 
        destfile = temp_file, 
        mode = "wb", 
        quiet = !verbose,  # Show download progress if verbose
        method = NULL,     # Auto-select the best method
        cacheOK = FALSE    # Don't use cached version of file
      )
    }
    
    msg("Download complete. Processing data...")
    
    # Read the data based on format and encoding
    if (!requireNamespace("haven", quietly = TRUE)) {
      stop("Package 'haven' is required to read this data. Please install it.")
    }
    
    # Use read options to preserve all metadata
    if (dataset_info$format == "stata") {
      # Handle encoding parameter - "default" means let haven auto-detect
      if (dataset_info$encoding == "default") {
        data <- haven::read_dta(temp_file, 
                                col_select = NULL,  # Include all columns
                                skip = 0,           # Don't skip any rows
                                n_max = Inf,        # Read all rows
                                .name_repair = "unique")  # Ensure unique names
      } else {
        data <- haven::read_dta(temp_file, 
                                encoding = dataset_info$encoding,
                                col_select = NULL,  # Include all columns
                                skip = 0,           # Don't skip any rows
                                n_max = Inf,        # Read all rows
                                .name_repair = "unique")  # Ensure unique names
      }
    } else {
      # Default to SPSS format
      if (dataset_info$encoding == "default") {
        data <- haven::read_sav(temp_file,
                               col_select = NULL,  # Include all columns
                               skip = 0,           # Don't skip any rows 
                               n_max = Inf,        # Read all rows
                               .name_repair = "unique")  # Ensure unique names
      } else {
        data <- haven::read_sav(temp_file, 
                               encoding = dataset_info$encoding,
                               col_select = NULL,  # Include all columns
                               skip = 0,           # Don't skip any rows
                               n_max = Inf,        # Read all rows
                               .name_repair = "unique")  # Ensure unique names
      }
    }
    
    # Show information about the loaded dataset
    msg(paste0("Data loaded successfully: ", nrow(data), " rows and ", ncol(data), " columns"))
    
    # Save to cache
    if (use_cache) {
      msg("Saving data to cache for faster future access...")
      saveRDS(data, cache_file)
      msg(paste0("Data cached at: ", cache_file))
    }
    
    # Clean up temporary files
    msg("Cleaning up temporary files...")
    unlink(temp_file)
  }
  
  # Clean the data if requested
  if (clean) {
    msg("Cleaning and processing the data...")
    if (preserve_metadata) {
      # Use more careful cleaning to preserve metadata
      msg("Using metadata-preserving cleaning method")
      data <- clean_ces_data_preserve_metadata(data, year, language)
    } else {
      # Use standard cleaning
      msg("Using standard cleaning method")
      data <- clean_ces_data(data, year, language)
    }
    msg("Data cleaning complete")
  }
  
  # Convert to requested format
  msg(paste0("Converting data to ", format, " format..."))
  if (format == "tibble") {
    if (!requireNamespace("tibble", quietly = TRUE)) {
      warning("Package 'tibble' is required to return a tibble. Returning a data.frame instead.")
      data <- as.data.frame(data)
    } else {
      data <- tibble::as_tibble(data)
    }
  } else if (format == "data.frame") {
    data <- as.data.frame(data)
  }
  
  msg(paste0("CES ", year, " (", variant, ") dataset ready for use"))
  
  # Display citation information
  if (verbose && !is.null(dataset_info$citation) && dataset_info$citation != "") {
    cat("\n" , rep("=", 80), "\n", sep = "")
    cat(dataset_info$citation)
    cat("\n", rep("=", 80), "\n\n", sep = "")
  }
  
  return(data)
}

#' Clean Canadian Election Study Dataset
#'
#' This function performs cleaning operations on CES data, including recoding variables,
#' converting factors, and standardizing column names.
#'
#' @param data A tibble or data.frame containing raw CES data.
#' @param year A character string indicating the year of the CES data.
#' @param language A character string indicating the language for labels ("en" or "fr").
#'
#' @return A cleaned tibble with standardized variables.
#'
#' @keywords internal
clean_ces_data <- function(data, year, language = "en") {
  # Common cleaning operations across all datasets
  
  # Store original attributes for all columns
  col_attributes <- list()
  for (col in names(data)) {
    col_attributes[[col]] <- attributes(data[[col]])
  }
  
  # 1. Convert haven_labelled class to factors with proper labels
  if (requireNamespace("haven", quietly = TRUE)) {
    labelled_cols <- sapply(data, function(x) inherits(x, "haven_labelled"))
    
    if (any(labelled_cols)) {
      for (col in names(data)[labelled_cols]) {
        # Get the labels
        labels <- attr(data[[col]], "labels")
        label_attr <- attr(data[[col]], "label")
        
        if (length(labels) > 0) {
          # Create a named vector for the labels
          label_names <- names(labels)
          
          # If no names, use the values themselves
          if (is.null(label_names)) {
            label_names <- as.character(labels)
          }
          
          # Create the factor with labels preserved
          data[[col]] <- haven::as_factor(data[[col]])
          
          # Re-apply the variable label
          if (!is.null(label_attr)) {
            attr(data[[col]], "label") <- label_attr
          }
        }
      }
    }
  }
  
  # 2. Create a copy of the data before name standardization
  data_orig_names <- names(data)
  
  # 3. Standardize variable names - lowercase and replace spaces with underscores
  names(data) <- tolower(names(data))
  names(data) <- gsub("\\s+", "_", names(data))
  
  # 4. Re-apply attributes that might have been lost
  for (i in seq_along(data_orig_names)) {
    old_name <- data_orig_names[i]
    new_name <- names(data)[i]
    
    # Skip if we don't have stored attributes
    if (is.null(col_attributes[[old_name]])) next
    
    # Get important attributes to preserve
    orig_attrs <- col_attributes[[old_name]]
    
    # Re-apply label attribute if present
    if (!is.null(orig_attrs$label)) {
      attr(data[[new_name]], "label") <- orig_attrs$label
    }
    
    # Re-apply labels attribute if present and not already set
    if (!is.null(orig_attrs$labels) && is.null(attr(data[[new_name]], "labels"))) {
      attr(data[[new_name]], "labels") <- orig_attrs$labels
    }
  }
  
  # 5. Handle year-specific cleaning
  if (year == "2019") {
    # Example: Specific cleaning for 2019 dataset
  } else if (year == "2015") {
    # Example: Specific cleaning for 2015 dataset
  }
  
  return(data)
}