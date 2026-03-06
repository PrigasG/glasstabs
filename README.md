# glasstabs <img src="man/figures/logo.png" align="right" height="120" />

> Animated glass-style tab navigation and multi-select filter for R Shiny

<!-- badges: start -->
[![R-CMD-check](https://github.com/YOUR_GITHUB_USERNAME/glasstabs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/glasstabs/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/glasstabs)](https://CRAN.R-project.org/package=glasstabs)
<!-- badges: end -->


---

## Installation

```r
# From CRAN
install.packages("glasstabs")

# From GitHub
pak::pak("YOUR_GITHUB_USERNAME/glasstabs")
devtools::install_github("YOUR_GITHUB_USERNAME/glasstabs")

# From source
devtools::install_local("path/to/glasstabs")
```

## Quick start

```r
library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),            # inject CSS + JS once
  glassTabsUI(
    id       = "main",
    extra_ui = glassMultiSelect("cat", c(A = "a", B = "b", C = "c")),

    glassTabPanel("t1", "Overview", selected = TRUE,
      h3("Overview"), p("Content here."), glassFilterTags("cat")
    ),
    glassTabPanel("t2", "Details",
      h3("Details"),  p("More content."),  glassFilterTags("cat")
    )
  )
)

server <- function(input, output, session) {
  observe({
    cat("Active tab:", input[["main-active_tab"]], "\n")
    cat("Selected:",   paste(input$cat, collapse=", "), "\n")
  })
}
shinyApp(ui, server)
```

---

## Functions

| Function | Description |
|---|---|
| `useGlassTabs()` | Inject CSS/JS dependency — call once in UI |
| `glassTabsUI(id, ..., selected, wrap, extra_ui)` | Full tab bar + content area |
| `glassTabPanel(value, label, ..., selected)` | Define one tab + its content |
| `glassTabsServer(id)` | Returns reactive active tab value |
| `glassMultiSelect(inputId, choices, ...)` | Multi-select dropdown filter |
| `glassMultiSelectServer(inputId)` | Returns list of reactives: `selected`, `style` |
| `glassFilterTags(inputId)` | Tag-pill display area tied to a multiselect |
| `glass_tab_theme(...)` | Custom color theme for `glassTabsUI()` |
| `glass_select_theme(...)` | Custom color theme for `glassMultiSelect()` |

---

## Shiny inputs

| Input | Type | Description |
|---|---|---|
| `input[["<id>-active_tab"]]` | character | Currently active tab value |
| `input$<inputId>` | character vector | Selected filter values |
| `input$<inputId>_style` | character | Active checkbox style |

## Theming

Both widgets expose a parallel theme API — supply only the values you want to change, everything else falls back to the dark preset.

```r
# Tab widget
glassTabsUI("nav", theme = glass_tab_theme(
  halo_bg         = "rgba(251,191,36,0.15)",
  tab_active_text = "#fef3c7"
))

# Multi-select dropdown
glassMultiSelect("filter", choices, theme = glass_select_theme(
  accent_color = "#f59e0b"
))

# Built-in light preset for both
glassTabsUI("nav",    theme = "light", ...)
glassMultiSelect("f", theme = "light", ...)
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
| `accent_color` | Ticks, badge, checked states, Clear all |


## Checkbox styles

The `glassMultiSelect()` dropdown includes a built-in style switcher:

| Style | Appearance |
|---|---|
| `"checkbox"` | Ghost box with animated tick (default) |
| `"check-only"` | Tick only, no box |
| `"filled"` | Solid box in each option's unique hue |

```r
glassMultiSelect("f", choices, check_style = "filled", show_style_switcher = FALSE)
```

Hues auto-distribute around the color wheel or can be set manually via the `hues` argument.



## bs4Dash compatibility

Pass `wrap = FALSE` to `glassTabsUI()` when embedding inside a bs4Dash card or box — the card already provides the containing element.

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

Multiple `glassTabsUI()` + `glassMultiSelect()` widgets on the same page work independently — each is scoped by its `id`.

---

## Roadmap

- [ ] `glassTabsUpdate()` server function to change active tab programmatically  
- [ ] Theming via CSS custom properties (`--gt-halo-color`, `--gt-bg`, etc.)  
- [ ] `glassMultiSelectUpdate()` to update choices from the server  


# License

MIT

## Full Example App

A complete working example is included in the documentation site. 
