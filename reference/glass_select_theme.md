# Create a custom color theme for glass select widgets

All color arguments accept any valid CSS color string (hex,
[`rgb()`](https://rdrr.io/r/grDevices/rgb.html), `rgba()`, named
colors). Unset fields inherit from the `mode` base preset.

## Usage

``` r
glass_select_theme(
  mode = c("dark", "light"),
  bg_color = NULL,
  border_color = NULL,
  text_color = NULL,
  accent_color = NULL,
  label_color = NULL
)
```

## Arguments

- mode:

  Base preset. One of `"dark"` (default) or `"light"`. Custom colors are
  layered on top.

- bg_color:

  Background of the trigger button and dropdown panel.

- border_color:

  Border color of the trigger and dropdown.

- text_color:

  Main text color for options and the trigger label.

- accent_color:

  Highlight color for checkmarks, badges, and selected states. Also used
  for the focus ring.

- label_color:

  Widget label color. Defaults to `text_color` when `NULL`.

## Value

A named list of class `"glass_select_theme"` for passing to the `theme`
argument of
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
or
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md).

## Examples

``` r
# Teal accent on a dark base
teal_theme <- glass_select_theme(
  mode         = "dark",
  accent_color = "#2dd4bf",
  bg_color     = "rgba(9, 20, 42, 0.97)"
)

# Light mode with a custom purple accent
purple_light <- glass_select_theme(
  mode         = "light",
  accent_color = "#7c3aed",
  border_color = "rgba(124, 58, 237, 0.35)"
)

if (interactive()) {
  library(shiny)
  choices <- c(Revenue = "rev", Orders = "ord", Returns = "ret")
  ui <- fluidPage(
    useGlassTabs(),
    glassMultiSelect("metric", choices, theme = teal_theme),
    glassSelect("region", c(All = "all", North = "n", South = "s"),
                theme = purple_light)
  )
  server <- function(input, output, session) {}
  shinyApp(ui, server)
}
```
