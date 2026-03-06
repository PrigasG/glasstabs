# Internal utilities

`%||%` <- function(a, b) if (!is.null(a)) a else b

#' Shiny tag helper for a filter-tags display area tied to a glassMultiSelect
#'
#' Renders a `<div>` that the JS engine will populate with colored tag pills
#' whenever the corresponding [glassMultiSelect()] selection changes.
#'
#' @param inputId The `inputId` of the [glassMultiSelect()] this display
#'   should reflect.
#' @param class   Additional CSS classes for the container.
#'
#' @return An `htmltools` tag.
#' @export
glassFilterTags <- function(inputId, class = NULL) {
  shiny::div(
    class            = paste(c("gt-filter-tags", class), collapse = " "),
    `data-tags-for`  = inputId
  )
}
