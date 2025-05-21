# ces 0.1.0

* Initial release
* Added functions for accessing Canadian Election Study datasets:
  * `get_ces()` - Download and load CES data for a specific year
  * `list_ces_datasets()` - List available CES datasets
  * `get_ces_subset()` - Get a subset of variables from a CES dataset
  * `create_codebook()` - Generate a comprehensive codebook for CES datasets
  * `export_codebook()` - Export codebooks to CSV or Excel formats
  * `examine_metadata()` - Analyze metadata across variables in a dataset
  * `download_pdf_codebook()` - Download official PDF codebooks for any CES year
  * `download_ces_dataset()` - Download a single CES dataset by year
  * `download_all_ces_datasets()` - Download all or selected CES datasets at once
* Enhanced metadata preservation:
  * Metadata preservation is now enabled by default
  * All variable labels and value labels are automatically maintained
  * Complete preservation of original dataset attributes for better data documentation
* Supported datasets from 1965 to 2021
* Added vignette and examples
* Included support for variable documentation and metadata exploration