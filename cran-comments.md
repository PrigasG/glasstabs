## Submission

This is a development release (0.3.4) of glasstabs.

The previous CRAN version is 0.3.3. This development release is not intended
for immediate CRAN submission; it follows the 0.3.3 CRAN release with dropdown
lifecycle hardening.

## Changes in this version (0.3.4)

This release focuses on dropdown lifecycle hardening for complex Shiny layouts.

- Added public close helpers: `closeGlassSelect()`,
  `closeGlassMultiSelect()`, and `closeAllGlassSelects()`.
- Select widgets now expose `input$<inputId>_open` so applications can react to
  open/closed dropdown state.
- Open dropdowns close on more lifecycle events, including outside
  pointer-down, resize, Bootstrap tab/modal/collapse hiding,
  sidebar/offcanvas transitions, Shiny value replacement, and disconnect.

See NEWS.md for the full list.

## Test environments

- local Windows 11, R 4.5.1

## R CMD check results

0 errors | 0 warnings | 2 notes

Command used locally:
- `R CMD check --as-cran --no-manual glasstabs_0.3.4.tar.gz`

Notes:
- CRAN incoming reports `Days since last update: 0` because 0.3.3 was just
  submitted.
- The local Windows check reported `unable to verify current time`.

## CRAN pretest follow-up

- A previous Debian pretest reported `checking for detritus in the temp
  directory ... NOTE` with a `calibre-*` directory. CRAN indicated this can be
  caused by opening a browser in non-interactive mode. `runGlassExample()`
  explicitly refuses to launch Shiny apps in non-interactive sessions, and a
  regression test covers this guard. All `shinyApp(ui, server)` calls in the
  README, vignettes, and shipped example apps are protected by
  `if (interactive())`.
