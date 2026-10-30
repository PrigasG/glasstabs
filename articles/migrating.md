# Migrating from native Shiny controls

This guide converts an existing app without changing its downstream
code. The filter logic stays identical; only the input construction and
the update calls change. The one trap that breaks migrations is the
empty-selection default — it is covered first, because it decides the
rest.

## The trap: empty does not mean the same thing

Native Shiny and glasstabs disagree about the starting state:

| Control | `selected = NULL` means |
|----|----|
| `selectInput(multiple = TRUE)` | Nothing selected |
| [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md) | Every enabled choice selected |

A migration that copies `selected = NULL` across changes the app’s
initial filter from “nothing” to “everything.” Decide which behavior the
app had, and write it explicitly — do not let the default decide for
you. The behavior-preserving migration below uses
`selected = character(0)` to keep the native empty start.

## Before and after: a multi-select filter

Before, with native Shiny:

``` r

library(shiny)

regions <- c(North = "north", South = "south", East = "east")
data <- data.frame(
  region = c("north", "south", "east", "north"),
  cases = c(12, 8, 5, 3)
)

ui <- fluidPage(
  selectInput(
    "region",
    "Region",
    choices = regions,
    multiple = TRUE,
    selected = NULL
  ),
  tableOutput("rows")
)

server <- function(input, output, session) {
  output$rows <- renderTable({
    data[data$region %in% input$region, , drop = FALSE]
  })
}

shinyApp(ui, server)
```

After, with glasstabs. The downstream filter is untouched:

``` r

library(shiny)
library(glasstabs)

regions <- c(North = "north", South = "south", East = "east")
data <- data.frame(
  region = c("north", "south", "east", "north"),
  cases = c(12, 8, 5, 3)
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect(
    "region",
    choices = regions,
    label = "Region",
    selected = character(0),
    theme = "auto"
  ),
  tableOutput("rows")
)

server <- function(input, output, session) {
  output$rows <- renderTable({
    data[data$region %in% input$region, , drop = FALSE]
  })
}

shinyApp(ui, server)
```

The example above is complete: it defines its dataset, both app halves,
and the app object, so it runs end to end.

Two changes beyond the widget swap:
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
once at the UI root (the one rule), and `selected = character(0)`
preserving the native empty start. If the app actually wants the
glasstabs default (all enabled selected), drop the `selected` argument
and keep the filter — but then say so in the filter’s comments, because
the next reader will otherwise assume the native default.

For a single-select the swap is
[`selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html)
(without `multiple = TRUE`) to
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
with the same
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
addition. The cleared state of a single-select returns `NULL` in both
worlds, so no default trap applies there.

## Update function mapping

| Native | glasstabs | Notes |
|----|----|----|
| `updateSelectInput(session, id, choices, selected)` | `updateGlassMultiSelect(session, id, choices, selected, ...)` or `updateGlassSelect(session, id, choices, selected, ...)` | Choose by widget, not by the old call |
| `updateSelectizeInput(session, id, choices, selected)` | Same as above | Server-side selectize becomes `server = TRUE` + the `*Server()` helper, not an update call |
| `label` argument on the native updaters | No equivalent | The glasstabs updaters take no `label`; a label change means recreating the widget with [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) |
| `selected = NULL` (keep) | `selected = NULL` (keep) | Same meaning on both sides for updates |
| `selected = character(0)` (clear) | `selected = character(0)` (clear) | Same meaning on both sides for updates |

The update semantics that have no native counterpart are the transaction
options: `preserve_selection`, `drop_invalid`, and `notify` on the
multi-select updater (see the linked-filters article). A migration that
passes only `choices` and `selected` behaves like the native updater;
the extra options are opt-in.

## What native selectize can do that glasstabs cannot

Be candid about the gaps before migrating a selectize-heavy app:

- **User-created choices** (`options = list(create = TRUE)`): no
  equivalent. glasstabs choices come from the app, not the user.
- **Selectize plugins** (`options = list(plugins = ...)`): no equivalent
  — no drag-and-drop sorting, no remove-button plugin (tag pills have
  their own remove affordance, but it is not the plugin).
- **Server-side selectize as a drop-in**: the mechanism differs. Native
  selectize queries the server per keystroke through its own protocol;
  glasstabs server mode uses `server = TRUE` plus a `*Server()` helper
  with bounded results. The user-visible behavior is close, but the code
  is not interchangeable.

## When a native control is still the better choice

- The app needs user-created choices or a selectize plugin above.
- The app must render a plain `<select>` with no JavaScript enhancement
  (for example, a no-JS fallback page).
- The list is tiny, static, and already working: a migration buys
  styling and consistency, not behavior, and that trade is not always
  worth the review.

For everything else — searchable dropdowns, multi-select filters, themed
dashboards, server-backed large lists — the migration above is the whole
job: swap the constructor, add
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md),
pin the initial selection explicitly, and remap the update calls.
