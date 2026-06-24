#' Run a built-in glasstabs example app
#'
#' Launches one of the example Shiny apps that ship with the package.
#' A list of available examples is printed when called with no arguments.
#' Example apps are launched only in interactive sessions.
#'
#' @param example Name of the example to run, such as `"basic"`,
#'   `"bslib"`, `"dashboard"`, `"server-select"`, `"smoke-test"`, or
#'   `"square-corners"`. When `NULL` (default), lists all available
#'   examples.
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
#'   runGlassExample("bslib")
#'   runGlassExample("smoke-test")
#'   runGlassExample("server-select")
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
  if (!interactive()) {
    stop(
      "runGlassExample() launches a Shiny app and must be called interactively.\n",
      "Use if (interactive()) runGlassExample(\"", example, "\") in examples, ",
      "tests, and vignettes.",
      call. = FALSE
    )
  }
  shiny::runApp(app_dir, ...)
}

#' Display the glasstabs changelog
#'
#' Prints the package NEWS to the R console. Useful for quickly checking what
#' changed between versions without leaving your R session.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   glasstabs_news()
#' }
#'
#' @export
glasstabs_news <- function() {
  if (!interactive()) return(invisible(NULL))
  news_file <- system.file("NEWS.md", package = "glasstabs")
  if (nzchar(news_file) && file.exists(news_file)) {
    cat(readLines(news_file, warn = FALSE), sep = "\n")
    cat("\n")
  } else {
    url <- "https://github.com/prigasG/glasstabs/blob/main/NEWS.md"
    message(
      "Could not retrieve glasstabs changelog from the installed package.\n",
      "View the full changelog online: ", url
    )
  }
  invisible(NULL)
}

#' Attach glasstabs CSS and JS dependencies
#'
#' Call this once in your UI - either inside `fluidPage()`, `bs4DashPage()`,
#' or any other Shiny page wrapper. It injects the required CSS and JS as
#' proper `htmltools` dependencies so they are deduplicated automatically.
#'
#' @return An `htmltools::htmlDependency` object (invisible to the user,
#'   consumed by Shiny's renderer).
#'
#' @examples
#' # Returns an htmlDependency object - no Shiny session needed:
#' deps <- useGlassTabs()
#'
#' # Typical usage inside a Shiny UI:
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
    version = "0.3.3",
    src     = list(file = system.file("www", package = "glasstabs")),
    stylesheet = "glass.css",
    script     = "glass.js"
  )
}
