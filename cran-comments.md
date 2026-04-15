## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local Windows 11: R 4.5.1
- GitHub Actions CI: macOS, Windows, Ubuntu on R release and devel
- win-builder: R release and devel

## Resubmission

This is a resubmission.

## Changes in this version (0.3.0)

New exported functions:

- `runGlassExample()` — launches built-in example Shiny apps.
- `glassTabPanel()` gains an `icon` argument accepting any
  htmltools-compatible tag (e.g. `shiny::icon("table")`).
- `disableGlassTab()` / `enableGlassTab()` — gray out a tab without hiding it.
- `updateGlassTabBadge()` — display a live numeric count badge on a tab button.
- `glassTabsServer()` gains a `bookmark` argument (default `TRUE`) for Shiny
  URL bookmark integration.
- `glassTabsOutput()` / `renderGlassTabs()` — server-driven reactive tab
  rendering; JS reinitialises automatically after each render.

Other improvements:

- `glassTabsUI()` now errors early on duplicate `glassTabPanel()` values.
- `glassTabsServer()` warns on namespaced ids (containing `"-"`).
- CSS: added `.gt-tab-disabled`, `.gt-tab-icon`, `.gt-tab-label`, `.gt-tab-badge`.
- JS: scoped `shiny:value` listener for automatic reinit on `renderGlassTabs()`.
- Added `inst/cheatsheet/glasstabs-cheatsheet.tex` — printable LaTeX reference.
- Cheatsheet vignette extended with module usage, dynamic values, and bs4Dash.

