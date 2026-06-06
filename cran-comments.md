## Submission

This is a minor release (1.1.0) of the ces package.

### Changes in this version

* Added the 2025 Canadian Election Study web survey, retrieved from Harvard
  Dataverse (doi:10.7910/DVN/2YAQ8D). Coverage now spans 23 datasets from
  1965 to 2025.
* Restored downloads of the 2015 phone and combined (web/phone) surveys, which
  had stopped working. The upstream host began returning an HTML
  bot-protection page to programmatic clients; the package now sends a standard
  browser `User-Agent` (saved and restored on exit, so global options are not
  modified) so the data files are retrieved correctly. The 2015 combined survey
  is additionally sourced from the Borealis repository for stability.

## Test environments

* Local: Arch Linux, R 4.6.0
* R-hub (GitHub Actions): Ubuntu Linux (R-devel) and Windows (R-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

`R CMD check --as-cran` passed cleanly (Status: OK) on the local environment,
and the R-hub Ubuntu (R-devel) and Windows (R-devel) checks passed.
All examples that access the internet are wrapped in `\donttest{}`; tests that
require network resources skip gracefully when those resources are unavailable.

## Reverse dependencies

There are currently no reverse dependencies for this package.
