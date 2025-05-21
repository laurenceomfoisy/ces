#' Clean Canadian Election Study Dataset while Preserving Metadata
#'
#' This function performs minimal cleaning operations on CES data to maximize
#' preservation of variable metadata, including labels and attributes.
#'
#' @param data A tibble or data.frame containing raw CES data.
#' @param year A character string indicating the year of the CES data.
#' @param language A character string indicating the language for labels ("en" or "fr").
#'
#' @return A cleaned tibble with preserved metadata.
#'
#' @keywords internal
clean_ces_data_preserve_metadata <- function(data, year, language = "en") {
  # Create a deep copy to preserve all attributes
  result <- data
  
  # 1. Standardize variable names without altering the data
  # First create a mapping table of old to new names
  old_names <- names(result)
  new_names <- tolower(old_names)
  new_names <- gsub("\\s+", "_", new_names)
  
  # Create a name conversion table
  name_mapping <- data.frame(
    old_name = old_names,
    new_name = new_names,
    stringsAsFactors = FALSE
  )
  
  # 2. Apply name changes but preserve all attributes
  for (i in seq_along(old_names)) {
    if (old_names[i] != new_names[i]) {
      # The name needs to be changed, so transfer with all attributes preserved
      result[[new_names[i]]] <- result[[old_names[i]]]
      
      # Then remove the old column
      result[[old_names[i]]] <- NULL
    }
  }
  
  # 3. Apply minimal year-specific cleaning without disrupting metadata
  # This would be extended for different years as needed
  if (year == "2019") {
    # Example: specific minimal cleaning for 2019
  } else if (year == "2015") {
    # Example: specific minimal cleaning for 2015
  }
  
  return(result)
}