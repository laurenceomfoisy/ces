#' Examine Variable Metadata in a CES Dataset
#'
#' This function provides an overview of the metadata available in a CES dataset,
#' showing which variables have labels, value labels, and other attributes.
#'
#' @param data A CES dataset, typically retrieved using \code{get_ces()}.
#' @param show_labels Logical indicating whether to show the actual labels.
#'   Default is FALSE.
#' @param variable_pattern Optional regular expression to filter variables.
#'
#' @return A data.frame with metadata information for each variable.
#'
#' @examples
#' \donttest{
#' # Get CES data with preserved metadata
#' ces_2019 <- get_ces("2019", preserve_metadata = TRUE)
#'
#' # Examine metadata for all variables
#' metadata_overview <- examine_metadata(ces_2019)
#'
#' # Examine metadata for voting-related variables, showing labels
#' voting_metadata <- examine_metadata(ces_2019, 
#'                                    show_labels = TRUE,
#'                                    variable_pattern = "vote|ballot")
#' }
#'
#' @export
examine_metadata <- function(data, show_labels = FALSE, variable_pattern = NULL) {
  # Initialize vectors to store results
  variable_names <- character()
  has_label <- logical()
  has_value_labels <- logical()
  label_texts <- character()
  n_value_labels <- integer()
  data_types <- character()
  
  # Filter variables if pattern provided
  if (!is.null(variable_pattern)) {
    var_names <- names(data)[grepl(variable_pattern, names(data), ignore.case = TRUE)]
    if (length(var_names) == 0) {
      warning("No variables match the pattern '", variable_pattern, "'")
      var_names <- names(data)
    }
  } else {
    var_names <- names(data)
  }
  
  # Process each variable
  for (var_name in var_names) {
    variable_names <- c(variable_names, var_name)
    
    # Check for label attribute
    label <- attr(data[[var_name]], "label")
    has_label <- c(has_label, !is.null(label))
    
    if (!is.null(label) && show_labels) {
      label_texts <- c(label_texts, as.character(label))
    } else if (!is.null(label) && !show_labels) {
      label_texts <- c(label_texts, "[Has label]")
    } else {
      label_texts <- c(label_texts, NA_character_)
    }
    
    # Check for value labels
    value_labels <- attr(data[[var_name]], "labels")
    has_value_labels <- c(has_value_labels, !is.null(value_labels) && length(value_labels) > 0)
    
    if (!is.null(value_labels)) {
      n_value_labels <- c(n_value_labels, length(value_labels))
    } else {
      n_value_labels <- c(n_value_labels, 0)
    }
    
    # Get data type
    data_types <- c(data_types, class(data[[var_name]])[1])
  }
  
  # Create the result data.frame
  result <- data.frame(
    variable = variable_names,
    has_label = has_label,
    has_value_labels = has_value_labels,
    n_value_labels = n_value_labels,
    data_type = data_types,
    label = label_texts,
    stringsAsFactors = FALSE
  )
  
  return(result)
}