# Show or hide a glass tab

`showGlassTab()` makes a hidden tab visible again. `hideGlassTab()`
hides a tab from the navigation bar. If the hidden tab is currently
active, the first remaining visible tab is activated automatically.

## Usage

``` r
showGlassTab(session, id, value)

hideGlassTab(session, id, value)
```

## Arguments

- session:

  Shiny session object.

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

- value:

  Value of the tab to show or hide.

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
      glassTabPanel("b", "B", p("Tab B")),
      glassTabPanel("admin", "Admin", p("Admin only"))
    ),
    checkboxInput("is_admin", "Admin mode", FALSE)
  )
  server <- function(input, output, session) {
    observeEvent(input$is_admin, {
      if (input$is_admin) showGlassTab(session, "tabs", "admin")
      else                hideGlassTab(session, "tabs", "admin")
    }, ignoreInit = FALSE)
  }
  shinyApp(ui, server)
}
```
