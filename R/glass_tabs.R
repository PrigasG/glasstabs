#' Define a single glass tab panel
#'
#' Used as child arguments inside [glassTabsUI()]. Each call defines one tab
#' button and its associated content pane.
#'
#' @param value    A unique string identifier for this tab (e.g. `"A"`).
#' @param label    The text shown on the tab button.
#' @param ...      UI elements for the pane content.
#' @param selected Logical. Whether this tab starts selected. Only the first
#'   `selected = TRUE` tab takes effect; defaults to `FALSE`.
#'
#' @return A list of class `"glassTabPanel"` consumed by [glassTabsUI()].
#'
#' @examples
#' glassTabPanel("overview", "Overview",
#'   shiny::h3("Welcome"),
#'   shiny::p("This is the overview tab.")
#' )
#'
#' @export
glassTabPanel <- function(value, label, ..., selected = FALSE) {
  structure(
    list(
      value    = value,
      label    = label,
      content  = list(...),
      selected = isTRUE(selected)
    ),
    class = "glassTabPanel"
  )
}


#' Animated glass-style tab navigation UI
#'
#' Renders the full tab bar + content area. Place [useGlassTabs()] somewhere
#' in the same page to attach styles and scripts.
#'
#' Works in plain `fluidPage()`, `bs4DashPage()`, and any other container —
#' pass `wrap = FALSE` if you are embedding inside a bs4Dash box or card that
#' already provides a constrained container.
#'
#' @param id         Module namespace id. Used to scope Shiny inputs.
#' @param ...        One or more [glassTabPanel()] objects.
#' @param selected   Value of the initially selected tab. If `NULL` the first
#'   tab is selected.
#' @param wrap       Logical. When `TRUE` (default) wraps everything in a
#'   `div.gt-container`. Set to `FALSE` when embedding inside bs4Dash boxes.
#' @param extra_ui   Optional additional UI placed to the right of the tab bar
#'   (e.g. a [glassMultiSelect()] filter). Defaults to `NULL`.
#'
#' @return An `htmltools::tagList` ready to use in a Shiny UI.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI("tabs",
#'       glassTabPanel("A", "Overview", p("Content A"), selected = TRUE),
#'       glassTabPanel("B", "Details",  p("Content B")),
#'       glassTabPanel("C", "Settings", p("Content C"))
#'     )
#'   )
#'   server <- function(input, output, session) {
#'     glassTabsServer("tabs")
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @export
glassTabsUI <- function(id, ..., selected = NULL, wrap = TRUE, extra_ui = NULL) {
  ns     <- shiny::NS(id)
  panels <- list(...)

  # Validate inputs
  if (!all(vapply(panels, inherits, logical(1), "glassTabPanel"))) {
    stop("All `...` arguments to glassTabsUI() must be glassTabPanel() objects.")
  }
  if (length(panels) == 0) stop("glassTabsUI() requires at least one glassTabPanel().")

  # Determine which tab starts active
  active_val <- selected %||% {
    sel <- Filter(function(p) p$selected, panels)
    if (length(sel)) sel[[1]]$value else panels[[1]]$value
  }

  # ── Tab link buttons ────────────────────────────────────────────────────────
  tab_links <- lapply(panels, function(p) {
    cls <- paste("gt-tab-link", if (p$value == active_val) "active" else "")
    shiny::tags$div(
      class         = cls,
      `data-value`  = p$value,
      `data-ns`     = id,
      p$label
    )
  })

  # ── Content panes ───────────────────────────────────────────────────────────
  panes <- lapply(panels, function(p) {
    cls <- paste("gt-tab-pane", if (p$value == active_val) "active" else "")
    shiny::div(
      class = cls,
      id    = ns(paste0("pane-", p$value)),
      do.call(shiny::div, c(list(class = "gt-card"), p$content))
    )
  })

  # ── Assemble ─────────────────────────────────────────────────────────────────
  navbar <- shiny::div(
    class = "gt-topbar",
    shiny::div(
      class = "gt-navbar",
      id    = ns("navbar"),
      `data-ns` = id,
      tab_links
    ),
    extra_ui
  )

  inner <- htmltools::tagList(
    navbar,
    shiny::tags$div(class = "gt-halo",     id = ns("halo")),
    shiny::tags$div(class = "gt-transfer", id = ns("transfer")),
    shiny::div(class = "gt-tab-wrap", panes)
  )

  if (wrap) {
    shiny::div(class = "gt-container", inner)
  } else {
    inner
  }
}


#' Server logic for glass tabs
#'
#' Tracks the active tab and exposes it as a reactive value. Also registers
#' Shiny input binding so the active tab is available as `input$<id>_active`.
#'
#' @param id Module id matching the `id` passed to [glassTabsUI()].
#'
#' @return A `reactive` string — the value of the currently active tab.
#'
#' @export
glassTabsServer <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # JS sets input$<ns>_active via Shiny.setInputValue on every tab click
    active <- shiny::reactive({
      input[["active_tab"]] %||% NULL
    })
    active
  })
}


# Null-coalescing helper (not exported)
`%||%` <- function(a, b) if (!is.null(a)) a else b
