#' List Available Canadian Election Study Datasets
#'
#' This function displays a formatted catalog of all available CES datasets that can be
#' accessed through the package, showing year, variant, type, and description.
#' All 22 datasets are displayed in full to ensure complete visibility.
#'
#' @return Invisibly returns a tibble with columns for year, variant, type, and description.
#'   The full catalog is printed to the console for easy viewing.
#'
#' @examples
#' # Display catalog of all available datasets (shows all 22 rows)
#' list_ces_datasets()
#'
#' @export
list_ces_datasets <- function() {
  # Create a formatted tibble with all dataset information
  if (!requireNamespace("tibble", quietly = TRUE)) {
    # Fallback if tibble is not available
    result <- ces_datasets[, c("year", "variant", "type", "description")]
    class(result) <- "data.frame"
    # Print all rows for data.frame
    print(result)
    return(invisible(result))
  }
  
  # Return selected columns from the internal dataset as a tibble
  result <- tibble::as_tibble(ces_datasets[, c("year", "variant", "type", "description")])
  
  # Sort by year and variant for better readability
  result <- result[order(result$year, result$variant), ]
  
  # Print all rows explicitly to ensure users see everything
  print(result, n = Inf)
  
  # Return invisibly so the output isn't printed twice
  return(invisible(result))
}