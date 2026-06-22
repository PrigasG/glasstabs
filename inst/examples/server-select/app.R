library(shiny)
library(glasstabs)

choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style("
    body {
      background:#071026;
      color:#e6eef8;
      font-family:Inter,system-ui,sans-serif;
    }
    .demo-wrap {
      max-width:720px;
      margin:36px auto;
      display:grid;
      gap:18px;
    }
    pre {
      background:rgba(255,255,255,0.06);
      color:#dbeafe;
      border:1px solid rgba(255,255,255,0.10);
      border-radius:8px;
    }
  ")),
  div(
    class = "demo-wrap",
    h2("Server-side glass selects"),
    glassSelect(
      "single",
      choices,
      label = "Single select",
      selected = "value-1500",
      clearable = TRUE,
      server = TRUE,
      server_limit = 30
    ),
    glassMultiSelect(
      "multi",
      choices,
      label = "Multi select",
      server = TRUE,
      server_limit = 30,
      show_style_switcher = FALSE
    ),
    verbatimTextOutput("selected")
  )
)

server <- function(input, output, session) {
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

if (interactive()) shinyApp(ui, server)
