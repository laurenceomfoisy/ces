#!/usr/bin/env Rscript

# Installation script for the ces package
# Just run this with Rscript install.R

# Function to install a package if not already installed
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing package:", pkg, "\n")
    install.packages(pkg)
  } else {
    cat("Package already installed:", pkg, "\n")
  }
}

# Install dependencies
cat("Installing dependencies...\n")
dependencies <- c("dplyr", "haven", "tibble", "testthat", "knitr", "rmarkdown", "openxlsx")
for (pkg in dependencies) {
  install_if_missing(pkg)
}

# Install devtools if needed
install_if_missing("devtools")

# Install the ces package from GitHub
cat("\nInstalling ces package from GitHub...\n")
devtools::install_github("laurenceomfoisy/ces")

cat("\nPackage installation complete!\n")
cat("You can now use the package by loading it with:\n")
cat("library(ces)\n\n")
cat("For examples, try:\n")
cat("help(ces)\n")
cat("vignette('ces-introduction')\n")