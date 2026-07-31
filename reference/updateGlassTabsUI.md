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

## See also

Other glass tabs:
[`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md),
[`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md),
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md),
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md),
[`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md),
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md),
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md),
[`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md),
[`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
[`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md)

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
