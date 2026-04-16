# Build a conditionalPanel condition for a glasstabs widget

Returns a JavaScript condition string that evaluates to `TRUE` when the
specified glasstabs widget has a given active tab. Pass the result
directly to the `condition` argument of
[`shiny::conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html).

## Usage

``` r
glassTabCondition(id, value)
```

## Arguments

- id:

  The `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).
  **Inside a Shiny module** use `ns("tabs")` here (same id you passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)),
  NOT the bare id you pass to
  [`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md).

- value:

  The tab value string (the `value` argument of the target
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md))
  that should trigger the condition.

## Value

A single character string for use in
[`shiny::conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html).

## Examples

``` r
# Basic usage in a plain Shiny app:
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI(
      "main",
      glassTabPanel("overview", "Overview", selected = TRUE,
        p("Always visible.")),
      glassTabPanel("details", "Details",
        p("Detail pane."))
    ),
    conditionalPanel(
      condition = glassTabCondition("main", "details"),
      wellPanel("This panel only shows on the Details tab.")
    )
  )
  server <- function(input, output, session) {}
  shinyApp(ui, server)
}

# Inside a module — use ns() for the id:
# UI:   glassTabCondition(ns("tabs"), "details")
# This produces: "input['mymod-tabs-active_tab'] === 'details'"
```
