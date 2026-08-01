#' Experimental fillable page for glasstabs apps
#'
#' `glassPage()` is a small convenience wrapper around
#' [bslib::page_fillable()]. It adds [useGlassTabs()] automatically and uses a
#' Bootstrap 5 theme by default. The function is experimental: its arguments
#' may change during the 0.4.x development cycle as it is used in more apps.
#'
#' @param ... UI elements placed on the page.
#' @param title Optional browser-window title.
#' @param theme A [bslib::bs_theme()] object. When `NULL`, a Bootstrap 5 theme
#'   is created for the page.
#' @param padding Optional page padding passed to [bslib::page_fillable()].
#' @param gap Optional spacing between page children passed to
#'   [bslib::page_fillable()].
#' @param fillable_mobile Whether the page should use fillable sizing on mobile
#'   browsers as well as desktop browsers.
#'
#' @return A fillable Bootstrap 5 page containing the glasstabs dependency.
#'
#' @examples
#' if (interactive() && requireNamespace("bslib", quietly = TRUE)) {
#'   library(shiny)
#'
#'   ui <- glassPage(
#'     title = "Team review",
#'     glassTabsUI(
#'       "review",
#'       glassTabPanel("queue", "Queue", p("Work waiting for review")),
#'       glassTabPanel("done", "Done", p("Completed work")),
#'       theme = "auto"
#'     )
#'   )
#'
#'   shinyApp(ui, function(input, output, session) {})
#' }
#'
#' @family setup
#' @export
glassPage <- function(..., title = NULL, theme = NULL, padding = NULL,
                      gap = NULL, fillable_mobile = FALSE) {
  if (!requireNamespace("bslib", quietly = TRUE)) {
    .gt_abort(
      paste0(
        "glassPage() needs the suggested package `bslib`.",
        "\nInstall it with: install.packages(\"bslib\")"
      ),
      class = "glasstabs_error_missing_package",
      argument = "bslib",
      value = NULL,
      expected = "an installed bslib package"
    )
  }

  if (!is.null(title)) {
    .gt_check_string(
      title,
      "title",
      "glassPage(): `title` must be a single non-empty string or NULL."
    )
  }
  .gt_check_flag(fillable_mobile, "fillable_mobile")

  if (is.null(theme)) {
    theme <- bslib::bs_theme(version = 5)
  } else if (!inherits(theme, "bs_theme")) {
    .gt_abort(
      paste0(
        "glassPage(): `theme` must be a bslib theme or NULL.",
        "\nCreate one with: bslib::bs_theme()"
      ),
      class = "glasstabs_error_bad_theme",
      argument = "theme",
      value = theme,
      expected = "a bslib::bs_theme() object or NULL"
    )
  }

  children <- list(...)
  args <- c(
    list(useGlassTabs()),
    children,
    list(
      padding = padding,
      gap = gap,
      fillable_mobile = fillable_mobile,
      title = title,
      theme = theme
    )
  )

  do.call(bslib::page_fillable, args)
}
