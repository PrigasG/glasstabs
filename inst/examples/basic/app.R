library(shiny)
library(glasstabs)

opts <- c(Alpha = "alpha", Beta = "beta", Gamma = "gamma", Delta = "delta", Epsilon = "epsilon")

ui <- fluidPage(
  useGlassTabs(),
  tags$head(
    tags$script(HTML("document.documentElement.setAttribute('data-bs-theme','dark');")),
    tags$style("
      body { background:linear-gradient(120deg,#f8fbff 0%,#edf4ff 100%);
             color:#172033; font-family:Inter,system-ui,sans-serif; margin:0; }
      [data-bs-theme='dark'] body {
        background:linear-gradient(120deg,#071026 0%,#04101a 100%); color:#e6eef8;
      }
      .basic-theme { max-width:900px; margin:18px auto 0; padding:0 20px; }
      .basic-theme .form-group { margin-bottom:0; }
    "),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('basic_theme', function(mode) {
        document.documentElement.setAttribute('data-bs-theme', mode);
      });
    "))
  ),

  tags$div(
    class = "basic-theme",
    radioButtons(
      "example_theme", "Example theme",
      choices = c("Dark" = "dark", "Light" = "light"),
      selected = "dark", inline = TRUE
    )
  ),

  glassTabsUI(
    id        = "main",
    selected  = "A",
    extra_ui  = glassMultiSelect(
      inputId     = "category",
      choices     = opts,
      placeholder = "Filter by Category",
      theme = "auto"
    ),
    theme = "auto",

    glassTabPanel("A", "Overview", selected = TRUE,
      shiny::h2("Overview"),
      shiny::p("The glass halo snaps to the active tab with a crisp spring."),
      shiny::p("Active filters:"),
      glassFilterTags("category")
    ),
    glassTabPanel("B", "Details",
      shiny::h2("Details"),
      shiny::p("Pane lifts in tightly coupled to the halo movement."),
      shiny::p("Active filters:"),
      glassFilterTags("category")
    ),
    glassTabPanel("C", "Extras",
      shiny::h2("Extras"),
      shiny::p("Three checkbox styles: Check / Box / Fill."),
      shiny::p("Active filters:"),
      glassFilterTags("category")
    ),
    glassTabPanel("D", "Final",
      shiny::h2("Final"),
      shiny::p("input$category and input[[\"main-active_tab\"]] available in server."),
      shiny::p("Active filters:"),
      glassFilterTags("category")
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$example_theme, {
    session$sendCustomMessage("basic_theme", input$example_theme)
  }, ignoreInit = FALSE)

  observe({
    cat("Tab:", input[["main-active_tab"]],
        "| Selected:", paste(input$category, collapse = ", "),
        "| Style:", input$category_style, "\n")
  })
}

shinyApp(ui, server)
