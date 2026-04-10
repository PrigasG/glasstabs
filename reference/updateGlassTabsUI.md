# Programmatically switch the active glass tab

Server-side equivalent of Shiny's
[`updateTabsetPanel()`](https://rdrr.io/pkg/shiny/man/updateTabsetPanel.html).
Sends a message to the browser to animate the tab switch just as if the
user had clicked the tab button.

## Usage

``` r
updateGlassTabsUI(session, id, selected)
```

## Arguments

- session:

  Shiny session object.

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

- selected:

  Value of the tab to activate.

## Value

Called for its side effect; returns `NULL` invisibly.

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
    ),
    actionButton("go", "Go to B")
  )
  server <- function(input, output, session) {
    observeEvent(input$go, {
      updateGlassTabsUI(session, "tabs", selected = "b")
    })
  }
  shinyApp(ui, server)
}
```
