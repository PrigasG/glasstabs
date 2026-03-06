# Getting Started with glasstabs

## What is glasstabs?

glasstabs provides two animated Shiny widgets:

- **Tabs** — a glass-morphism tab navigation bar with a sliding halo,
  spring easing, and a luminous transfer trace between tabs
- **Multi-select filter** — a dropdown filter with animated checkboxes,
  live search, tag-pill display, and three checkbox styles

Both widgets work in plain
[`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html) and in
bs4Dash. They can be used together or completely independently.

------------------------------------------------------------------------

## Installation

``` r
# From CRAN (once available)
install.packages("glasstabs")

# From GitHub
pak::pak("YOUR_GITHUB_USERNAME/glasstabs")

# From source
devtools::install_local("path/to/glasstabs")
```

------------------------------------------------------------------------

## The one rule: call `useGlassTabs()` once

Every glasstabs app needs exactly one call to
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
somewhere in the UI. It injects the CSS and JavaScript as a proper
`htmltools` dependency — Shiny deduplicates it automatically so it is
safe to call inside helper functions too.

``` r
library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),   # <-- this is all you need
  # ... rest of your UI
)
```

------------------------------------------------------------------------

## Tab widget in 3 minutes

### Step 1 — define your tabs

Each
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
takes a unique `value`, a display `label`, and any UI content:

``` r
glassTabPanel("overview", "Overview", selected = TRUE,
  h3("Welcome"),
  p("This is the overview pane.")
)
```

### Step 2 — assemble with `glassTabsUI()`

Pass your panels to
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
along with a namespace `id`:

``` r
ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI("nav",
    glassTabPanel("overview", "Overview", selected = TRUE,
      shiny::h3("Welcome"),
      shiny::p("Start here.")
    ),
    glassTabPanel("analysis", "Analysis",
      shiny::h3("Analysis"),
      shiny::p("Your charts go here.")
    ),
    glassTabPanel("settings", "Settings",
      shiny::h3("Settings"),
      shiny::p("Configuration options.")
    )
  )
)
```

### Step 3 — read the active tab in the server

The active tab value is pushed to Shiny automatically on every click:

``` r
server <- function(input, output, session) {
  observe({
    req(input[["nav-active_tab"]])
    message("User is on: ", input[["nav-active_tab"]])
  })
}

shinyApp(ui, server)
```

------------------------------------------------------------------------

## Multi-select filter

### Step 1 — define choices and place the widget

``` r
choices <- c(Alpha = "alpha", Beta = "beta", Gamma = "gamma", Delta = "delta")

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("category", choices),
  verbatimTextOutput("selected")
)
```

### Step 2 — read the selection in the server

``` r
server <- function(input, output, session) {
  output$selected <- renderPrint(input$category)
}

shinyApp(ui, server)
```

`input$category` is always a plain character vector of the checked
values — use it like any other Shiny input to filter data, drive
outputs, or trigger reactives.

------------------------------------------------------------------------

## Using them together

The most common pattern is a filter in the tab bar driving content in
each pane. Pass the dropdown to `extra_ui` and place
[`glassFilterTags()`](https://prigasg.github.io/glasstabs/reference/glassFilterTags.md)
inside each pane to show the active selection as removable tag pills:

``` r
choices <- c(North = "north", South = "south", East = "east", West = "west")

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI("main",
    extra_ui = glassMultiSelect(
      inputId             = "region",
      choices             = choices,
      show_style_switcher = FALSE
    ),
    glassTabPanel("summary", "Summary", selected = TRUE,
      shiny::h3("Summary"),
      glassFilterTags("region"),        # tag pills appear here
      shiny::uiOutput("summary_text")
    ),
    glassTabPanel("detail", "Detail",
      shiny::h3("Detail"),
      glassFilterTags("region"),        # same filter, second pane
      shiny::tableOutput("detail_table")
    )
  )
)

server <- function(input, output, session) {

  selected_regions <- reactive({
    input$region %||% unique(unname(choices))
  })

  output$summary_text <- renderUI({
    shiny::p("Showing data for: ",
             shiny::strong(paste(selected_regions(), collapse = ", ")))
  })

  output$detail_table <- renderTable({
    data.frame(Region = selected_regions())
  })
}

shinyApp(ui, server)
```

------------------------------------------------------------------------

## Choosing a theme

Both widgets default to `"dark"`. Switch to `"light"` or supply a custom
theme object — in each case you only override what you need:

``` r
# Built-in light preset
glassTabsUI("nav",    theme = "light", ...)
glassMultiSelect("f", theme = "light", ...)

# Custom — one field each
glassTabsUI("nav",
  theme = glass_tab_theme(halo_bg = "rgba(251,191,36,0.15)"),
  ...
)

glassMultiSelect("f", choices,
  theme = glass_select_theme(accent_color = "#f59e0b")
)
```

------------------------------------------------------------------------

## bs4Dash

Add `wrap = FALSE` so the glass halo positions itself relative to the
card body rather than a full-page container. Pair with
`theme = "light"`:

``` r
library(bs4Dash)
library(glasstabs)

ui <- bs4DashPage(
  header  = bs4DashNavbar(title = "My App"),
  sidebar = bs4DashSidebar(disable = TRUE),
  body    = bs4DashBody(
    useGlassTabs(),
    bs4Card(
      title = "Analysis", width = 12,
      glassTabsUI("dash",
        wrap     = FALSE,
        theme    = "light",
        extra_ui = glassMultiSelect("f", choices,
                                    theme = "light",
                                    show_style_switcher = FALSE),
        glassTabPanel("a", "Overview", selected = TRUE,
          shiny::p("Overview content.")
        ),
        glassTabPanel("b", "Detail",
          shiny::p("Detail content.")
        )
      )
    )
  )
)

server <- function(input, output, session) {}
shinyApp(ui, server)
```

------------------------------------------------------------------------

## Next steps

- **[Animated
  Tabs](https://prigasg.github.io/glasstabs/articles/tabs.md)** — full
  reference for
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md):
  theming, keyboard nav, multiple instances, server patterns
- **[Multi-Select
  Filter](https://prigasg.github.io/glasstabs/articles/multiselect.md)**
  — full reference for
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md):
  checkbox styles, custom hues, tag pills, theming
- **Reference** — complete function documentation at
  [`help(package = "glasstabs")`](https://prigasg.github.io/glasstabs/reference)
