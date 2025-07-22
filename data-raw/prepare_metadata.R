# Script to prepare CES metadata
# This could be used to create internal data objects for the package

library(tibble)

# Create a tibble with metadata about CES datasets
ces_datasets <- tibble(
  year = c("1965", "1968", "1972", "1972", "1972", "1974", "1974-1980", "1984", "1988", "1993", 
           "1997", "2000", "2004", "2006", "2008", "2011", 
           "2015", "2015", "2015", "2019", "2019", "2021"),
  variant = c("survey", "survey", "jnjl", "sep", "nov", "survey", "panel", "survey", "survey", "survey",
              "survey", "survey", "survey", "survey", "survey", "survey",
              "web", "phone", "combo", "web", "phone", "web"),
  url = c(
    "https://borealisdata.ca/api/access/datafile/563651", # 1965
    "https://borealisdata.ca/api/access/datafile/563469", # 1968
    "https://borealisdata.ca/api/access/datafile/881553", # 1972 jnjl
    "https://borealisdata.ca/api/access/datafile/881549", # 1972 sep
    "https://borealisdata.ca/api/access/datafile/881545", # 1972 nov
    "https://borealisdata.ca/api/access/datafile/880887", # 1974
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
    "https://borealisdata.ca/api/access/datafile/563704", # 2015 web
    "https://ces-eec.sites.olt.ubc.ca/files/2018/08/CES2015-phone-Stata.zip", # 2015 phone
    "https://ces-eec.sites.olt.ubc.ca/files/2017/04/CES2015_Combined_Stata14.zip", # 2015 combo
    "https://borealisdata.ca/api/access/datafile/563748", # 2019 web
    "https://borealisdata.ca/api/access/datafile/880812", # 2019 phone
    "https://borealisdata.ca/api/access/datafile/658983"  # 2021 web
  ),
  is_zip = c(
    FALSE, # 1965
    FALSE, # 1968
    TRUE,  # 1972 jnjl
    TRUE,  # 1972 sep
    TRUE,  # 1972 nov
    TRUE,  # 1974
    FALSE, # 1974-1980
    FALSE, # 1984
    FALSE, # 1988
    FALSE, # 1993
    FALSE, # 1997
    FALSE, # 2000
    FALSE, # 2004
    FALSE, # 2006
    FALSE, # 2008
    FALSE, # 2011
    FALSE, # 2015 web
    TRUE,  # 2015 phone
    TRUE,  # 2015 combo
    FALSE, # 2019 web
    TRUE,  # 2019 phone
    FALSE  # 2021 web
  ),
  format = c(
    "spss", # 1965
    "spss", # 1968
    "spss", # 1972 jnjl
    "spss", # 1972 sep
    "spss", # 1972 nov
    "spss", # 1974
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
    "spss", # 2015 web
    "stata", # 2015 phone (contains .dta file)
    "spss", # 2015 combo
    "spss", # 2019 web
    "stata", # 2019 phone (contains .dta file)
    "stata"  # 2021 web
  ),
  encoding = c(
    "default", # 1965
    "default", # 1968
    "default", # 1972 jnjl
    "default", # 1972 sep
    "default", # 1972 nov
    "default", # 1974
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
    "Latin1",  # 2015 web
    "default", # 2015 phone
    "default", # 2015 combo
    "Latin1",  # 2019 web
    "default", # 2019 phone
    "UTF-8"    # 2021 web
  ),
  type = c(
    "Survey",     # 1965
    "Survey",     # 1968
    "Survey",     # 1972 jnjl
    "Survey",     # 1972 sep
    "Survey",     # 1972 nov
    "Survey",     # 1974
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
    "Web",        # 2015 web
    "Phone",      # 2015 phone
    "Web/Phone",  # 2015 combo
    "Web",        # 2019 web
    "Phone",      # 2019 phone
    "Web"         # 2021 web
  ),
  description = c(
    "1965 Canadian Election Study",
    "1968 Canadian Election Study",
    "1972 Canadian Election Study - June and July",
    "1972 Canadian Election Study - September",
    "1972 Canadian Election Study - November",
    "1974 Canadian Election Study",
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
    "2015 Canadian Election Study - Online Survey",
    "2015 Canadian Election Study - Phone Survey",
    "2015 Canadian Election Study - Combined Online and Phone",
    "2019 Canadian Election Study - Online Survey",
    "2019 Canadian Election Study - Phone Survey",
    "2021 Canadian Election Study - Online Survey"
  ),
  codebook_url = c(
    "https://borealisdata.ca/api/access/datafile/563560", # 1965
    "https://borealisdata.ca/api/access/datafile/563415", # 1968
    "", # 1972 jnjl - no codebook URL available
    "", # 1972 sep - no codebook URL available
    "", # 1972 nov - no codebook URL available
    "", # 1974 - no codebook URL available
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
    "https://borealisdata.ca/api/access/datafile/563239", # 2015 web
    "", # 2015 phone - no separate codebook
    "", # 2015 combo - no separate codebook
    "https://borealisdata.ca/api/access/datafile/563276", # 2019 web
    "", # 2019 phone - no separate codebook
    "https://borealisdata.ca/api/access/datafile/658980"  # 2021 web
  )
)

# Save this as an internal data object (overwrite existing data)
usethis::use_data(ces_datasets, internal = TRUE, overwrite = TRUE)

# Could also prepare a sample dataset for examples
# This would be a small subset of one of the CES datasets
# usethis::use_data(ces_sample, overwrite = TRUE)