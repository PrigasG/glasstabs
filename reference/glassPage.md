# Experimental fillable page for glasstabs apps

`glassPage()` is a small convenience wrapper around
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).
It adds
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
automatically and uses a Bootstrap 5 theme by default. The function is
experimental: its arguments may change during the 0.4.x development
cycle as it is used in more apps.

## Usage

``` r
glassPage(
  ...,
  title = NULL,
  theme = NULL,
  padding = NULL,
  gap = NULL,
  fillable_mobile = FALSE
)
```

## Arguments

- ...:

  UI elements placed on the page.

- title:

  Optional browser-window title.

- theme:

  A
  [`bslib::bs_theme()`](https://rstudio.github.io/bslib/reference/bs_theme.html)
  object. When `NULL`, a Bootstrap 5 theme is created for the page.

- padding:

  Optional page padding passed to
  [`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).

- gap:

  Optional spacing between page children passed to
  [`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).

- fillable_mobile:

  Whether the page should use fillable sizing on mobile browsers as well
  as desktop browsers.

## Value

A fillable Bootstrap 5 page containing the glasstabs dependency.

## Examples

``` r
if (interactive() && requireNamespace("bslib", quietly = TRUE)) {
  library(shiny)

  ui <- glassPage(
    title = "Team review",
    glassTabsUI(
      "review",
      glassTabPanel("queue", "Queue", p("Work waiting for review")),
      glassTabPanel("done", "Done", p("Completed work")),
      theme = "auto"
    )
  )

  shinyApp(ui, function(input, output, session) {})
}
```
