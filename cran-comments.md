## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local macOS: R 4.4.x
- GitHub Actions CI: macOS, Windows, Ubuntu on R release and devel
- win-builder: R release and devel

## Resubmission

This is a resubmission.

## Changes in this version

- Added `glassSelect()`, an animated single-select dropdown widget for Shiny.
- Added `updateGlassSelect()` and `updateGlassMultiSelect()` for server-side widget updates.
- Added `glassSelectValue()` and `glassMultiSelectValue()` convenience reactive helpers.
- Updated documentation and vignettes to reflect direct Shiny input usage and server-side update patterns.
- Expanded test coverage for new select widgets and update helpers.

## Notes for reviewers

The package provides Shiny UI widgets implemented with HTML, CSS, and JavaScript bundled in `inst/www/`.

The widgets do not perform any network access at runtime.

Examples that launch Shiny apps are wrapped in `if (interactive())`.
