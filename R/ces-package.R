#' Canadian Election Study Data Package
#'
#' @description
#' Provides tools to easily access and analyze Canadian Election Study data.
#' The package simplifies the process of downloading, cleaning, and using CES datasets
#' for political science research and analysis. The Canadian Election Study (CES)
#' has been conducted during federal elections since 1965, surveying Canadians
#' on their political preferences, engagement, and demographics.
#'
#' @section Key Functions:
#' \itemize{
#'   \item \code{\link{get_ces}}: Download and load CES data for a specific year
#'   \item \code{\link{list_ces_datasets}}: List available CES datasets
#'   \item \code{\link{get_ces_subset}}: Get a subset of variables from a CES dataset
#'   \item \code{\link{create_codebook}}: Generate a comprehensive codebook for CES datasets
#'   \item \code{\link{download_pdf_codebook}}: Download official PDF codebooks
#'   \item \code{\link{download_ces_dataset}}: Download a single CES dataset
#'   \item \code{\link{download_all_ces_datasets}}: Download all CES datasets
#' }
#'
#' @section Data Source:
#' Data is accessed from the Borealis Data repository, which serves as the official host 
#' for CES datasets. This package is not officially affiliated with the Canadian Election 
#' Study or Borealis Data, and users should cite the original data sources in their work.
#'
#' @author Laurence-Olivier M. Foisy
#'
#' @references
#' For more information about the Canadian Election Study, visit:
#' \url{https://ces-eec.arts.ubc.ca/}
#'
#' @keywords package
#' @docType package
#' @name ces-package
"_PACKAGE"

#' @importFrom dplyr filter select mutate
#' @importFrom haven read_sav read_dta as_factor
#' @importFrom tibble as_tibble
#' @importFrom utils download.file unzip

NULL