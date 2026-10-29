#' Animated glass single-select dropdown
#'
#' A stylized single-select Shiny input with optional search, clear control,
#' selection-marker styling, and programmatic updates via [updateGlassSelect()].
#'
#' The widget registers one Shiny input:
#'
#' \itemize{
#'   \item \code{input$<inputId>} : selected value as a length-1 character string,
#'   or \code{NULL} when nothing is selected
#' }
#'
#' @param selected Initially selected value. Defaults to \code{NULL}.
#' @param searchable Search visibility. Use \code{TRUE} (default) to always
#'   show search, \code{FALSE} to hide it, or \code{"auto"} to show it only
#'   when the choice count reaches \code{search_threshold}.
#' @param clearable Logical. Show clear control for removing the current
#'   selection? Default \code{FALSE}.
#' @param include_all Logical. Prepend an explicit "All" option. Default
#'   \code{FALSE}.
#' @param all_choice_label Label used for the explicit "All" option.
#' @param all_choice_value Value used for the explicit "All" option.
#' @param server Logical. If \code{TRUE}, render only an initial slice of
#'   choices and use [glassSelectServer()] to search the full choice set from
#'   the Shiny server. Default \code{FALSE}.
#' @param overflow_tooltip Tooltip behavior for trigger text that is visually
#'   truncated with an ellipsis. \code{"auto"} (default) shows the complete
#'   text on pointer hover or keyboard focus only when truncation is detected;
#'   \code{"never"} disables it. On touch devices, opening the dropdown remains
#'   the primary way to inspect the full, wrapped option text.
#' @inheritParams glassMultiSelect
#'
#' @return An \code{htmltools::tagList} containing the single-select trigger,
#'   dropdown panel, and scoped \code{<style>} block.
#' @family glass select widgets
#'
#' @examples
#' fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
#'
#' fruit_select <- glassSelect("fruit", fruits)
#'
#' selected_fruit <- glassSelect(
#'   "fruit",
#'   fruits,
#'   selected = "banana",
#'   clearable = TRUE
#' )
#'
#' all_fruits <- glassSelect(
#'   "fruit",
#'   fruits,
#'   include_all = TRUE,
#'   all_choice_label = "All fruits",
#'   all_choice_value = "__all__"
#' )
#'
#' filled_fruit <- glassSelect(
#'   "fruit",
#'   fruits,
#'   check_style = "filled"
#' )
#'
#' @export
glassSelect <- function(
    inputId,
    choices,
    selected = NULL,
    label = NULL,
    placeholder = "Select an option",
    searchable = TRUE,
    clearable = FALSE,
    include_all = FALSE,
    all_choice_label = "All categories",
    all_choice_value = "__all__",
    check_style = c("checkbox", "check-only", "filled"),
    theme = "dark",
    shape = c("rounded", "square"),
    width = NULL,
    disabled = FALSE,
    disabled_choices = NULL,
    server = FALSE,
    server_limit = 50L,
    server_min_chars = 0L,
    no_matches_text = "No matches",
    tongue = TRUE,
    label_bold = TRUE,
    label_size = "14px",
    search_focus_ring = FALSE,
    overflow_tooltip = c("auto", "never"),
    search_threshold = 15L,
    dark_selector = NULL
) {
  .gt_check_string(
    inputId,
    "inputId",
    "glassSelect(): `inputId` must be a single non-empty string."
  )
  .gt_check_text(no_matches_text, "no_matches_text", "glassSelect")
  .gt_check_flag(clearable, "clearable")
  .gt_check_flag(include_all, "include_all")
  .gt_check_flag(disabled, "disabled")
  .gt_check_flag(server, "server")
  .gt_check_flag(tongue, "tongue")
  .gt_check_flag(label_bold, "label_bold")
  .gt_check_flag(search_focus_ring, "search_focus_ring")
  label_size <- .gt_css_unit(label_size, "label_size")
  overflow_tooltip <- .gt_match_arg(
    overflow_tooltip,
    c("auto", "never"),
    "overflow_tooltip"
  )
  check_style <- .gt_match_arg(check_style, c("checkbox", "check-only", "filled"), "check_style")
  shape <- .gt_match_arg(shape, c("rounded", "square"), "shape")
  searchable <- .gt_search_mode(searchable)
  search_threshold <- .gt_positive_int(search_threshold, "search_threshold")
  field_width_style <- .gt_field_width_style(width)
  inner_width_style <- if (is.null(width)) NULL else "width:100%;"
  disabled_choices <- if (is.null(disabled_choices)) character(0) else as.character(disabled_choices)
  server_limit <- .gt_positive_int(server_limit, "server_limit")
  server_min_chars <- .gt_nonnegative_int(server_min_chars, "server_min_chars")
  colors <- .ms_resolve_theme(theme)
  is_auto <- .is_auto_theme(theme)
  if (is_auto && is.null(dark_selector)) dark_selector <- '[data-bs-theme="dark"]'
  if (!is.null(dark_selector)) .gt_check_string(dark_selector, "dark_selector")

  normalized <- .gt_normalize_choices(choices)
  vals <- normalized$values
  labels <- normalized$labels
  groups <- normalized$groups

  if (isTRUE(include_all) && !all_choice_value %in% vals) {
    vals <- c(all_choice_value, vals)
    labels <- c(all_choice_label, labels)
    groups <- c("", groups)
  }

  if (!is.null(selected)) {
    .gt_check_no_missing(selected, "selected", "glassSelect")
    selected <- as.character(selected)

    if (length(selected) > 1) {
      .gt_abort(
        sprintf(
          paste0(
            "glassSelect(): `selected` must be a single value, got %d values: %s\n",
            "For multi-selection use glassMultiSelect() instead."
          ),
          length(selected), paste(utils::head(selected, 3), collapse = ", ")
        ),
        class = "glasstabs_error_bad_choice",
        argument = "selected",
        value = selected,
        expected = "a single choice value"
      )
    }

    if (length(selected) == 0) {
      selected <- NULL
    } else {
      selected <- selected[[1]]

      if (!selected %in% vals) {
        selected <- NULL
      }
    }
  }

  init_label <- .gs_label(
    vals = vals,
    labels = labels,
    selected = selected,
    placeholder = placeholder
  )

  render_idx <- seq_along(vals)
  if (server) {
    render_idx <- seq_len(min(length(vals), server_limit))
    if (!is.null(selected)) {
      selected_idx <- match(selected, vals)
      if (!is.na(selected_idx) && !selected_idx %in% render_idx) {
        render_idx <- c(render_idx, selected_idx)
      }
    }
  }
  render_vals <- vals[render_idx]
  render_labels <- labels[render_idx]
  render_groups <- groups[render_idx]

  field_id <- paste0(inputId, "-field")
  scope_id <- paste0(inputId, "-wrap")

  theme_css <- sprintf(
    "#%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;--ms-focus-ring:%s;--ms-label:%s;--gt-label-size:%s;%s}",
    field_id, colors$bg, colors$border, colors$text, colors$accent, colors$focus, colors$label,
    label_size, .to_rgba_vars(colors)
  )
  dark_override_style <- if (is_auto) {
    .select_dark_override_style(dark_selector, field_id)
  } else {
    NULL
  }

  wrap_cls <- trimws(gsub(
    "[ ]+", " ",
    paste(
      "gt-gs-wrap",
      paste0("style-", check_style),
      if (search_focus_ring) "gt-search-ring" else NULL,
      if (!tongue) "gt-no-tongue" else NULL,
      if (identical(shape, "square")) "shape-square" else NULL,
      if (disabled) "gt-disabled" else NULL,
      if (is_auto) "theme-auto" else NULL,
      if (.is_light_theme(theme)) "theme-light" else NULL
    )
  ))

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
      class = trimws(paste(
        "gt-input-label",
        if (!label_bold) "gt-label-regular" else NULL
      )),
      `for` = paste0(inputId, "-trigger"),
      label
    )
  } else {
    NULL
  }

  option_rows <- list()
  prev_group <- ""
  for (i in seq_along(render_vals)) {
    v <- render_vals[[i]]
    lbl <- render_labels[[i]]
    grp <- render_groups[[i]]

    if (nzchar(grp) && !identical(grp, prev_group)) {
      option_rows[[length(option_rows) + 1L]] <- shiny::div(
        class = "gt-gs-optgroup",
        `data-group` = grp,
        role = "presentation",
        grp
      )
    }
    prev_group <- grp

    is_disabled <- v %in% disabled_choices
    cls <- paste(
      c(
        "gt-gs-option",
        if (!is.null(selected) && identical(v, selected)) "selected" else NULL,
        if (is_disabled) "disabled" else NULL
      ),
      collapse = " "
    )

    option_rows[[length(option_rows) + 1L]] <- shiny::div(
      class = cls,
      `data-value` = v,
      `data-group` = if (nzchar(grp)) grp else NULL,
      role = "option",
      `aria-selected` = if (!is.null(selected) && identical(v, selected)) "true" else "false",
      `aria-disabled` = if (is_disabled) "true" else NULL,
      shiny::div(class = "gt-gs-check", check_svg),
      shiny::tags$span(lbl)
    )
  }

  clear_btn <- if (isTRUE(clearable)) {
    shiny::tags$span(
      class = "gt-gs-clear",
      id = paste0(inputId, "-clear"),
      "Clear"
    )
  } else {
    shiny::tags$span(
      class = "gt-gs-clear",
      id = paste0(inputId, "-clear"),
      style = "display:none;",
      "Clear"
    )
  }

  htmltools::tagList(
    .make_style_tag(theme_css),
    dark_override_style,
    shiny::div(
      class = "gt-gs-field",
      id = field_id,
      style = field_width_style,
      label_tag,
      shiny::div(
        class = wrap_cls,
        id = scope_id,
        style = inner_width_style,
        `data-input-id` = inputId,
        `data-placeholder` = placeholder,
        `data-no-matches-text` = no_matches_text,
        `data-searchable` = searchable,
        `data-search-threshold` = as.character(search_threshold),
        `data-clearable` = tolower(as.character(clearable)),
        `data-all-choice-label` = all_choice_label,
        `data-all-choice-value` = all_choice_value,
        `data-server` = tolower(as.character(server)),
        `data-server-total` = as.character(length(vals)),
        `data-server-min-chars` = as.character(server_min_chars),
        `data-overflow-tooltip` = overflow_tooltip,

        shiny::div(
          class = "gt-gs-trigger",
          id = paste0(inputId, "-trigger"),
          style = inner_width_style,
          role = "combobox",
          tabindex = if (disabled) "-1" else "0",
          `aria-haspopup` = "listbox",
          `aria-expanded` = "false",
          `aria-disabled` = if (disabled) "true" else NULL,
          `aria-controls` = paste0(inputId, "-dropdown"),
          shiny::tags$span(id = paste0(inputId, "-label"), init_label),
          shiny::div(
            style = "display:flex;align-items:center;gap:6px;",
            clear_btn,
            shiny::tags$svg(
              class = "gt-gs-chevron",
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
          class = "gt-gs-dropdown",
          id = paste0(inputId, "-dropdown"),
          role = "listbox",

          shiny::div(
            class = trimws(paste(
              "gt-gs-search",
              if (identical(searchable, "never") ||
                  (identical(searchable, "auto") && length(vals) < search_threshold)) "hidden" else NULL
            )),
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

          shiny::div(
            id = paste0(inputId, "-options"),
            option_rows
          )
        )
      )
    )
  )
}

#' Update a glassSelect widget
#'
#' Update the available choices, current selection, and/or selection-marker
#' style of an existing [glassSelect()] input.
#'
#' This function follows Shiny-style update semantics:
#'
#' \itemize{
#'   \item \code{choices = NULL} leaves choices unchanged
#'   \item \code{selected = NULL} leaves selection unchanged
#'   \item \code{selected = character(0)} clears the selection
#'   \item \code{check_style = NULL} leaves the current style unchanged
#' }
#'
#' When \code{choices} is supplied and \code{selected} is not, the browser side
#' keeps the current selection if it is still present in the new choices.
#'
#' @param session Shiny session.
#' @param inputId Input id of the widget.
#' @param choices New choices, or \code{NULL} to keep current choices.
#' @param selected New selected value, or \code{NULL} to keep the current
#'   selection. Use \code{character(0)} to clear.
#' @param check_style Optional new style string. One of \code{"checkbox"},
#'   \code{"check-only"}, or \code{"filled"}. Defaults to \code{NULL}, which
#'   keeps the current style unchanged.
#' @param shape Optional new corner style. One of \code{"rounded"} or
#'   \code{"square"}. Defaults to \code{NULL}, which keeps the current shape
#'   unchanged.
#' @param disabled Optional logical. \code{TRUE}/\code{FALSE} toggles the
#'   whole-widget disabled state. Defaults to \code{NULL}, which leaves it
#'   unchanged.
#' @param disabled_choices Optional character vector of choice values to render
#'   as disabled. Defaults to \code{NULL}, which leaves disabled choices
#'   unchanged.
#' @param searchable Optional new search visibility: \code{TRUE}, \code{FALSE},
#'   or \code{"auto"}. \code{NULL} keeps the current setting.
#' @param search_threshold Optional new choice-count threshold used when
#'   \code{searchable = "auto"}. \code{NULL} keeps the current threshold.
#'
#' @return No return value. Called for its side effect of updating the client-side
#'   widget.
#'
#' @family glass select widgets
#' @export
updateGlassSelect <- function(
    session,
    inputId,
    choices = NULL,
    selected = NULL,
    check_style = NULL,
    shape = NULL,
    disabled = NULL,
    disabled_choices = NULL,
    searchable = NULL,
    search_threshold = NULL
) {
  if (is.function(session$sendCustomMessage) && is.function(session$ns)) {
    .gt_check_session(session, "sendCustomMessage")
  } else {
    .gt_check_session(session, "sendInputMessage")
  }
  if (!is.null(check_style)) {
    check_style <- .gt_match_arg(check_style, c("checkbox", "check-only", "filled"), "check_style")
  }
  if (!is.null(shape)) {
    shape <- .gt_match_arg(shape, c("rounded", "square"), "shape")
  }
  if (!is.null(disabled)) .gt_check_flag(disabled, "disabled")
  if (!is.null(searchable)) searchable <- .gt_search_mode(searchable)
  if (!is.null(search_threshold)) {
    search_threshold <- .gt_positive_int(search_threshold, "search_threshold")
  }

  message <- list()

  if (!is.null(choices)) {
    message$choices <- .gt_update_choice_payload(choices, disabled_choices)
  }

  if (!is.null(selected)) {
    .gt_check_no_missing(selected, "selected", "updateGlassSelect")
    selected <- as.character(selected)

    if (length(selected) > 1) {
      .gt_abort(
        sprintf(
          paste0(
            "updateGlassSelect(): `selected` must be a single value or character(0) to clear,\n",
            "got %d values. For multi-selection use updateGlassMultiSelect() instead."
          ),
          length(selected)
        ),
        class = "glasstabs_error_bad_choice",
        argument = "selected",
        value = selected,
        expected = "a single choice value or character(0)"
      )
    }

    message$selected <- unname(selected)
  }

  if (!is.null(check_style)) {
    message$style <- check_style
  }

  if (!is.null(shape)) {
    message$shape <- shape
  }

  if (!is.null(disabled)) {
    message$disabled <- disabled
  }

  if (!is.null(disabled_choices)) {
    message$disabled_choices <- unname(as.character(disabled_choices))
  }
  if (!is.null(searchable)) message$searchable <- searchable
  if (!is.null(search_threshold)) message$search_threshold <- search_threshold

  if (is.function(session$sendCustomMessage) && is.function(session$ns)) {
    session$sendCustomMessage(
      "glasstabs_update_select",
      list(inputId = session$ns(inputId), data = message)
    )
  } else {
    session$sendInputMessage(inputId, message)
  }
  invisible(NULL)
}

#' Reactive helper for glassSelect values
#'
#' Convenience helper for extracting a single-select widget's value from Shiny's
#' \code{input} object without using modules.
#'
#' @param input Shiny \code{input} object.
#' @param inputId Input id used in [glassSelect()].
#'
#' @return A reactive expression returning the current selected value as a
#'   character scalar, or \code{NULL} when nothing is selected.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassSelect("fruit", c(Apple = "apple", Banana = "banana"))
#'   )
#'
#'   server <- function(input, output, session) {
#'     fruit <- glassSelectValue(input, "fruit")
#'     observe({
#'       print(fruit())
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @family glass select widgets
#' @export
glassSelectValue <- function(input, inputId) {
  shiny::reactive(input[[inputId]] %||% NULL)
}

#' Register server-side search for a glassSelect widget
#'
#' Use this with \code{glassSelect(..., server = TRUE)} when the choice set is
#' large. The browser sends search queries to Shiny and the server returns a
#' bounded list of matching choices.
#'
#' @param inputId Input id used in [glassSelect()].
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
#'     glassSelect("pick", choices, server = TRUE)
#'   )
#'
#'   server <- function(input, output, session) {
#'     glassSelectServer("pick", choices, session = session)
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @family glass select widgets
#' @export
glassSelectServer <- function(
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
    type = "single"
  )
}
