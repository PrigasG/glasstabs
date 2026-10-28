library(shiny)
library(glasstabs)

# Theme-switcher stress test for the tongue dropdown. One switch flips every
# select between dark and light, so the same long labels, wide text, narrow
# phone frame, and bottom-of-page flip can be inspected in both themes.
# Selections survive the switch: each re-rendered widget is seeded from its
# current input value, and the switch itself is re-rendered with its new
# value, so nothing the user picked is lost when the theme flips.

or_default <- function(x, default = "(none)") {
  if (is.null(x) || length(x) == 0) default else x
}

categories <- c(
  "The nature of the industry is going down" = "industry-down",
  "Consumer discretionary spending on durable goods and household appliances" = "consumer-discretionary",
  "Renewable energy generation, storage, and grid-scale distribution networks" = "renewable-energy",
  "Commercial real estate development and property management services" = "commercial-real-estate",
  "Healthcare" = "healthcare"
)

wide_text <- c(
  "A very wide description that keeps going well beyond the field width" = "wide-1",
  "Short" = "short",
  "Another extremely long label that should wrap inside the dropdown instead of stretching it wider than the phone screen" = "wide-2",
  "Medium length label for comparison" = "medium"
)

long_tags <- c(
  "The nature of the industry is going down" = "industry-down",
  "Supply chain logistics and warehouse automation across three continents" = "supply-chain",
  "Customer success and implementation" = "customer-success",
  "Data engineering and analytics" = "data-engineering"
)

