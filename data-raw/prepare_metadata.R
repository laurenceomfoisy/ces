# Script to prepare CES metadata
# This could be used to create internal data objects for the package

library(tibble)

# Create a tibble with metadata about CES datasets
ces_datasets <- tibble(
  year = c("1965", "1968", "1974-1980", "1984", "1988", "1993", 
           "1997", "2000", "2004", "2006", "2008", "2011", 
           "2015", "2019", "2021"),
  url = c(
    "https://borealisdata.ca/api/access/datafile/563651", # 1965
    "https://borealisdata.ca/api/access/datafile/563469", # 1968
    "https://borealisdata.ca/api/access/datafile/563390", # 1974-1980
    "https://borealisdata.ca/api/access/datafile/563500", # 1984
    "https://borealisdata.ca/api/access/datafile/563590", # 1988
    "https://borealisdata.ca/api/access/datafile/563806", # 1993
    "https://borealisdata.ca/api/access/datafile/563617", # 1997
    "https://borealisdata.ca/api/access/datafile/563672", # 2000
    "https://borealisdata.ca/api/access/datafile/563592", # 2004
    "https://borealisdata.ca/api/access/datafile/563752", # 2006
    "https://borealisdata.ca/api/access/datafile/563439", # 2008
    "https://borealisdata.ca/api/access/datafile/563961", # 2011
    "https://borealisdata.ca/api/access/datafile/563704", # 2015
    "https://borealisdata.ca/api/access/datafile/563748", # 2019
    "https://borealisdata.ca/api/access/datafile/658983"  # 2021
  ),
  format = c(
    "spss", # 1965
    "spss", # 1968
    "spss", # 1974-1980
    "spss", # 1984
    "spss", # 1988
    "spss", # 1993
    "spss", # 1997
    "spss", # 2000
    "spss", # 2004
    "spss", # 2006
    "spss", # 2008
    "spss", # 2011
    "spss", # 2015
    "spss", # 2019
    "stata"  # 2021
  ),
  encoding = c(
    "default", # 1965
    "default", # 1968
    "default", # 1974-1980
    "default", # 1984
    "default", # 1988
    "default", # 1993
    "default", # 1997
    "default", # 2000
    "default", # 2004
    "default", # 2006
    "default", # 2008
    "default", # 2011
    "Latin1",  # 2015
    "Latin1",  # 2019
    "UTF-8"    # 2021
  ),
  type = c(
    "Survey",     # 1965
    "Survey",     # 1968
    "Panel",      # 1974-1980
    "Survey",     # 1984
    "Survey",     # 1988
    "Survey",     # 1993
    "Survey",     # 1997
    "Survey",     # 2000
    "Survey",     # 2004
    "Survey",     # 2006
    "Survey",     # 2008
    "Survey",     # 2011
    "Web/Phone",  # 2015
    "Web/Phone",  # 2019
    "Web/Phone"   # 2021
  ),
  description = c(
    "1965 Canadian Election Study",
    "1968 Canadian Election Study",
    "1974-1980 Canadian Election Study Panel",
    "1984 Canadian Election Study",
    "1988 Canadian Election Study",
    "1993 Canadian Election Study",
    "1997 Canadian Election Study",
    "2000 Canadian Election Study",
    "2004 Canadian Election Study",
    "2006 Canadian Election Study",
    "2008 Canadian Election Study",
    "2011 Canadian Election Study",
    "2015 Canadian Election Study - Online and Phone Surveys",
    "2019 Canadian Election Study - Online and Phone Surveys",
    "2021 Canadian Election Study - Online Survey"
  ),
  codebook_url = c(
    "https://borealisdata.ca/api/access/datafile/563560", # 1965
    "https://borealisdata.ca/api/access/datafile/563415", # 1968
    "https://borealisdata.ca/api/access/datafile/563334", # 1974-1980
    "https://borealisdata.ca/api/access/datafile/563316", # 1984
    "https://borealisdata.ca/api/access/datafile/563269", # 1988
    "https://borealisdata.ca/api/access/datafile/563432", # 1993
    "https://borealisdata.ca/api/access/datafile/563289", # 1997
    "https://borealisdata.ca/api/access/datafile/563551", # 2000
    "https://borealisdata.ca/api/access/datafile/563285", # 2004
    "https://borealisdata.ca/api/access/datafile/563285", # 2006
    "https://borealisdata.ca/api/access/datafile/563226", # 2008
    "https://borealisdata.ca/api/access/datafile/563355", # 2011
    "https://borealisdata.ca/api/access/datafile/563239", # 2015
    "https://borealisdata.ca/api/access/datafile/563276", # 2019
    "https://borealisdata.ca/api/access/datafile/658980"  # 2021
  )
)

# Save this as an internal data object (overwrite existing data)
usethis::use_data(ces_datasets, internal = TRUE, overwrite = TRUE)

# Could also prepare a sample dataset for examples
# This would be a small subset of one of the CES datasets
# usethis::use_data(ces_sample, overwrite = TRUE)