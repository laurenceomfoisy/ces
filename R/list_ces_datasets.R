#' List Available Canadian Election Study Datasets
#'
#' This function returns information about available CES datasets that can be
#' accessed through the package.
#'
#' @param details Logical indicating whether to return detailed information
#'   about each dataset. Default is FALSE.
#'
#' @return If details is FALSE, a character vector of available dataset years.
#'   If TRUE, a tibble with columns for year, type, and description.
#'
#' @examples
#' # Get list of available years
#' list_ces_datasets()
#'
#' # Get detailed information
#' list_ces_datasets(details = TRUE)
#'
#' @export
list_ces_datasets <- function(details = FALSE) {
  # Basic list of available years
  years <- ces_datasets$year
  
  if (!details) {
    return(years)
  }
  
  # Create a tibble with details about each dataset
  if (!requireNamespace("tibble", quietly = TRUE)) {
    warning("Package 'tibble' is required for detailed output. Returning year vector instead.")
    return(years)
  }
  
  # Return selected columns from the internal dataset
  result <- ces_datasets[, c("year", "type", "description")]
  
  return(result)
}