page_css <- "
.ts-shell { max-width: 980px; margin: 0 auto; padding: 36px 20px 64px; }
.ts-dark { color: #e7ecf5; }
.ts-light { color: #172033; }
.ts-hero h1 { margin: 0 0 8px; font-size: 30px; }
.ts-hero p { margin: 0; max-width: 720px; line-height: 1.6; opacity: .8; }
.ts-switch { margin: 22px 0 26px; padding: 16px 18px; border-radius: 14px; }
.ts-dark .ts-switch { background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.14); }
.ts-light .ts-switch { background: #fff; border: 1px solid #d8e2ef; box-shadow: 0 10px 30px rgba(46,70,110,.08); }
.ts-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
.ts-card { min-width: 0; padding: 20px; border-radius: 16px; }
.ts-dark .ts-card { background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.12); }
.ts-light .ts-card { background: rgba(255,255,255,.86); border: 1px solid #d8e2ef; box-shadow: 0 14px 38px rgba(46,70,110,.08); }
.ts-card h3 { margin: 0 0 6px; font-size: 18px; }
.ts-card p { margin: 0 0 16px; line-height: 1.5; opacity: .75; }
.ts-phone { width: 360px; max-width: 100%; margin: 0 auto; padding: 18px; border-radius: 28px; }
.ts-dark .ts-phone { background: #101828; border: 2px solid rgba(255,255,255,.18); box-shadow: 0 18px 44px rgba(0,0,0,.45); }
.ts-light .ts-phone { background: #f4f8ff; border: 2px solid #c4d2e6; box-shadow: 0 18px 44px rgba(46,70,110,.18); }
.ts-phone h3 { margin: 0 0 6px; font-size: 17px; }
.ts-phone p { margin: 0 0 14px; line-height: 1.5; opacity: .75; }
.ts-state { margin-top: 20px; padding: 16px 18px; border-radius: 12px; line-height: 1.6; }
.ts-dark .ts-state { background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.12); }
.ts-light .ts-state { background: #fff; border: 1px solid #d8e2ef; }
.ts-try { margin: 26px 0 0; padding-left: 20px; line-height: 1.7; opacity: .85; }
@media (max-width: 700px) { .ts-grid { grid-template-columns: 1fr; } }
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$main(
    class = "ts-shell",
    uiOutput("themed")
  )
)

server <- function(input, output, session) {
  theme <- reactive({
    mode <- input$theme_mode
    if (is.null(mode)) "dark" else mode
  })

  output$themed <- renderUI({
    mode <- theme()
    tags$div(
      class = paste0("ts-", mode),
      # The page background follows the theme too, so dark selects are not
      # left floating on a white page.
      tags$style(paste0(
        "body { background: ",
        if (mode == "dark") "#0d1526" else "#f2f6fc",
        "; }"
      )),
      tags$header(
        class = "ts-hero",
        tags$h1("Tongue dropdown: theme switcher"),
        tags$p(
          "One switch flips every select below between dark and light. ",
          "Long category names, wide text, a narrow phone frame, and a ",
          "bottom-of-page flip are all here so the new dropdown can be ",
          "exercised in both themes without leaving the page."
        )
      ),
      tags$div(
        class = "ts-switch",
        radioButtons(
          "theme_mode", "Mode",
          choices = c("Dark" = "dark", "Light" = "light"),
          selected = mode, inline = TRUE
        )
      ),
      tags$div(
        class = "ts-grid",
        tags$section(
          class = "ts-card",
          tags$h3("Long category names"),
          tags$p(
            "Pick a long label. The trigger ellipsizes it, the dropdown ",
            "wraps it, and the panel never grows wider than the field."
          ),
          glassSelect(
            "category", categories,
            label = "Category",
            placeholder = "Choose a category",
            selected = isolate(input$category),
            searchable = TRUE, clearable = TRUE,
            width = "240px",
            theme = mode
          )
        ),
        tags$section(
          class = "ts-card",
          tags$h3("Long labels, multi-select"),
          tags$p(
            "Chips for the picks plus a searchable dropdown with the same ",
            "long labels. Flip the theme and watch the shadows follow."
          ),
          glassMultiSelect(
            "tags", long_tags,
            label = "Tags",
            placeholder = "Choose tags",
            selected = isolate(input$tags),
            searchable = TRUE,
            width = "240px",
            theme = mode
          )
        )
      ),
      tags$section(
        class = "ts-card",
        style = "margin-top: 18px;",
        tags$div(
          class = "ts-phone",
          tags$h3("Mobile view"),
          tags$p(
            "A 360px phone frame. Open the menus here: wide text wraps ",
            "inside the panel instead of pushing it past the screen edge. ",
            "On a real phone, shrink the browser window and the grid above ",
            "collapses to one column."
          ),
          glassSelect(
            "mobile_wide", wide_text,
            label = "Wide text",
            placeholder = "Choose a wide label",
            selected = isolate(input$mobile_wide),
            searchable = TRUE, clearable = TRUE,
            width = "240px",
            theme = mode
          ),
          glassMultiSelect(
            "mobile_tags", long_tags,
            label = "Tags on mobile",
            placeholder = "Choose tags",
            selected = isolate(input$mobile_tags),
            searchable = TRUE,
            width = "240px",
            theme = mode
          )
        )
      ),
      tags$section(
        class = "ts-card",
        style = "margin-top: 18px;",
        tags$h3("Flip above the field"),
        tags$p(
          "This select sits near the bottom of the page, so its panel has ",
          "no room below and must flip above the field, retracting back ",
          "into the trigger when it closes. Try it in both themes."
        ),
        glassSelect(
          "bottom_pick", categories,
          label = "Bottom select",
          placeholder = "Choose a category",
          selected = isolate(input$bottom_pick),
          searchable = TRUE, clearable = TRUE,
          theme = mode
        )
      ),
      tags$div(
        class = "ts-state",
        tags$strong("Current theme: "), textOutput("theme_state", inline = TRUE),
        tags$br(),
        tags$strong("Category: "), textOutput("category_state", inline = TRUE),
        tags$br(),
        tags$strong("Tags: "), textOutput("tags_state", inline = TRUE),
        tags$br(),
        tags$strong("Mobile wide: "), textOutput("mobile_state", inline = TRUE)
      ),
      tags$ul(
        class = "ts-try",
        tags$li("Flip the mode switch, then reopen a menu: shadows and colors follow the theme."),
        tags$li("Open the long category in the phone frame: text wraps, the panel stays inside the frame."),
        tags$li("Scroll to the bottom select and open it: the panel flips above and closes back into the field."),
        tags$li("Search for \u201cindustry\u201d in any searchable menu: the long label is still findable.")
      )
    )
  })

  output$theme_state <- renderText(theme())
  output$category_state <- renderText(or_default(input$category))
  output$tags_state <- renderText(paste(or_default(input$tags), collapse = ", "))
  output$mobile_state <- renderText(or_default(input$mobile_wide))
}

shinyApp(ui, server)
