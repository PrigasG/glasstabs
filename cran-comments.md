## R CMD check results

0 errors | 0 warnings | 0 notes (local check)

Tested on:

• macOS (local): R 4.4.x  
• GitHub Actions CI: macOS, Windows, Ubuntu (R release and devel)  
• win-builder: R release and devel

## New submission

This is a new package. There are no previous CRAN versions.

## Notes for reviewers

The package provides two Shiny UI widgets: `glassTabsUI()` for animated tab navigation and `glassMultiSelect()` for a searchable multi-select dropdown filter.

Both widgets are implemented using HTML, CSS, and JavaScript bundled in `inst/www/`. They do not perform any network access at runtime.

Examples that launch a Shiny app are wrapped in `if (interactive())`.
