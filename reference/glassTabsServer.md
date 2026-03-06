# Server logic for glass tabs

Tracks the active tab and exposes it as a reactive value.

## Usage

``` r
glassTabsServer(id)
```

## Arguments

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

## Value

A reactive expression returning the active tab value.

## Examples

``` r
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI(
      "tabs",
      glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
      glassTabPanel("b", "B", p("Tab B"))
    )
  )
  server <- function(input, output, session) {
    active <- glassTabsServer("tabs")
    observe(print(active()))
  }
  shinyApp(ui, server)
}
```
