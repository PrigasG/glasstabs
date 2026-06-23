# Multi-Select Filter with glasstabs

## Overview

[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
is an animated multi-select dropdown for Shiny. It can be used inside a
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
layout or completely on its own in any Shiny page.

The widget behaves like a standard Shiny input: `input$<inputId>` stores
the selected values, and `input$<inputId>_style` stores the active
indicator style.

It also supports server-side updates with
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md).

## Basic usage

``` r

library(shiny)
library(glasstabs)

fruits <- c(Apple = "apple", 
            Banana = "banana", 
            Cherry = "cherry",
            Mango  = "mango", 
            Peach  = "peach")

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("pick", fruits),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)
}

if (interactive()) shinyApp(ui, server)
```

## Shiny inputs produced

| Input                   | Type             | Value                     |
|-------------------------|------------------|---------------------------|
| `input$<inputId>`       | character vector | Currently selected values |
| `input$<inputId>_style` | character        | Active checkbox style     |

## Initial selection

``` r

# All selected (default)
glassMultiSelect("f", fruits)

# Subset pre-selected
glassMultiSelect("f", fruits, selected = c("apple", "cherry"))

# Nothing pre-selected
glassMultiSelect("f", fruits, selected = character(0))
```

## Checkbox styles

Three indicator styles are available via `check_style`:

``` r

# Bordered box + animated tick (default)
glassMultiSelect("f", fruits, check_style = "checkbox")

# Tick only — minimal, no box border
glassMultiSelect("f", fruits, check_style = "check-only")

# Solid coloured box — each option gets its own hue
glassMultiSelect("f", fruits, check_style = "filled")
```

By default, a style switcher row is shown inside the dropdown so the
user can change the style at runtime. Hide it with
`show_style_switcher = FALSE`:

``` r

glassMultiSelect("f", fruits,
  check_style         = "check-only",
  show_style_switcher = FALSE          # lock the style silently
)
```

### Custom hues for the filled style

When `check_style = "filled"`, hues are auto-assigned evenly around the
colour wheel. Override them with a named integer vector of HSL hue
angles (0-360):

``` r

glassMultiSelect("f", fruits,
  check_style = "filled",
  hues = c(apple = 0, banana = 50, cherry = 340, mango = 30, peach = 20)
)
```

## Corner shape

By default the trigger and dropdown use the signature rounded glass
corners. Pass `shape = "square"` for crisp, selectize-style corners so
the widget blends into layouts built around native
[`selectizeInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html)
controls:

``` r

# Rounded (default)
glassMultiSelect("filters_rounded", fruits, shape = "rounded")

# Square - matches selectizeInput()
glassMultiSelect("filters_square", fruits, shape = "square")
```

The shape can also be switched at runtime from the server with
`updateGlassMultiSelect(session, "filters_square", shape = "square")`.
The `runGlassExample("square-corners")` app shows the square shape next
to native selectize.

## Width, grouped choices, and disabled options

Like native
[`selectizeInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html),
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
accepts a `width`, grouped choices as a named list, and disabled state:

``` r

# Fixed / fluid width
glassMultiSelect("filters_w", fruits, width = "100%")

# Grouped choices (selectInput()-style named list)
glassMultiSelect("food", list(
  Fruit = c(Apple = "apple", Banana = "banana"),
  Veg   = c(Carrot = "carrot", Pea = "pea")
))

# Disable the whole widget, or specific options
glassMultiSelect("filters_d", fruits, disabled = TRUE)
glassMultiSelect("filters_dc", fruits, disabled_choices = "banana")
```

`disabled_choices` are skipped by “Select all”, and both can be toggled
at runtime with
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md).

## Show / hide UI chrome

All three interactive chrome elements can be toggled independently.
Defaults are all `TRUE`:

``` r

glassMultiSelect("f", fruits,
  show_style_switcher = FALSE,   # hide the Check / Box / Fill row
  show_select_all     = FALSE,   # hide the "Select all" row
  show_clear_all      = FALSE    # hide the "Clear all" footer link
)
```

## Filter tag pills with `glassFilterTags()`

