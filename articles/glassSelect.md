# Single-Select Dropdown with glasstabs

## Overview

[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
is an animated single-select dropdown for Shiny.

It behaves like a standard Shiny input: `input$<inputId>` stores the
selected value as a single character string, or `NULL` when nothing is
selected.

It supports:

- optional labels
- search and clear controls
- built-in dark and light themes
- custom theming with
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
- selectable marker styles via `check_style`
- server-side updates with
  [`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)

## Basic usage

``` r
library(shiny)
library(glasstabs)

fruits <- c(
  Apple  = "apple",
  Banana = "banana",
  Cherry = "cherry",
  Mango  = "mango"
)

ui <- fluidPage(
  useGlassTabs(),
  glassSelect("pick", fruits),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)
}

shinyApp(ui, server)
```

## Initial selection

``` r
# No selection (default)
glassSelect("f", fruits)

# Pre-select one value
glassSelect("f", fruits, selected = "banana")
```

## Optional label

``` r
glassSelect("f", fruits, label = "Choose a fruit")
```

## Selection styles

[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
supports three selection marker styles:

- `"checkbox"` (default)
- `"check-only"`
- `"filled"`

``` r
glassSelect("f1", fruits, check_style = "checkbox")
glassSelect("f2", fruits, check_style = "check-only")
glassSelect("f3", fruits, check_style = "filled")
```

## Searchable and clearable

Search is enabled by default. You can also enable a clear control.

``` r
glassSelect(
  "f",
  fruits,
  searchable = TRUE,
  clearable = TRUE
)
```

To hide the search box:

``` r
glassSelect(
  "f",
  fruits,
  searchable = FALSE
)
```

## Explicit “All” option

You can prepend an explicit “All” option:

``` r
glassSelect(
  "f",
  fruits,
  include_all = TRUE,
  all_choice_label = "All fruits",
  all_choice_value = "__all__"
)
```

This is useful when you want the UI to distinguish between: - no
selection - a deliberate “All” selection

## Server-side access

Read the current value directly from `input$<inputId>`:

``` r
server <- function(input, output, session) {
  observe({
  message("Selected: ", if (is.null(input$pick)) "NULL" else input$pick)
})
}
```

## Reactive helper

If you want a small convenience wrapper, use
[`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md):

``` r
server <- function(input, output, session) {
  pick <- glassSelectValue(input, "pick")

  observe({
    print(pick())
  })
}
```

## Updating choices and selection from the server

[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)
can update: - available choices - current selection - selection marker
style

``` r
observeEvent(input$filled, {
  updateGlassSelect(
    session,
    "pick",
    check_style = "filled"
  )
})
```

It follows Shiny-style update semantics:

- `choices = NULL` leaves choices unchanged
- `selected = NULL` leaves selection unchanged
- `selected = character(0)` clears the selection

``` r
ui <- fluidPage(
  useGlassTabs(),
  actionButton("subset", "Keep first 2 fruits"),
  actionButton("banana", "Select banana"),
  actionButton("clear", "Clear"),
  actionButton("filled", "Use filled style"),
  glassSelect("pick", fruits, clearable = TRUE),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)

  observeEvent(input$subset, {
    updateGlassSelect(
      session,
      "pick",
      choices = fruits[1:2]
    )
  })

  observeEvent(input$banana, {
    updateGlassSelect(
      session,
      "pick",
      selected = "banana"
    )
  })

  observeEvent(input$clear, {
    updateGlassSelect(
      session,
      "pick",
      selected = character(0)
    )
  })
}

shinyApp(ui, server)
```

When `choices` is updated without `selected`, the widget keeps the
current value if it still exists in the new set of choices.

## Theming

### Built-in presets

``` r
glassSelect("f", fruits, theme = "dark")
glassSelect("f", fruits, theme = "light")
```

### Custom theme with `glass_select_theme()`

``` r
glassSelect(
  "f",
  fruits,
  theme = glass_select_theme(
    mode = "dark",
    accent_color = "#f59e0b"
  )
)

glassSelect(
  "f",
  fruits,
  theme = glass_select_theme(
    bg_color = "#1a0a2e",
    border_color = "#a855f7",
    text_color = "#ede9fe",
    accent_color = "#a855f7"
  )
)


#other themes
glassSelect(
  "f",
  fruits,
  theme = glass_select_theme(
    mode = "light",
    accent_color = "#2563eb"
  )
)

#more themes
glassSelect(
  "f",
  fruits,
  theme = glass_select_theme(
    mode = "light",
    bg_color = "#ffffff",
    border_color = "rgba(0,0,0,0.15)",
    text_color = "#111111",
    accent_color = "#111111",
    label_color = "#111111"
  )
)
```

## Standalone usage

[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
can be used without the tab widget. You only need
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
to load the package CSS and JavaScript assets:

``` r
ui <- fluidPage(
  useGlassTabs(),
  glassSelect("region", c(North = "North", South = "South", East = "East")),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$region)
}

shinyApp(ui, server)
```
