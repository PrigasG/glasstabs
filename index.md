# glasstabs

------------------------------------------------------------------------

editor_options: markdown: wrap: 72 —

> Animated tabs and select inputs that feel at home in a Shiny app.

glasstabs gives Shiny apps polished navigation and filtering without
asking you to write custom JavaScript or CSS. The package includes:

- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  for animated horizontal or vertical tab navigation
- [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  for a searchable single-select input
- [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  for multi-select filters with optional tag pills

The widgets work in a regular
[`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html), a `bslib`
app, or a `bs4Dash` dashboard. Each one can use a dark, light,
automatic, or custom colour theme.

## Installation

Install the CRAN release:

``` r

install.packages("glasstabs")
```

Or install the development version from GitHub:

``` r

pak::pak("prigasG/glasstabs")
```

## A complete app

Call
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
once in the UI, then compose the widgets like ordinary Shiny controls.
This app places a filter beside two tabs and displays the current tab
and selection.

``` r

library(shiny)
library(glasstabs)

choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "main",
    glassTabPanel(
      "overview", "Overview", selected = TRUE,
      h3("Fruit summary"),
      glassFilterTags("fruit")
    ),
    glassTabPanel(
      "details", "Details",
      h3("Selection details"),
      verbatimTextOutput("selection")
    ),
    extra_ui = glassMultiSelect(
      "fruit",
      choices,
      show_style_switcher = FALSE
    )
  ),
  verbatimTextOutput("active_tab")
)

server <- function(input, output, session) {
  active_tab <- glassTabsServer("main")

  output$active_tab <- renderPrint(active_tab())
  output$selection <- renderPrint(input$fruit)
}

if (interactive()) {
  shinyApp(ui, server)
}
```

[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
selects every choice by default. Use `selected = character(0)` when the
filter should start empty.

## Pick the control you need

Tabs are made from
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
objects. The first selected panel is shown when the app opens.

``` r

glassTabsUI(
  "reports",
  glassTabPanel("summary", "Summary", selected = TRUE, summary_ui),
  glassTabPanel("table", "Table", tableOutput("results")),
  glassTabPanel("notes", "Notes", textAreaInput("notes", NULL))
)
```

A single-select behaves like a standard Shiny input. Its value is
available at `input$region`.

``` r

glassSelect(
  "region",
  c(North = "north", South = "south", East = "east", West = "west"),
  label = "Region",
  clearable = TRUE
)
```

A multi-select returns a character vector and can display the selected
values as tag pills anywhere in the UI.

``` r

glassMultiSelect(
  "status",
  c(Open = "open", Review = "review", Closed = "closed"),
  selected = c("open", "review"),
  label = "Status"
)

glassFilterTags("status")
```

## Match the surrounding app

Use `theme = "auto"` in Bootstrap 5 or `bslib` apps so the widgets
follow the page’s light and dark modes. Use `shape = "square"` when the
controls sit next to native Shiny inputs.

``` r

glassTabsUI(
  "nav",
  glassTabPanel("one", "One", selected = TRUE, p("First panel")),
  glassTabPanel("two", "Two", p("Second panel")),
  indicator = "underline",
  theme = "auto"
)

glassSelect("region", choices, shape = "square", theme = "auto")
glassMultiSelect("filters", choices, shape = "square", theme = "auto")
```

Tabs also support a vertical rail and three indicator styles:

``` r

glassTabsUI(
  "workflow",
  glassTabPanel("intake", "Intake", selected = TRUE, intake_ui),
  glassTabPanel("review", "Review", review_ui),
  glassTabPanel("approve", "Approve", approve_ui),
  orientation = "vertical",
  indicator = "solid",
  tab_align = "left"
)
```

## Tabs that fit the screen

Long tab bars stay on one line and scroll on smaller screens. The active
tab comes back into view after a click, keyboard change, swipe, or
server update.

``` r

glassTabsUI(
  "reports",
  glassTabPanel("summary", "Summary", selected = TRUE, summary_ui),
  glassTabPanel("activity", "Recent activity", activity_ui),
  glassTabPanel("quality", "Data quality", quality_ui),
  glassTabPanel("settings", "Team settings", settings_ui),
  overflow = "scroll"
)
```

`overflow = "wrap"` keeps every label visible on as many rows as needed.
`overflow = "menu"` replaces the strip with a compact native chooser.
Touch swipes are available with `swipe = TRUE`; they start only on
ordinary panel content, leaving inputs, plots, maps, and horizontally
scrolling tables alone.

Keyboard focus follows the selected tab. Arrow keys move between
available tabs, while Home and End jump to the first and last. Motion is
shortened when the device asks for reduced motion, and solid colors take
over when glass blur is unavailable.

## An experimental fillable page

[`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
is a small wrapper around
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).
It loads the package assets automatically and starts with Bootstrap 5.
The wrapper is experimental during the 0.4.x cycle; regular Shiny and
bslib pages remain fully supported.

