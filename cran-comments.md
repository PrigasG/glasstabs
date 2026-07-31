## Submission

This is an update to glasstabs 0.3.4. The previous CRAN version is 0.3.3.

## Changes in this version (0.3.4)

This release expands tab layouts and theming, hardens select dropdown behavior,
and improves internal consistency and diagnostics.

- Added glass, solid, and underline tab indicators, vertical tab orientation,
  and configurable tab-label alignment.
- Added automatic Bootstrap 5 / bslib light and dark theming for tabs and select
  widgets.
- Added public close helpers: `closeGlassSelect()`,
  `closeGlassMultiSelect()`, and `closeAllGlassSelects()`.
- Select widgets now expose `input$<inputId>_open` so applications can react to
  open/closed dropdown state.
- Open dropdowns close on more lifecycle events, including outside
  pointer-down, resize, Bootstrap tab/modal/collapse hiding,
  sidebar/offcanvas transitions, Shiny value replacement, and disconnect.
- Teleported dropdowns now stay within the browser viewport.
- Added structured package error classes and broader regression coverage.
- Reworked the README and pkgdown articles around self-contained, copy-ready
  examples.

See NEWS.md for the full list.

## Test environments

- local Windows 11, R 4.5.1

## R CMD check results

0 errors | 0 warnings | 0 notes

Command used locally:
- `R CMD check --as-cran glasstabs_0.3.4.tar.gz`

## CRAN pretest follow-up

- A previous Debian pretest reported `checking for detritus in the temp
  directory ... NOTE` with a `calibre-*` directory. CRAN indicated this can be
  caused by opening a browser in non-interactive mode. `runGlassExample()`
  explicitly refuses to launch Shiny apps in non-interactive sessions, and a
  regression test covers this guard. All `shinyApp(ui, server)` calls in the
  README, vignettes, and shipped example apps are protected by
  `if (interactive())`.
