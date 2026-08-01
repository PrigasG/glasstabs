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
#' overview_tab <- glassTabPanel("overview", "Overview",
#'   shiny::h3("Welcome"),
#'   shiny::p("This is the overview tab.")
#' )
#'
#' # With a Shiny icon
#' data_tab <- glassTabPanel("data", "Data",
#'   icon = shiny::icon("table"),
#'   shiny::p("Data content here.")
#' )
#'
#' @family glass tabs
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
#'   the `.gt-compact` CSS modifier - useful inside dashboard cards or tight
#'   layouts (e.g. bs4Dash).
#' @param shape Corner style for the tab bar and content. One of `"rounded"`
#'   (default) for the signature glass look, or `"square"` for crisp,
#'   selectize-style corners that match [glassSelect()] and
#'   [glassMultiSelect()] when `shape = "square"`.
#' @param indicator Style of the sliding active-tab indicator. One of:
#'   * `"glass"` (default) - the signature frosted-glass halo with
#'     backdrop blur, shimmer, and transfer particle.
#'   * `"solid"` - a flat, opaque sliding pill. No `backdrop-filter` or
#'     shimmer; lighter on the GPU and better suited to plain or
#'     enterprise-style dashboards. Colors still follow the theme's
#'     `halo_bg` / `halo_border`.
#'   * `"underline"` - a slim sliding bar under the active tab; tab
#'     buttons lose their pill background for a classic tabbed look.
#'     The bar color follows the theme's `halo_border`.
#' @param orientation One of `"horizontal"` (default) or `"vertical"`. In
#'   vertical mode the tab buttons stack in a left-hand rail and the content
#'   pane sits beside them. The sliding halo follows automatically, arrow-key
#'   navigation switches to Up/Down, and `indicator = "underline"` renders as
#'   a slim bar on the edge of the active tab adjacent to the content.
#' @param tab_align Alignment of the tab group within the available navigation
#'   area in either orientation. One of
#'   `"center"` (default), `"left"`, or `"right"`.
#' @param text_align Alignment of text and icons inside each tab button. One of
#'   `"center"` (default), `"left"`, or `"right"`.
#' @param extra_ui Optional additional UI placed to the right of the tab bar
#'   (below the tab rail when `orientation = "vertical"`).
#' @param overflow How the tab strip behaves when labels no longer fit. One of
#'   `"scroll"` (the default), `"wrap"`, or `"menu"`. Scroll mode keeps a
#'   single touch-friendly row and brings the active tab into view. Wrap mode
#'   allows more than one row. Menu mode uses a compact native chooser and is
#'   available only when `orientation = "horizontal"`.
#' @param swipe Whether a horizontal touch swipe over non-interactive panel
#'   content should move to the previous or next available tab. The default is
#'   `FALSE` so maps, plots, tables, and other interactive content keep their
#'   normal gestures.
#' @param theme One of `"dark"`, `"light"`, `"auto"`, or a
#'   [glass_tab_theme()] object. `"auto"` bridges to Bootstrap 5 / bslib
#'   color modes: light-theme variables apply by default and dark-theme
#'   variables apply whenever an ancestor carries `data-bs-theme="dark"`
#'   (e.g. `bslib::toggle_dark_mode()` or `input_dark_mode()`), with the
#'   switch handled live in the browser - no server round-trip.
#' @param dark_selector Optional CSS selector for a parent element that signals
#'   dark mode (e.g. `"body.dark-mode"` for bs4Dash, `"[data-bs-theme=dark]"`
#'   for Bootstrap 5). When provided and `theme = "light"`, a second scoped
#'   `<style>` block overrides the CSS variables back to the dark-mode defaults
#'   whenever that selector is active - so the tabs stay readable after a
#'   dark-mode toggle without any server-side intervention.
#'
#' @return An `htmltools::tagList` ready to use in a Shiny UI.
#' @family glass tabs
#' @export
glassTabsUI <- function(
    id, ...,
    selected = NULL,
    wrap = TRUE,
    compact = FALSE,
    shape = c("rounded", "square"),
    indicator = c("glass", "solid", "underline"),
    orientation = c("horizontal", "vertical"),
    tab_align = c("center", "left", "right"),
    overflow = c("scroll", "wrap", "menu"),
    swipe = FALSE,
    extra_ui = NULL,
    theme = NULL,
    dark_selector = NULL,
    text_align = c("center", "left", "right")
) {
  ns          <- shiny::NS(id)
  panels      <- list(...)
  shape       <- .gt_match_arg(shape, c("rounded", "square"), "shape")
  indicator   <- .gt_match_arg(indicator, c("glass", "solid", "underline"), "indicator")
  orientation <- .gt_match_arg(orientation, c("horizontal", "vertical"), "orientation")
  tab_align   <- .gt_match_arg(tab_align, c("center", "left", "right"), "tab_align")
  text_align  <- .gt_match_arg(text_align, c("center", "left", "right"), "text_align")
  overflow    <- .gt_match_arg(overflow, c("scroll", "wrap", "menu"), "overflow")

  if (identical(orientation, "vertical") && identical(overflow, "menu")) {
    .gt_abort(
      paste0(
        "glassTabsUI(): `overflow = \"menu\"` is available only for horizontal tabs.\n",
        "Use `orientation = \"horizontal\"`, or choose `overflow = \"scroll\"` for a vertical tab rail."
      ),
      class = "glasstabs_error_bad_choice",
      argument = "overflow",
      value = overflow,
      expected = "scroll or wrap when orientation is vertical"
    )
  }

  if (!is.logical(swipe) || length(swipe) != 1L || is.na(swipe)) {
    .gt_abort(
      "glassTabsUI(): `swipe` must be either TRUE or FALSE.",
      class = "glasstabs_error_bad_argument",
      argument = "swipe",
      value = swipe,
      expected = "TRUE or FALSE"
    )
  }

  ## theme = "auto": bridge to Bootstrap 5 / bslib color modes. Base vars are
  ## the light preset; dark vars are scoped under [data-bs-theme="dark"] via
  ## the existing dark_selector machinery. glass.js toggles the structural
  ## .theme-light class live when the attribute changes.
  is_auto <- identical(theme, "auto")
  if (is_auto) {
    if (is.null(dark_selector)) dark_selector <- '[data-bs-theme="dark"]'
    theme <- "light"
  }

  if (length(panels) == 0) {
    .gt_abort(
      paste0(
        "glassTabsUI() requires at least one glassTabPanel() child.\n",
        "Add tabs like: glassTabPanel(\"tab1\", \"Tab Label\", p(\"Content\"))"
      ),
      class = "glasstabs_error_bad_argument",
      argument = "...",
      value = panels,
      expected = "at least one glassTabPanel object"
    )
  }
  bad_panels <- Filter(function(p) !inherits(p, "glassTabPanel"), panels)
  if (length(bad_panels) > 0) {
    bad_cls <- unique(vapply(bad_panels, function(x) class(x)[1], character(1)))
    .gt_abort(
      sprintf(
        paste0(
          "glassTabsUI() received %d non-panel argument(s) of class: %s.\n",
          "All `...` arguments must be glassTabPanel() objects.\n",
          "Wrap content in: glassTabPanel(value, label, ...content...)"
        ),
        length(bad_panels), paste(bad_cls, collapse = ", ")
      ),
      class = "glasstabs_error_bad_argument",
      argument = "...",
      value = bad_panels,
      expected = "glassTabPanel objects"
    )
  }

  theme_vals  <- .tab_resolve_theme(theme)
  panel_vals  <- vapply(panels, function(p) p$value, character(1))

  if (anyDuplicated(panel_vals)) {
    dupes <- unique(panel_vals[duplicated(panel_vals)])
    .gt_abort(
      sprintf(
        paste0(
          "Duplicate glassTabPanel() values found: %s\n",
          "Each tab must have a unique `value` string."
        ),
        paste(dupes, collapse = ", ")
      ),
      class = "glasstabs_error_bad_choice",
      argument = "value",
      value = dupes,
      expected = "unique tab values"
    )
  }

  if (!is.null(selected) && !selected %in% panel_vals) {
    .gt_abort(
      sprintf(
        paste0(
          "glassTabsUI(): `selected = \"%s\"` does not match any tab value.\n",
          "Valid tab values: %s"
        ),
        selected,
        paste(panel_vals, collapse = ", ")
      ),
      class = "glasstabs_error_bad_choice",
      argument = "selected",
      value = selected,
      expected = panel_vals
    )
  }

  active_val <- selected %||% {
    sel <- Filter(function(p) p$selected, panels)
    if (length(sel)) sel[[1]]$value else panels[[1]]$value
  }

  tab_links <- lapply(panels, function(p) {
    .gt_tab_link(p, p$value == active_val, id, preserve_inactive_space = TRUE)
  })

  panes <- lapply(panels, function(p) {
    .gt_tab_pane(
      p,
      p$value == active_val,
      ns(paste0("pane-", p$value)),
      tab_id = ns(paste0("tab-", p$value)),
      preserve_inactive_space = TRUE
    )
  })

  navbar <- shiny::div(
    class = "gt-tab-viewport",
    shiny::div(
      class    = "gt-navbar",
      id       = ns("navbar"),
      `data-ns` = id,
      role     = "tablist",
      `aria-orientation` = orientation,
      tab_links
    ),
    shiny::tags$div(class = "gt-halo", id = ns("halo")),
    shiny::tags$div(class = "gt-transfer", id = ns("transfer"))
  )

  topbar <- shiny::div(
    class = "gt-topbar",
    navbar,
    shiny::tags$select(
      class = "gt-tab-menu-select",
      id = ns("menu"),
      `aria-label` = "Choose a tab"
    ),
    extra_ui
  )

  if (!is.null(dark_selector) &&
      (!is.character(dark_selector) || length(dark_selector) != 1L || !nzchar(dark_selector))) {
    .gt_abort(
      "glassTabsUI(): `dark_selector` must be a single non-empty CSS selector string, e.g. \"body.dark-mode\".",
      class = "glasstabs_error_bad_argument",
      argument = "dark_selector",
      value = dark_selector,
      expected = "a single non-empty CSS selector string"
    )
  }

  scope_id <- ns("wrap")
  theme_css <- .gt_tab_theme_css(theme_vals, scope_id)

  dark_override_style <- if (!is.null(dark_selector)) {
    dark_vals <- .tab_resolve_theme("dark")
    dark_css <- .gt_tab_theme_css(dark_vals, scope_id, dark_selector)
    .make_style_tag(dark_css)
  } else {
    NULL
  }

  inner <- htmltools::tagList(
    .make_style_tag(theme_css),
    dark_override_style,
    topbar,
    shiny::div(class = "gt-tab-wrap", panes)
  )

  is_light <- identical(theme, "light") ||
    (inherits(theme, "glass_tab_theme") && isTRUE(attr(theme, "mode") == "light"))

  container_cls <- trimws(paste(
    c(if (isTRUE(wrap))    "gt-container",
      if (!isTRUE(wrap))   "gt-wrap-shell",
      if (isTRUE(compact)) "gt-compact",
      if (identical(shape, "square")) "shape-square",
      if (!identical(indicator, "glass")) paste0("indicator-", indicator),
      if (identical(orientation, "vertical")) "gt-vertical",
      paste0("gt-overflow-", overflow),
      paste0("gt-align-", tab_align),
      paste0("gt-text-align-", text_align),
      if (is_auto)         "theme-auto",
      if (is_light)        "theme-light"),
    collapse = " "
  ))
  shiny::div(
    class = if (nzchar(container_cls)) container_cls else NULL,
    id = scope_id,
    `data-swipe` = if (isTRUE(swipe)) "true" else "false",
    inner
  )
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
#' @family glass tabs
#' @export
updateGlassTabsUI <- function(session, id, selected) {
  session$sendCustomMessage(
    "glasstabs_update_tabs",
    list(ns = session$ns(id), selected = selected)
  )
  invisible(NULL)
}

#' Update the badge count on a glass tab
#'
#' Adds or updates a small numeric badge on a tab button - useful for
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
#' @family glass tabs
#' @export
updateGlassTabBadge <- function(session, id, value, count) {
  count <- if (is.na(count)) 0L else as.integer(count)
  session$sendCustomMessage(
    "glasstabs_tab_badge",
    list(ns = session$ns(id), value = value, count = count)
  )
  invisible(NULL)
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
#' @family glass tabs
#' @export
showGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_show_tab",
    list(ns = session$ns(id), value = value)
  )
  invisible(NULL)
}

