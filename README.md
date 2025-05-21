# ces: Canadian Election Study Data Package

This R package provides easy access to Canadian Election Study (CES) datasets for analysis in R.

## Installation

You can install the released version of ces from CRAN with:

```r
install.packages("ces")
```

And the development version from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("laurenceomfoisy/ces")
```

## Example

```r
library(ces)

# Get the 2019 CES data (metadata is preserved by default)
ces_2019 <- get_ces("2019")

# If you need to disable metadata preservation (uncommon)
# ces_2019_minimal <- get_ces("2019", preserve_metadata = FALSE)

# View available datasets
list_ces_datasets()

# Create a codebook for the dataset
codebook <- create_codebook(ces_2019)

# Examine variable metadata
metadata <- examine_metadata(ces_2019, variable_pattern = "vote")

# Get subset of variables about voting behavior
voting_data <- get_ces_subset("2019", variables = c("vote_choice", "turnout"))

# Download the official codebook PDF
download_pdf_codebook("2019")

# Download a single dataset
download_ces_dataset("2019", path = "~/CES_data")

# Download all datasets at once
download_all_ces_datasets(path = "~/CES_data")
```

## Features

- Easy access to CES datasets from various years (1965-2021)
- Consistent data format across years
- Simple filtering and subsetting functions
- Automatic generation of variable codebooks
- Complete preservation of variable metadata (labels, value labels)
- Metadata examination tools
- Export capabilities for sharing dataset documentation
- Official PDF codebook downloads for all datasets

## Troubleshooting

For package developers: If you encounter a note about "unable to verify current time" during package check, use this environment setting:

```r
# Disable time verification entirely
Sys.setenv("_R_CHECK_SYSTEM_CLOCK_" = "0")
devtools::check()
```

This is the CRAN-approved way to eliminate timestamp verification issues.

## Acknowledgments and Disclaimers

### Data Source
This package accesses data from the [Borealis Data repository](https://borealisdata.ca/), which serves as the official host for the Canadian Election Study datasets. We gratefully acknowledge Borealis Data for maintaining and providing access to these valuable datasets.

The package author is not affiliated with the Canadian Election Study or Borealis Data. Users of this package should properly cite the original Canadian Election Study data in their research publications.

### Package Development
This package was developed with assistance from Claude Sonnet 3.7, an AI assistant by Anthropic. Claude helped with structuring the package, writing documentation, and implementing the core functionality. The collaboration between the human author and AI demonstrates how these tools can be used to create helpful resources for the research community.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
