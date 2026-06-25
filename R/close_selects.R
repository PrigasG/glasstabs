#' Close open glass select dropdowns
#'
#' Programmatically closes one `glassSelect()` dropdown, one
#' `glassMultiSelect()` dropdown, or every open glasstabs select dropdown in
#' the current Shiny session.
#'
#' These helpers are useful before switching tabs, opening modals, rebuilding
#' UI, or changing layouts that can otherwise leave a dropdown visually open
#' after its trigger moved or disappeared.
#'
#' @param session Shiny session. Defaults to the current reactive domain.
#' @param inputId Input id of the widget.
#'
#' @return No return value. Called for the side effect of closing dropdowns in
#'   the browser.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     actionButton("close", "Close dropdowns"),
#'     glassSelect("region", c(North = "north", South = "south")),
#'     glassMultiSelect("filters", c(A = "a", B = "b"))
#'   )
#'
#'   server <- function(input, output, session) {
#'     observeEvent(input$close, {
#'       closeAllGlassSelects(session)
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @export
closeGlassSelect <- function(session = shiny::getDefaultReactiveDomain(), inputId) {
  .gt_close_select(session, inputId, type = "single")
}

#' @rdname closeGlassSelect
#' @export
closeGlassMultiSelect <- function(session = shiny::getDefaultReactiveDomain(), inputId) {
  .gt_close_select(session, inputId, type = "multi")
}

#' @rdname closeGlassSelect
#' @export
closeAllGlassSelects <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session) || !is.function(session$sendCustomMessage)) {
    stop("`session` must be a Shiny session with sendCustomMessage().", call. = FALSE)
  }

  session$sendCustomMessage("glasstabs_close_selects", list())
  invisible(NULL)
}

#' @noRd
.gt_close_select <- function(session, inputId, type) {
  if (missing(inputId) || length(inputId) != 1 || is.na(inputId) || !nzchar(inputId)) {
    stop("`inputId` must be a non-empty character scalar.", call. = FALSE)
  }
  if (is.null(session) || !is.function(session$sendInputMessage)) {
    stop("`session` must be a Shiny session with sendInputMessage().", call. = FALSE)
  }

  session$sendInputMessage(inputId, list(close = TRUE))
  invisible(NULL)
}
