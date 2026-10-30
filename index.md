# glasstabs

> Animated tabs and select inputs that feel at home in a Shiny app.

## Introduction

glasstabs gives Shiny apps polished navigation and filtering without
asking you to write custom JavaScript or CSS. It provides animated tab
navigation, a searchable single-select, and a multi-select filter, all
of which work in a regular
[`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html), a `bslib`
app, or a `bs4Dash` dashboard.

- [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
  for animated horizontal or vertical tab navigation
- [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  for a searchable single-select input
- [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  for multi-select filters with optional tag pills

## Installation

Install the CRAN release:

``` r

install.packages("glasstabs")
```

Install the development version from GitHub when you want changes that
are not yet available in the CRAN release:

``` r

pak::pak("PrigasG/glasstabs@main")
packageVersion("glasstabs")
```

Installing from GitHub replaces the installed copy on your machine. For
most people, the CRAN installation above is the simpler choice.

## Quick Start

Call
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
once at the UI root, then use the widgets like ordinary Shiny controls.
This minimal app is complete and runnable:

``` r

library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),
  glassSelect(
    "fruit",
    c(Apple = "apple", Banana = "banana", Cherry = "cherry"),
    label = "Fruit"
  ),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$fruit)
}

shinyApp(ui, server)
```

The selected value is available at `input$fruit` (`NULL` when nothing is
selected). Tabs and multi-selects follow the same pattern; see Main
Features below.

## Main Features

**Tabs.**
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
builds an animated tab bar from
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
objects. Long bars scroll on small screens (`overflow = "scroll"`, the
default), wrap onto rows (`"multiline"`), or collapse into a compact
chooser (`"menu"`). Vertical rails, touch swipes, and glass, solid, or
underline indicators are options, and arrow keys move between tabs with
Home and End jumping to the ends.

``` r

glassTabsUI(
  "reports",
  glassTabPanel("summary", "Summary", selected = TRUE, p("Summary content")),
  glassTabPanel("table", "Table", tableOutput("results")),
  glassTabPanel("notes", "Notes", textAreaInput("notes", NULL)),
  indicator = "underline",
  theme = "auto"
)
```

The active tab is available at `input[["reports-active_tab"]]`, and
`glassTabsServer("reports")` returns it as a reactive.

**Single-select.**
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
behaves like a standard Shiny input with search, an optional clear
button, and a panel that always matches the trigger width (long labels
wrap inside it). The panel unfurls from its field like a tongue:
attached flush, squared off at the join, and flipping above when there
is no room below. An empty-string value is an ordinary choice value,
distinct from clearing to `NULL`.

``` r

glassSelect(
  "region",
  c(North = "north", South = "south", East = "east", West = "west"),
  label = "Region",
  clearable = TRUE
)
```

**Multi-select.**
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
returns a character vector. By default every enabled choice starts
selected (`selected = NULL`); pass `selected = character(0)` for an
empty start. Selected values can show as tag pills anywhere in the UI,
and the built-in select-all row tracks all, some, or none with a
tri-state checkbox.

``` r

glassMultiSelect(
  "status",
  c(Open = "open", Review = "review", Closed = "closed"),
  selected = c("open", "review"),
  label = "Status"
)

glassFilterTags("status")
```

**Server-side search.** For hundreds or thousands of choices, keep the
full vector on the server and send a small bounded slice of matches to
the browser. The widget takes `server = TRUE` and a matching helper
answers each search:

``` r

library(shiny)
library(glasstabs)

many_choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  glassSelect(
    "item",
    many_choices,
    server = TRUE,
    server_limit = 30
  ),
  verbatimTextOutput("selected")
)

server <- function(input, output, session) {
  glassSelectServer(
    "item",
    many_choices,
    session = session,
    limit = 30
  )

  output$selected <- renderPrint(input$item)
}

