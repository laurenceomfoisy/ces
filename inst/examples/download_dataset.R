## Example of downloading a single CES dataset

library(ces)

# 1. Download a single CES dataset to the current directory
# download_ces_dataset("2019")

# 2. Download to a specific directory
download_ces_dataset(
  year = "2019",
  path = file.path(tempdir(), "CES_single")
)

# 3. Check the downloaded file
list.files(file.path(tempdir(), "CES_single"))

# 4. Download another specific dataset
download_ces_dataset(
  year = "2021",
  path = file.path(tempdir(), "CES_single"),
  overwrite = TRUE  # Overwrite if already exists
)

# 5. You can also download older datasets
# For example, to get the 1965 dataset:
download_ces_dataset(
  year = "1965",
  path = file.path(tempdir(), "CES_historical")
)