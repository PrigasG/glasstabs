library(shiny)
library(glasstabs)

choices <- c(
  "The nature of the industry is going down" = "industry-down",
  "Consumer discretionary spending on durable goods and household appliances" = "consumer-discretionary",
  "Renewable energy generation, storage, and grid-scale distribution networks" = "renewable-energy",
  "Commercial real estate development and property management services" = "commercial-real-estate",
  "Healthcare" = "healthcare"
)

short_choices <- c(
  "Operations" = "operations",
  "Finance" = "finance",
  "Product" = "product",
  "Support" = "support"
)

value_or <- function(value, fallback) {
  if (is.null(value) || !length(value)) fallback else value
}

page_css <- "
body { background: #eef3f9; color: #172033; }
.nc-shell { max-width: 1120px; margin: 0 auto; padding: 32px 20px 64px; }
.nc-hero h1 { margin: 0 0 8px; font-size: 30px; }
.nc-hero p { max-width: 850px; line-height: 1.6; color: #536078; }
.nc-controls { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 18px; margin: 22px 0; padding: 18px; border: 1px solid #d6e0ed; border-radius: 16px; background: #fff; box-shadow: 0 10px 30px rgba(46,70,110,.08); }
.nc-controls .form-group { margin-bottom: 0; }
.nc-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
.nc-card { min-width: 0; padding: 20px; border: 1px solid #d6e0ed; border-radius: 16px; background: #fff; box-shadow: 0 12px 32px rgba(46,70,110,.07); }
.nc-card h3 { margin: 0 0 6px; }
.nc-card > p { min-height: 48px; color: #607089; line-height: 1.5; }
.nc-dark { background: #0d1526; color: #e7ecf5; border-radius: 16px; padding: 18px; }
.nc-dark .nc-card { background: #111d31; border-color: rgba(255,255,255,.12); color: #e7ecf5; }
.nc-dark .nc-card > p { color: #aebcd1; }
.nc-value { margin-top: 16px; padding: 10px 12px; border-radius: 10px; background: #eef4fb; color: #26354d; font-family: ui-monospace, SFMono-Regular, Consolas, monospace; font-size: 12px; overflow-wrap: anywhere; }
.nc-dark .nc-value { background: rgba(255,255,255,.07); color: #d8e8ff; }
.nc-stack { display: grid; gap: 20px; }
.nc-note { margin-top: 18px; padding: 14px 16px; border-left: 4px solid #3182ce; border-radius: 8px; background: #e9f3ff; line-height: 1.55; }
.nc-dark .nc-note { background: rgba(49,130,206,.14); }
.nc-findings { display: grid; gap: 14px; }
.nc-finding { padding: 16px 18px; border: 1px solid #d6e0ed; border-radius: 12px; background: #fff; }
.nc-finding h3 { margin: 0 0 8px; }
.nc-finding ul { margin-bottom: 0; line-height: 1.6; }
.nc-code { margin-top: 18px; padding: 16px; border-radius: 12px; background: #101827; color: #d7e8ff; overflow-x: auto; }
.nav-tabs { margin-bottom: 18px; }
@media (max-width: 760px) {
  .nc-controls, .nc-grid { grid-template-columns: 1fr; }
  .nc-card > p { min-height: 0; }
}
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$main(
    class = "nc-shell",
    tags$header(
      class = "nc-hero",
      tags$h1("Native Shiny and glasstabs, side by side"),
      tags$p(
        "This lab compares browser-native Shiny selects, Selectize-backed ",
        "Shiny inputs, and glasstabs controls using the same choices and ",
        "width. Use each where it best fits; they share ordinary Shiny input ",
        "values and can coexist in the same form."
      )
    ),
    tags$section(
      class = "nc-controls",
      radioButtons(
        "compare_theme", "Glass theme",
        choices = c("Dark" = "dark", "Light" = "light"),
        selected = "light", inline = TRUE
      ),
      checkboxInput(
        "compare_tongue",
        "Use glass tongue attachment and animation",
        value = TRUE
      ),
      sliderInput(
        "compare_width", "Shared field width",
        min = 160, max = 360, value = 260, step = 20,
        post = " px"
      )
    ),
    tabsetPanel(
      id = "comparison_tab",
      tabPanel("Single-select", value = "single", uiOutput("single_compare")),
      tabPanel("Search and multi-select", value = "enhanced", uiOutput("enhanced_compare")),
      tabPanel("Use both", value = "coexist", uiOutput("coexist_compare")),
      tabPanel(
        "Findings",
        value = "findings",
        tags$div(
          class = "nc-findings",
          tags$div(
            class = "nc-finding",
            tags$h3("Where native Shiny is strongest"),
            tags$ul(
              tags$li("A familiar operating-system control with minimal visual weight."),
              tags$li("Excellent for short, simple lists where search and custom rendering are unnecessary."),
              tags$li("The browser owns much of the keyboard and assistive-technology behavior.")
            )
          ),
          tags$div(
            class = "nc-finding",
            tags$h3("Native and Selectize limitations exposed here"),
            tags$ul(
              tags$li("The operating-system popup cannot inherit the glass theme or tongue treatment."),
              tags$li("Long labels, menu width, wrapping, and mobile presentation vary by browser."),
              tags$li("Selectize adds search and multiple values, but its tokens and dropdown styling follow a separate design system.")
            )
          ),
          tags$div(
            class = "nc-finding",
            tags$h3("Where glasstabs earns its extra styling"),
            tags$ul(
              tags$li("Predictable long-label wrapping, matching trigger/panel widths, themes, and selection styles."),
              tags$li("Optional server search, disabled choices, custom summaries, and consistent mobile behavior."),
              tags$li("The signature tongue remains the default but can be disabled per input with tongue = FALSE.")
            )
          ),
          tags$pre(
            class = "nc-code",
            "selectInput(\"team\", \"Team\", short_choices, selectize = FALSE)\n",
            "glassSelect(\"industry\", choices, width = \"260px\", tongue = FALSE)\n",
            "glassMultiSelect(\"topics\", choices, width = \"260px\", tongue = TRUE)"
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  field_width <- reactive(paste0(value_or(input$compare_width, 260), "px"))
  glass_theme <- reactive(value_or(input$compare_theme, "light"))
  use_tongue <- reactive(isTRUE(input$compare_tongue))

  output$single_compare <- renderUI({
    width <- field_width()
    theme <- glass_theme()
    tongue <- use_tongue()

    tags$div(
      class = if (theme == "dark") "nc-dark" else NULL,
      tags$div(
        class = "nc-grid",
        tags$section(
          class = "nc-card",
          tags$h3("Native selectInput()"),
          tags$p("A browser-native popup: compact and familiar, without search, wrapping controls, or a themeable menu."),
          selectInput(
            "native_single", "Industry",
            choices = choices,
            selected = isolate(value_or(input$native_single, "industry-down")),
            selectize = FALSE,
            width = width
          ),
          tags$div(class = "nc-value", "input$native_single: ", textOutput("native_single_value", inline = TRUE))
        ),
        tags$section(
          class = "nc-card",
          tags$h3("glassSelect()"),
          tags$p("The same values with controlled wrapping, a searchable panel, matching widths, and optional tongue motion."),
          glassSelect(
            "glass_single", choices,
            label = "Industry",
            selected = isolate(value_or(input$glass_single, "industry-down")),
            searchable = TRUE,
            clearable = TRUE,
            width = width,
            tongue = tongue,
            theme = theme
          ),
          tags$div(class = "nc-value", "input$glass_single: ", textOutput("glass_single_value", inline = TRUE))
        )
      ),
      tags$div(
        class = "nc-note",
        "Both controls use the same named choice vector and produce the same scalar Shiny value. The visual behavior is the only reason to choose one over the other."
      )
    )
  })

  output$enhanced_compare <- renderUI({
    width <- field_width()
    theme <- glass_theme()
    tongue <- use_tongue()

    tags$div(
      class = if (theme == "dark") "nc-dark" else NULL,
      tags$div(
        class = "nc-grid",
        tags$section(
          class = "nc-card nc-stack",
          tags$div(
            tags$h3("Shiny selectize inputs"),
            tags$p("Shiny's enhanced path adds search and multiple values through Selectize."),
            selectizeInput(
              "native_search", "Search one",
              choices = choices,
              selected = isolate(value_or(input$native_search, "industry-down")),
              multiple = FALSE,
              width = width
            ),
            selectizeInput(
              "native_multi", "Select several",
              choices = choices,
              selected = isolate(value_or(input$native_multi, c("industry-down", "healthcare"))),
              multiple = TRUE,
              width = width
            )
          ),
          tags$div(class = "nc-value", "input$native_multi: ", textOutput("native_multi_value", inline = TRUE))
        ),
        tags$section(
          class = "nc-card nc-stack",
          tags$div(
            tags$h3("glasstabs inputs"),
            tags$p("The parallel controls keep the package's wrapping, summaries, themes, and style choices."),
            glassSelect(
              "glass_search", choices,
              label = "Search one",
              selected = isolate(value_or(input$glass_search, "industry-down")),
              width = width,
              tongue = tongue,
              theme = theme
            ),
            glassMultiSelect(
              "glass_multi", choices,
              label = "Select several",
              selected = isolate(value_or(input$glass_multi, c("industry-down", "healthcare"))),
              selection_display = "summary",
              width = width,
              tongue = tongue,
              theme = theme
            )
          ),
          tags$div(class = "nc-value", "input$glass_multi: ", textOutput("glass_multi_value", inline = TRUE))
        )
      )
    )
  })

  output$coexist_compare <- renderUI({
    width <- field_width()
    theme <- glass_theme()
    tongue <- use_tongue()

    tags$div(
      class = if (theme == "dark") "nc-dark" else NULL,
      tags$section(
        class = "nc-card",
        tags$h3("One form, two appropriate controls"),
        tags$p("Use native Shiny for the short team list and glasstabs for long, searchable topics. No adapter or exclusive choice is required."),
        tags$div(
          class = "nc-grid",
          selectInput(
            "mixed_team", "Team",
            choices = short_choices,
            selected = isolate(value_or(input$mixed_team, "operations")),
            selectize = FALSE,
            width = width
          ),
          glassMultiSelect(
            "mixed_topics", choices,
            label = "Topics",
            selected = isolate(value_or(input$mixed_topics, c("industry-down", "renewable-energy"))),
            selection_display = "summary",
            width = width,
            tongue = tongue,
            theme = theme
          )
        ),
        tags$div(
          class = "nc-value",
          "Combined server state: ", textOutput("mixed_value", inline = TRUE)
        )
      )
    )
  })

  output$native_single_value <- renderText(value_or(input$native_single, "(none)"))
  output$glass_single_value <- renderText(value_or(input$glass_single, "(none)"))
  output$native_multi_value <- renderText(paste(value_or(input$native_multi, "(none)"), collapse = ", "))
  output$glass_multi_value <- renderText(paste(value_or(input$glass_multi, "(none)"), collapse = ", "))
  output$mixed_value <- renderText(paste0(
    "team=", value_or(input$mixed_team, "(none)"),
    "; topics=", paste(value_or(input$mixed_topics, "(none)"), collapse = ", ")
  ))
}

shinyApp(ui, server)
