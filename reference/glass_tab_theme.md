# Create a custom color theme for glassTabsUI

All arguments accept any valid CSS color string (hex,
[`rgb()`](https://rdrr.io/r/grDevices/rgb.html), `rgba()`, named
colors). Pass only the fields you want to override — unset fields fall
back to the dark-mode defaults.

## Usage

``` r
glass_tab_theme(
  tab_text = NULL,
  tab_active_text = NULL,
  halo_bg = NULL,
  halo_border = NULL,
  content_bg = NULL,
  content_border = NULL,
  card_bg = NULL,
  card_text = NULL
)
```

## Arguments

- tab_text:

  Inactive tab text color.

- tab_active_text:

  Active tab text color (and headings inside cards).

- halo_bg:

  Background fill of the animated glass halo.

- halo_border:

  Border color of the glass halo.

- content_bg:

  Tab content area background.

- content_border:

  Tab content area border.

- card_bg:

  Inner `.gt-card` background.

- card_text:

  Inner `.gt-card` text color.

## Value

A named list of class `"glass_tab_theme"` for passing to the `theme`
argument of
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

## Examples

``` r
# Amber / warm accent on a dark base
amber <- glass_tab_theme(
  halo_bg         = "rgba(251, 191, 36, 0.15)",
  halo_border     = "rgba(251, 191, 36, 0.40)",
  tab_active_text = "#fef3c7"
)

if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI(
      "demo",
      glassTabPanel("a", "Alpha", selected = TRUE, p("Alpha content")),
      glassTabPanel("b", "Beta",  p("Beta content")),
      theme = amber
    )
  )
  server <- function(input, output, session) {}
  shinyApp(ui, server)
}
```
