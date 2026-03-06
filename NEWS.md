# glasstabs 0.1.0

First release.

## New features

### Tab widget

* `glassTabsUI()` — animated glass-morphism tab navigation with a sliding
  glass halo, spring easing, and a luminous transfer trace between tabs.
* `glassTabPanel()` — defines a single tab button and its content pane.
* `glassTabsServer()` — reactive tracking the active tab value.
* `glass_tab_theme()` — custom colour theme for `glassTabsUI()` with eight
  independent handles: `tab_text`, `tab_active_text`, `halo_bg`,
  `halo_border`, `content_bg`, `content_border`, `card_bg`, `card_text`.
* Built-in `"dark"` (default) and `"light"` presets for `glassTabsUI()`.
* Keyboard navigation via Arrow Left / Right.
* Full bs4Dash compatibility via `wrap = FALSE`.

### Multi-select filter widget

* `glassMultiSelect()` — animated dropdown filter with live search,
  select-all with indeterminate state, and three checkbox indicator styles:
  `"checkbox"`, `"check-only"`, and `"filled"`.
* `glassMultiSelectServer()` — typed reactive wrapper exposing `selected`
  and `style` reactives.
* `glassFilterTags()` — tag-pill display area that stays in sync with a
  `glassMultiSelect()` automatically via JS; clicking × on a pill deselects
  that option.
* `glass_select_theme()` — custom color theme with four handles: `bg_color`,
  `border_color`, `text_color`, `accent_color`.
* Built-in `"dark"` and `"light"` presets for `glassMultiSelect()`.
* `show_style_switcher`, `show_select_all`, `show_clear_all` flags to hide
  UI chrome (all default `TRUE`).
* Per-option HSL hue angles for the `"filled"` style via the `hues` argument
  (auto-assigned if omitted).

### General

* `useGlassTabs()` — injects CSS and JS as a proper `htmltools::htmlDependency`
  (deduplicated automatically by Shiny).
* All theming uses pre-computed CSS variables — no `color-mix()` — ensuring
  compatibility with Shiny's embedded browser.
* Multiple instances of either widget on the same page work fully
  independently; each is scoped to its own `id`.
