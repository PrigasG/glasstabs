# Disable or enable a glass tab

`disableGlassTab()` grays out a tab and prevents the user from clicking
it without removing it from the navigation bar. `enableGlassTab()`
reverses this. Unlike
[`hideGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
a disabled tab remains visible.

## Usage

``` r
disableGlassTab(session, id, value)

enableGlassTab(session, id, value)
```

## Arguments

- session:

  Shiny session object.

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

- value:

  Value of the tab to disable or enable.

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
      glassTabPanel("locked", "Locked", p("Locked content"))
    ),
    checkboxInput("unlocked", "Unlock tab", FALSE)
  )
  server <- function(input, output, session) {
    # Start with "locked" tab disabled
    observe({
      if (input$unlocked) enableGlassTab(session, "tabs", "locked")
      else                disableGlassTab(session, "tabs", "locked")
    })
  }
  shinyApp(ui, server)
}
```
