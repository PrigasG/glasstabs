# Changelog

## glasstabs 0.1.1

### New features

#### Single-select widget

- Added
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
  an animated single-select dropdown for Shiny.
- Added
  [`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)
  for server-side updates to choices and selection.
- Added
  [`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md)
  as a convenience reactive helper for reading the selected value.

#### Multi-select widget

- Added
  [`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md)
  for server-side updates to choices, selection, and checkbox style.
- Added
  [`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md)
  as a convenience reactive helper for reading selected values and
  active style.
- Added optional `label` support to
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).
- Added configurable `all_label` support to control the trigger text
  shown when all choices are selected.

### Improvements

- Aligned
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  and
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  more closely with standard Shiny input behavior.
- Added client-side input bindings so select widgets now support
  `session$sendInputMessage()` update patterns.
- Preserved current
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  default behavior where `selected = NULL` initializes all choices as
  selected.
- Improved choice normalization so named choices retain display labels
  correctly.
- Improved hue normalization for the `"filled"` multi-select style.
- Updated vignettes and examples to show direct Shiny input usage and
  server-side update patterns.

### Documentation

- Added a new vignette for
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md).
- Updated the getting started vignette to include
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md).
- Updated the multi-select vignette to document
  [`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md)
  and
  [`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md).

### Internal changes

- Added tests for
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
  [`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md),
  and
  [`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md).
- Expanded tests for
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  server-side updates and helper utilities.

------------------------------------------------------------------------

## glasstabs 0.1.0

CRAN release: 2026-03-11

Initial release.

### New features

#### Tab widget

- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  — animated glassmorphism-style tab navigation with a sliding glass
  halo and transfer trace between tabs.
- [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  — defines a single tab button and its content pane.
- [`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md)
  — reactive helper that tracks the active tab value.
- [`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
  — custom color theme for
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  with eight independent handles: `tab_text`, `tab_active_text`,
  `halo_bg`, `halo_border`, `content_bg`, `content_border`, `card_bg`,
  `card_text`.
- Built-in `"dark"` (default) and `"light"` presets for
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).
- Keyboard navigation using the Left and Right arrow keys.
- Full `bs4Dash` compatibility via `wrap = FALSE`.

#### Multi-select filter widget

- [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  — dropdown filter with live search, select-all with indeterminate
  state, and three checkbox indicator styles: `"checkbox"`,
  `"check-only"`, and `"filled"`.
- [`glassFilterTags()`](https://prigasg.github.io/glasstabs/reference/glassFilterTags.md)
  — tag-pill display area that stays in sync with a
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  automatically via JavaScript; clicking × on a pill deselects that
  option.
- [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  — custom color theme with four handles: `bg_color`, `border_color`,
  `text_color`, `accent_color`.
- Built-in `"dark"` and `"light"` presets for
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).
- `show_style_switcher`, `show_select_all`, `show_clear_all` flags to
  hide UI chrome (all default `TRUE`).
- Per-option HSL hue angles for the `"filled"` style via the `hues`
  argument (auto-assigned if omitted).

#### General

- [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
  — injects CSS and JavaScript via
  [`htmltools::htmlDependency`](https://rstudio.github.io/htmltools/reference/htmlDependency.html),
  which is deduplicated automatically by Shiny.
- All theming uses pre-computed CSS variables (no `color-mix()`),
  ensuring compatibility with Shiny’s embedded browser.
- Multiple instances of either widget on the same page work
  independently; each instance is scoped to its own `id`.
