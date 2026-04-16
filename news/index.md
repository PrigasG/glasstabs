# Changelog

## glasstabs 0.3.1

### New features

- Added `glassTabCondition(id, value)` — generates the correct
  JavaScript condition string for \[shiny::conditionalPanel()\] without
  needing to remember the `input[["id-active_tab"]]` key pattern.
- Added
  [`glasstabs_news()`](https://prigasg.github.io/glasstabs/reference/glasstabs_news.md)
  — prints the package changelog to the R console.
- Added `ROADMAP.md` tracking planned features and known limitations
  (not shipped in the package).

### Improvements

- Error messages across all functions are now actionable: they name the
  bad argument class, show what was received, and suggest the correct
  fix.
- [`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
  and
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  now have full `@examples` with interactive app snippets.
- `.gt-container` no longer forces `max-width:960px` or
  `margin:48px auto` — the widget now behaves like a normal block
  element inside Shiny layouts.
- Light-mode halo box-shadow replaced with a soft blue-tinted shadow via
  the `--gt-halo-shadow` CSS variable, replacing the harsh dark drop
  shadow.

------------------------------------------------------------------------

## glasstabs 0.3.0

### New features

#### Tab widget

- Added
  [`runGlassExample()`](https://prigasg.github.io/glasstabs/reference/runGlassExample.md)
  to launch any of the built-in example apps directly from the R console
  (`runGlassExample("smoke-test")`, etc.).
- Added `icon` argument to
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  — accepts any htmltools-compatible tag (e.g. `shiny::icon("table")`).
  Renders with `gt-tab-icon` / `gt-tab-label` spans so icon and text can
  be styled independently.
- Added
  [`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md)
  and
  [`enableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md)
  — gray out a tab without hiding it. Completes the
  visibility/disabled/removal trio alongside
  [`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md)
  /
  [`hideGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md).
- Added
  [`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md)
  — set a numeric count badge on any tab button. Pass `count = 0` or
  `count = NA` to hide the badge. Values above 99 display as `"99+"`.
- [`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md)
  now integrates with Shiny’s URL bookmarking: the active tab is
  automatically saved and restored when `enableBookmarking = "url"` is
  set on the app. Opt out per widget with `bookmark = FALSE`.
- Added
  [`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md)
  /
  [`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md)
  for server-driven tab rendering. The JavaScript engine re-initialises
  automatically after each render via a scoped `shiny:value` listener,
  so no manual `glasstabs_reinit` calls are needed.

### Improvements

- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  now errors early on duplicate
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  values, reporting the offending value(s) by name.
- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  gains a `compact = FALSE` argument. Setting `compact = TRUE` applies
  the `.gt-compact` CSS modifier which reduces margins, tab-link
  padding, font size, and content area padding — ideal for embedding
  inside bs4Dash cards or any tight dashboard layout.
- [`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md)
  emits a [`warning()`](https://rdrr.io/r/base/warning.html) when the
  `id` argument contains `"-"`, which is the most common sign that
  `ns("tabs")` was passed instead of the bare `"tabs"` id. The warning
  includes corrective guidance.
- CSS: added `.gt-tab-disabled`, `.gt-tab-icon`, `.gt-tab-label`, and
  `.gt-tab-badge` rules. Badges adapt their background to the active
  halo colour via the existing CSS custom property.
- CSS: all color values are now consumed via `var(--gt-xxx, fallback)`
  instead of being hardcoded — this was the root cause of light theme
  appearing invisible. Light theme defaults were also strengthened for
  better contrast.
- CSS: dropdown active-state z-index raised to 9000/9001 so glasstabs
  dropdowns render above bs4Dash card stacking contexts.
- `shiny:value` listener limits bootAll re-initialisation to outputs
  that actually contain glasstabs elements, so ordinary Shiny outputs
  are unaffected.
- Added `inst/cheatsheet/glasstabs-cheatsheet.tex` — a printable
  four-column LaTeX reference card covering the full API, module
  pattern, bs4Dash integration, theming, and common gotchas.

### Documentation

- Cheatsheet vignette (`vignettes/cheatsheet.Rmd`) extended with new
  sections: “Tabs inside a Shiny module”, “Dynamic tab values and
  selected”, “Tabs inside bs4Dash”, and updated common gotchas.
- All new functions have full roxygen docs, `@examples`, and
  cross-links.

------------------------------------------------------------------------

## glasstabs 0.2.1

CRAN release: 2026-04-11

### New features

#### Tab widget

- Added
  [`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)
  for programmatic tab switching from the server.
- Added
  [`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md)
  and
  [`hideGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md)
  for dynamically showing and hiding tabs at runtime.
- Added
  [`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md)
  and
  [`removeGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md)
  for adding and removing tabs at runtime.

### Improvements

- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  now validates `selected` against the available
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  values and errors early on invalid tab ids.
- The tab widget now reports its initial active tab to Shiny immediately
  after session startup, so
  [`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md)
  is populated on first render.
- Added ARIA roles and selected-state attributes to tab navigation
  markup.
- Improved tab re-initialization and transition handling for dynamic tab
  changes, including show/hide, append/remove, and rapid successive
  updates.
- Improved halo and transfer-trace positioning after runtime tab layout
  changes.

### Bug fixes

- Opening a dropdown now closes any other open glasstabs dropdown,
  fixing a visual stacking issue where multiple dropdowns appeared
  simultaneously.

- Improved widget lifecycle in dynamic UI
  ([`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html),
  [`conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html)).
  Widgets initialize more reliably and clean up properly when removed.

- Widgets now emit their initial value to Shiny immediately after
  rendering, fixing timing issues with
  [`conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html)
  and dynamic UI.

### Internal improvements

- JavaScript engine refactored to use internal state instead of DOM
  scanning. No changes to the R API — all existing code works without
  modification.

- Added scroll containers for long option lists, debounced search, and
  `.gt-loading` / `.gt-disabled` CSS utility classes.

### Documentation

- Added a dedicated cheatsheet vignette for common widget patterns and
  server-side helpers.
- Added a smoke-test example app covering programmatic tab switching,
  dynamic tab visibility, runtime tab insertion/removal, and rapid
  interaction paths.
- Expanded README and pkgdown navigation to surface the new server-side
  tab controls and cheatsheet more clearly.

------------------------------------------------------------------------

## glasstabs 0.1.1

CRAN release: 2026-03-13

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
