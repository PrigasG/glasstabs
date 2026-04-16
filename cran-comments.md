## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local Windows 11: R 4.5.1
- GitHub Actions CI: macOS, Windows, Ubuntu on R release and devel
- win-builder: R release and devel

## Changes in this version (0.3.1)

New exported functions:

- `glassTabCondition(id, value)` — generates the correct JavaScript condition
  string for `conditionalPanel()`, removing the need to recall the
  `input[["id-active_tab"]]` key pattern manually.
- `glasstabs_news()` — prints the package changelog to the R console.

Improvements:

- Error messages across all functions are now actionable: they identify the
  bad argument class, show what was received, and suggest the corrective fix.
- `glass_tab_theme()` and `glass_select_theme()` now have full `@examples`
  with interactive Shiny app snippets.
- `.gt-container` no longer forces `max-width:960px` or `margin:48px auto`;
  the widget now flows naturally inside Shiny columns and dashboard cards.
- Light-mode halo shadow improved via `--gt-halo-shadow` CSS variable
  (soft blue-tinted shadow instead of a harsh black drop shadow).
- `ROADMAP.md` added to the repository (excluded from the built package).
- 27 new tests covering `glassTabCondition()`, `glasstabs_news()`, and all
  improved error message paths.
