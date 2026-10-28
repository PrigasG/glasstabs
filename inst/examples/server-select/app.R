library(shiny)
library(glasstabs)

choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  tags$head(
    tags$script(HTML("document.documentElement.setAttribute('data-bs-theme','dark');")),
    tags$style("
    body {
      background:#f4f8ff;
      color:#172033;
      font-family:Inter,system-ui,sans-serif;
    }
    [data-bs-theme='dark'] body { background:#071026; color:#e6eef8; }
    .demo-wrap {
      max-width:720px;
      margin:36px auto;
      display:grid;
      gap:18px;
    }
    pre {
      background:#fff;
      color:#26354d;
      border:1px solid #d6e0ed;
      border-radius:8px;
    }
    [data-bs-theme='dark'] pre {
      background:rgba(255,255,255,0.06); color:#dbeafe;
      border-color:rgba(255,255,255,0.10);
    }
    .demo-theme .form-group { margin-bottom:0; }
  "),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('server_select_theme', function(mode) {
        document.documentElement.setAttribute('data-bs-theme', mode);
      });
    "))
  ),
  div(
    class = "demo-wrap",
    h2("Server-side glass selects"),
    div(
      class = "demo-theme",
      radioButtons(
        "example_theme", "Example theme",
        choices = c("Dark" = "dark", "Light" = "light"),
        selected = "dark", inline = TRUE
      )
    ),
    glassSelect(
      "single",
      choices,
      label = "Single select",
      selected = "value-1500",
      clearable = TRUE,
      server = TRUE,
      server_limit = 30,
      theme = "auto"
    ),
    glassMultiSelect(
      "multi",
      choices,
      label = "Multi select",
      server = TRUE,
      server_limit = 30,
      show_style_switcher = FALSE,
      theme = "auto"
    ),
    verbatimTextOutput("selected")
  )
)

server <- function(input, output, session) {
  observeEvent(input$example_theme, {
    session$sendCustomMessage("server_select_theme", input$example_theme)
  }, ignoreInit = FALSE)

  glassSelectServer("single", choices, session = session, limit = 30)
  glassMultiSelectServer("multi", choices, session = session, limit = 30)

  output$selected <- renderPrint({
    multi <- input$multi
    if (is.null(multi)) multi <- character(0)

    list(
      single = input$single,
      multi_selected = length(multi)
    )
  })
}

shinyApp(ui, server)
