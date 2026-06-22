# Register server-side search for a glassSelect widget

Use this with `glassSelect(..., server = TRUE)` when the choice set is
large. The browser sends search queries to Shiny and the server returns
a bounded list of matching choices.

## Usage

``` r
glassSelectServer(
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
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md).

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
    glassSelect("pick", choices, server = TRUE)
  )

  server <- function(input, output, session) {
    glassSelectServer("pick", choices, session = session)
  }

  shinyApp(ui, server)
}
```
