#!/usr/bin/env Rscript

# This script fixes timestamps on all package files to avoid the
# "unable to verify current time" NOTE during R CMD check

# Get package directory
pkg_dir <- normalizePath(".")

# Get list of all files in the package
all_files <- list.files(pkg_dir, recursive = TRUE, all.files = TRUE, full.names = TRUE)

# Exclude .git directory and other hidden files
all_files <- all_files[!grepl("\\.(git|Rproj.user)", all_files)]

# Get current time
current_time <- as.POSIXct(Sys.time())

# Set all timestamps to current time
cat("Setting timestamps for", length(all_files), "files...\n")
for (file in all_files) {
  if (file.exists(file) && !file.info(file)$isdir) {
    Sys.setFileTime(file, current_time)
  }
}

cat("Done.\n")