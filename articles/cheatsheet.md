# glasstabs Cheatsheet

## One rule

Call
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
once somewhere in your UI before using any widget.

``` r
ui <- fluidPage(
  useGlassTabs(),
  # widgets go here
)
```

## Tabs: basic pattern

``` r
ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "main",
    glassTabPanel("overview", "Overview", selected = TRUE, h3("Overview")),
    glassTabPanel("details", "Details", h3("Details"))
  )
)

server <- function(input, output, session) {
  active_tab <- glassTabsServer("main")
}
```

## Tabs: server actions

``` r
# Switch active tab
updateGlassTabsUI(session, "main", "details")

# Hide or show a tab
hideGlassTab(session, "main", "admin")
showGlassTab(session, "main", "admin")

# Append or remove a tab at runtime
appendGlassTab(
  session, "main",
  glassTabPanel("compare", "Compare", h3("Compare")),
  select = TRUE
)
removeGlassTab(session, "main", "compare")
```

## Tabs: common options

``` r
glassTabsUI(
  "main",
  glassTabPanel("a", "A", selected = TRUE, p("A")),
  glassTabPanel("b", "B", p("B")),
  selected = "a",
  wrap = TRUE,
  extra_ui = tags$div("Right side UI"),
  theme = "light"
)
```

## Multi-select: basic pattern

``` r
choices <- c(Revenue = "revenue", Orders = "orders", Returns = "returns")

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("metric", choices),
  glassFilterTags("metric")
)

server <- function(input, output, session) {
  metric <- glassMultiSelectValue(input, "metric")
}
```

## Multi-select: update from server

``` r
updateGlassMultiSelect(
  session,
  "metric",
  selected = c("revenue", "orders"),
  check_style = "filled"
)

# Clear selection
updateGlassMultiSelect(session, "metric", selected = character(0))
```

## Multi-select: useful arguments

``` r
glassMultiSelect(
  "metric",
  choices,
  selected = unname(choices),
  label = "Metrics",
  placeholder = "Choose metrics",
  all_label = "All metrics",
  check_style = "checkbox",
  show_style_switcher = TRUE,
  show_select_all = TRUE,
  show_clear_all = TRUE,
  theme = "dark"
)
```

## Single-select: basic pattern

``` r
regions <- c("All Regions" = "all", North = "north", South = "south")

ui <- fluidPage(
  useGlassTabs(),
  glassSelect("region", regions, selected = "all")
)

server <- function(input, output, session) {
  region <- glassSelectValue(input, "region")
}
```

## Single-select: update from server

``` r
updateGlassSelect(session, "region", selected = "south")

# Clear value
updateGlassSelect(session, "region", selected = character(0))
```

## Single-select: useful arguments

``` r
glassSelect(
  "region",
  regions,
  selected = "all",
  label = "Region",
  placeholder = "Pick a region",
  searchable = TRUE,
  clearable = TRUE,
  include_all = FALSE,
  check_style = "checkbox",
  theme = "light"
)
```

## Theme helpers

``` r
# Tabs
glassTabsUI(
  "main",
  glassTabPanel("a", "A", selected = TRUE, p("A")),
  theme = glass_tab_theme(
    halo_bg = "rgba(251,191,36,0.15)",
    tab_active_text = "#fef3c7"
  )
)

# Select widgets
glassMultiSelect(
  "metric", choices,
  theme = glass_select_theme(
    mode = "dark",
    accent_color = "#38bdf8"
  )
)
```

## Input values at a glance

| Widget                            | Server value                                                             |
|-----------------------------------|--------------------------------------------------------------------------|
| `glassTabsUI("main", ...)`        | `input[["main-active_tab"]]` or `glassTabsServer("main")()`              |
| `glassMultiSelect("metric", ...)` | `input$metric` or `glassMultiSelectValue(input, "metric")$selected()`    |
| multi-select style                | `input$metric_style` or `glassMultiSelectValue(input, "metric")$style()` |
| `glassSelect("region", ...)`      | `input$region` or `glassSelectValue(input, "region")()`                  |

## Common gotchas

- [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
  must be called once in the UI.
- [`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md)
  returns a reactive function, not a list.
- [`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md)
  returns a list with `selected()` and `style()`.
- For
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md),
  `selected` should use choice values, not labels.
- If you add new JS/CSS behavior during development, reinstall or
  `load_all()` before retesting.
