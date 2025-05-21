#!/usr/bin/env Rscript

# This script performs a "clean" check with no timestamp verification warnings
message("Setting up for clean R CMD check...")

# Set environment variable to disable time checks
Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = "0")

# Fix any timestamps in the package
source("tools/fix-timestamps.R")

# Run the check
message("\nRunning R CMD check with time verification disabled...\n")
devtools::check(env_vars = c("_R_CHECK_SYSTEM_CLOCK_" = "0"))

message("\nCheck complete.")