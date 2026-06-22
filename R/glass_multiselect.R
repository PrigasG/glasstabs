#' Animated glass multi-select dropdown filter
#'
#' A stylized multi-select Shiny input with optional search, style switching,
#' select-all behavior, and programmatic updates via [updateGlassMultiSelect()].
#'
#' The widget registers two Shiny inputs:
#'
#' \itemize{
#'   \item \code{input$<inputId>} : character vector of selected values
#'   \item \code{input$<inputId>_style} : active style string
#'     (\code{"checkbox"}, \code{"check-only"}, or \code{"filled"})
#' }
#'
#' By default, when \code{selected = NULL}, all choices are initially selected.
#' This preserves the existing package behavior.
#'
#' @param inputId Shiny input id.
#' @param choices Named or unnamed character vector of choices.
#' @param selected Initially selected values. Defaults to all choices when
#'   \code{NULL}.
#' @param label Optional field label shown above the widget.
#' @param placeholder Trigger label when nothing is selected.
#' @param all_label Label shown when all choices are selected.
#' @param check_style One of \code{"checkbox"} (default),
#'   \code{"check-only"}, or \code{"filled"}.
#' @param show_style_switcher Show the Check / Box / Fill switcher row inside
#'   the dropdown? Default \code{TRUE}.
#' @param show_select_all Show the "Select all" row? Default \code{TRUE}.
#' @param show_clear_all Show the "Clear all" footer link? Default \code{TRUE}.
#' @param theme Color theme. One of \code{"dark"} (default) or \code{"light"},
#'   or a [glass_select_theme()] object.
#' @param shape Corner style for the trigger and dropdown. One of
#'   \code{"rounded"} (default) for the signature glass look, or
#'   \code{"square"} for crisp, selectize-style corners so the widget sits
#'   neatly alongside native 'Shiny' \code{selectizeInput()} controls.
#' @param hues Optional named integer vector of HSL hue angles (0 to 360) for
#'   the \code{"filled"} style. Auto-assigned if \code{NULL}.
#' @param dark_selector Optional CSS selector that signals dark mode (e.g.
#'   \code{"body.dark-mode"} for bs4Dash). When provided and
#'   \code{theme = "light"}, emits an extra scoped \code{<style>} block that
#'   reverts colors to the dark-mode defaults whenever that selector is active.
#' @param server Logical. If \code{TRUE}, render only an initial slice of
#'   choices and use [glassMultiSelectServer()] to search the full choice set
#'   from the Shiny server. Default \code{FALSE}.
#' @param server_limit Maximum number of choices rendered initially and returned
#'   for each server-side search. Default \code{50}.
#' @param server_min_chars Minimum search characters required before server-side
#'   matching filters choices. Default \code{0}.
#'
#' @return An \code{htmltools::tagList} containing the trigger button, dropdown
#'   panel, and scoped \code{<style>} block.
#'
#' @examples
#' fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
#'
#' # Minimal
#' fruit_filter <- glassMultiSelect("f", fruits)
#'
#' # Lock style, hide extra controls
#' locked_filter <- glassMultiSelect(
#'   "f",
#'   fruits,
#'   check_style = "check-only",
#'   show_style_switcher = FALSE,
#'   show_select_all = FALSE,
#'   show_clear_all = FALSE
#' )
#'
#' # Light theme
#' light_filter <- glassMultiSelect("f", fruits, theme = "light")
#'
#' @export
glassMultiSelect <- function(
    inputId,
    choices,
    selected            = NULL,
    label               = NULL,
    placeholder         = "Filter by Category",
    all_label           = "All categories",
    check_style         = c("checkbox", "check-only", "filled"),
    show_style_switcher = TRUE,
    show_select_all     = TRUE,
    show_clear_all      = TRUE,
    theme               = "dark",
    shape               = c("rounded", "square"),
    hues                = NULL,
    dark_selector       = NULL,
    server              = FALSE,
    server_limit        = 50L,
    server_min_chars    = 0L
) {
  if (!is.character(inputId) || length(inputId) != 1L || !nzchar(inputId)) {
    stop(
      "glassMultiSelect(): `inputId` must be a single non-empty string.",
      call. = FALSE
    )
  }
  check_style <- match.arg(check_style)
  shape <- match.arg(shape)
  server <- isTRUE(server)
  server_limit <- .gt_positive_int(server_limit, "server_limit")
  server_min_chars <- .gt_nonnegative_int(server_min_chars, "server_min_chars")
  colors <- .ms_resolve_theme(theme)

  normalized <- .gt_normalize_choices(choices)
  vals <- normalized$values
  labels <- normalized$labels


  selected_is_default <- is.null(selected)
  if (is.null(selected)) {
    selected <- vals
  } else {
    selected <- as.character(selected)
  }

  selected <- vals[vals %in% selected]

  if (is.null(hues)) {
    n <- length(vals)
    hues <- stats::setNames(
      as.integer(seq(200, 200 + 360 * (n - 1) / max(1, n), length.out = n) %% 360),
      vals
    )
  } else {
    hues <- .gt_normalize_hues(hues = hues, vals = vals)
  }

  n_total <- length(vals)
  n_sel <- length(selected)
  init_label <- .ms_label(
    vals        = vals,
    labels      = labels,
    selected    = selected,
    placeholder = placeholder,
    all_label   = all_label
  )
  badge_cls <- if (n_sel < 2 || (n_total > 0 && n_sel == n_total)) {
    "gt-ms-badge hidden"
  } else {
    "gt-ms-badge"
  }

  render_idx <- seq_along(vals)
  if (server) {
    render_idx <- seq_len(min(length(vals), server_limit))
    if (!selected_is_default && length(selected) == 1L) {
      selected_idx <- match(selected, vals)
      selected_idx <- selected_idx[!is.na(selected_idx)]
      render_idx <- unique(c(render_idx, selected_idx))
    }
  }
  render_vals <- vals[render_idx]
  render_labels <- labels[render_idx]

  field_id <- paste0(inputId, "-field")
  scope_id <- paste0(inputId, "-wrap")

  theme_css <- sprintf(
    "#%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;--ms-label:%s;%s}",
    field_id, colors$bg, colors$border, colors$text, colors$accent, colors$label,
    .to_rgba_vars(colors)
  )

  dark_override_style <- if (!is.null(dark_selector) && nzchar(dark_selector)) {
    dark_colors <- .ms_resolve_theme("dark")
    .make_style_tag(sprintf(
      "%s #%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;--ms-label:%s;%s}",
      dark_selector, field_id,
      dark_colors$bg, dark_colors$border, dark_colors$text,
      dark_colors$accent, dark_colors$label,
      .to_rgba_vars(dark_colors)
    ))
  } else {
    NULL
  }

  check_svg <- shiny::tags$svg(
    width = "10",
    height = "8",
    viewBox = "0 0 10 8",
    fill = "none",
    shiny::tags$path(
      d = "M1 4l2.8 3L9 1",
      stroke = colors$accent,
      `stroke-width` = "1.8",
      `stroke-linecap` = "round",
      `stroke-linejoin` = "round"
    )
  )

  label_tag <- if (!is.null(label)) {
    shiny::tags$label(
      class = "gt-input-label",
      `for` = paste0(inputId, "-trigger"),
      label
    )
  } else {
    NULL
  }

  style_btns <- if (isTRUE(show_style_switcher)) {
    shiny::div(
      class = "gt-style-switcher",
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "check-only") "active" else ""),
        `data-style` = "check-only",
        shiny::tags$svg(
          class = "gt-sb-icon",
          viewBox = "0 0 14 14",
          fill = "none",
          shiny::tags$path(
            d = "M2 7l3.5 4L12 3",
            stroke = colors$accent,
            `stroke-width` = "1.9",
            `stroke-linecap` = "round",
            `stroke-linejoin` = "round"
          )
        ),
        shiny::tags$span("Check")
      ),
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "checkbox") "active" else ""),
        `data-style` = "checkbox",
        shiny::tags$svg(
          class = "gt-sb-icon",
          viewBox = "0 0 14 14",
          fill = "none",
          shiny::tags$rect(
            x = "1.5",
            y = "1.5",
            width = "11",
            height = "11",
            rx = "3",
            stroke = colors$accent,
            `stroke-width` = "1.6"
          ),
          shiny::tags$path(
            d = "M3.5 7l2.8 3L10.5 4",
            stroke = colors$accent,
            `stroke-width` = "1.7",
            `stroke-linecap` = "round",
            `stroke-linejoin` = "round"
          )
        ),
        shiny::tags$span("Box")
      ),
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "filled") "active" else ""),
        `data-style` = "filled",
        shiny::tags$svg(
          class = "gt-sb-icon",
          viewBox = "0 0 14 14",
          fill = "none",
          shiny::tags$rect(
            x = "1.5",
            y = "1.5",
            width = "11",
            height = "11",
            rx = "3",
            fill = colors$accent,
            `fill-opacity` = "0.45",
            stroke = colors$accent,
            `stroke-opacity` = "0.75",
            `stroke-width` = "1.4"
          )
        ),
        shiny::tags$span("Fill")
      )
    )
  } else {
    NULL
  }

  all_cls <- paste(
    "gt-ms-all",
    if (n_total > 0 && n_sel == n_total) "checked" else if (n_sel > 0) "indeterminate" else ""
  )

  all_row <- if (isTRUE(show_select_all)) {
    shiny::div(
      class = all_cls,
      id = paste0(inputId, "-all"),
      role = "option",
      `aria-selected` = if (n_total > 0 && n_sel == n_total) "true" else "false",
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  } else {
    shiny::div(
      class = all_cls,
      id = paste0(inputId, "-all"),
      style = "display:none;",
      role = "option",
      `aria-selected` = if (n_total > 0 && n_sel == n_total) "true" else "false",
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  }

  option_rows <- lapply(seq_along(render_vals), function(i) {
    v <- render_vals[[i]]
    lbl <- render_labels[[i]]
    cls <- paste("gt-ms-option", if (v %in% selected) "checked" else "")

    shiny::div(
      class = cls,
      `data-value` = v,
      style = paste0("--opt-hue:", unname(hues[v]), ";"),
      role = "option",
      `aria-selected` = if (v %in% selected) "true" else "false",
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span(lbl)
    )
  })

  footer <- shiny::div(
    class = "gt-ms-footer",
    shiny::tags$span(
      class = "gt-ms-count",
      id = paste0(inputId, "-count"),
      paste0(n_sel, " / ", n_total, " selected")
    ),
    if (isTRUE(show_clear_all)) {
      shiny::tags$span(
        class = "gt-ms-clear",
        id = paste0(inputId, "-clear"),
        "Clear all"
      )
    } else {
      shiny::tags$span(
        class = "gt-ms-clear",
        id = paste0(inputId, "-clear"),
        style = "display:none;",
        "Clear all"
      )
    }
  )

  wrap_cls <- paste(
    "gt-ms-wrap",
    paste0("style-", check_style),
    if (identical(shape, "square")) "shape-square" else NULL,
    if (.is_light_theme(theme)) "theme-light" else NULL
  )

  htmltools::tagList(
    .make_style_tag(theme_css),
    dark_override_style,
    shiny::div(
      class = "gt-ms-field",
      label_tag,
      id = field_id,
      shiny::div(
        class = wrap_cls,
        id = scope_id,
        `data-input-id` = inputId,
        `data-placeholder` = placeholder,
        `data-all-label` = all_label,
        `data-server` = tolower(as.character(server)),
        `data-server-total` = as.character(n_total),
        `data-server-min-chars` = as.character(server_min_chars),
        `data-selected-values` = .gt_json_array(selected),

        shiny::div(
          class = "gt-ms-trigger",
          id = paste0(inputId, "-trigger"),
          role = "combobox",
          tabindex = "0",
          `aria-haspopup` = "listbox",
          `aria-expanded` = "false",
          `aria-controls` = paste0(inputId, "-dropdown"),
          shiny::tags$span(id = paste0(inputId, "-label"), init_label),
          shiny::div(
            style = "display:flex;align-items:center;gap:6px;",
            shiny::tags$span(
              class = badge_cls,
              id = paste0(inputId, "-badge"),
              as.character(n_sel)
            ),
            shiny::tags$svg(
              class = "gt-ms-chevron",
              viewBox = "0 0 24 24",
              fill = "none",
              stroke = "currentColor",
              `stroke-width` = "2.2",
              shiny::tags$path(
                `stroke-linecap` = "round",
                `stroke-linejoin` = "round",
                d = "M19 9l-7 7-7-7"
              )
            )
          )
        ),

        shiny::div(
          class = "gt-ms-dropdown",
          id = paste0(inputId, "-dropdown"),
          role = "listbox",

          shiny::div(
            class = "gt-ms-search",
            shiny::tags$svg(
              width = "13",
              height = "13",
              viewBox = "0 0 24 24",
              fill = "none",
              stroke = colors$accent,
              `stroke-width` = "2.2",
              shiny::tags$circle(cx = "11", cy = "11", r = "8"),
              shiny::tags$path(`stroke-linecap` = "round", d = "M21 21l-4.35-4.35")
            ),
            shiny::tags$input(
              type = "text",
              id = paste0(inputId, "-search"),
              placeholder = "Search options...",
              autocomplete = "off"
            )
          ),

          style_btns,
          all_row,
          shiny::div(
            id = paste0(inputId, "-options"),
            option_rows
          ),
          footer
        )
      )
    )
  )
}

#' Label helper for glassMultiSelect
#'
#' @param vals Choice values.
#' @param labels Choice labels.
#' @param selected Selected values.
#' @param placeholder Placeholder label when nothing is selected.
#' @param all_label Label shown when all choices are selected.
#'
#' @return A single character string.
#' @noRd
.ms_label <- function(vals, labels, selected, placeholder, all_label = "All categories") {
  n <- length(selected)

  if (n == 0) {
    return(placeholder)
  }

  if (n == length(vals)) {
    return(all_label)
  }

  if (n == 1) {
    idx <- match(selected[[1]], vals)
    if (!is.na(idx)) {
      return(labels[[idx]])
    }
    return(placeholder)
  }

  "Multiple selection"
}

#' Update a glassMultiSelect widget
#'
#' Update the available choices and/or current selection of an existing
#' [glassMultiSelect()] input.
#'
#' This function now follows Shiny-style update semantics more closely:
#'
#' \itemize{
#'   \item \code{choices = NULL} leaves choices unchanged
#'   \item \code{selected = NULL} leaves selection unchanged
#'   \item \code{selected = character(0)} clears the selection
#' }
#'
#' When \code{choices} is supplied and \code{selected} is not, the browser side
#' keeps the intersection of the current selection and the new set of choices.
#'
#' @param session Shiny session.
#' @param inputId Input id of the widget.
#' @param choices New choices, or \code{NULL} to keep current choices.
#' @param selected New selected values, or \code{NULL} to keep current
#'   selection. Use \code{character(0)} to clear.
#' @param check_style Optional new style string. One of \code{"checkbox"},
#'   \code{"check-only"}, or \code{"filled"}. Defaults to \code{NULL}, which
#'   keeps the current style unchanged.
#' @param shape Optional new corner style. One of \code{"rounded"} or
#'   \code{"square"}. Defaults to \code{NULL}, which keeps the current shape
#'   unchanged.
#'
#' @return No return value. Called for its side effect of updating the
#'   client-side widget.
#'
#' @export
updateGlassMultiSelect <- function(
    session,
    inputId,
    choices = NULL,
    selected = NULL,
    check_style = NULL,
    shape = NULL
) {
  if (!is.null(check_style)) {
    check_style <- match.arg(check_style, c("checkbox", "check-only", "filled"))
  }
  if (!is.null(shape)) {
    shape <- match.arg(shape, c("rounded", "square"))
  }

  message <- list()

  if (!is.null(choices)) {
    normalized <- .gt_normalize_choices(choices)

    message$choices <- Map(
      f = function(label, value) {
        list(label = label, value = value)
      },
      label = normalized$labels,
      value = normalized$values
    )
  }

  if (!is.null(selected)) {
    message$selected <- unname(as.character(selected))
  }

  if (!is.null(check_style)) {
    message$style <- check_style
  }

  if (!is.null(shape)) {
    message$shape <- shape
  }

  if (is.function(session$sendCustomMessage) && is.function(session$ns)) {
    session$sendCustomMessage(
      "glasstabs_update_multiselect",
      list(inputId = session$ns(inputId), data = message)
    )
  } else {
    session$sendInputMessage(inputId, message)
  }
}

#' Reactive helpers for glassMultiSelect values
#'
#' Convenience helper for extracting a multi-select widget's value and style
#' from Shiny's \code{input} object without using modules.
#'
#' @param input Shiny \code{input} object.
#' @param inputId Input id used in [glassMultiSelect()].
#'
#' @return A named list with two reactives:
#' \describe{
#'   \item{\code{selected}}{Reactive character vector of selected values}
#'   \item{\code{style}}{Reactive string for the active style}
#' }
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassMultiSelect("cats", c(A = "a", B = "b", C = "c"))
#'   )
#'
#'   server <- function(input, output, session) {
#'     ms <- glassMultiSelectValue(input, "cats")
#'     observe({
#'       message("Selected: ", paste(ms$selected(), collapse = ", "))
#'       message("Style: ", ms$style())
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @export
glassMultiSelectValue <- function(input, inputId) {
  list(
    selected = shiny::reactive(input[[inputId]] %||% character(0)),
    style = shiny::reactive(input[[paste0(inputId, "_style")]] %||% "checkbox")
  )
}

#' Register server-side search for a glassMultiSelect widget
#'
#' Use this with \code{glassMultiSelect(..., server = TRUE)} when the choice set
#' is large. The browser sends search queries to Shiny and the server returns a
#' bounded list of matching choices.
#'
#' @param inputId Input id used in [glassMultiSelect()].
#' @param choices Named or unnamed character vector of choices.
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param limit Maximum number of matching choices returned per search.
#'   Default \code{50}.
#' @param ignore_case Logical. Match labels and values case-insensitively.
#'   Default \code{TRUE}.
#'
#' @return An observer created by [shiny::observeEvent()].
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   choices <- stats::setNames(
#'     sprintf("value-%04d", 1:1000),
#'     sprintf("Choice %04d", 1:1000)
#'   )
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassMultiSelect("pick", choices, server = TRUE)
#'   )
#'
#'   server <- function(input, output, session) {
#'     glassMultiSelectServer("pick", choices, session = session)
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @export
glassMultiSelectServer <- function(
    inputId,
    choices,
    session = shiny::getDefaultReactiveDomain(),
    limit = 50L,
    ignore_case = TRUE
) {
  .gt_register_server_choices(
    inputId = inputId,
    choices = choices,
    session = session,
    limit = limit,
    ignore_case = ignore_case,
    type = "multi"
  )
}

#' @noRd
.gt_normalize_choices <- function(choices) {
  if (is.null(choices)) {
    stop(
      paste0(
        "`choices` cannot be NULL.\n",
        "Provide a character vector, e.g.:\n",
        "  choices = c(\"Option A\", \"Option B\")\n",
        "  choices = c(Label = \"value\", Other = \"other\")"
      ),
      call. = FALSE
    )
  }

  if (!length(choices)) {
    return(list(
      values = character(0),
      labels = character(0)
    ))
  }

  if (is.list(choices) && !is.atomic(choices)) {
    stop(
      paste0(
        "`choices` must be a named or unnamed atomic vector, not a list.\n",
        "Use: choices = c(\"A\", \"B\") or choices = c(Label = \"a\", Other = \"b\")\n",
        "For grouped choices, flatten to a single vector first."
      ),
      call. = FALSE
    )
  }

  orig_names <- names(choices)
  values <- as.character(unname(choices))

  if (is.null(orig_names)) {
    labels <- values
  } else {
    labels <- orig_names
  }

  list(
    values = values,
    labels = labels
  )
}

#' @noRd
.gt_normalize_hues <- function(hues, vals) {
  if (is.null(hues)) {
    return(NULL)
  }

  orig_names <- names(hues)
  hues <- as.integer(hues)

  if (is.null(orig_names)) {
    if (length(hues) != length(vals)) {
      stop(
        "`hues` must either be named by choice values or have the same length as `choices`.",
        call. = FALSE
      )
    }
    names(hues) <- vals
  } else {
    names(hues) <- as.character(orig_names)
  }

  out <- stats::setNames(rep.int(210L, length(vals)), vals)

  overlap <- intersect(vals, names(hues))
  out[overlap] <- hues[overlap]

  out <- as.integer(pmax(0L, pmin(360L, out)))
  names(out) <- vals

  out
}

#' @noRd
.gt_positive_int <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 1) {
    stop(sprintf("`%s` must be a single positive integer.", name), call. = FALSE)
  }
  as.integer(x)
}

