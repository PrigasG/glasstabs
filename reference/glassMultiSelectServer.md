# Register server-side search for a glassMultiSelect widget

Use this with `glassMultiSelect(..., server = TRUE)` when the choice set
is large. The browser sends search queries to Shiny and the server
returns a bounded list of matching choices.

## Usage

``` r
glassMultiSelectServer(
  inputId,
  choices,
  session = shiny::getDefaultReactiveDomain(),
  limit = 50L,
  ignore_case = TRUE
)
```

## Arguments

- inputId:

  Input id used in
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md).

- choices:

  Named or unnamed character vector of choices.

- session:

  Shiny session. Defaults to the current reactive domain.

- limit:

  Maximum number of matching choices returned per search. Default `50`.

- ignore_case:

  Logical. Match labels and values case-insensitively. Default `TRUE`.

## Value

An observer created by
[`shiny::observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html).

## See also

Other glass select widgets:
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md),
[`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md),
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
[`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md),
[`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md),
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md),
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)

## Examples

``` r
if (interactive()) {
  library(shiny)

  choices <- stats::setNames(
    sprintf("value-%04d", 1:1000),
    sprintf("Choice %04d", 1:1000)
  )

  ui <- fluidPage(
    useGlassTabs(),
    glassMultiSelect("pick", choices, server = TRUE)
  )

  server <- function(input, output, session) {
    glassMultiSelectServer("pick", choices, session = session)
  }

  shinyApp(ui, server)
}
```
