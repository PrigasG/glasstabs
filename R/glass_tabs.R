#' Define a single glass tab panel
#'
#' Used as child arguments inside [glassTabsUI()]. Each call defines one tab
#' button and its associated content pane.
#'
#' @param value    A unique string identifier for this tab (e.g. `"A"`).
#' @param label    The text shown on the tab button.
#' @param ...      UI elements for the pane content.
#' @param icon     Optional icon shown to the left of the tab label. Accepts
#'   any htmltools-compatible tag, e.g. `shiny::icon("table")` or
#'   `fontawesome::fa("house")`. Pass `NULL` (default) for no icon.
#' @param selected Logical. Whether this tab starts selected. Only the first
#'   `selected = TRUE` tab takes effect; defaults to `FALSE`.
#'
#' @return A list of class `"glassTabPanel"` consumed by [glassTabsUI()].
#'
#' @examples
#' # Plain text label
#' glassTabPanel("overview", "Overview",
#'   shiny::h3("Welcome"),
#'   shiny::p("This is the overview tab.")
#' )
#'
#' # With a Shiny icon
#' glassTabPanel("data", "Data",
#'   icon = shiny::icon("table"),
#'   shiny::p("Data content here.")
#' )
#'
#' @export
glassTabPanel <- function(value, label, ..., icon = NULL, selected = FALSE) {
  structure(
    list(
      value    = value,
      label    = label,
      icon     = icon,
      content  = list(...),
      selected = isTRUE(selected)
    ),
    class = "glassTabPanel"
  )
}


