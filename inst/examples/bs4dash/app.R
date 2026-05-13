# glasstabs — bs4Dash example
# install.packages("bs4Dash")
library(shiny)
library(bs4Dash)
library(glasstabs)

opts   <- c(Alpha = "alpha", Beta = "beta", Gamma = "gamma", Delta = "delta")
months <- c(Jan = "jan", Feb = "feb", Mar = "mar", Apr = "apr")

ui <- bs4DashPage(
  header  = bs4DashNavbar(title = "glasstabs + bs4Dash"),
  sidebar = bs4DashSidebar(disable = TRUE),
  body    = bs4DashBody(

    useGlassTabs(),

    bs4Card(
      title = "Animated Tabs", width = 12,
      # wrap = FALSE — the card-body is the positioning container
      glassTabsUI(
        id            = "dash",
        wrap          = FALSE,
        compact       = TRUE,
        theme         = "light",
        dark_selector = "body.dark-mode",
        extra_ui = glassMultiSelect(
          inputId             = "filter",
          choices             = opts,
          theme               = "light",
          dark_selector       = "body.dark-mode",
          show_style_switcher = FALSE
        ),
        glassTabPanel("A", "Overview", selected = TRUE,
          p("Overview content here."),
          glassFilterTags("filter")
        ),
        glassTabPanel("B", "Details",
          p("Details content here."),
          glassFilterTags("filter"),
          glassMultiSelect(
            inputId             = "month",
            choices             = months,
            theme               = "light",
            dark_selector       = "body.dark-mode",
            show_style_switcher = FALSE,
            placeholder         = "Filter by Month",
            all_label           = "All months"
          )
        ),
        glassTabPanel("C", "Settings",
          p("Settings content here."),
          glassFilterTags("filter")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  observe({
    cat("Tab:", input[["dash-active_tab"]],
        "| Filter:", paste(input$filter, collapse = ", "), "\n")
  })
}

shinyApp(ui, server)
