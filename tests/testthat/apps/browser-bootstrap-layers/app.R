library(shiny)
pkg_root <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = "")
if (nzchar(pkg_root) && file.exists(file.path(pkg_root, "DESCRIPTION")) &&
    requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(pkg_root, quiet = TRUE)
} else {
  library(glasstabs)
}

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5),
  useGlassTabs(),
  actionButton("open_modal", "Open modal"),
  div(
    id = "test_offcanvas", class = "offcanvas offcanvas-end", tabindex = "-1",
    div(class = "offcanvas-body",
        glassSelect("off_single", month.abb, searchable = TRUE, width = "130px"),
        glassMultiSelect("off_multi", month.abb, searchable = TRUE, width = "130px"))
  )
)

server <- function(input, output, session) {
  observeEvent(input$open_modal, {
    showModal(modalDialog(
      glassSelect("modal_single", month.abb, searchable = TRUE, width = "130px"),
      glassMultiSelect("modal_multi", month.abb, searchable = TRUE, width = "130px"),
      easyClose = TRUE
    ))
  })
}

shinyApp(ui, server)
