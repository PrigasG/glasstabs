library(shiny)

pkg_root <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = "")
if (!nzchar(pkg_root)) {
  pkg_root <- normalizePath(file.path(getwd(), "..", "..", ".."), mustWork = FALSE)
}
if (file.exists(file.path(pkg_root, "DESCRIPTION")) &&
    requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(pkg_root, quiet = TRUE)
} else {
  library(glasstabs)
}

choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

ui <- fluidPage(
  useGlassTabs(),
  tags$style(HTML("
    body { padding: 24px; }
    .test-row { max-width: 420px; display: grid; gap: 18px; }
  ")),
  tags$div(
    class = "test-row",
    glassSelect(
      "fruit",
      choices,
      selected = "apple",
      clearable = TRUE,
      shape = "rounded"
    ),
    glassMultiSelect(
      "cats",
      choices,
      selected = "apple",
      show_style_switcher = FALSE,
      shape = "rounded"
    ),
    radioButtons(
      "shape",
      "Shape",
      choices = c(Rounded = "rounded", Square = "square"),
      selected = "rounded",
      inline = TRUE
    ),
    glassSelect(
      "shape_single",
      choices,
      selected = "apple",
      shape = "rounded"
    )
  )
)

server <- function(input, output, session) {
  observe({
    req(input$shape)
    updateGlassSelect(session, "shape_single", shape = input$shape)
  })
}

shinyApp(ui, server)
