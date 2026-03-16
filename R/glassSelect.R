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
#' @param inputId Shiny input id.
#' @param choices Named or unnamed character vector of choices.
#' @param selected Initially selected value. Defaults to \code{NULL}.
#' @param label Optional field label shown above the widget.
#' @param placeholder Trigger label when nothing is selected.
#' @param searchable Logical. Show search input inside dropdown? Default
#'   \code{TRUE}.
#' @param clearable Logical. Show clear control for removing the current
#'   selection? Default \code{FALSE}.
#' @param include_all Logical. Prepend an explicit "All" option. Default
#'   \code{FALSE}.
#' @param all_choice_label Label used for the explicit "All" option.
#' @param all_choice_value Value used for the explicit "All" option.
#' @param check_style One of \code{"checkbox"} (default),
#'   \code{"check-only"}, or \code{"filled"}.
#' @param theme Color theme. One of \code{"dark"} (default) or \code{"light"},
#'   or a [glass_select_theme()] object.
#'
#' @return An \code{htmltools::tagList} containing the single-select trigger,
#'   dropdown panel, and scoped \code{<style>} block.
#'
#' @examples
#' fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
#'
#' glassSelect("fruit", fruits)
#'
#' glassSelect(
#'   "fruit",
#'   fruits,
#'   selected = "banana",
#'   clearable = TRUE
#' )
#'
#' glassSelect(
#'   "fruit",
#'   fruits,
#'   include_all = TRUE,
#'   all_choice_label = "All fruits",
#'   all_choice_value = "__all__"
#' )
#'
#' glassSelect(
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
    theme = "dark"
) {
  check_style <- match.arg(check_style)
  colors <- .ms_resolve_theme(theme)

  normalized <- .gt_normalize_choices(choices)
  vals <- normalized$values
  labels <- normalized$labels

  if (isTRUE(include_all) && !all_choice_value %in% vals) {
    vals <- c(all_choice_value, vals)
    labels <- c(all_choice_label, labels)
  }

  if (!is.null(selected)) {
    selected <- as.character(selected)

    if (length(selected) > 1) {
      stop("`selected` must be NULL, character(0), or a single value for glassSelect().", call. = FALSE)
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

  field_id <- paste0(inputId, "-field")
  scope_id <- paste0(inputId, "-wrap")

  theme_css <- sprintf(
    "#%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;--ms-label:%s;}",
    field_id, colors$bg, colors$border, colors$text, colors$accent, colors$label
  )

  wrap_cls <- paste(
    "gt-gs-wrap",
    paste0("style-", check_style),
    if (.is_light_theme(theme)) "theme-light" else NULL
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

  option_rows <- lapply(seq_along(vals), function(i) {
    v <- vals[[i]]
    lbl <- labels[[i]]
    cls <- paste(
      c(
        "gt-gs-option",
        if (!is.null(selected) && identical(v, selected)) "selected" else NULL
      ),
      collapse = " "
    )

    shiny::div(
      class = cls,
      `data-value` = v,
      shiny::div(class = "gt-gs-check", check_svg),
      shiny::tags$span(lbl)
    )
  })

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
    shiny::tags$style(theme_css),
    shiny::div(
      class = "gt-gs-field",
      id = field_id,
      label_tag,
      shiny::div(
        class = wrap_cls,
        id = scope_id,
        `data-input-id` = inputId,
        `data-placeholder` = placeholder,
        `data-searchable` = tolower(as.character(searchable)),
        `data-clearable` = tolower(as.character(clearable)),
        `data-all-choice-label` = all_choice_label,
        `data-all-choice-value` = all_choice_value,

        shiny::div(
          class = "gt-gs-trigger",
          id = paste0(inputId, "-trigger"),
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

          if (isTRUE(searchable)) {
            shiny::div(
              class = "gt-gs-search",
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
            )
          },

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
#'
#' @return No return value. Called for its side effect of updating the client-side
#'   widget.
#'
#' @export
updateGlassSelect <- function(
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
    selected <- as.character(selected)

    if (length(selected) > 1) {
      stop(
        "`selected` must be NULL, character(0), or a single value in updateGlassSelect().",
        call. = FALSE
      )
    }

    message$selected <- unname(selected)
  }

  if (!is.null(check_style)) {
    message$style <- check_style
  }

  session$sendInputMessage(inputId, message)
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
#' @export
glassSelectValue <- function(input, inputId) {
  shiny::reactive(input[[inputId]] %||% NULL)
}
