## Example of using the codebook functionality of the ces package

library(ces)

# 1. Get a CES dataset
ces_data <- get_ces("2019")

# 2. Create a codebook
codebook <- create_codebook(ces_data)

# 3. View the first few entries of the codebook
head(codebook)

# 4. Count the number of questions by type
if (requireNamespace("dplyr", quietly = TRUE)) {
  library(dplyr)
  
  # Check how many questions contain certain keywords
  question_themes <- codebook %>%
    mutate(
      about_voting = grepl("vote|ballot|election", question, ignore.case = TRUE),
      about_leaders = grepl("leader|prime minister|trudeau|scheer", question, ignore.case = TRUE),
      about_issues = grepl("issue|policy|economy|climate|immigration", question, ignore.case = TRUE),
      about_demographics = grepl("age|gender|education|income|province", question, ignore.case = TRUE)
    ) %>%
    summarize(
      voting_questions = sum(about_voting, na.rm = TRUE),
      leader_questions = sum(about_leaders, na.rm = TRUE),
      issue_questions = sum(about_issues, na.rm = TRUE),
      demographic_questions = sum(about_demographics, na.rm = TRUE),
      total_questions = n()
    )
  
  print(question_themes)
}

# 5. Find specific types of questions
party_vars <- codebook %>%
  filter(grepl("party", question, ignore.case = TRUE))

print(party_vars)

# 6. Export the codebook to a CSV file
# export_codebook(codebook, "ces_2019_codebook.csv")

# 7. Get a subset of voting-related variables using the codebook
voting_vars <- codebook %>%
  filter(grepl("vote|voted", question, ignore.case = TRUE)) %>%
  pull(variable)

# Get the subset of data
voting_data <- get_ces_subset("2019", variables = voting_vars)

# 8. View the structure of the voting data
str(voting_data)