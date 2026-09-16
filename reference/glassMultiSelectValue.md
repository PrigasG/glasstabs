# Reactive helpers for glassMultiSelect values

Convenience helper for extracting a multi-select widget's value and
style from Shiny's `input` object without using modules.

## Usage

``` r
glassMultiSelectValue(
  input,
  inputId,
  choices = NULL,
  empty_behavior = c("none", "all", "null")
)
```

## Arguments

- input:

  Shiny `input` object.

- inputId:

  Input id used in
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).

- choices:

  Optional choices used to resolve an empty selection when
  `empty_behavior = "all"`. This may be a static choice object or a
  zero-argument reactive/function that returns choices.

- empty_behavior:

  Meaning of an empty selection for `resolved`: `"none"` keeps
  `character(0)`, `"all"` returns every choice value, and `"null"`
  returns `NULL`. The raw `selected` reactive is never changed.

## Value

A named list with four reactives:

- `selected`:

  Reactive character vector of selected values

- `resolved`:

  Reactive value after applying empty behavior

- `is_empty`:

  Reactive logical indicating an empty selection

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
