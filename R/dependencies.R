#' Run a built-in glasstabs example app
#'
#' Launches one of the example Shiny apps that ship with the package.
#' A list of available examples is printed when called with no arguments.
#'
#' @param example Name of the example to run. One of `"smoke-test"`,
#'   `"basic"`, `"bs4dash"`, `"dashboard"`. When `NULL` (default), lists
#'   all available examples.
#' @param ... Additional arguments passed to [shiny::runApp()].
#'
#' @return Called for its side-effect (launches a Shiny app).
#'
#' @examples
#' # List available examples
#' runGlassExample()
#'
#' # Run an example interactively
#' if (interactive()) {
#'   runGlassExample("smoke-test")
#' }
#'
#' @export
runGlassExample <- function(example = NULL, ...) {
  examples_dir <- system.file("examples", package = "glasstabs")
  available    <- list.dirs(examples_dir, full.names = FALSE, recursive = FALSE)
  available    <- available[nzchar(available)]

  if (is.null(example)) {
    message("Available glasstabs examples:\n",
            paste0("  - ", available, collapse = "\n"),
            "\n\nRun one with: runGlassExample(\"", available[1], "\")")
    return(invisible(available))
  }

  if (!example %in% available) {
    stop(
      sprintf(
        "Example \"%s\" not found. Available: %s",
        example,
        paste(available, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  app_dir <- file.path(examples_dir, example)
  shiny::runApp(app_dir, ...)
}

#' Attach glasstabs CSS and JS dependencies
#'
#' Call this once in your UI — either inside `fluidPage()`, `bs4DashPage()`,
#' or any other Shiny page wrapper. It injects the required CSS and JS as
#' proper `htmltools` dependencies so they are deduplicated automatically.
#'
#' @return An `htmltools::htmlDependency` object (invisible to the user,
#'   consumed by Shiny's renderer).
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassTabsUI("demo",
#'       glassTabPanel("A", "Tab A", p("Content A")),
#'       glassTabPanel("B", "Tab B", p("Content B"))
#'     )
#'   )
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' }
#'
#' @export
useGlassTabs <- function() {
  htmltools::htmlDependency(
    name    = "glasstabs",
    version = "0.3.0",
    src     = list(file = system.file("www", package = "glasstabs")),
    stylesheet = "glass.css",
    script     = "glass.js"
  )
}
