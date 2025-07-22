## Example of downloading a single CES dataset

library(ces)

# 1. Download a single CES dataset to the current directory (defaults to web for 2015/2019)
# download_ces_dataset("2019")

# 2. Download the 2019 web survey to a specific directory
download_ces_dataset(
  year = "2019",
  path = file.path(tempdir(), "CES_single")
)

# 2b. Download the 2019 phone survey
download_ces_dataset(
  year = "2019",
  variant = "phone",
  path = file.path(tempdir(), "CES_single")
)

# 3. Check the downloaded files (note the variant in filename)
list.files(file.path(tempdir(), "CES_single"))

# 4. Download the 2015 combo dataset (combined web + phone)
download_ces_dataset(
  year = "2015",
  variant = "combo",
  path = file.path(tempdir(), "CES_single"),
  overwrite = TRUE  # Overwrite if already exists
)

# 5. Download a 1972 survey variant (September)
download_ces_dataset(
  year = "1972",
  variant = "sep",
  path = file.path(tempdir(), "CES_historical")
)

# 6. You can also download older datasets with single variants
download_ces_dataset(
  year = "1965",
  path = file.path(tempdir(), "CES_historical")
)