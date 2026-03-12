# Internal utilities

#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0) b else a
}

#' @noRd
.is_light_theme <- function(theme) {
  isTRUE(
    (is.character(theme) && length(theme) == 1 && identical(theme, "light")) ||
      (inherits(theme, "glass_select_theme") && identical(theme$mode, "light"))
  )
}

#' Label helper for glassSelect
#'
#' @param vals Choice values.
#' @param labels Choice labels.
#' @param selected Selected value or \code{NULL}.
#' @param placeholder Placeholder label when nothing is selected.
#'
#' @return A single character string used for the trigger label.
#' @noRd
.gs_label <- function(vals, labels, selected, placeholder) {
  if (is.null(selected) || length(selected) == 0) {
    return(placeholder)
  }

  idx <- match(selected[[1]], vals)
  if (is.na(idx)) {
    return(placeholder)
  }

  labels[[idx]]
}

#' Shiny tag helper for a filter-tags display area tied to a glassMultiSelect
#'
#' Renders a \code{<div>} that the JS engine will populate with colored tag pills
#' whenever the corresponding [glassMultiSelect()] selection changes.
#'
#' @param inputId The \code{inputId} of the [glassMultiSelect()] this display
#'   should reflect.
#' @param class Additional CSS classes for the container.
#'
#' @return An \code{htmltools} tag.
#' @export
glassFilterTags <- function(inputId, class = NULL) {
  classes <- c("gt-filter-tags", class)
  classes <- classes[!is.na(classes) & nzchar(classes)]

  shiny::div(
    class = paste(classes, collapse = " "),
    `data-tags-for` = inputId
  )
}
