library(shiny)
pkg_root <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = "")
if (nzchar(pkg_root) && file.exists(file.path(pkg_root, "DESCRIPTION")) &&
    requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(pkg_root, quiet = TRUE)
} else {
  library(glasstabs)
}

ui <- fluidPage(
  useGlassTabs(),
  actionButton("open_modal", "Open modal"),
  textOutput("selection")
)

server <- function(input, output, session) {
  observeEvent(input$open_modal, {
    showModal(modalDialog(
      glassSelect("modal_single", month.abb, searchable = TRUE),
      glassMultiSelect("modal_multi", month.abb, searchable = TRUE),
      easyClose = TRUE
    ))
  })
  output$selection <- renderText(paste(input$modal_single, paste(input$modal_multi, collapse = ",")))
}

shinyApp(ui, server)
