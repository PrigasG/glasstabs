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
#' @param hues Optional named integer vector of HSL hue angles (0 to 360) for
#'   the \code{"filled"} style. Auto-assigned if \code{NULL}.
#'
#' @return An \code{htmltools::tagList} containing the trigger button, dropdown
#'   panel, and scoped \code{<style>} block.
#'
#' @examples
#' fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
#'
#' # Minimal
#' glassMultiSelect("f", fruits)
#'
#' # Lock style, hide extra controls
#' glassMultiSelect(
#'   "f",
#'   fruits,
#'   check_style = "check-only",
#'   show_style_switcher = FALSE,
#'   show_select_all = FALSE,
#'   show_clear_all = FALSE
#' )
#'
#' # Light theme
#' glassMultiSelect("f", fruits, theme = "light")
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
    hues                = NULL
) {
  check_style <- match.arg(check_style)
  colors <- .ms_resolve_theme(theme)

  # Normalize choices
  normalized <- .gt_normalize_choices(choices)
  vals <- normalized$values
  labels <- normalized$labels


  # Preserve existing CRAN behavior:
  # selected = NULL means all choices selected initially
  if (is.null(selected)) {
    selected <- vals
  } else {
    selected <- as.character(selected)
  }

  # Keep only valid selected values, preserve choice order
  selected <- vals[vals %in% selected]

  # Auto hues
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

  field_id <- paste0(inputId, "-field")
  scope_id <- paste0(inputId, "-wrap")

  theme_css <- sprintf(
    "#%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;--ms-label:%s;}",
    field_id, colors$bg, colors$border, colors$text, colors$accent, colors$label
  )

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
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  } else {
    shiny::div(
      class = all_cls,
      id = paste0(inputId, "-all"),
      style = "display:none;",
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  }

  option_rows <- lapply(seq_along(vals), function(i) {
    v <- vals[[i]]
    lbl <- labels[[i]]
    cls <- paste("gt-ms-option", if (v %in% selected) "checked" else "")

    shiny::div(
      class = cls,
      `data-value` = v,
      style = paste0("--opt-hue:", unname(hues[v]), ";"),
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
    if (.is_light_theme(theme)) "theme-light" else NULL
  )

  htmltools::tagList(
    shiny::tags$style(theme_css),
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

        shiny::div(
          class = "gt-ms-trigger",
          id = paste0(inputId, "-trigger"),
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
#'
#' @export
updateGlassMultiSelect <- function(
    session,
    inputId,
    choices = NULL,
    selected = NULL,
    check_style = NULL
) {
  if (!is.null(check_style)) {
    check_style <- match.arg(check_style, c("checkbox", "check-only", "filled"))
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

  session$sendInputMessage(inputId, message)
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
