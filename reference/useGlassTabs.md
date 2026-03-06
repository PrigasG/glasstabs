# Attach glasstabs CSS and JS dependencies

Call this once in your UI — either inside
[`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html),
`bs4DashPage()`, or any other Shiny page wrapper. It injects the
required CSS and JS as proper `htmltools` dependencies so they are
deduplicated automatically.

## Usage

``` r
useGlassTabs()
```

## Value

An
[`htmltools::htmlDependency`](https://rstudio.github.io/htmltools/reference/htmlDependency.html)
object (invisible to the user, consumed by Shiny's renderer).

## Examples

``` r
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI("demo",
      glassTabPanel("A", "Tab A", p("Content A")),
      glassTabPanel("B", "Tab B", p("Content B"))
    )
  )
  server <- function(input, output, session) {}
  shinyApp(ui, server)
}
```
