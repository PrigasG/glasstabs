# Render a reactive glass tab UI

Server-side render function that pairs with
[`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md).
The expression should return a
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
call. After each render the glasstabs JavaScript engine is automatically
reinitialised so animations and event handlers are correctly attached to
the new DOM nodes.

## Usage

``` r
renderGlassTabs(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- expr:

  An expression that returns a
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  tag object.

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Logical. Whether `expr` is already quoted.

## Value

A render function suitable for assigning to an `output` slot.

## See also

Other glass tabs:
[`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md),
[`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md),
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md),
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md),
[`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md),
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md),
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md),
[`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
[`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md),
[`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    useGlassTabs(),
    radioButtons("theme", "Theme", c("dark", "light"), inline = TRUE),
    glassTabsOutput("tabs_out")
  )

  server <- function(input, output, session) {
    output$tabs_out <- renderGlassTabs({
      glassTabsUI(
        "themed",
        glassTabPanel("x", "X", selected = TRUE, p("X content")),
        glassTabPanel("y", "Y", p("Y content")),
        theme = input$theme
      )
    })
  }

  shinyApp(ui, server)
}
```
