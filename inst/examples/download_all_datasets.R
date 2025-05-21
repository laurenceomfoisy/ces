## Example of downloading all CES datasets

library(ces)

# 1. Download all CES datasets to the current directory
# Note: This will download all available CES datasets and may take some time
# download_all_ces_datasets()

# 2. Download only recent datasets
download_all_ces_datasets(
  years = c("2015", "2019", "2021"),
  path = file.path(tempdir(), "CES_datasets")
)

# 3. Check what datasets were downloaded
list.files(file.path(tempdir(), "CES_datasets"), pattern = "ces_.*\\.(sav|dta)$")

# 4. You can also download datasets for specific research periods
# For example, to get all datasets from the 1980s and 1990s:
download_all_ces_datasets(
  years = c("1984", "1988", "1993", "1997"),
  path = file.path(tempdir(), "CES_historical"),
  overwrite = TRUE
)