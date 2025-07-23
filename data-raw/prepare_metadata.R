# Script to prepare CES metadata
# This could be used to create internal data objects for the package

library(tibble)

# Create a tibble with metadata about CES datasets
ces_datasets <- tibble(
  year = c("1965", "1968", "1972", "1972", "1972", "1974", "1974", "1984", "1988", "1993", 
           "1997", "2000", "2004", "2006", "2008", "2011", 
           "2015", "2015", "2015", "2019", "2019", "2021"),
  variant = c("single_survey", "single_survey", "jnjl", "sep", "nov", "single_survey", "1974_1980", "single_survey", "single_survey", "single_survey",
              "single_survey", "single_survey", "single_survey", "single_survey", "single_survey", "single_survey",
              "web", "phone", "combo", "web", "phone", "web"),
  url = c(
    "https://borealisdata.ca/api/access/datafile/563651", # 1965
    "https://borealisdata.ca/api/access/datafile/563469", # 1968
    "https://borealisdata.ca/api/access/datafile/881553", # 1972 jnjl
    "https://borealisdata.ca/api/access/datafile/881549", # 1972 sep
    "https://borealisdata.ca/api/access/datafile/881545", # 1972 nov
    "https://borealisdata.ca/api/access/datafile/880887", # 1974
    "https://borealisdata.ca/api/access/datafile/563390", # 1974 1974_1980
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
    "https://ces-eec.arts.ubc.ca/files/2018/08/CES2015-phone-Stata.zip", # 2015 phone
    "https://ces-eec.arts.ubc.ca/files/2017/04/CES2015_Combined_Stata14.zip", # 2015 combo
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
    "UTF-8", # 2019 phone
    "UTF-8"    # 2021 web
  ),
  type = c(
    "Survey",     # 1965
    "Survey",     # 1968
    "Survey",     # 1972 jnjl
    "Survey",     # 1972 sep
    "Survey",     # 1972 nov
    "Survey",     # 1974
    "Panel",      # 1974 1974_1980
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
    "https://borealisdata.ca/api/access/datafile/563235", # 1972 jnjl
    "https://borealisdata.ca/api/access/datafile/563221", # 1972 sep
    "https://borealisdata.ca/api/access/datafile/563222", # 1972 nov
    "https://borealisdata.ca/api/access/datafile/563262", # 1974
    "https://borealisdata.ca/api/access/datafile/563334", # 1974 1974_1980
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
    "https://borealisdata.ca/api/access/datafile/563381", # 2015 phone
    "https://borealisdata.ca/api/access/datafile/563239", # 2015 combo
    "https://borealisdata.ca/api/access/datafile/563276", # 2019 web
    "https://borealisdata.ca/api/access/datafile/761212", # 2019 phone
    "https://borealisdata.ca/api/access/datafile/658980"  # 2021 web
  ),
  citation = c(
    "TO CITE THIS SURVEY FILE: Converse, P, Meisel, J, Pinard, M, Regenstreif, P and Schwartz, M. 1966. Canadian Election Survey, 1965. [Microdata File]. Inter-University Consortium for Political and Social Research, University of Michigan, Ann Arbor MI [Producer].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1965&mode=documentation&top=yes", # 1965
    
    "TO CITE THIS SURVEY FILE: Meisel, J. 1968. The 1968 Canadian Election Study [dataset]. Inter-University Consortium for Political and Social Research, University of Michigan, Ann Arbor MI [Producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1968&mode=documentation&top=yes", # 1968
    
    "TO CITE THIS SURVEY FILE: Ruban, C. 1972. The 1972 Canadian Election Study [dataset]. 2nd ICPSR version. Toronto, Ontario, Canada: Market Opinion Research (Canada) Ltd. [producer], 1972. Ann Arbor, MI: Interuniversity Consortium for Political and Social Research [distributor], 2001.\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1972-jun-july&mode=documentation&top=yes", # 1972 jnjl
    
    "TO CITE THIS SURVEY FILE: Ruban, C. 1972. The 1972 Canadian Election Study [dataset]. 2nd ICPSR version. Toronto, Ontario, Canada: Market Opinion Research (Canada) Ltd. [producer], 1972. Ann Arbor, MI: Interuniversity Consortium for Political and Social Research [distributor], 2001.\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1972-sept&mode=documentation&top=yes", # 1972 sep
    
    "TO CITE THIS SURVEY FILE: Ruban, C. 1972. The 1972 Canadian Election Study [dataset]. 2nd ICPSR version. Toronto, Ontario, Canada: Market Opinion Research (Canada) Ltd. [producer], 1972. Ann Arbor, MI: Interuniversity Consortium for Political and Social Research [distributor], 2001.\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1972-nov&mode=documentation&top=yes", # 1972 nov
    
    "TO CITE THIS SURVEY FILE: Clarke, H, Jenson, J, LeDuc, L and Pammett, J. 1975. The 1974 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1974&mode=documentation&top=yes", # 1974
    
    "TO CITE THIS SURVEY FILE: Clarke, H, Jenson, J, LeDuc, L and Pammett, J. 1980. The 1974-1980 Merged Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1974-1980&mode=documentation&top=yes", # 1974-1980
    
    "TO CITE THIS SURVEY FILE: Lambert, R. D., Brown, S. D., Curtis, J. E., Kay, B. J. and Wilson, J. M. 1985. The 1984 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1984&mode=documentation&top=yes", # 1984
    
    "TO CITE THIS SURVEY FILE: Johnston, R, Blais, A, Brady, H. E. and Crête, J. 1989. The 1988 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK:http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1988&mode=documentation&top=yes", # 1988
    
    "TO CITE THIS SURVEY FILE: Blais, A, Brady, H, Gidengil, E, Johnston, R and Nevitte, N. 1994. The 1993 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1993&mode=documentation&top=yes", # 1993
    
    "TO CITE THIS SURVEY FILE: Blais, A, Gidengil, E, Nadeau, R and Nevitte, N. 1998. The 1997 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-1997&mode=documentation&top=yes", # 1997
    
    "TO CITE THIS SURVEY FILE: Blais, A, Gidengil, E, Nadeau, R and Nevitte, N. 2001. The 2000 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-2000&mode=documentation&top=yes", # 2000
    
    "TO CITE THIS SURVEY FILE: Blais, A, Everitt, J, Fournier, P, Gidengil, E and Nevitte, N. 2005. The 2004 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-2004&mode=documentation&top=yes", # 2004
    
    "TO CITE THIS SURVEY FILE: Blais, A, Everitt, J, Fournier, P and Nevitte, N. 2011. The 2011 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&submode=abstract&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-2004-2006&mode=documentation&top=yes", # 0406
    
    "TO CITE THIS SURVEY FILE: Gidengil, E, Everitt, J, Fournier, P and Nevitte, N. 2009. The 2008 Canadian Election Study [dataset]. Toronto, Ontario, Canada: Institute for Social Research [producer and distributor].\nLINK: http://odesi2.scholarsportal.info/webview/index.jsp?v=2&previousmode=table&analysismode=table&study=http%3A%2F%2F142.150.190.128%3A80%2Fobj%2FfStudy%2FCES-E-2008&mode=documentation&top=yes", # 2008
    
    "TO CITE THIS SURVEY FILE: Fournier, Patrick, Fred Cutler, Stuart Soroka and Dietlind Stolle. 2011. The 2011 Canadian Election Study. [dataset]\nLINK: https://ces-eec.arts.ubc.ca/english-section/surveys/", # 2011
    
    "TO CITE THIS SURVEY FILE: Fournier, Patrick, Fred Cutler, Stuart Soroka and Dietlind Stolle. 2015. The 2015 Canadian Election Study. [dataset]\nLINK: https://ces-eec.arts.ubc.ca/english-section/surveys/", # 2015 web
    
    "TO CITE THIS SURVEY FILE: Fournier, Patrick, Fred Cutler, Stuart Soroka and Dietlind Stolle. 2015. The 2015 Canadian Election Study. [dataset]\nLINK:https://ces-eec.arts.ubc.ca/english-section/surveys/", # 2015 phone
    
    "TO CITE THIS SURVEY FILE: Fournier, Patrick, Fred Cutler, Stuart Soroka and Dietlind Stolle. 2015. The 2015 Canadian Election Study. [dataset]\nLINK: https://ces-eec.arts.ubc.ca/english-section/surveys/", # 2015 combo
    
    "TO CITE THIS SURVEY FILE:\n- Stephenson, Laura B; Harell, Allison; Rubenson, Daniel; Loewen, Peter John, 2020, '2019 Canadian Election Study - Online Survey', https://doi.org/10.7910/DVN/DUS88V, Harvard Dataverse, V1\n- Stephenson, Laura, Allison Harrel, Daniel Rubenson and Peter Loewen. Forthcoming. 'Measuring Preferences and Behaviour in the 2019 Canadian Election Study,' Canadian Journal of Political Science.\nLINK: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DUS88V", # 2019 web
    
    "TO CITE THIS SURVEY FILE:\n- Stephenson, Laura B; Harell, Allison; Rubenson, Daniel; Loewen, Peter John, 2020, '2019 Canadian Election Study - Phone Survey', https://doi.org/10.7910/DVN/8RHLG1, Harvard Dataverse, V1, UNF:6:eyR28qaoYlHj9qwPWZmmVQ== [fileUNF]\n- Stephenson, Laura, Allison Harrel, Daniel Rubenson and Peter Loewen. Forthcoming. 'Measuring Preferences and Behaviour in the 2019 Canadian Election Study,' Canadian Journal of Political Science.\nLINK: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8RHLG1", # 2019 phone
    
    "TO CITE THIS SURVEY FILE:\n- Stephenson, Laura B.; Harell, Allison; Rubenson, Daniel; Loewen, Peter John, 2023, 'Canadian Election Study 2021', https://doi.org/10.5683/SP3/MMXTFC, Borealis, V5," # 2021
  )
)

# Save this as an internal data object (overwrite existing data)
usethis::use_data(ces_datasets, internal = TRUE, overwrite = TRUE)

# Could also prepare a sample dataset for examples
# This would be a small subset of one of the CES datasets
# usethis::use_data(ces_sample, overwrite = TRUE)