# Indicator Styles, Vertical Tabs, and Auto Theming

## Overview

[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
renders its active-tab indicator in three styles, controlled by the
`indicator` argument:

| Value | Look | When to use |
|----|----|----|
| `"glass"` (default) | Frosted-glass halo with backdrop blur, shimmer, and a transfer particle | The signature look; dark, image, or gradient backgrounds |
| `"solid"` | Flat, opaque sliding pill | Plain or enterprise dashboards; lighter on the GPU (no `backdrop-filter`) |
| `"underline"` | Slim sliding bar under the active tab | Classic tabbed look; dense layouts |

All three animate identically - the same spring easing moves the
indicator between tabs. Only the rendering changes.

## Side by side

``` r

library(shiny)
library(glasstabs)

demo_tabs <- function(id, indicator) {
  glassTabsUI(
    id,
    glassTabPanel("overview", "Overview", p("Overview content")),
    glassTabPanel("data",     "Data",     p("Data content")),
    glassTabPanel("settings", "Settings", p("Settings content")),
    indicator = indicator,
    compact   = TRUE
  )
}

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style("body{background:#0f172a;color:#e2e8f0;}")),
  h4("indicator = \"glass\""),     demo_tabs("g",  "glass"),
  h4("indicator = \"solid\""),     demo_tabs("s",  "solid"),
  h4("indicator = \"underline\""), demo_tabs("u",  "underline")
)

server <- function(input, output, session) {}
shinyApp(ui, server)
```

The indicator colors always follow the active theme: `halo_bg` /
`halo_border` from
[`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
drive the glass halo and the solid pill, and `halo_border` drives the
underline bar. A custom theme therefore restyles every indicator variant
with no extra work:

``` r

amber <- glass_tab_theme(
  halo_bg     = "rgba(251, 191, 36, 0.18)",
  halo_border = "rgba(251, 191, 36, 0.65)"
)

glassTabsUI("amber_demo",
  glassTabPanel("a", "Alpha", p("...")),
  glassTabPanel("b", "Beta",  p("...")),
  indicator = "underline",   # amber bar
  theme     = amber
)
```

## Vertical orientation

`orientation = "vertical"` stacks the tab buttons in a left-hand rail
with the content pane beside them. Arrow-key navigation switches to
Up/Down, and `indicator = "underline"` renders as a slim bar on the edge
of the active tab adjacent to the content:

``` r

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "side",
    glassTabPanel("inbox",   "Inbox",   p("Inbox content")),
    glassTabPanel("sent",    "Sent",    p("Sent content")),
    glassTabPanel("archive", "Archive", p("Archive content")),
    orientation = "vertical",
    indicator   = "underline"
  )
)
```

On screens narrower than 600px the rail stacks back above the content
automatically.

## Auto theming with bslib

`theme = "auto"` bridges to Bootstrap 5 color modes. Light-theme
variables apply by default, and dark-theme variables take over whenever
an ancestor carries `data-bs-theme="dark"` - which is exactly what
[`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
and
[`bslib::toggle_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
set. The switch happens live in the browser with no server round-trip:

``` r

library(bslib)

ui <- page_fluid(
  theme = bs_theme(version = 5),
  useGlassTabs(),
  input_dark_mode(id = "mode"),
  glassTabsUI(
    "auto_demo",
    glassTabPanel("a", "Alpha", p("Toggle dark mode above - the tabs follow.")),
    glassTabPanel("b", "Beta",  p("No server code needed.")),
    theme = "auto"
  )
)

server <- function(input, output, session) {}
shinyApp(ui, server)
```

For non-bslib dark-mode implementations (e.g. bs4Dash), keep using the
`dark_selector` argument with your framework’s dark-mode selector:

``` r

glassTabsUI("bs4",
  glassTabPanel("a", "Alpha", p("...")),
  theme = "light",
  dark_selector = "body.dark-mode"
)
```

## Try it

The package ships a runnable demo of everything on this page:

``` r

glasstabs::runGlassExample("indicators")
```
