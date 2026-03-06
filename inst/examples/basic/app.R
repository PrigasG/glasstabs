# glasstabs — basic Shiny example
# Run with: shiny::runApp("inst/examples/basic")
library(shiny)
library(glasstabs)

opts <- c(Alpha = "alpha", Beta = "beta", Gamma = "gamma", Delta = "delta", Epsilon = "epsilon")

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style("
    body { background: linear-gradient(120deg,#071026 0%,#04101a 100%);
           color:#e6eef8; font-family:Inter,system-ui,sans-serif; margin:0; }
  ")),

  glassTabsUI(
    id        = "main",
    selected  = "A",
    extra_ui  = glassMultiSelect(
      inputId     = "category",
      choices     = opts,
      placeholder = "Filter by Category"
    ),

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
      shiny::p("input$category and input$main_active available in server."),
      shiny::p("Active filters:"),
      glassFilterTags("category")
    )
  )
)

server <- function(input, output, session) {
  observe({
    cat("Tab:", input[["main-active_tab"]],
        "| Selected:", paste(input$category, collapse = ", "),
        "| Style:", input$category_style, "\n")
  })
}

shinyApp(ui, server)
