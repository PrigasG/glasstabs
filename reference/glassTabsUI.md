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
  `.gt-compact` CSS modifier — useful inside dashboard cards or tight
  layouts (e.g. bs4Dash).

- shape:

  Corner style for the tab bar and content. One of `"rounded"` (default)
  for the signature glass look, or `"square"` for crisp, selectize-style
  corners that match
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  and
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  when `shape = "square"`.

- extra_ui:

  Optional additional UI placed to the right of the tab bar.

- theme:

  One of `"dark"`, `"light"`, or a
  [`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
  object.

- dark_selector:

  Optional CSS selector for a parent element that signals dark mode
  (e.g. `"body.dark-mode"` for bs4Dash, `"[data-bs-theme=dark]"` for
  Bootstrap 5). When provided and `theme = "light"`, a second scoped
  `<style>` block overrides the CSS variables back to the dark-mode
  defaults whenever that selector is active — so the tabs stay readable
  after a dark-mode toggle without any server-side intervention.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
ready to use in a Shiny UI.