#' @rdname showGlassTab
#' @export
hideGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_hide_tab",
    list(ns = session$ns(id), value = value)
  )
  invisible(NULL)
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
#' @family glass tabs
#' @export
disableGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_disable_tab",
    list(ns = session$ns(id), value = value)
  )
  invisible(NULL)
}

#' @rdname disableGlassTab
#' @export
enableGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_enable_tab",
    list(ns = session$ns(id), value = value)
  )
  invisible(NULL)
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
#' @family glass tabs
#' @export
appendGlassTab <- function(session, id, tab, select = FALSE) {
  if (!inherits(tab, "glassTabPanel")) {
    .gt_abort(
      sprintf(
        paste0(
          "appendGlassTab(): `tab` must be a glassTabPanel() object, got %s.\n",
          "Create one with: glassTabPanel(value, label, ...content...)"
        ),
        class(tab)[1]
      ),
      class = "glasstabs_error_bad_argument",
      argument = "tab",
      value = tab,
      expected = "a glassTabPanel object"
    )
  }

  full_ns <- session$ns(id)

  link_html <- as.character(.gt_tab_link(tab, FALSE, full_ns))
  pane_html <- as.character(.gt_tab_pane(
    tab,
    FALSE,
    paste0(full_ns, "-pane-", tab$value),
    tab_id = paste0(full_ns, "-tab-", tab$value)
  ))

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
  invisible(NULL)
}