#' @noRd
.gt_nonnegative_int <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 0) {
    stop(sprintf("`%s` must be a single non-negative integer.", name), call. = FALSE)
  }
  as.integer(x)
}

#' @noRd
.gt_json_array <- function(x) {
  x <- unname(as.character(x %||% character(0)))
  paste0("[", paste(vapply(x, .gt_js_string, character(1)), collapse = ","), "]")
}

#' @noRd
.gt_choice_payload <- function(labels, values, hues = NULL) {
  if (is.null(hues)) {
    unname(Map(
      f = function(label, value) {
        list(label = label, value = value)
      },
      label = labels,
      value = values
    ))
  } else {
    unname(Map(
      f = function(label, value, hue) {
        list(label = label, value = value, hue = unname(as.integer(hue)))
      },
      label = labels,
      value = values,
      hue = hues
    ))
  }
}

#' @noRd
.gt_filter_choices <- function(choices, query = "", limit = 50L, ignore_case = TRUE) {
  normalized <- .gt_normalize_choices(choices)
  limit <- .gt_positive_int(limit, "limit")
  query <- paste(as.character(query %||% ""), collapse = " ")
  query <- trimws(query)

  labels <- normalized$labels
  values <- normalized$values
  keep <- seq_along(values)

  if (nzchar(query)) {
    haystack <- paste(labels, values)
    if (isTRUE(ignore_case)) {
      haystack <- tolower(haystack)
      query <- tolower(query)
    }
    keep <- which(grepl(query, haystack, fixed = TRUE))
  }

  total <- length(keep)
  keep <- utils::head(keep, limit)

  list(
    labels = labels[keep],
    values = values[keep],
    indices = keep,
    total = total
  )
}