Place a
[`glassFilterTags()`](https://prigasg.github.io/glasstabs/reference/glassFilterTags.md)
container anywhere on the page to show the active selections as
removable tag pills. The JS engine keeps them in sync automatically -
clicking x on a tag deselects that option.

``` r

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("cat", fruits, show_style_switcher = FALSE),
  glassFilterTags("cat")    # can be placed anywhere, even in a different tab pane
)
```

You can place multiple `glassFilterTags("cat")` containers for the same
filter — all will stay in sync.

## Server-side access

Read the selection directly from `input$<inputId>` and the style from
`input$<inputId>_style`:

``` r

server <- function(input, output, session) {

  # Direct access
  observe({
    message("Selected: ", paste(input$pick, collapse = ", "))
    message("Style: ",    input$pick_style)
  })
}
```

## Reactive helper

If you want a small convenience wrapper, use
[`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md):

``` r

server <- function(input, output, session) {
  ms <- glassMultiSelectValue(input, "pick")

  observe({
    message("Selected: ", paste(ms$selected(), collapse = ", "))
    message("Style: ", ms$style())
  })
}
```

## Server-side search for large choice sets

For large filters, set `server = TRUE` in the UI and register
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
in the server function. The control keeps the selected values on the
client while rendering only the current page of matching choices.

``` r

many_choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect(
    "pick",
    many_choices,
    server = TRUE,
    server_limit = 30,
    show_style_switcher = FALSE
  ),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  glassMultiSelectServer("pick", many_choices, session = session, limit = 30)
  output$out <- renderPrint(length(input$pick))
}

if (interactive()) shinyApp(ui, server)
```

This pattern is also suitable for controls inserted by
[`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html). Register
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
once for the same `inputId`, and the newly rendered control will receive
search results through Shiny.

## Updating choices and selection from the server

[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md)
can update: - available choices - current selection - active style

It follows Shiny-style update semantics:

- `choices = NULL` leaves choices unchanged
- `selected = NULL` leaves selection unchanged
- `selected = character(0)` clears the selection

``` r

ui <- fluidPage(
  useGlassTabs(),
  actionButton("subset", "Keep first 3 fruits"),
  actionButton("pick2", "Select 2 fruits"),
  actionButton("clear", "Clear"),
  actionButton("fill", "Switch to filled style"),
  glassMultiSelect("pick", fruits),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)

  observeEvent(input$subset, {
    updateGlassMultiSelect(
      session,
      "pick",
      choices = fruits[1:3]
    )
  })

  observeEvent(input$pick2, {
    updateGlassMultiSelect(
      session,
      "pick",
      selected = c("apple", "cherry")
    )
  })

  observeEvent(input$clear, {
    updateGlassMultiSelect(
      session,
      "pick",
      selected = character(0)
    )
  })

  observeEvent(input$fill, {
    updateGlassMultiSelect(
      session,
      "pick",
      check_style = "filled"
    )
  })
}

if (interactive()) shinyApp(ui, server)
```

When `choices` is updated without `selected`, the widget keeps the
intersection of the current selection and the new choice set.

## Theming

### Built-in presets

``` r

glassMultiSelect("f", fruits, theme = "dark")   # default
glassMultiSelect("f", fruits, theme = "light")  # white panel, dark text
```

### Custom theme with `glass_select_theme()`

Supply only the colors you want to change:

``` r

# One field — accent colour only
glassMultiSelect("f", fruits,
  theme = glass_select_theme(accent_color = "#f59e0b")
)

# Two fields
glassMultiSelect("f", fruits,
  theme = glass_select_theme(
    text_color   = "#1e293b",
    accent_color = "#2563eb"
  )
)

# All four fields
glassMultiSelect("f", fruits,
  theme = glass_select_theme(
    bg_color     = "#1a0a2e",
    border_color = "#a855f7",
    text_color   = "#ede9fe",
    accent_color = "#a855f7"
  )
)
```

| Argument       | What it controls                                      |
|----------------|-------------------------------------------------------|
| `bg_color`     | Dropdown panel and trigger button background          |
| `border_color` | Border colour                                         |
| `text_color`   | Main text and label colour                            |
| `accent_color` | Tick marks, badge, checked highlights, Clear all link |

## Standalone usage — no tabs required

[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
is fully independent of the tab widget. You only need
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
for the CSS and JS:

``` r

library(shiny)
library(glasstabs)

sales <- data.frame(
  region  = c("North","North","South","South","East","West"),
  product = c("Alpha","Beta","Alpha","Gamma","Beta","Alpha"),
  revenue = c(42000, 31000, 27000, 55000, 38000, 61000)
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("region",  c(North="North", South="South",
                                East="East",   West="West"),
                   show_style_switcher = FALSE),
  glassMultiSelect("product", c(Alpha="Alpha", Beta="Beta", Gamma="Gamma"),
                   show_style_switcher = FALSE,
                   check_style = "check-only"),
  glassFilterTags("region"),
  glassFilterTags("product"),
  tableOutput("tbl")
)

server <- function(input, output, session) {
  filtered <- reactive({
    sales[sales$region  %in% (input$region  %||% unique(sales$region)) &
          sales$product %in% (input$product %||% unique(sales$product)), ]
  })
  output$tbl <- renderTable(filtered())
}

if (interactive()) shinyApp(ui, server)
```

## Multiple dropdowns on one page

Each
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
is scoped to its own `inputId` and works independently. When one
dropdown is open it automatically floats above all others:

``` r

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("a", c(X = "x", Y = "y", Z = "z")),
  glassMultiSelect("b", c(P = "p", Q = "q", R = "r"),
                   check_style = "filled",
                   show_style_switcher = FALSE)
)
```
