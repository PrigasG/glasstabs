# Reactive helpers for glassMultiSelect values

Convenience helper for extracting a multi-select widget's value and
style from Shiny's `input` object without using modules.

## Usage

``` r
glassMultiSelectValue(input, inputId)
```

## Arguments

- input:

  Shiny `input` object.

- inputId:

  Input id used in
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).

## Value

A named list with two reactives:

- `selected`:

  Reactive character vector of selected values

- `style`:

  Reactive string for the active style

## See also

Other glass select widgets:
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md),
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md),
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
[`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md),
[`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md),
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md),
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)

## Examples

``` r
if (interactive()) {
  library(shiny)

  ui <- fluidPage(
    useGlassTabs(),
    glassMultiSelect("cats", c(A = "a", B = "b", C = "c"))
  )

  server <- function(input, output, session) {
    ms <- glassMultiSelectValue(input, "cats")
    observe({
      message("Selected: ", paste(ms$selected(), collapse = ", "))
      message("Style: ", ms$style())
    })
  }

  shinyApp(ui, server)
}
```
