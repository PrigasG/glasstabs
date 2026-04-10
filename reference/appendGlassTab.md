# Append or remove a glass tab at runtime

`appendGlassTab()` adds a new
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
to an existing
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
at runtime. `removeGlassTab()` removes a tab by value. If the removed
tab was active, the first remaining tab is activated.

## Usage

``` r
appendGlassTab(session, id, tab, select = FALSE)

removeGlassTab(session, id, value)
```

## Arguments

- session:

  Shiny session object.

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

- tab:

  A
  [`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
  object (for `appendGlassTab()` only).

- select:

  Logical. If `TRUE`, the new tab is immediately activated. Defaults to
  `FALSE`.

- value:

  Value of the tab to remove (for `removeGlassTab()` only).

## Value

Called for its side effect; returns `NULL` invisibly.

## Examples

``` r
if (interactive()) {
  library(shiny)
  ui <- fluidPage(
    useGlassTabs(),
    glassTabsUI(
      "tabs",
      glassTabPanel("home", "Home", p("Home content"), selected = TRUE)
    ),
    actionButton("add",    "Add tab"),
    actionButton("remove", "Remove tab")
  )
  server <- function(input, output, session) {
    observeEvent(input$add, {
      appendGlassTab(session, "tabs",
        glassTabPanel("new", "New Tab", p("Dynamic content")),
        select = TRUE
      )
    })
    observeEvent(input$remove, {
      removeGlassTab(session, "tabs", "new")
    })
  }
  shinyApp(ui, server)
}
```
