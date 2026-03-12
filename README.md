# glasstabs <img src="man/figures/logo.svg" align="right" height="120" />

> Animated glass-morphism tab navigation and multi-select filter widgets for R Shiny

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/glasstabs)](https://CRAN.R-project.org/package=glasstabs)
[![R-CMD-check](https://github.com/prigasG/glasstabs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/prigasG/glasstabs/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

---

## Overview

**glasstabs** provides two Shiny widgets built around a glass-morphism aesthetic:

- **`glassTabsUI()`** — an animated tab bar with a sliding glass halo that follows the active tab
- **`glassMultiSelect()`** — a dropdown filter with three checkbox styles, live search, and auto-syncing tag pills, and server-side update support
- **`glassSelect()`**: an animated single-select dropdown with optional search, clear support, and server-side update support


Both widgets are self-contained, fully themeable, and work in plain `fluidPage()`, `bs4DashPage()`, or any other Shiny page wrapper.

**Full documentation:** <https://prigasg.github.io/glasstabs/>

---

## Installation

```r
# From CRAN
install.packages("glasstabs")

# From GitHub (development version)
pak::pak("prigasG/glasstabs")
# or
devtools::install_github("prigasG/glasstabs")
```

---

## Quick start

```r
library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "main",
    glassTabPanel(
      "t1", "Overview", selected = TRUE,
      h3("Overview"),
      p("Content here."),
      glassFilterTags("cat")
    ),
    glassTabPanel(
      "t2", "Details",
      h3("Details"),
      p("More content."),
      glassFilterTags("cat")
    ),
    extra_ui = glassMultiSelect(
      "cat",
      c(A = "a", B = "b", C = "c"),
      show_style_switcher = FALSE
    )
  ),
  verbatimTextOutput("info")
)

server <- function(input, output, session) {
  tabs <- glassTabsServer("main")
  filt <- glassMultiSelectValue(input, "cat")

  output$info <- renderPrint({
    list(
      active_tab = tabs(),
      selected = filt$selected(),
      style = filt$style()
    )
  })
}

shinyApp(ui, server)
```

> **Note:** `useGlassTabs()` must be called once somewhere in the UI before any `glassTabsUI()` or `glassMultiSelect()` call. It injects the shared CSS and JavaScript as a properly deduplicated `htmltools` dependency.

---

## Function reference

| Function | Description |
|---|---|
| `useGlassTabs()` | Inject CSS/JS — call once in UI |
| `glassTabsUI(id, ..., selected, wrap, extra_ui, theme)` | Animated tab bar with content area |
| `glassTabPanel(value, label, ..., selected)` | Define one tab and its content |
| `glassTabsServer(id)` | Reactive returning the active tab value |
| `glassMultiSelect(inputId, choices, ...)` | Multi-select dropdown filter |
| `updateGlassMultiSelect(session, inputId, ...)` | Update multiselect choices, selection, or style |
| `glassSelect(inputId, choices, ...)`	| Single-select dropdown |
| `updateGlassSelect(session, inputId, ...)` |	Update single-select choices or selection |
| `glassSelectValue(input, inputId)`	| Reactive helper for selected value |
| `glassFilterTags(inputId)` | Tag-pill display area synced to a multiselect |
| `glass_tab_theme(...)` | Custom color theme for `glassTabsUI()` |
| `glass_select_theme(...)` | Custom color theme for `glassMultiSelect()` |

---

## Shiny inputs

| Input | Type | Description |
|---|---|---|
| `input[["<id>-active_tab"]]` | `character` | Currently active tab value |
| `input$<inputId>` | `character vector` | Selected filter values |
| `input$<inputId>_style` | `character` | Active checkbox style |

---


## Mult-select example

```r
library(shiny)
library(glasstabs)

choices <- c(
  Apple  = "apple",
  Banana = "banana",
  Cherry = "cherry"
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("fruit", choices),
  glassFilterTags("fruit"),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$fruit)
}

shinyApp(ui, server)
```

> **Note:** By default, `glassMultiSelect()` starts with all choices selected.

## Server-side updates

```r
server <- function(input, output, session) {
  observeEvent(input$clear, {
    updateGlassMultiSelect(
      session,
      "fruit",
      selected = character(0)
    )
  })

  observeEvent(input$fill_style, {
    updateGlassMultiSelect(
      session,
      "fruit",
      check_style = "filled"
    )
  })
}

```

---

## Single-select example

```r
library(shiny)
library(glasstabs)

choices <- c(
  North = "north",
  South = "south",
  East  = "east",
  West  = "west"
)

ui <- fluidPage(
  useGlassTabs(),
  glassSelect("region", choices, clearable = TRUE),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$region)
}

shinyApp(ui, server)
```

## Server-side updates

```r
server <- function(input, output, session) {
  observeEvent(input$pick_south, {
    updateGlassSelect(
      session,
      "region",
      selected = "south"
    )
  })

  observeEvent(input$clear_region, {
    updateGlassSelect(
      session,
      "region",
      selected = character(0)
    )
  })
}
```

---

## Theming

All widgets default to "dark". Switch to "light" or supply a custom
theme object.

```r
# Tab widget
glassTabsUI("nav",
  glassTabPanel("a", "A", selected = TRUE, p("Content")),
  theme = glass_tab_theme(
    halo_bg = "rgba(251,191,36,0.15)",
    tab_active_text = "#fef3c7"
  )
)

# Multi-select
glassMultiSelect("filter", choices,
  theme = glass_select_theme(accent_color = "#f59e0b")
)

# Single-select
glassSelect("region", choices,
  theme = glass_select_theme(accent_color = "#2563eb")
)

# Built-in light preset
glassTabsUI("nav", theme = "light", ...)
glassMultiSelect("f", choices, theme = "light", ...)
glassSelect("s", choices, theme = "light", ...)
```

### `glass_tab_theme()` handles

| Argument | Controls |
|---|---|
| `tab_text` | Inactive tab label color |
| `tab_active_text` | Active tab label color |
| `halo_bg` | Sliding glass halo fill |
| `halo_border` | Sliding glass halo border |
| `content_bg` | Tab content panel background |
| `content_border` | Tab content panel border |
| `card_bg` | Inner card background |
| `card_text` | Inner card text color |

### `glass_select_theme()` handles

| Argument | Controls |
|---|---|
| `bg_color` | Dropdown panel and trigger background |
| `border_color` | Border color |
| `text_color` | Main text color |
| `accent_color` | Ticks, badge, checked states, "Clear all" link |

---

## Checkbox styles

`glassMultiSelect()` ships with three checkbox indicator styles, switchable via a built-in UI or locked via `check_style`:

| Style | Appearance |
|---|---|
| `"checkbox"` | Ghost box with animated tick (default) |
| `"check-only"` | Tick only, no box |
| `"filled"` | Solid colored box, unique hue per option |

```r
# Lock to filled style, hide the switcher
glassMultiSelect("f", choices,
  check_style         = "filled",
  show_style_switcher = FALSE
)
```

Hues distribute automatically around the color wheel or can be set manually:

```r
glassMultiSelect("f", c(Apple = "apple", Banana = "banana", Cherry = "cherry"),
  check_style = "filled",
  hues = c(apple = 10L, banana = 50L, cherry = 340L)
)
```

---

## bs4Dash compatibility

Pass `wrap = FALSE` when embedding inside a bs4Dash card.

```r
bs4Card(
  glassTabsUI("dash",
    wrap     = FALSE,
    theme    = "light",
    extra_ui = glassMultiSelect("f", choices, theme = "light"),
    glassTabPanel("a", "Overview", selected = TRUE, p("Content")),
    glassTabPanel("b", "Details",  p("More"))
  )
)
```

---

## Multiple instances

Multiple `glassTabsUI()` and `glassMultiSelect()` widgets on the same page work independently — each is scoped by its `id`, so CSS variables and JS event handlers never bleed across instances.

---

## Articles

Full vignettes are available on the documentation site:

| Article | Description |
|---|---|
| [Getting started](https://prigasg.github.io/glasstabs/articles/getting-started.html) | Progressive walkthrough of both widgets |
| [Animated tabs](https://prigasg.github.io/glasstabs/articles/tabs.html) | Full `glassTabsUI()` reference with theming and bs4Dash |
| [Multi-select filter](https://prigasg.github.io/glasstabs/articles/multiselect.html) | Full `glassMultiSelect()` reference with styles, tags and updates |
| [Single-select filter](https://prigasg.github.io/glasstabs/articles/glassSelect.html) | Full `glassSelect()` reference with search, clear, and updates |

---

## Roadmap

- Programmatic tab switching from the server

- Additional select widget presets and examples

- More layout examples for bs4Dash and standard Shiny apps

---

## License

MIT © glasstabs authors
