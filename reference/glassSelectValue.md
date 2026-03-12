# Reactive helper for glassSelect values

Convenience helper for extracting a single-select widget's value from
Shiny's `input` object without using modules.

## Usage

``` r
glassSelectValue(input, inputId)
```

## Arguments

- input:

  Shiny `input` object.

- inputId:

  Input id used in
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md).

## Value

A reactive expression returning the current selected value as a
character scalar, or `NULL` when nothing is selected.

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    useGlassTabs(),
    glassSelect("fruit", c(Apple = "apple", Banana = "banana"))
  )

  server <- function(input, output, session) {
    fruit <- glassSelectValue(input, "fruit")
    observe({
      print(fruit())
    })
  }

  shinyApp(ui, server)
}
```
