# Internal utilities

`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0) b else a
}

#' Shiny tag helper for a filter-tags display area tied to a glassMultiSelect
#'
#' Renders a `<div>` that the JS engine will populate with colored tag pills
#' whenever the corresponding [glassMultiSelect()] selection changes.
#'
#' @param inputId The `inputId` of the [glassMultiSelect()] this display
#'   should reflect.
#' @param class Additional CSS classes for the container.
#'
#' @return An `htmltools` tag.
#' @export
glassFilterTags <- function(inputId, class = NULL) {
  shiny::div(
    class = paste(c("gt-filter-tags", class), collapse = " "),
    `data-tags-for` = inputId
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
