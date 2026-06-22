library(shiny)
library(glasstabs)

# ---------------------------------------------------------------------------
# glasstabs + bslib square-corner example
#
# Demonstrates glassSelect() and glassMultiSelect() with shape = "square"
# inside a bslib-themed app, alongside a native selectizeInput().
#
# Run with:  if (interactive()) glasstabs::runGlassExample("bslib")
# ---------------------------------------------------------------------------

if (!requireNamespace("bslib", quietly = TRUE)) {
  stop(
    "The bslib example requires the bslib package.\n",
    "Install it with install.packages(\"bslib\") and rerun runGlassExample(\"bslib\").",
    call. = FALSE
  )
}

products <- c(
  "Analytics Suite" = "analytics",
  "Forecast Desk" = "forecast",
  "Retention Lab" = "retention",
  "Revenue Pulse" = "revenue"
)

segments <- c(
  Enterprise = "enterprise",
  Midmarket  = "midmarket",
  Startup    = "startup",
  Education  = "education",
  Nonprofit  = "nonprofit"
)

page_css <- "
.gt-bslib-page {
  max-width: 1120px;
  margin: 0 auto;
  padding: 28px 18px 44px;
}
.gt-bslib-hero {
  margin-bottom: 18px;
}
.gt-bslib-hero h1 {
  margin: 0 0 8px;
  font-size: 28px;
}
.gt-bslib-hero p {
  max-width: 720px;
  margin: 0;
  color: var(--bs-secondary-color);
}
.gt-bslib-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}
.gt-bslib-card {
  padding: 16px;
  border: 1px solid var(--bs-border-color);
  border-radius: var(--bs-border-radius);
  background: var(--bs-body-bg);
}
.gt-bslib-label {
  display: block;
  margin-bottom: 8px;
  color: var(--bs-secondary-color);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: .06em;
  text-transform: uppercase;
}
.gt-bslib-card .selectize-input {
  border-radius: 3px;
}
.gt-bslib-state {
  margin-top: 16px;
}
@media (max-width: 860px) {
  .gt-bslib-grid {
    grid-template-columns: 1fr;
  }
}
"

ui <- fluidPage(
  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2474a6",
    base_font = bslib::font_google("Inter")
  ),
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$div(
    class = "gt-bslib-page",
    tags$div(
      class = "gt-bslib-hero",
      tags$h1("glasstabs with bslib"),
      tags$p(
        "Square corners make glassSelect and glassMultiSelect feel native in ",
        "Bootstrap 5 and bslib layouts while keeping the glass interaction model."
      )
    ),
    bslib::navset_card_tab(
      id = "section",
      bslib::nav_panel(
        "Filters",
        tags$div(
          class = "gt-bslib-grid",
          tags$div(
            class = "gt-bslib-card",
            tags$span(class = "gt-bslib-label", "glassSelect"),
            glassSelect(
              "product",
              products,
              selected = "forecast",
              clearable = TRUE,
              theme = "light",
              shape = "square"
            )
          ),
          tags$div(
            class = "gt-bslib-card",
            tags$span(class = "gt-bslib-label", "glassMultiSelect"),
            glassMultiSelect(
              "segments",
              segments,
              selected = c("enterprise", "midmarket"),
              show_style_switcher = FALSE,
              theme = "light",
              shape = "square"
            )
          ),
          tags$div(
            class = "gt-bslib-card",
            tags$span(class = "gt-bslib-label", "native selectize"),
            selectizeInput(
              "native_product",
              NULL,
              choices = products,
              selected = "forecast",
              options = list(placeholder = "Pick a product")
            )
          )
        ),
        tags$div(
          class = "gt-bslib-state",
          bslib::card(
            bslib::card_header("Live state"),
            verbatimTextOutput("state")
          )
        )
      ),
      bslib::nav_panel(
        "Checklist",
        tags$ul(
          tags$li("Open each dropdown and confirm the trigger and panel corners stay square."),
          tags$li("Compare the glass controls against native selectize in the same bslib theme."),
          tags$li("Change selections and confirm the state output updates.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  product <- glassSelectValue(input, "product")
  selected_segments <- glassMultiSelectValue(input, "segments")

  output$state <- renderPrint({
    list(
      product = product(),
      segments = selected_segments$selected(),
      native_product = input$native_product
    )
  })
}

if (interactive()) shinyApp(ui, server)
