# Server logic for glass tabs

Tracks the active tab and exposes it as a reactive value. Optionally
integrates with Shiny's bookmarking system so the active tab is
preserved in bookmarked URLs.

## Usage

``` r
glassTabsServer(id, bookmark = TRUE)
```

## Arguments

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).
  Do **not** wrap this in `ns()` — `glassTabsServer()` handles
  namespacing internally via
  [`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html).

- bookmark:

  Logical. When `TRUE` (default), registers
  [`shiny::onBookmark()`](https://rdrr.io/pkg/shiny/man/onBookmark.html)
  and
  [`shiny::onRestored()`](https://rdrr.io/pkg/shiny/man/onBookmark.html)
  hooks so the active tab is saved and restored automatically when Shiny
  bookmarking is enabled. Set to `FALSE` to opt out.

## Value

A reactive expression returning the active tab value.

## Details

`glassTabsServer()` follows the same calling convention as all Shiny
module server functions: pass the **bare** module id, not a namespaced
one. Inside a parent module, pair it with `glassTabsUI(ns("tabs"), ...)`
in the UI, and call `glassTabsServer("tabs")` (without `ns()`) in the
server.

## Examples

``` r
# --- Standalone app ---
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI(
      "tabs",
      glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
      glassTabPanel("b", "B", p("Tab B"))
    )
  )
  server <- function(input, output, session) {
    active <- glassTabsServer("tabs")
    observe(print(active()))
  }
  shinyApp(ui, server)
}

# --- Bookmarking ---
if (interactive()) {
  library(shiny)
  ui <- function(request) {
    fluidPage(
      useGlassTabs(),
      bookmarkButton(),
      glassTabsUI(
        "tabs",
        glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
        glassTabPanel("b", "B", p("Tab B"))
      )
    )
  }
  server <- function(input, output, session) {
    active <- glassTabsServer("tabs", bookmark = TRUE)
  }
  shinyApp(ui, server, enableBookmarking = "url")
}

# --- Inside a Shiny module ---
# UI side: use ns() to namespace the widget id
my_module_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    useGlassTabs(),
    glassTabsUI(
      ns("tabs"),                          # <-- ns() wraps the id here
      glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
      glassTabPanel("b", "B", p("Tab B"))
    )
  )
}

# Server side: pass the bare id — NOT ns("tabs")
my_module_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    active <- glassTabsServer("tabs")     # <-- bare id, no ns()
    shiny::observe(print(active()))
  })
}
```
