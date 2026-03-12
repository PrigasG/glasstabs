# Create a custom color theme for glass select widgets

Create a custom color theme for glass select widgets

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

  Base theme preset. One of `"dark"` (default) or `"light"`. Custom
  colors are applied on top of this base mode.

- bg_color:

  Background color of the trigger button and dropdown panel.

- border_color:

  Border color.

- text_color:

  Main text color.

- accent_color:

  Accent color used for the animated tick, badge, checked-state
  highlights, and clear controls.

- label_color:

  Optional label color. If `NULL`, the label defaults to `text_color`.

## Value

A named list of class `"glass_select_theme"`.
