# Update the badge count on a glass tab

Adds or updates a small numeric badge on a tab button — useful for
surfacing counts such as unread items, pending rows, or notification
totals. Set `count` to `0` or `NA` to hide the badge.

## Usage

``` r
updateGlassTabBadge(session, id, value, count)
```

## Arguments

- session:

  Shiny session object.

- id:

  Module id matching the `id` passed to
  [`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

- value:

  Value of the tab to update.

- count:

  Integer count to display. Values above 99 are shown as `"99+"`. `0` or
  `NA` hides the badge.

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
      glassTabPanel("inbox",  "Inbox",  p("Messages here"), selected = TRUE),
      glassTabPanel("sent",   "Sent",   p("Sent items")),
      glassTabPanel("drafts", "Drafts", p("Draft items"))
    ),
    actionButton("refresh", "Refresh counts")
  )
  server <- function(input, output, session) {
    observeEvent(input$refresh, {
      updateGlassTabBadge(session, "tabs", "inbox",  count = sample(1:20, 1))
      updateGlassTabBadge(session, "tabs", "drafts", count = sample(0:5, 1))
    })
  }
  shinyApp(ui, server)
}
```