#' @rdname appendGlassTab
#' @export
removeGlassTab <- function(session, id, value) {
  session$sendCustomMessage(
    "glasstabs_remove_tab",
    list(ns = session$ns(id), value = value)
  )
  invisible(NULL)
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
#'   Do **not** wrap this in `ns()` - `glassTabsServer()` handles namespacing
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
#' # Server side: pass the bare id - NOT ns("tabs")
#' my_module_server <- function(id) {
#'   shiny::moduleServer(id, function(input, output, session) {
#'     active <- glassTabsServer("tabs")     # <-- bare id, no ns()
#'     shiny::observe(print(active()))
#'   })
#' }
#' @family glass tabs
#' @export
glassTabsServer <- function(id, bookmark = TRUE) {
  if (grepl("-", id, fixed = TRUE)) {
    warning(
      sprintf(
        paste0(
          "glassTabsServer() received id \"%s\" which contains \"-\".\n",
          "This usually means ns(\"tabs\") was passed instead of the bare id \"tabs\".\n",
          "Fix: glassTabsServer(\"tabs\")  # NOT glassTabsServer(ns(\"tabs\"))\n",
          "moduleServer() handles namespacing automatically."
        ),
        id
      ),
      call. = FALSE
    )
  }

  shiny::moduleServer(id, function(input, output, session) {
    active <- shiny::reactive({
      input$active_tab
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
#' # Creates a UI placeholder tag - no Shiny session needed:
#' tabs_placeholder <- glassTabsOutput("my_tabs")
#'
#' # Full dynamic-tab app example:
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
#' @family glass tabs
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
#' @family glass tabs
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

#' Build a conditionalPanel condition for a glasstabs widget
#'
#' Returns a JavaScript condition string that evaluates to `TRUE` when the
#' specified glasstabs widget has a given active tab. Pass the result directly
#' to the `condition` argument of [shiny::conditionalPanel()].
#'
#' @param id    The `id` passed to [glassTabsUI()]. **Inside a Shiny module**
#'   use `ns("tabs")` here (same id you passed to `glassTabsUI()`), NOT the
#'   bare id you pass to [glassTabsServer()].
#' @param value The tab value string (the `value` argument of the target
#'   [glassTabPanel()]) that should trigger the condition.
#'
#' @return A single character string for use in [shiny::conditionalPanel()].
#'
#' @examples
#' # Returns a plain JS condition string - no Shiny session needed:
#' glassTabCondition("main", "details")
#'
#' # Inside a module - use ns() for the id:
#' # UI:   glassTabCondition(ns("tabs"), "details")
#' # This produces: "input['mymod-tabs-active_tab'] === 'details'"
#'
#' # Full app example showing conditionalPanel usage:
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI(
#'       "main",
#'       glassTabPanel("overview", "Overview", selected = TRUE,
#'         p("Always visible.")),
#'       glassTabPanel("details", "Details",
#'         p("Detail pane."))
#'     ),
#'     conditionalPanel(
#'       condition = glassTabCondition("main", "details"),
#'       wellPanel("This panel only shows on the Details tab.")
#'     )
#'   )
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' }
#'
#' @family glass tabs
#' @export
glassTabCondition <- function(id, value) {
  .gt_check_string(
    id,
    "id",
    paste0(
      "glassTabCondition(): `id` must be a single non-empty string matching ",
      "the id passed to glassTabsUI()."
    )
  )
  .gt_check_string(
    value,
    "value",
    paste0(
      "glassTabCondition(): `value` must be a single non-empty string matching ",
      "a glassTabPanel() value."
    )
  )
  input_key <- .gt_js_string(paste0(id, "-active_tab"))
  tab_value <- .gt_js_string(value)
  sprintf("input[%s] === %s", input_key, tab_value)
}

#' @noRd
.gt_js_string <- function(x) {
  x <- enc2utf8(as.character(x))
  x <- gsub("\\\\", "\\\\\\\\", x)
  x <- gsub("\"", "\\\\\"", x)
  x <- gsub("\r", "\\r", x, fixed = TRUE)
  x <- gsub("\n", "\\n", x, fixed = TRUE)
  x <- gsub("\t", "\\t", x, fixed = TRUE)
  x <- gsub("\u2028", "\\u2028", x, fixed = TRUE)
  x <- gsub("\u2029", "\\u2029", x, fixed = TRUE)
  paste0("\"", x, "\"")
}