shinyApp(ui, server)
```

[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
is the multi-select counterpart. Results are bounded, not paginated.

**Themes.** Every widget takes `theme = "dark"` (the default),
`"light"`, `"auto"` (follows the page’s Bootstrap signal), or a custom
theme object from
[`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
/
[`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md).
Dashboards with their own dark-mode toggle need `dark_selector` pointed
at that toggle’s marker.

**Keyboard and accessibility.** Dropdown options and their chrome rows
(style switcher, select-all, clear) form one wrapping keyboard cycle;
screen readers get labelled triggers, listbox roles, and tri-state
select-all. Motion shortens under reduced-motion preferences.

**Reading and updating values.** Updates are one transaction: existing
selections are kept when they still exist, and Shiny is notified only
when the effective value changes.

``` r

server <- function(input, output, session) {
  observeEvent(input$reset_filters, {
    updateGlassSelect(session, "region", selected = character(0))
    updateGlassMultiSelect(session, "status", selected = character(0))
  })
}
```

[`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
is an experimental fillable Bootstrap 5 page wrapper that loads the
package assets automatically; regular Shiny and bslib pages remain fully
supported.

## Customization

The options most apps reach for, with their defaults. The full argument
lists live in the function reference on the website.

Shared by both select widgets:

- `theme = "dark"` (`"light"`, `"auto"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object)
- `shape = "rounded"` (`"square"` sits better next to native inputs)
- `check_style = "checkbox"` (`"check-only"`, `"filled"`)
- `searchable = TRUE` (always show search; `"auto"` shows it only at
  `search_threshold = 15` choices, `FALSE` hides it)
- `width = NULL` (trigger width; uses a compact 160px default width; the
  panel always matches it)
- `tongue = TRUE` (attached unfurl animation; `FALSE` is a detached
  fade)
- `label_size = "14px"`, `label_bold = TRUE`,
  `search_focus_ring = FALSE`, `overflow_tooltip = "auto"`
- `server = FALSE`, `server_limit = 50`, `server_min_chars = 0`

Single-select only: `clearable = FALSE`, `include_all = FALSE` (All
value `"__all__"`), `placeholder = "Select an option"`.

Multi-select only: `show_select_all = TRUE`, `show_clear_all = TRUE`,
`show_style_switcher = TRUE`, `selection_display = "auto"` (`"count"`,
`"summary"`, `"labels"`), `selection_max_items = 2`,
`placeholder = "Filter by Category"`, `fill_colors = "single"`
(`"multi"` for per-choice hues).

Tabs: `style = "floating"` (`"attached"` docks the bar onto the content
box), `transition = "fade"` (`"slide"`), `indicator = "glass"`
(`"solid"`, `"underline"`), `orientation = "horizontal"` (`"vertical"`),
`overflow = "scroll"` (`"multiline"`, `"menu"`), `swipe = FALSE`,
`tab_align = "center"`, `text_align = "center"`, `compact = FALSE`,
`wrap = TRUE`.

## More Examples

The website holds the full guides:

- [Getting
  started](https://prigasg.github.io/glasstabs/articles/getting-started.html)
  — first app, all three widgets
- [Single-select
  guide](https://prigasg.github.io/glasstabs/articles/glassSelect.html)
  — one-value controls, server mode, updates
- [Multi-select
  guide](https://prigasg.github.io/glasstabs/articles/multiselect.html)
  — selection semantics, summaries, search, linked filters
- [Tabs](https://prigasg.github.io/glasstabs/articles/tabs.html) and
  [indicators](https://prigasg.github.io/glasstabs/articles/indicators.html)
  — navigation, overflow, badges
- [Shiny
  modules](https://prigasg.github.io/glasstabs/articles/modules.html)
  and [linked
  filters](https://prigasg.github.io/glasstabs/articles/linked-filters.html)
  — recipes for real apps
- [Migrating from native Shiny
  controls](https://prigasg.github.io/glasstabs/articles/migrating.html)
  — before-and-after conversions
- [Responsive design and
  accessibility](https://prigasg.github.io/glasstabs/articles/responsive-accessibility.html)
  — keyboard, screen readers, small screens
- [Troubleshooting](https://prigasg.github.io/glasstabs/articles/troubleshooting.html)
  — the full issue list
- [Example
  gallery](https://prigasg.github.io/glasstabs/articles/examples-gallery.html)
  — every built-in demo
- [Posit Connect
  deployment](https://prigasg.github.io/glasstabs/articles/posit-connect.html)
  — versions, assets, CSP
- [Cheatsheet](https://prigasg.github.io/glasstabs/articles/cheatsheet.html)
  — the one-page reference

Built-in demos, launched with
[`runGlassExample()`](https://prigasg.github.io/glasstabs/reference/runGlassExample.md):
`basic`, `bs4dash`, `bslib`, `connect-workflow`, `dashboard`,
`indicators`, `light-mode`, `native-comparison`, `server-select`,
`smoke-test`, `square-corners`, `stress-test`, `theme-switcher`. The
`native-comparison` demo places native Shiny and glasstabs fields side
by side; `theme-switcher` flips every select between dark and light with
one switch.

## Troubleshooting

Short answers; the [troubleshooting
guide](https://prigasg.github.io/glasstabs/articles/troubleshooting.html)
has the full entries.

- **Dropdown looks unstyled.** The CSS and JavaScript never loaded: call
  [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
  exactly once at the UI root, not inside
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) or a
  module UI.
  ([`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
  loads it automatically.)
- **Server search never returns results.** Register the helper in the
  server function, once per input ID, with the same ID as the widget:
  [`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md)
  for single-select,
  [`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
  for multi-select. In a module, pass the module session and the bare
  ID, not the namespaced one.
- **Multi-select starts with everything checked.** That is the default,
  not a bug: `selected = NULL` selects every enabled choice. Pass
  `selected = character(0)` for an empty start.
- **Clearing shows all records.** The widget returns `character(0)` on
  clear; if the app treats empty as “no filter,” that choice must be
  deliberate. Use `glassMultiSelectValue(..., empty_behavior = "all")` /
  `"none"` to resolve empty consistently.
- **Selection disappears after a choices update.** The value is absent
  from the new set: multi-select drops it when `drop_invalid = TRUE`
  (the default) and keeps it when `FALSE`; single-select clears a
  vanished selection to `NULL` with no knob. Set the policy explicitly.
- **Dropdown is too narrow.** The panel matches the trigger by design:
  widen the trigger with `width` (for example `"100%"` inside a wide
  container) and check the parent column or card, which caps the trigger
  first.
- **Theme differs from the dashboard.** Use `theme = "auto"`, plus
  `dark_selector` pointed at the dashboard’s dark-mode marker when the
  dashboard has its own toggle.
- **Server update misses a module control.** Module server code takes
  the bare ID (`"region"`), not `ns("region")` — a namespaced ID
  addresses a nonexistent input, silently.
- **Dropdown closes when a modal opens.** By design: open dropdowns
  close rather than stranding above a full-screen overlay. Close
  deliberately first with
  [`closeAllGlassSelects()`](https://prigasg.github.io/glasstabs/reference/closeGlassSelect.md)
  (or
  [`closeGlassSelect()`](https://prigasg.github.io/glasstabs/reference/closeGlassSelect.md)
  /
  [`closeGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/closeGlassSelect.md)
  for one widget) if the close looks abrupt.
- **Widget unstyled or unbound after
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html).** Keep
  [`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
  at the root and server registration in the server function (not inside
  the render), and re-apply the intended selection after the rebuild — a
  rebuilt widget starts from its UI arguments.

Release notes are in
[`NEWS.md`](https://prigasg.github.io/glasstabs/NEWS.md) or from R with
[`glasstabs_news()`](https://prigasg.github.io/glasstabs/reference/glasstabs_news.md).
If a widget does not fit naturally into your app, please open a [GitHub
issue](https://github.com/PrigasG/glasstabs/issues) with a small Shiny
example.
