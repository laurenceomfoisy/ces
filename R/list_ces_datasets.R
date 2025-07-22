#' List Available Canadian Election Study Datasets
#'
#' This function returns a formatted catalog of all available CES datasets that can be
#' accessed through the package, showing year, variant, type, and description.
#'
#' @return A tibble with columns for year, variant, type, and description showing
#'   all available dataset combinations.
#'
#' @examples
#' # Get formatted catalog of all available datasets
#' list_ces_datasets()
#'
#' @export
list_ces_datasets <- function() {
  # Create a formatted tibble with all dataset information
  if (!requireNamespace("tibble", quietly = TRUE)) {
    # Fallback if tibble is not available
    result <- ces_datasets[, c("year", "variant", "type", "description")]
    class(result) <- "data.frame"
    return(result)
  }
  
  # Return selected columns from the internal dataset as a tibble
  result <- tibble::as_tibble(ces_datasets[, c("year", "variant", "type", "description")])
  
  # Sort by year and variant for better readability
  result <- result[order(result$year, result$variant), ]
  
  return(result)
}