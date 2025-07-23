#' Create a Codebook for Canadian Election Study Dataset
#'
#' This function generates a comprehensive codebook for a CES dataset, including
#' variable names, question labels, and response options.
#'
#' @param data A CES dataset, typically retrieved using \code{get_ces()}.
#' @param include_values Logical indicating whether to include response values
#'   in addition to labels. Default is TRUE.
#' @param format A character string indicating the format to return the codebook in.
#'   Default is "tibble". Options include "tibble" or "data.frame".
#'
#' @return A tibble or data.frame containing the codebook with columns for
#'   variable name, question label, and response options.
#'
#' @examples
#' \donttest{
#' # Get the 2019 CES data
#' ces_2019 <- get_ces("2019")
#'
#' # Create a codebook
#' codebook <- create_codebook(ces_2019)
#'
#' # View the first few entries
#' head(codebook)
#'
#' # Create a codebook without values
#' codebook_simple <- create_codebook(ces_2019, include_values = FALSE)
#' }
#'
#' @export
create_codebook <- function(data, include_values = TRUE, format = "tibble") {
  # Check inputs
  if (!is.data.frame(data)) {
    stop("Input must be a data.frame or tibble")
  }
  
  valid_formats <- c("tibble", "data.frame")
  if (!format %in% valid_formats) {
    stop("Invalid format. Available formats are: ", paste(valid_formats, collapse = ", "))
  }
  
  # Initialize empty vectors to store results
  variables <- character()
  question_labels <- character()
  response_options <- list()
  
  # Process each variable
  for (var_name in names(data)) {
    var <- data[[var_name]]
    
    # Get variable name
    variables <- c(variables, var_name)
    
    # Get question label (if available)
    label <- attr(var, "label")
    if (is.null(label)) {
      question_labels <- c(question_labels, NA_character_)
    } else {
      question_labels <- c(question_labels, as.character(label))
    }
    
    # Get response options/labels (if available)
    val_labels <- attr(var, "labels")
    
    if (is.null(val_labels) || length(val_labels) == 0) {
      # No labels found
      if (is.factor(var)) {
        # For factors, use levels as labels
        levels_text <- paste(levels(var), collapse = ", ")
        response_options <- append(response_options, list(levels_text))
      } else {
        response_options <- append(response_options, list(NA_character_))
      }
    } else {
      # Format the value labels
      if (include_values) {
        # Include both values and labels
        labels_text <- paste(
          names(val_labels), "=", val_labels, 
          collapse = "; "
        )
      } else {
        # Include only labels
        labels_text <- paste(val_labels, collapse = "; ")
      }
      
      response_options <- append(response_options, list(labels_text))
    }
  }
  
  # Create the codebook dataframe
  codebook <- data.frame(
    variable = variables,
    question = question_labels,
    responses = unlist(response_options),
    stringsAsFactors = FALSE
  )
  
  # Convert to tibble if requested
  if (format == "tibble") {
    if (!requireNamespace("tibble", quietly = TRUE)) {
      warning("Package 'tibble' is required to return a tibble. Returning a data.frame instead.")
    } else {
      codebook <- tibble::as_tibble(codebook)
    }
  }
  
  return(codebook)
}

#' Export Codebook to CSV or Excel
#'
#' This function exports a CES codebook to a CSV or Excel file for easier viewing and sharing.
#'
#' @param codebook A codebook dataframe created with \code{create_codebook()}.
#' @param file_path The path where the file should be saved, including file extension.
#'   Use .csv for CSV or .xlsx for Excel.
#' @param ... Additional arguments passed to write functions.
#'
#' @return Invisibly returns the file path where the codebook was saved.
#'
#' @examples
#' \donttest{
#' # Get data and create codebook
#' ces_data <- get_ces("2019")
#' codebook <- create_codebook(ces_data)
#'
#' # Export to CSV
#' export_codebook(codebook, "ces_2019_codebook.csv")
#'
#' # Export to Excel
#' export_codebook(codebook, "ces_2019_codebook.xlsx")
#' }
#'
#' @export
export_codebook <- function(codebook, file_path, ...) {
  # Check input
  if (!is.data.frame(codebook)) {
    stop("Codebook must be a data.frame or tibble")
  }
  
  if (missing(file_path) || !is.character(file_path)) {
    stop("File path must be provided as a character string")
  }
  
  # Determine file type from extension
  file_ext <- tolower(tools::file_ext(file_path))
  
  if (file_ext == "csv") {
    # Export to CSV
    utils::write.csv(codebook, file = file_path, row.names = FALSE, ...)
  } else if (file_ext == "xlsx") {
    # Check if openxlsx is available
    if (!requireNamespace("openxlsx", quietly = TRUE)) {
      stop("Package 'openxlsx' is required to export to Excel. Please install it or export to CSV instead.")
    }
    
    # Export to Excel
    openxlsx::write.xlsx(codebook, file = file_path, ...)
  } else {
    stop("Unsupported file extension. Use .csv or .xlsx")
  }
  
  message("Codebook exported successfully to: ", file_path)
  return(invisible(file_path))
}