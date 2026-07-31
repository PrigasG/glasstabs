# Dynamic glass tab UI output

A drop-in replacement for
[`shiny::uiOutput()`](https://rdrr.io/pkg/shiny/man/htmlOutput.html)
that pairs with
[`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md).
It creates a placeholder `<div>` that Shiny fills with a fully reactive
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
when the server-side render function runs. The JavaScript engine is
automatically (re-)initialised after each render.

## Usage

``` r
glassTabsOutput(outputId, ...)
```

## Arguments

- outputId:

  The output id used in the paired
  [`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md)
  call.

- ...:

  Additional arguments forwarded to
  [`shiny::uiOutput()`](https://rdrr.io/pkg/shiny/man/htmlOutput.html).

## Value

A `shiny.tag` suitable for use in a Shiny UI.

## See also

Other glass tabs:
[`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md),
[`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md),
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md),
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md),
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md),
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md),
[`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md),
[`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
[`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md),
[`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)

## Examples

``` r
# Creates a UI placeholder tag - no Shiny session needed:
tabs_placeholder <- glassTabsOutput("my_tabs")

# Full dynamic-tab app example:
if (interactive()) {
  library(shiny)

  tab_data <- list(
    list(value = "a", label = "Alpha"),
    list(value = "b", label = "Beta"),
    list(value = "c", label = "Gamma")
  )

  ui <- fluidPage(
    useGlassTabs(),
    selectInput("n", "Show tabs", choices = 2:3, selected = 2),
    glassTabsOutput("dynamic_tabs")
  )

  server <- function(input, output, session) {
    output$dynamic_tabs <- renderGlassTabs({
      panels <- lapply(
        head(tab_data, as.integer(input$n)),
        function(t) glassTabPanel(t$value, t$label, p(t$label))
      )
      do.call(glassTabsUI, c(list("dyn"), panels))
    })
  }

  shinyApp(ui, server)
}
```
