## Example of exploring and working with metadata in CES datasets

library(ces)

# 1. Get CES data (metadata is preserved by default)
ces_2019 <- get_ces("2019")

# 2. Get an overview of available metadata
metadata_summary <- examine_metadata(ces_2019)
print(head(metadata_summary, 10))

# 3. Find how many variables have labels
with_labels <- sum(metadata_summary$has_label)
total_vars <- nrow(metadata_summary)
cat("Variables with question labels:", with_labels, "out of", total_vars, 
    sprintf("(%.1f%%)\n", with_labels/total_vars*100))

# 4. Find how many variables have value labels
with_value_labels <- sum(metadata_summary$has_value_labels)
cat("Variables with value labels:", with_value_labels, "out of", total_vars,
    sprintf("(%.1f%%)\n", with_value_labels/total_vars*100))

# 5. Look at specific types of variables
if (requireNamespace("dplyr", quietly = TRUE)) {
  library(dplyr)
  
  # Find vote choice variables
  vote_vars <- examine_metadata(ces_2019, show_labels = TRUE, 
                                variable_pattern = "vote")
  print(vote_vars)
  
  # Find demographic variables
  demo_vars <- examine_metadata(ces_2019, show_labels = TRUE,
                              variable_pattern = "age|gender|education|income")
  print(demo_vars)
}

# 6. Examine label content for a specific variable
if ("vote_choice" %in% names(ces_2019)) {
  # Get the question label
  question <- attr(ces_2019$vote_choice, "label")
  cat("Question:", question, "\n\n")
  
  # Get the value labels
  value_labels <- attr(ces_2019$vote_choice, "labels")
  
  if (!is.null(value_labels)) {
    cat("Answer Options:\n")
    for (i in seq_along(value_labels)) {
      cat(sprintf("  %s = %s\n", names(value_labels)[i], value_labels[i]))
    }
  }
}

# 7. Example of creating a table with both codes and labels
if (requireNamespace("dplyr", quietly = TRUE) && 
    "vote_choice" %in% names(ces_2019) && 
    !is.null(attr(ces_2019$vote_choice, "labels"))) {
  
  # Get frequency table
  vote_table <- table(ces_2019$vote_choice)
  
  # Get value labels
  vote_labels <- attr(ces_2019$vote_choice, "labels")
  
  # Create a data frame with both codes and labels
  vote_summary <- data.frame(
    value = as.numeric(names(vote_table)),
    count = as.numeric(vote_table),
    stringsAsFactors = FALSE
  )
  
  # Add labels
  vote_summary$label <- sapply(vote_summary$value, function(v) {
    idx <- which(vote_labels == v)
    if (length(idx) > 0) return(names(vote_labels)[idx])
    return(NA_character_)
  })
  
  # Calculate percentages
  vote_summary$percent <- vote_summary$count / sum(vote_summary$count) * 100
  
  # Show results
  print(vote_summary)
}