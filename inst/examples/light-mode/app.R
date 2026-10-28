library(shiny)
library(glasstabs)

# A bright, everyday application showing that glasstabs is not limited to
# dark dashboards. Long labels intentionally exercise adaptive dropdown width.

teams <- c(
  "Customer success and implementation" = "customer-success",
  "Product design and user research" = "product-design",
  "Data engineering and analytics" = "data-engineering",
  "Finance and business operations" = "finance",
  "Sales" = "sales"
)

priorities <- c(
  "High priority - needs attention this week" = "high",
  "Medium priority - review during planning" = "medium",
  "Low priority - keep on the backlog" = "low"
)

page_css <- "
body {
  background: linear-gradient(145deg, #f8fbff 0%, #eef5ff 100%);
  color: #172033;
  font-family: Inter, system-ui, sans-serif;
}
.light-shell { max-width: 980px; margin: 0 auto; padding: 36px 20px 56px; }
.light-hero { margin-bottom: 22px; }
.light-hero h1 { margin: 0 0 8px; color: #172033; font-size: 30px; }
.light-hero p { margin: 0; max-width: 700px; color: #52627a; line-height: 1.6; }
.light-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
.light-card {
  min-width: 0; padding: 20px; border: 1px solid #d8e2ef; border-radius: 16px;
  background: rgba(255,255,255,.86); box-shadow: 0 14px 38px rgba(46,70,110,.08);
}
.light-card h3 { margin: 0 0 6px; color: #1f2a44; font-size: 18px; }
.light-card p { margin: 0 0 16px; color: #607089; }
.light-state { margin-top: 20px; padding: 16px 18px; border-radius: 12px; background: #fff; border: 1px solid #d8e2ef; }
@media (max-width: 700px) { .light-grid { grid-template-columns: 1fr; } }
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$main(
    class = "light-shell",
    tags$header(
      class = "light-hero",
      tags$h1("glasstabs in light mode"),
      tags$p(
        "A bright workspace with adaptive dropdowns. Short choices stay compact, ",
        "while longer labels receive enough room and wrap only when necessary."
      )
    ),
    glassTabsUI(
      "light_tabs",
      glassTabPanel(
        "filters", "Filters", selected = TRUE,
        tags$div(
          class = "light-grid",
          tags$section(
            class = "light-card",
            tags$h3("Single select"),
            tags$p("Open the menu to compare short and long team names."),
            glassSelect(
              "team", teams,
              label = "Owning team",
              placeholder = "Choose a team",
              searchable = TRUE,
              clearable = TRUE,
              theme = "light"
            )
          ),
          tags$section(
            class = "light-card",
            tags$h3("Multi-select"),
            tags$p("The Check, Box, and Fill controls remain fully visible."),
            glassMultiSelect(
              "priority", priorities,
              selected = c("high", "medium"),
              label = "Priority bands",
              show_style_switcher = TRUE,
              selection_display = "summary",
              theme = "light"
            )
          )
        ),
        tags$div(class = "light-state", verbatimTextOutput("selection"))
      ),
      glassTabPanel(
        "about", "About this example",
        tags$div(
          class = "light-card",
          tags$h3("Designed for both modes"),
          tags$p(
            "Use theme = \"light\" for a fixed bright interface, or theme = ",
            "\"auto\" in Bootstrap 5 applications that switch modes live."
          )
        )
      ),
      theme = "light"
    )
  )
)

server <- function(input, output, session) {
  output$selection <- renderPrint({
    list(team = input$team, priorities = input$priority)
  })
}

if (interactive()) shinyApp(ui, server)
