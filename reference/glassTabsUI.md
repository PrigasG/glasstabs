# Animated glass-style tab navigation UI

Animated glass-style tab navigation UI

## Usage

``` r
glassTabsUI(
  id,
  ...,
  selected = NULL,
  wrap = TRUE,
  compact = FALSE,
  shape = c("rounded", "square"),
  indicator = c("glass", "solid", "underline"),
  orientation = c("horizontal", "vertical"),
  tab_align = c("center", "left", "right"),
  text_align = c("center", "left", "right"),
  overflow = c("scroll", "multiline", "menu"),
  swipe = FALSE,
  extra_ui = NULL,
  theme = NULL,
  dark_selector = NULL
)
```

## Arguments

- id:

  Module namespace id.

- ...:

  One or more
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  objects.

- selected:

  Value of the initially selected tab.

- wrap:

  Logical. When `TRUE` wraps everything in a `div.gt-container`.

- compact:

  Logical. When `TRUE` applies reduced padding and spacing via the
  `.gt-compact` CSS modifier - useful inside dashboard cards or tight
  layouts (e.g. bs4Dash).

- shape:

  Corner style for the tab bar and content. One of `"rounded"` (default)
  for the signature glass look, or `"square"` for crisp, selectize-style
  corners that match
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  and
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  when `shape = "square"`.

- indicator:

  Style of the sliding active-tab indicator. One of:

  - `"glass"` (default) - the signature frosted-glass halo with backdrop
    blur, shimmer, and transfer particle.

  - `"solid"` - a flat, opaque sliding pill. No `backdrop-filter` or
    shimmer; lighter on the GPU and better suited to plain or
    enterprise-style dashboards. Colors still follow the theme's
    `halo_bg` / `halo_border`.

  - `"underline"` - a slim sliding bar under the active tab; tab buttons
    lose their pill background for a classic tabbed look. The bar color
    follows the theme's `halo_border`.

- orientation:

  One of `"horizontal"` (default) or `"vertical"`. In vertical mode the
  tab buttons stack in a left-hand rail and the content pane sits beside
  them. The sliding halo follows automatically, arrow-key navigation
  switches to Up/Down, and `indicator = "underline"` renders as a slim
  bar on the edge of the active tab adjacent to the content.

- tab_align:

  Alignment of the tab group within the available navigation area in
  either orientation. One of `"center"` (default), `"left"`, or
  `"right"`.

- text_align:

  Alignment of text and icons inside each tab button. One of `"center"`
  (default), `"left"`, or `"right"`.

- overflow:

  How the tab strip behaves when labels no longer fit. One of `"scroll"`
  (the default), `"multiline"`, or `"menu"`. Scroll mode keeps a single
  touch-friendly row and brings the active tab into view. Multiline mode
  allows more than one row. Menu mode uses a compact native chooser and
  is available only when `orientation = "horizontal"`.

- swipe:

  Whether a horizontal touch swipe over non-interactive panel content
  should move to the previous or next available tab. The default is
  `FALSE` so maps, plots, tables, and other interactive content keep
  their normal gestures.

- extra_ui:

  Optional additional UI placed to the right of the tab bar (below the
  tab rail when `orientation = "vertical"`).

- theme:

  One of `"dark"`, `"light"`, `"auto"`, or a
  [`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
  object. `"auto"` bridges to Bootstrap 5 / bslib color modes:
  light-theme variables apply by default and dark-theme variables apply
  whenever an ancestor carries `data-bs-theme="dark"` (e.g.
  [`bslib::toggle_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
  or `input_dark_mode()`), with the switch handled live in the browser -
  no server round-trip.

- dark_selector:

  Optional CSS selector for a parent element that signals dark mode
  (e.g. `"body.dark-mode"` for bs4Dash, `"[data-bs-theme=dark]"` for
  Bootstrap 5). When provided and `theme = "light"`, a second scoped
  `<style>` block overrides the CSS variables back to the dark-mode
  defaults whenever that selector is active - so the tabs stay readable
  after a dark-mode toggle without any server-side intervention.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
ready to use in a Shiny UI.

## See also

Other glass tabs:
[`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md),
[`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md),
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md),
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md),
[`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md),
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md),
[`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md),
[`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
[`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md),
[`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)
