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
    .mobile-frame { width: 300px; }
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
    verbatimTextOutput("fruit_open_state"),
    glassSelect(
      "shape_single",
      choices,
      selected = "apple",
      shape = "rounded"
    ),
    tags$div(
      class = "mobile-frame",
      glassTabsUI(
        "mobile_tabs",
        glassTabPanel("summary", "Summary", p("Summary content")),
        glassTabPanel("activity", "Recent activity", p("Activity content")),
        glassTabPanel("quality", "Data quality", p("Quality content")),
        glassTabPanel("settings", "Team settings", p("Settings content")),
        overflow = "scroll",
        swipe = TRUE
      )
    ),
    glassTabsUI(
      "menu_tabs",
      glassTabPanel("queue", "Queue", p("Queue content")),
      glassTabPanel("complete", "Complete", p("Complete content")),
      overflow = "menu"
    ),
    actionButton("append_tab", "Append tab")
  )
)

server <- function(input, output, session) {
  observe({
    req(input$shape)
    updateGlassSelect(session, "shape_single", shape = input$shape)
  })

  output$fruit_open_state <- renderText({
    if (isTRUE(input$fruit_open)) "open" else "closed"
  })

  observeEvent(input$append_tab, {
    appendGlassTab(
      session,
      "mobile_tabs",
      glassTabPanel("archive", "Archive", p("Archive content")),
      select = TRUE
    )
  }, once = TRUE)
}

shinyApp(ui, server)