#' Animated glass-style tab navigation UI
#'
#' @param id Module namespace id.
#' @param ... One or more [glassTabPanel()] objects.
#' @param selected Value of the initially selected tab.
#' @param wrap Logical. When `TRUE` wraps everything in a `div.gt-container`.
#' @param compact Logical. When `TRUE` applies reduced padding and spacing via
#'   the `.gt-compact` CSS modifier — useful inside dashboard cards or tight
#'   layouts (e.g. bs4Dash).
#' @param extra_ui Optional additional UI placed to the right of the tab bar.
#' @param theme One of `"dark"`, `"light"`, or a [glass_tab_theme()] object.
#'
#' @return An `htmltools::tagList` ready to use in a Shiny UI.
#' @export
glassTabsUI <- function(
    id, ...,
    selected = NULL,
    wrap = TRUE,
    compact = FALSE,
    extra_ui = NULL,
    theme = NULL
) {
  ns     <- shiny::NS(id)
  panels <- list(...)

  if (length(panels) == 0) {
    stop("glassTabsUI() requires at least one glassTabPanel().", call. = FALSE)
  }
  if (!all(vapply(panels, inherits, logical(1), "glassTabPanel"))) {
    stop("All `...` arguments to glassTabsUI() must be glassTabPanel() objects.", call. = FALSE)
  }

  theme_vals  <- .tab_resolve_theme(theme)
  panel_vals  <- vapply(panels, function(p) p$value, character(1))

  if (anyDuplicated(panel_vals)) {
    dupes <- unique(panel_vals[duplicated(panel_vals)])
    stop(
      sprintf(
        "Duplicate glassTabPanel() values are not allowed: %s",
        paste(dupes, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (!is.null(selected) && !selected %in% panel_vals) {
    stop(
      sprintf(
        "'selected' value \"%s\" does not match any glassTabPanel() value. Valid values: %s",
        selected,
        paste(panel_vals, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  active_val <- selected %||% {
    sel <- Filter(function(p) p$selected, panels)
    if (length(sel)) sel[[1]]$value else panels[[1]]$value
  }

  tab_links <- lapply(panels, function(p) {
    is_active <- p$value == active_val
    cls <- paste("gt-tab-link", if (is_active) "active" else "")
    label_content <- if (!is.null(p$icon)) {
      list(
        shiny::tags$span(class = "gt-tab-icon", p$icon),
        shiny::tags$span(class = "gt-tab-label", p$label)
      )
    } else {
      list(p$label)
    }
    shiny::tags$div(
      class          = cls,
      `data-value`   = p$value,
      `data-ns`      = id,
      role           = "tab",
      tabindex       = "0",
      `aria-selected` = if (is_active) "true" else "false",
      label_content
    )
  })

  panes <- lapply(panels, function(p) {
    cls <- paste("gt-tab-pane", if (p$value == active_val) "active" else "")
    shiny::div(
      class = cls,
      id    = ns(paste0("pane-", p$value)),
      role  = "tabpanel",
      do.call(shiny::div, c(list(class = "gt-card"), p$content))
    )
  })

  navbar <- shiny::div(
    class = "gt-topbar",
    shiny::div(
      class    = "gt-navbar",
      id       = ns("navbar"),
      `data-ns` = id,
      role     = "tablist",
      tab_links
    ),
    extra_ui
  )

  scope_id <- ns("wrap")
  theme_css <- sprintf(
    "#%s{--gt-tab-text:%s;--gt-tab-active-text:%s;--gt-halo-bg:%s;--gt-halo-border:%s;--gt-content-bg:%s;--gt-content-border:%s;--gt-card-bg:%s;--gt-card-text:%s;}",
    scope_id,
    theme_vals$tab_text,
    theme_vals$tab_active_text,
    theme_vals$halo_bg,
    theme_vals$halo_border,
    theme_vals$content_bg,
    theme_vals$content_border,
    theme_vals$card_bg,
    theme_vals$card_text
  )

  inner <- htmltools::tagList(
    shiny::tags$style(theme_css),
    navbar,
    shiny::tags$div(class = "gt-halo", id = ns("halo")),
    shiny::tags$div(class = "gt-transfer", id = ns("transfer")),
    shiny::div(class = "gt-tab-wrap", panes)
  )

  container_cls <- trimws(paste(
    c(if (isTRUE(wrap)) "gt-container", if (isTRUE(compact)) "gt-compact"),
    collapse = " "
  ))
  shiny::div(class = if (nzchar(container_cls)) container_cls else NULL,
             id = scope_id, inner)
}

#' Programmatically switch the active glass tab
#'
#' Server-side equivalent of Shiny's \code{updateTabsetPanel()}. Sends a
#' message to the browser to animate the tab switch just as if the user had
#' clicked the tab button.
#'
#' @param session Shiny session object.
#' @param id      Module id matching the `id` passed to [glassTabsUI()].
#' @param selected Value of the tab to activate.
#'
#' @return Called for its side effect; returns \code{NULL} invisibly.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'       glassTabPanel("b", "B", p("Tab B"))
#'     ),
#'     actionButton("go", "Go to B")
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$go, {
#'       updateGlassTabsUI(session, "tabs", selected = "b")
#'     })
#'   }
#'   shinyApp(ui, server)
#' }
#' @export
updateGlassTabsUI <- function(session, id, selected) {
  session$sendCustomMessage(
    "glasstabs_update_tabs",
    list(ns = session$ns(id), selected = selected)
  )
}

#' Update the badge count on a glass tab
#'
#' Adds or updates a small numeric badge on a tab button — useful for
#' surfacing counts such as unread items, pending rows, or notification
#' totals. Set `count` to `0` or `NA` to hide the badge.
#'
#' @param session Shiny session object.
#' @param id      Module id matching the `id` passed to [glassTabsUI()].
#' @param value   Value of the tab to update.
#' @param count   Integer count to display. Values above 99 are shown as
#'   `"99+"`. `0` or `NA` hides the badge.
#'
#' @return Called for its side effect; returns \code{NULL} invisibly.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("inbox",  "Inbox",  p("Messages here"), selected = TRUE),
#'       glassTabPanel("sent",   "Sent",   p("Sent items")),
#'       glassTabPanel("drafts", "Drafts", p("Draft items"))
#'     ),
#'     actionButton("refresh", "Refresh counts")
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$refresh, {
#'       updateGlassTabBadge(session, "tabs", "inbox",  count = sample(1:20, 1))
#'       updateGlassTabBadge(session, "tabs", "drafts", count = sample(0:5, 1))
#'     })
#'   }
#'   shinyApp(ui, server)
#' }
#' @export
updateGlassTabBadge <- function(session, id, value, count) {
  count <- if (is.na(count)) 0L else as.integer(count)
  session$sendCustomMessage(
    "glasstabs_tab_badge",
    list(ns = session$ns(id), value = value, count = count)
  )
}

#' Show or hide a glass tab
#'
#' `showGlassTab()` makes a hidden tab visible again.
#' `hideGlassTab()` hides a tab from the navigation bar. If the hidden tab is
#' currently active, the first remaining visible tab is activated automatically.
#'
#' @param session Shiny session object.
#' @param id      Module id matching the `id` passed to [glassTabsUI()].
#' @param value   Value of the tab to show or hide.
#'
#' @return Called for its side effect; returns \code{NULL} invisibly.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'       glassTabPanel("b", "B", p("Tab B")),
#'       glassTabPanel("admin", "Admin", p("Admin only"))
#'     ),
#'     checkboxInput("is_admin", "Admin mode", FALSE)
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$is_admin, {
#'       if (input$is_admin) showGlassTab(session, "tabs", "admin")
#'       else                hideGlassTab(session, "tabs", "admin")
#'     }, ignoreInit = FALSE)
#'   }
#'   shinyApp(ui, server)
#' }
#' @export
showGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_show_tab",
    list(ns = session$ns(id), value = value)
  )
}

#' @rdname showGlassTab
#' @export
hideGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_hide_tab",
    list(ns = session$ns(id), value = value)
  )
}

#' Disable or enable a glass tab
#'
#' `disableGlassTab()` grays out a tab and prevents the user from clicking it
#' without removing it from the navigation bar. `enableGlassTab()` reverses
#' this. Unlike [hideGlassTab()], a disabled tab remains visible.
#'
#' @param session Shiny session object.
#' @param id      Module id matching the `id` passed to [glassTabsUI()].
#' @param value   Value of the tab to disable or enable.
#'
#' @return Called for its side effect; returns \code{NULL} invisibly.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'       glassTabPanel("b", "B", p("Tab B")),
#'       glassTabPanel("locked", "Locked", p("Locked content"))
#'     ),
#'     checkboxInput("unlocked", "Unlock tab", FALSE)
#'   )
#'   server <- function(input, output, session) {
#'     # Start with "locked" tab disabled
#'     observe({
#'       if (input$unlocked) enableGlassTab(session, "tabs", "locked")
#'       else                disableGlassTab(session, "tabs", "locked")
#'     })
#'   }
#'   shinyApp(ui, server)
#' }
#' @export
disableGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_disable_tab",
    list(ns = session$ns(id), value = value)
  )
}

#' @rdname disableGlassTab
#' @export
enableGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_enable_tab",
    list(ns = session$ns(id), value = value)
  )
}

#' Append or remove a glass tab at runtime
#'
#' `appendGlassTab()` adds a new [glassTabPanel()] to an existing
#' [glassTabsUI()] at runtime. `removeGlassTab()` removes a tab by value.
#' If the removed tab was active, the first remaining tab is activated.
#'
#' @param session Shiny session object.
#' @param id      Module id matching the `id` passed to [glassTabsUI()].
#' @param tab     A [glassTabPanel()] object (for `appendGlassTab()` only).
#' @param select  Logical. If `TRUE`, the new tab is immediately activated.
#'   Defaults to `FALSE`.
#' @param value   Value of the tab to remove (for `removeGlassTab()` only).
#'
#' @return Called for its side effect; returns \code{NULL} invisibly.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("home", "Home", p("Home content"), selected = TRUE)
#'     ),
#'     actionButton("add",    "Add tab"),
#'     actionButton("remove", "Remove tab")
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$add, {
#'       appendGlassTab(session, "tabs",
#'         glassTabPanel("new", "New Tab", p("Dynamic content")),
#'         select = TRUE
#'       )
#'     })
#'     observeEvent(input$remove, {
#'       removeGlassTab(session, "tabs", "new")
#'     })
#'   }
#'   shinyApp(ui, server)
#' }
#' @export
appendGlassTab <- function(session, id, tab, select = FALSE) {
  if (!inherits(tab, "glassTabPanel")) {
    stop("'tab' must be a glassTabPanel() object.", call. = FALSE)
  }

  full_ns <- session$ns(id)

  link_html <- as.character(shiny::tags$div(
    class           = "gt-tab-link",
    `data-value`    = tab$value,
    `data-ns`       = full_ns,
    role            = "tab",
    tabindex        = "0",
    `aria-selected` = "false",
    tab$label
  ))

  pane_html <- as.character(
    shiny::div(
      class = "gt-tab-pane",
      id    = paste0(full_ns, "-pane-", tab$value),
      role  = "tabpanel",
      do.call(shiny::div, c(list(class = "gt-card"), tab$content))
    )
  )

  session$sendCustomMessage(
    "glasstabs_append_tab",
    list(
      ns        = full_ns,
      value     = tab$value,
      link_html = link_html,
      pane_html = pane_html,
      select    = isTRUE(select)
    )
  )
}

#' @rdname appendGlassTab
#' @export
removeGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_remove_tab",
    list(ns = session$ns(id), value = value)
  )
}

#' Server logic for glass tabs
#'
#' Tracks the active tab and exposes it as a reactive value. Optionally
#' integrates with Shiny's bookmarking system so the active tab is preserved
#' in bookmarked URLs.
#'
#' `glassTabsServer()` follows the same calling convention as all Shiny module
#' server functions: pass the **bare** module id, not a namespaced one.
#' Inside a parent module, pair it with `glassTabsUI(ns("tabs"), ...)` in the
#' UI, and call `glassTabsServer("tabs")` (without `ns()`) in the server.
#'
#' @param id       Module id matching the `id` passed to [glassTabsUI()].
#'   Do **not** wrap this in `ns()` — `glassTabsServer()` handles namespacing
#'   internally via [shiny::moduleServer()].
#' @param bookmark Logical. When `TRUE` (default), registers [shiny::onBookmark()]
#'   and [shiny::onRestored()] hooks so the active tab is saved and restored
#'   automatically when Shiny bookmarking is enabled. Set to `FALSE` to opt out.
#'
#' @return A reactive expression returning the active tab value.
#'
#' @examples
#' # --- Standalone app ---
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "tabs",
#'       glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'       glassTabPanel("b", "B", p("Tab B"))
#'     )
#'   )
#'   server <- function(input, output, session) {
#'     active <- glassTabsServer("tabs")
#'     observe(print(active()))
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' # --- Bookmarking ---
#' if (interactive()) {
#'   library(shiny)
#'   ui <- function(request) {
#'     fluidPage(
#'       useGlassTabs(),
#'       bookmarkButton(),
#'       glassTabsUI(
#'         "tabs",
#'         glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'         glassTabPanel("b", "B", p("Tab B"))
#'       )
#'     )
#'   }
#'   server <- function(input, output, session) {
#'     active <- glassTabsServer("tabs", bookmark = TRUE)
#'   }
#'   shinyApp(ui, server, enableBookmarking = "url")
#' }
#'
#' # --- Inside a Shiny module ---
#' # UI side: use ns() to namespace the widget id
#' my_module_ui <- function(id) {
#'   ns <- shiny::NS(id)
#'   shiny::tagList(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       ns("tabs"),                          # <-- ns() wraps the id here
#'       glassTabPanel("a", "A", p("Tab A"), selected = TRUE),
#'       glassTabPanel("b", "B", p("Tab B"))
#'     )
#'   )
#' }
#'
#' # Server side: pass the bare id — NOT ns("tabs")
#' my_module_server <- function(id) {
#'   shiny::moduleServer(id, function(input, output, session) {
#'     active <- glassTabsServer("tabs")     # <-- bare id, no ns()
#'     shiny::observe(print(active()))
#'   })
#' }
#' @export
glassTabsServer <- function(id, bookmark = TRUE) {
  if (grepl("-", id, fixed = TRUE)) {
    warning(
      sprintf(
        paste0(
          "glassTabsServer() received id \"%s\" which contains \"-\". ",
          "This looks like a fully-namespaced id (e.g. the result of ns(\"tabs\")). ",
          "Pass the bare module id instead and let moduleServer() handle namespacing."
        ),
        id
      ),
      call. = FALSE
    )
  }

  shiny::moduleServer(id, function(input, output, session) {
    active <- shiny::reactive({
      input[["active_tab"]] %||% NULL
    })

    if (isTRUE(bookmark)) {
      session$onBookmark(function(state) {
        state$values$active_tab <- active()
      })

      session$onRestored(function(state) {
        val <- state$values$active_tab
        if (!is.null(val) && nzchar(val)) {
          # Reconstruct the fully-qualified namespace that the navbar uses as
          # data-ns.  Inside moduleServer("tabs"), session$ns("") = "tabs-";
          # strip the trailing separator to get "tabs" (or "parent-tabs").
          ns_str <- gsub("-$", "", session$ns(""))
          session$sendCustomMessage(
            "glasstabs_update_tabs",
            list(ns = ns_str, selected = val)
          )
        }
      })
    }

    active
  })
}

#' Dynamic glass tab UI output
#'
#' A drop-in replacement for [shiny::uiOutput()] that pairs with
#' [renderGlassTabs()]. It creates a placeholder `<div>` that Shiny fills
#' with a fully reactive [glassTabsUI()] when the server-side render function
#' runs. The JavaScript engine is automatically (re-)initialised after each
#' render.
#'
#' @param outputId The output id used in the paired [renderGlassTabs()] call.
#' @param ...      Additional arguments forwarded to [shiny::uiOutput()].
#'
#' @return A `shiny.tag` suitable for use in a Shiny UI.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   tab_data <- list(
#'     list(value = "a", label = "Alpha"),
#'     list(value = "b", label = "Beta"),
#'     list(value = "c", label = "Gamma")
#'   )
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     selectInput("n", "Show tabs", choices = 2:3, selected = 2),
#'     glassTabsOutput("dynamic_tabs")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$dynamic_tabs <- renderGlassTabs({
#'       panels <- lapply(
#'         head(tab_data, as.integer(input$n)),
#'         function(t) glassTabPanel(t$value, t$label, p(t$label))
#'       )
#'       do.call(glassTabsUI, c(list("dyn"), panels))
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
glassTabsOutput <- function(outputId, ...) {
  shiny::uiOutput(outputId, ...)
}

#' Render a reactive glass tab UI
#'
#' Server-side render function that pairs with [glassTabsOutput()]. The
#' expression should return a [glassTabsUI()] call. After each render the
#' glasstabs JavaScript engine is automatically reinitialised so animations and
#' event handlers are correctly attached to the new DOM nodes.
#'
#' @param expr   An expression that returns a [glassTabsUI()] tag object.
#' @param env    The environment in which to evaluate `expr`.
#' @param quoted Logical. Whether `expr` is already quoted.
#'
#' @return A render function suitable for assigning to an `output` slot.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     radioButtons("theme", "Theme", c("dark", "light"), inline = TRUE),
#'     glassTabsOutput("tabs_out")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$tabs_out <- renderGlassTabs({
#'       glassTabsUI(
#'         "themed",
#'         glassTabPanel("x", "X", selected = TRUE, p("X content")),
#'         glassTabPanel("y", "Y", p("Y content")),
#'         theme = input$theme
#'       )
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
renderGlassTabs <- function(expr, env = parent.frame(), quoted = FALSE) {
  func <- shiny::exprToFunction(expr, env, quoted)

  shiny::renderUI({
    result <- func()
    session <- shiny::getDefaultReactiveDomain()
    if (!is.null(session)) {
      session$onFlushed(function() {
        session$sendCustomMessage("glasstabs_reinit", list())
      }, once = TRUE)
    }
    result
  })
}
