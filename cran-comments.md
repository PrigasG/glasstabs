## Submission

This is a new minor release (0.3.3) of glasstabs.

The previous CRAN version is 0.3.1. Version 0.3.2 was prepared as a development
snapshot and was not submitted to CRAN; its changes ship as part of this
release and are recorded under the `0.3.2` heading in NEWS.md.

## Changes in this version (0.3.3)

This release adds native-layout parity and square-corner styling for the select
widgets, plus opt-in server-side search for large choice sets.

- `glassSelect()` and `glassMultiSelect()` gained a `width` argument (passed to
  `shiny::validateCssUnit()`) so the widgets can fill a column or match a fixed
  layout, like native `selectizeInput()`.
- Both selects now accept grouped choices as a named list (selectInput()-style),
  rendering non-interactive group headers.
- Added disabled support (`disabled` and `disabled_choices`), reachable at
  runtime via `updateGlassSelect()` / `updateGlassMultiSelect()`.
- Added a `shape` argument (`"rounded"` default or `"square"`) to the select
  widgets and `glassTabsUI()` for crisp, selectize-style corners.
- Added opt-in server-side search (`server = TRUE`, `glassSelectServer()`,
  `glassMultiSelectServer()`) with loading and no-results states.
- Bug fixes for `updateGlassMultiSelect()` updates being lost during a
  `renderUI()` replacement, and for scalar `selected` values in the
  multi-select binding.

See NEWS.md for the full list.

## Test environments

- local Windows 11, R 4.5.1

## R CMD check results

0 errors | 0 warnings | 0 notes

Command used locally:
- `R CMD check --no-manual glasstabs_0.3.3.tar.gz`
- local CRAN incoming check: `checking CRAN incoming feasibility ... OK`

## CRAN pretest follow-up

- A previous Debian pretest reported `checking for detritus in the temp
  directory ... NOTE` with a `calibre-*` directory. CRAN indicated this can be
  caused by opening a browser in non-interactive mode. `runGlassExample()`
  explicitly refuses to launch Shiny apps in non-interactive sessions, and a
  regression test covers this guard. All `shinyApp(ui, server)` calls in the
  README, vignettes, and shipped example apps are protected by
  `if (interactive())`.
