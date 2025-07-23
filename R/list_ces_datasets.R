#' List Available Canadian Election Study Datasets
#'
#' This function displays a formatted catalog of all available CES datasets that can be
#' accessed through the package, showing year and available variants.
#' One row per year with variants listed as comma-separated values.
#'
#' @return Invisibly returns a tibble with columns for year and variants.
#'   The catalog is printed to the console for easy viewing.
#'
#' @examples
#' # Display catalog of all available datasets by year
#' list_ces_datasets()
#'
#' @export
list_ces_datasets <- function() {
  # Get unique years and aggregate variants
  years <- unique(ces_datasets$year)
  
  # Create result data frame
  result_list <- list()
  for (year in years) {
    year_data <- ces_datasets[ces_datasets$year == year, ]
    variants <- paste(year_data$variant, collapse = ", ")
    result_list[[length(result_list) + 1]] <- list(year = year, variants = variants)
  }
  
  # Convert to data frame
  result_df <- do.call(rbind, lapply(result_list, data.frame, stringsAsFactors = FALSE))
  
  # Sort by year (handle mixed character/numeric years properly)
  year_order <- order(
    suppressWarnings(
      ifelse(grepl("-", result_df$year), 
             as.numeric(substr(result_df$year, 1, 4)), 
             as.numeric(result_df$year))
    )
  )
  result_df <- result_df[year_order, ]
  
  # Create tibble if available, otherwise use data.frame
  if (requireNamespace("tibble", quietly = TRUE)) {
    result <- tibble::as_tibble(result_df)
  } else {
    result <- result_df
    class(result) <- "data.frame"
  }
  
  # Print all rows
  print(result, n = Inf)
  
  # Return invisibly so the output isn't printed twice
  return(invisible(result))
}