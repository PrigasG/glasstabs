# Animated Tabs with glasstabs

## Overview

[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
provides an animated glass-morphism tab navigation bar for Shiny. The
active tab is tracked by a sliding glass halo with spring easing, and a
luminous transfer trace sweeps across intermediate tabs during
navigation.

## Basic usage

Three functions work together:

- [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
  — injects the CSS and JS once, anywhere in the page UI
- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  — renders the full tab bar and content area
- [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  — defines one tab button and its associated content pane

``` r
library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI("nav",
    glassTabPanel("overview", "Overview", selected = TRUE,
      h3("Overview"),
      p("This pane is shown first.")
    ),
    glassTabPanel("details", "Details",
      h3("Details"),
      p("Switch to this tab using the button above.")
    ),
    glassTabPanel("settings", "Settings",
      h3("Settings"),
      p("A third tab.")
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
```

## Reading the active tab in the server

The active tab value is pushed to Shiny automatically on every click via
`Shiny.setInputValue`. Access it as `input[["<id>-active_tab"]]`:

``` r
server <- function(input, output, session) {
  observe({
    req(input[["nav-active_tab"]])
    message("Active tab: ", input[["nav-active_tab"]])
  })

  # Or use the convenience wrapper
  active <- glassTabsServer("nav")
  observe(message("Active: ", active()))
}
```

## Keyboard navigation

Arrow keys move between tabs when focus is inside the widget — no extra
code needed.

## Placing a filter widget beside the tabs

Pass any UI element to `extra_ui` to place it to the right of the tab
bar. The most common use is a
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
filter:

``` r
choices <- c(Alpha = "alpha", Beta = "beta", Gamma = "gamma")

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI("nav",
    extra_ui = glassMultiSelect("cat", choices, show_style_switcher = FALSE),
    glassTabPanel("a", "Tab A", selected = TRUE,
      p("Content A"),
      glassFilterTags("cat")   # tag pills synced to the filter
    ),
    glassTabPanel("b", "Tab B",
      p("Content B"),
      glassFilterTags("cat")
    )
  )
)
```

## Theming

### Built-in presets

``` r
# Dark (default)
glassTabsUI("nav", theme = "dark", ...)

# Light — suits white page backgrounds and bs4Dash cards
glassTabsUI("nav", theme = "light", ...)
```

### Custom theme with `glass_tab_theme()`

Supply only the values you want to change — everything else falls back
to the dark preset:

``` r
# Change only the halo colour
glassTabsUI("nav",
  theme = glass_tab_theme(
    halo_bg         = "rgba(251,191,36,0.18)",
    halo_border     = "rgba(251,191,36,0.40)",
    tab_active_text = "#fef3c7"
  ),
  glassTabPanel("a", "Tab", selected = TRUE, p("Content"))
)
```

All eight handles available in
[`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md):

| Argument          | What it controls             |
|-------------------|------------------------------|
| `tab_text`        | Inactive tab label colour    |
| `tab_active_text` | Active tab label colour      |
| `halo_bg`         | Sliding glass halo fill      |
| `halo_border`     | Sliding glass halo border    |
| `content_bg`      | Tab content panel background |
| `content_border`  | Tab content panel border     |
| `card_bg`         | Inner card background        |
| `card_text`       | Inner card text colour       |

## bs4Dash integration

Set `wrap = FALSE` when embedding inside a `bs4Card` or `bs4Box` — the
card body already provides a constrained container. Pair with
`theme = "light"` to match the card’s white background:

``` r
library(bs4Dash)
library(glasstabs)

ui <- bs4DashPage(
  header  = bs4DashNavbar(title = "My App"),
  sidebar = bs4DashSidebar(disable = TRUE),
  body    = bs4DashBody(
    useGlassTabs(),
    bs4Card(
      title = "Analysis", width = 12,
      glassTabsUI("dash",
        wrap     = FALSE,
        theme    = "light",
        extra_ui = glassMultiSelect("f", choices, theme = "light",
                                    show_style_switcher = FALSE),
        glassTabPanel("a", "Overview", selected = TRUE, p("Overview content")),
        glassTabPanel("b", "Details",  p("Detail content"))
      )
    )
  )
)
```

## Multiple tab widgets on one page

Each
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
instance is scoped to its own `id`, so multiple widgets work fully
independently:

``` r
ui <- fluidPage(
  useGlassTabs(),    # only needed once per page
  glassTabsUI("widget1",
    glassTabPanel("a", "One-A", selected = TRUE, p("Widget 1, pane A")),
    glassTabPanel("b", "One-B", p("Widget 1, pane B"))
  ),
  glassTabsUI("widget2",
    glassTabPanel("x", "Two-X", selected = TRUE, p("Widget 2, pane X")),
    glassTabPanel("y", "Two-Y", p("Widget 2, pane Y"))
  )
)

server <- function(input, output, session) {
  observe(message("Widget 1 active: ", input[["widget1-active_tab"]]))
  observe(message("Widget 2 active: ", input[["widget2-active_tab"]]))
}
```
