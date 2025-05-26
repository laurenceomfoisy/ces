#' Get Subset of Variables from Canadian Election Study Dataset
#'
#' This function allows users to get a specific subset of variables from a CES dataset.
#' It's useful for selecting only the variables of interest for a specific analysis.
#'
#' @param year A character string indicating the year of the CES data.
#' @param variables A character vector of variable names to select from the dataset.
#'   If NULL (default), all variables are returned.
#' @param regex A logical indicating whether to use regex matching for variable names.
#'   Default is FALSE.
#' @param format A character string indicating the format to return the data in.
#'   Default is "tibble". Options include "tibble", "data.frame", or "raw".
#' @param clean Logical indicating whether to clean the data. Default is TRUE.
#' @param use_cache Logical indicating whether to use cached data if available.
#'   Default is TRUE.
#'
#' @return A tibble or data.frame containing the requested CES data variables.
#'
#' @examples
#' \donttest{
#' # Get only vote choice and demographic variables from 2019
#' variables <- c("vote_choice", "age", "gender", "province", "education")
#' ces_subset <- get_ces_subset("2019", variables)
#'
#' # Get all variables containing "vote" in their name (using regex)
#' vote_vars <- get_ces_subset("2019", "vote", regex = TRUE)
#' }
#'
#' @export
get_ces_subset <- function(year, variables = NULL, regex = FALSE,
                           format = "tibble", clean = TRUE, use_cache = TRUE) {
  # Get the full dataset
  data <- get_ces(year, format = "tibble", clean = clean, use_cache = use_cache)
  
  # If no variables are specified, return the full dataset
  if (is.null(variables)) {
    return(data)
  }
  
  # Use dplyr if available
  if (requireNamespace("dplyr", quietly = TRUE)) {
    # If regex is TRUE, use grepl to filter variable names
    if (regex) {
      pattern <- paste(variables, collapse = "|")
      var_cols <- grepl(pattern, names(data), ignore.case = TRUE)
      
      if (!any(var_cols)) {
        warning("No variables matched the regex pattern. Returning full dataset.")
        return(data)
      }
      
      data <- dplyr::select(data, dplyr::all_of(names(data)[var_cols]))
    } else {
      # Check if any specified variables don't exist in the dataset
      missing_vars <- setdiff(variables, names(data))
      if (length(missing_vars) > 0) {
        warning("The following variables don't exist in the dataset: ",
                paste(missing_vars, collapse = ", "))
      }
      
      # Get the intersection of specified variables and dataset variables
      valid_vars <- intersect(variables, names(data))
      
      if (length(valid_vars) == 0) {
        warning("None of the specified variables exist in the dataset. Returning full dataset.")
        return(data)
      }
      
      data <- dplyr::select(data, dplyr::all_of(valid_vars))
    }
  } else {
    # Fallback if dplyr is not available
    if (regex) {
      pattern <- paste(variables, collapse = "|")
      var_cols <- grepl(pattern, names(data), ignore.case = TRUE)
      
      if (!any(var_cols)) {
        warning("No variables matched the regex pattern. Returning full dataset.")
        return(data)
      }
      
      data <- data[, var_cols, drop = FALSE]
    } else {
      # Check if any specified variables don't exist in the dataset
      missing_vars <- setdiff(variables, names(data))
      if (length(missing_vars) > 0) {
        warning("The following variables don't exist in the dataset: ",
                paste(missing_vars, collapse = ", "))
      }
      
      # Get the intersection of specified variables and dataset variables
      valid_vars <- intersect(variables, names(data))
      
      if (length(valid_vars) == 0) {
        warning("None of the specified variables exist in the dataset. Returning full dataset.")
        return(data)
      }
      
      data <- data[, valid_vars, drop = FALSE]
    }
  }
  
  # Convert to requested format
  if (format == "data.frame") {
    data <- as.data.frame(data)
  } else if (format == "tibble" && !inherits(data, "tbl_df") && requireNamespace("tibble", quietly = TRUE)) {
    data <- tibble::as_tibble(data)
  }
  
  return(data)
}