``` r

ui <- glassPage(
  title = "Team review",
  glassTabsUI(
    "review",
    glassTabPanel("queue", "Queue", queue_ui),
    glassTabPanel("done", "Done", done_ui),
    theme = "auto"
  )
)
```

For a custom accent, change only the fields your app needs:

``` r

glassTabsUI(
  "nav",
  glassTabPanel("a", "A", selected = TRUE, p("Content")),
  glassTabPanel("b", "B", p("More content")),
  theme = glass_tab_theme(
    halo_bg = "rgba(37, 99, 235, 0.16)",
    halo_border = "#2563eb"
  )
)

glassSelect(
  "region",
  choices,
  theme = glass_select_theme(mode = "light", accent_color = "#2563eb")
)
```

Inside a `bs4Dash` card, `compact = TRUE` reduces spacing and
`wrap = FALSE` lets the card provide the outer container.

``` r

bs4Dash::box(
  width = 12,
  glasstabs::glassTabsUI(
    "dashboard",
    glassTabPanel("summary", "Summary", selected = TRUE, summary_ui),
    glassTabPanel("detail", "Detail", detail_ui),
    compact = TRUE,
    wrap = FALSE,
    theme = "light"
  )
)
```

## Read and update values

The widgets expose familiar Shiny inputs:

| Widget | Current value |
|----|----|
| `glassTabsUI("main", ...)` | `input[["main-active_tab"]]` |
| `glassSelect("region", ...)` | `input$region` |
| `glassMultiSelect("status", ...)` | `input$status` |
| An open select dropdown | `input$region_open` or `input$status_open` |

Server helpers cover common programmatic changes:

``` r

server <- function(input, output, session) {
  observeEvent(input$next_step, {
    updateGlassTabsUI(session, "workflow", selected = "review")
    updateGlassTabBadge(session, "workflow", "review", count = 3)
  })

  observeEvent(input$reset_filters, {
    updateGlassSelect(session, "region", selected = character(0))
    updateGlassMultiSelect(session, "status", selected = character(0))
  })
}
```

Use
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md)
when a regular
[`conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html)
should follow the active glass tab:

``` r

conditionalPanel(
  condition = glassTabCondition("main", "details"),
  p("This appears while the Details tab is active.")
)
```

## Large choice sets

For hundreds or thousands of choices, keep the full vector on the server
and send a small page of matches to the browser.

``` r

many_choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  glassSelect("item", many_choices, server = TRUE, server_limit = 30),
  glassMultiSelect("filters", many_choices, server = TRUE, server_limit = 30)
)

