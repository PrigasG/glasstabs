# glasstabs 0.2.0
 
## Bug fixes
 
* Opening a dropdown now closes any other open glasstabs dropdown, fixing
  a visual stacking issue where multiple dropdowns appeared simultaneously.
 
* Improved widget lifecycle in dynamic UI (`renderUI()`, `conditionalPanel()`).
  Widgets initialize more reliably and clean up properly when removed.
 
* Widgets now emit their initial value to Shiny immediately after rendering,
  fixing timing issues with `conditionalPanel()` and dynamic UI.
 
## Internal improvements
 
* JavaScript engine refactored to use internal state instead of DOM scanning.
  No changes to the R API — all existing code works without modification.
 
* Added scroll containers for long option lists, debounced search, and
  `.gt-loading` / `.gt-disabled` CSS utility classes.

---

# glasstabs 0.1.1

## New features

### Single-select widget

* Added `glassSelect()`, an animated single-select dropdown for Shiny.
* Added `updateGlassSelect()` for server-side updates to choices and selection.
* Added `glassSelectValue()` as a convenience reactive helper for reading the selected value.

### Multi-select widget

* Added `updateGlassMultiSelect()` for server-side updates to choices, selection, and checkbox style.
* Added `glassMultiSelectValue()` as a convenience reactive helper for reading selected values and active style.
* Added optional `label` support to `glassMultiSelect()`.
* Added configurable `all_label` support to control the trigger text shown when all choices are selected.

## Improvements

* Aligned `glassSelect()` and `glassMultiSelect()` more closely with standard Shiny input behavior.
* Added client-side input bindings so select widgets now support `session$sendInputMessage()` update patterns.
* Preserved current `glassMultiSelect()` default behavior where `selected = NULL` initializes all choices as selected.
* Improved choice normalization so named choices retain display labels correctly.
* Improved hue normalization for the `"filled"` multi-select style.
* Updated vignettes and examples to show direct Shiny input usage and server-side update patterns.

## Documentation

* Added a new vignette for `glassSelect()`.
* Updated the getting started vignette to include `glassSelect()`.
* Updated the multi-select vignette to document `updateGlassMultiSelect()` and `glassMultiSelectValue()`.

## Internal changes

* Added tests for `glassSelect()`, `updateGlassSelect()`, and `glassSelectValue()`.
* Expanded tests for `glassMultiSelect()` server-side updates and helper utilities.

---

# glasstabs 0.1.0

Initial release.

## New features

### Tab widget

* `glassTabsUI()` — animated glassmorphism-style tab navigation with a sliding
  glass halo and transfer trace between tabs.
* `glassTabPanel()` — defines a single tab button and its content pane.
* `glassTabsServer()` — reactive helper that tracks the active tab value.
* `glass_tab_theme()` — custom color theme for `glassTabsUI()` with eight
  independent handles: `tab_text`, `tab_active_text`, `halo_bg`,
  `halo_border`, `content_bg`, `content_border`, `card_bg`, `card_text`.
* Built-in `"dark"` (default) and `"light"` presets for `glassTabsUI()`.
* Keyboard navigation using the Left and Right arrow keys.
* Full `bs4Dash` compatibility via `wrap = FALSE`.

### Multi-select filter widget

* `glassMultiSelect()` — dropdown filter with live search,
  select-all with indeterminate state, and three checkbox indicator styles:
  `"checkbox"`, `"check-only"`, and `"filled"`.
* `glassFilterTags()` — tag-pill display area that stays in sync with a
  `glassMultiSelect()` automatically via JavaScript; clicking × on a pill
  deselects that option.
* `glass_select_theme()` — custom color theme with four handles: `bg_color`,
  `border_color`, `text_color`, `accent_color`.
* Built-in `"dark"` and `"light"` presets for `glassMultiSelect()`.
* `show_style_switcher`, `show_select_all`, `show_clear_all` flags to hide
  UI chrome (all default `TRUE`).
* Per-option HSL hue angles for the `"filled"` style via the `hues` argument
  (auto-assigned if omitted).

### General

* `useGlassTabs()` — injects CSS and JavaScript via
  `htmltools::htmlDependency`, which is deduplicated automatically by Shiny.
* All theming uses pre-computed CSS variables (no `color-mix()`), ensuring
  compatibility with Shiny's embedded browser.
* Multiple instances of either widget on the same page work independently;
  each instance is scoped to its own `id`.
