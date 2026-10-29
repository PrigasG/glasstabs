## Submission

This is glasstabs 0.4.1. The previous CRAN version is 0.4.0.

## Changes in this version (0.4.1)

This is a minor update refining the select widgets, examples, and tab widget.

- `glassSelect()` and `glassMultiSelect()` dropdown panels now follow the
  rendered trigger width, clamp to the viewport on narrow screens, and wrap
  long labels within the available panel width.
- Both select widgets support automatic search visibility, configurable field
  width, optional tongue animation, label styling, search-focus styling, and
  accessible overflow tooltips for truncated trigger text.
- `glassMultiSelect()` adds compact selection summaries, a configurable
  option-list height, and either one fill color or multiple fill colors.
- Multi-select server updates are transactional and can notify Shiny only when
  the effective value changes, always, or never. Selection preservation and
  invalid-value handling are explicit.
- `glassMultiSelectValue()` can resolve an empty selection as none, all
  available choices, or `NULL`, while preserving the raw input value.
- Tab content now sits in a subtle glass container by default, so the tab bar
  and content read as one connected component. The active tab shows a soft
  inner light on its content-facing edge to tie them together.
- `glassTabsUI()` gains `style = "attached"`, docking the tab bar onto the
  content box as a single unified card, and `transition = "slide"`, sliding
  panes in the direction of travel. `content_min_height` (default `NULL`,
  i.e. `120px`, or `60px` when `compact = TRUE`) replaces the fixed 200px
  content minimum; an explicitly supplied value always wins.
- Added real-browser regression coverage for both widget types at narrow field
  widths, long labels, resizing, viewport-edge placement, adaptive search,
  quiet updates, summaries, and list height.
- Refreshed all shipped examples for dark and light themes, including a native
  Shiny comparison and stress-test controls for the new select options.
- Updated the package documentation, print cheatsheet, deployment manifest,
  and repository metadata to match the 0.4.1 API.

See NEWS.md for the full list.

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked from a clean source archive with R 4.5.1 on Windows 11 using
`R CMD check --as-cran`.

In addition to the package check, the release candidate passed JavaScript lint
and 1,014 package assertions, including 104 real-browser interaction checks.