server <- function(input, output, session) {
  glassSelectServer("item", many_choices, session = session, limit = 30)
  glassMultiSelectServer("filters", many_choices, session = session, limit = 30)
}
```

## Function reference

### Setup

| Function | Description |
|----|----|
| [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md) | Inject package CSS and JavaScript—call once in the UI |
| `glassPage(...)` | Experimental fillable Bootstrap 5 page with glasstabs already loaded |
| `runGlassExample(example)` | Launch a built-in example app ([`runGlassExample()`](https://prigasg.github.io/glasstabs/reference/runGlassExample.md) lists all available apps) |
| [`glasstabs_news()`](https://prigasg.github.io/glasstabs/reference/glasstabs_news.md) | Print the package changelog to the R console |

Built-in examples include `basic`, `bs4dash`, `bslib`,
`connect-workflow`, `dashboard`, `indicators`, `server-select`,
`smoke-test`, and `square-corners`. The Connect workflow doubles as a
v0.4.0 test lab, with the responsive, keyboard, touch, dynamic-tab,
badge, theme, and page-wrapper checks collected in one app.

### Tab widget

| Function | Description |
|----|----|
| `glassTabsUI(id, ..., selected, wrap, compact, shape, indicator, orientation, tab_align, overflow, swipe, extra_ui, theme)` | Animated tab bar with responsive overflow and optional touch swipes |
| `glassTabPanel(value, label, ..., icon, selected)` | Define one tab and its content; `icon` accepts [`shiny::icon()`](https://rdrr.io/pkg/shiny/man/icon.html) |
| `glassTabsServer(id, bookmark)` | Reactive returning the active tab; can bookmark the active tab in the URL |
| `glassTabsOutput(outputId)` | UI placeholder for a server-rendered tab widget |
| `renderGlassTabs({expr})` | Render a [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md) reactively; JavaScript reinitialises automatically |
| `glassTabCondition(id, value)` | JavaScript condition string for [`conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html) |
| `updateGlassTabsUI(session, id, selected)` | Switch the active tab from the server |
| `updateGlassTabBadge(session, id, value, count)` | Set a numeric badge on a tab button (`0` hides it) |
| `showGlassTab(session, id, value)` | Show a hidden tab |
| `hideGlassTab(session, id, value)` | Hide a tab from the navigation bar |
| `disableGlassTab(session, id, value)` | Disable a tab while keeping it visible |
| `enableGlassTab(session, id, value)` | Re-enable a disabled tab |
| `appendGlassTab(session, id, tab, select)` | Add a new tab at runtime |
| `removeGlassTab(session, id, value)` | Remove a tab at runtime |
| `glass_tab_theme(...)` | Create a custom colour theme for [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md) |

### Select widgets

| Function | Description |
|----|----|
| `glassMultiSelect(inputId, choices, ...)` | Multi-select dropdown widget |
| `glassMultiSelectServer(inputId, choices, ...)` | Server-side search for large multi-select choice sets |
| `updateGlassMultiSelect(session, inputId, ...)` | Update multi-select choices, selection, or style |
| `glassMultiSelectValue(input, inputId)` | Reactive helpers for multi-select value and style |
| `glassSelect(inputId, choices, ...)` | Single-select dropdown widget |
| `glassSelectServer(inputId, choices, ...)` | Server-side search for large single-select choice sets |
| `updateGlassSelect(session, inputId, ...)` | Update single-select choices, selection, or style |
| `glassSelectValue(input, inputId)` | Reactive helper for the selected value |
| `closeGlassSelect(session, inputId)` | Close one open single-select dropdown |
| `closeGlassMultiSelect(session, inputId)` | Close one open multi-select dropdown |
| `closeAllGlassSelects(session)` | Close every open glasstabs select dropdown |
| `glassFilterTags(inputId)` | Tag-pill display area synced to a multi-select |
| `glass_select_theme(...)` | Create a custom theme for [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md) and [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md) |

## Shiny inputs

| Input | Type | Description |
|----|----|----|
| `input[["<id>-active_tab"]]` | `character` | Active tab value from [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md) |
| `input$<inputId>` | `character vector` | Selected values from [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md) |
| `input$<inputId>_style` | `character` | Active selection style from [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md) |
| `input$<inputId>_open` | `logical` | Whether a select dropdown is open |
| `input$<inputId>` | `character` or `NULL` | Selected value from [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md) |

## Documentation and support

The [glasstabs website](https://prigasg.github.io/glasstabs/) includes
focused articles and a searchable function reference. Release notes are
available in [`NEWS.md`](https://prigasg.github.io/glasstabs/NEWS.md) or
from R with
[`glasstabs_news()`](https://prigasg.github.io/glasstabs/reference/glasstabs_news.md).

If a widget does not fit naturally into your app, please open a [GitHub
issue](https://github.com/PrigasG/glasstabs/issues) with a small Shiny
example. Questions, bug reports, and ideas for making the package easier
to use are all welcome.
