## Example of downloading CES codebook PDFs

library(ces)

# 1. Download the 2019 CES codebook to the default location (current working directory)
download_pdf_codebook("2019")

# 2. Download to a specific directory
codebook_dir <- file.path(tempdir(), "CES_codebooks")
download_pdf_codebook("2015", path = codebook_dir)

# 3. Download multiple codebooks to the same directory
years <- c("2011", "2015", "2019", "2021")
for (year in years) {
  download_pdf_codebook(year, path = codebook_dir, overwrite = TRUE)
}

# 4. Check what codebooks are now available
list.files(codebook_dir, pattern = "codebook\\.pdf$")