# Close open glass select dropdowns

Programmatically closes one
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
dropdown, one
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
dropdown, or every open glasstabs select dropdown in the current Shiny
session.

## Usage

``` r
closeGlassSelect(session = shiny::getDefaultReactiveDomain(), inputId)

closeGlassMultiSelect(session = shiny::getDefaultReactiveDomain(), inputId)

closeAllGlassSelects(session = shiny::getDefaultReactiveDomain())
```

## Arguments

- session:

  Shiny session. Defaults to the current reactive domain.

- inputId:

  Input id of the widget.

## Value

No return value. Called for the side effect of closing dropdowns in the
browser.

## Details

These helpers are useful before switching tabs, opening modals,
rebuilding UI, or changing layouts that can otherwise leave a dropdown
visually open after its trigger moved or disappeared.

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    useGlassTabs(),
    actionButton("close", "Close dropdowns"),
    glassSelect("region", c(North = "north", South = "south")),
    glassMultiSelect("filters", c(A = "a", B = "b"))
  )

  server <- function(input, output, session) {
    observeEvent(input$close, {
      closeAllGlassSelects(session)
    })
  }

  shinyApp(ui, server)
}
```
