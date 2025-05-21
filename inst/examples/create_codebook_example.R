## Example of creating and using codebooks with the ces package

library(ces)

# 1. Download a CES dataset
ces_data <- get_ces("2019")

# 2. Create a comprehensive codebook for the dataset
codebook <- create_codebook(ces_data)

# 3. View the structure of the codebook
str(codebook)

# 4. Look at the first few variables in the codebook
head(codebook, 10)

# 5. Find all variables related to voting
if (requireNamespace("dplyr", quietly = TRUE)) {
  library(dplyr)
  
  voting_vars <- codebook %>%
    filter(grepl("vote|voting|ballot", question, ignore.case = TRUE)) %>%
    select(variable, question)
  
  print(voting_vars)
  
  # 6. Get the data for these voting variables
  voting_data <- get_ces_subset("2019", variables = voting_vars$variable)
  
  # 7. Analyze voting patterns
  if ("vote_choice" %in% names(voting_data)) {
    vote_summary <- voting_data %>%
      group_by(vote_choice) %>%
      summarize(count = n()) %>%
      mutate(percentage = count / sum(count) * 100)
    
    print(vote_summary)
  }
}

# 8. Find all demographic variables
demographic_vars <- codebook %>%
  filter(grepl("age|gender|education|income|region|province", 
               question, ignore.case = TRUE)) %>%
  select(variable, question)

print(demographic_vars)

# 9. Export the codebook to CSV
# Uncomment to execute:
# export_codebook(codebook, "ces_2019_codebook.csv")

# 10. Create a simplified codebook without value codes
simple_codebook <- create_codebook(ces_data, include_values = FALSE)
head(simple_codebook, 10)

# 11. Create a codebook as a data.frame instead of a tibble
df_codebook <- create_codebook(ces_data, format = "data.frame")
class(df_codebook)