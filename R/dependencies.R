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
    version = "0.2.1",
    src     = list(file = system.file("www", package = "glasstabs")),
    stylesheet = "glass.css",
    script     = "glass.js"
  )
}
