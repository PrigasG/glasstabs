# Animated glass-style tab navigation UI

Animated glass-style tab navigation UI

## Usage

``` r
glassTabsUI(
  id,
  ...,
  selected = NULL,
  wrap = TRUE,
  extra_ui = NULL,
  theme = NULL
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

- extra_ui:

  Optional additional UI placed to the right of the tab bar.

- theme:

  One of `"dark"`, `"light"`, or a
  [`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
  object.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
ready to use in a Shiny UI.
