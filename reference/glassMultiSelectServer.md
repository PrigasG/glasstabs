# Server logic for glassMultiSelect

A convenience wrapper that exposes the widget's current state as typed
reactives. The underlying Shiny inputs are also available directly as
`input$<inputId>` and `input$<inputId>_style`.

## Usage

``` r
glassMultiSelectServer(inputId)
```

## Arguments

- inputId:

  The same `inputId` passed to
  [`glassMultiSelect`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).

## Value

A list with two elements:

- `selected`:

  Reactive character vector of currently selected values.

- `style`:

  Reactive string — the active checkbox style (`"checkbox"`,
  `"check-only"`, or `"filled"`).

## Examples

``` r
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassMultiSelect("cats", c(A = "a", B = "b", C = "c"))
  )
  server <- function(input, output, session) {
    ms <- glassMultiSelectServer("cats")
    observe(message("Selected: ", paste(ms$selected(), collapse = ", ")))
  }
  shinyApp(ui, server)
}
```