#' @noRd
.gt_register_server_choices <- function(
    inputId,
    choices,
    session,
    limit,
    ignore_case,
    type
) {
  if (is.null(session)) {
    stop("A Shiny session is required for server-side glass choice search.", call. = FALSE)
  }
  if (!is.character(inputId) || length(inputId) != 1L || !nzchar(inputId)) {
    stop("`inputId` must be a single non-empty string.", call. = FALSE)
  }
  limit <- .gt_positive_int(limit, "limit")
  normalized <- .gt_normalize_choices(choices)
  choices <- stats::setNames(normalized$values, normalized$labels)
  hues <- NULL
  if (identical(type, "multi")) {
    hues <- stats::setNames(
      as.integer(seq(200, 200 + 360 * (length(normalized$values) - 1) / max(1, length(normalized$values)),
        length.out = length(normalized$values)
      ) %% 360),
      normalized$values
    )
  }

  shiny::observeEvent(
    session$input[[paste0(inputId, "_search")]],
    {
      search <- session$input[[paste0(inputId, "_search")]]
      query <- if (is.list(search) && !is.null(search$query)) search$query else search
      filtered <- .gt_filter_choices(
        choices = choices,
        query = query,
        limit = limit,
        ignore_case = ignore_case
      )
      payload_hues <- if (is.null(hues)) NULL else hues[filtered$values]
      session$sendCustomMessage(
        "glasstabs_server_choices",
        list(
          inputId = session$ns(inputId),
          type = type,
          choices = .gt_choice_payload(filtered$labels, filtered$values, payload_hues),
          total = length(normalized$values),
          matched = filtered$total
        )
      )
    },
    ignoreInit = FALSE
  )
}
