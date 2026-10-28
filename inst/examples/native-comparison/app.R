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

call_preview_output <- function(output_id) {
  htmltools::tagAppendAttributes(
    verbatimTextOutput(output_id, placeholder = TRUE),
    class = "nc-call-preview"
  )
}

page_css <- "
body { background: #eef3f9; color: #172033; }
.nc-shell { max-width: 1120px; margin: 0 auto; padding: 32px 20px 64px; }
.nc-hero h1 { margin: 0 0 8px; font-size: 30px; }
.nc-hero p { max-width: 850px; line-height: 1.6; color: #536078; }
.nc-controls { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 18px; margin: 22px 0; padding: 18px; border: 1px solid #d6e0ed; border-radius: 16px; background: #fff; box-shadow: 0 10px 30px rgba(46,70,110,.08); }
.nc-controls-heading { grid-column: 1 / -1; }
.nc-controls-heading h3 { margin: 0 0 4px; }
.nc-controls-heading p { margin: 0; color: #607089; }
.nc-controls .form-group { margin-bottom: 0; }
.nc-feature-controls { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; margin: 0 0 14px; padding: 16px; border: 1px solid #d6e0ed; border-radius: 14px; background: #f8fbff; }
.nc-feature-controls-heading { grid-column: 1 / -1; }
.nc-feature-controls-heading h3 { margin: 0 0 4px; font-size: 17px; }
.nc-feature-controls-heading p { margin: 0; color: #607089; }
.nc-feature-controls .form-group { margin-bottom: 0; }
.nc-call-preview { margin: 0 0 18px; padding: 14px 16px; border-radius: 12px; background: #101827; color: #d7e8ff; font-size: 12px; white-space: pre-wrap; }
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
  .nc-controls, .nc-feature-controls, .nc-grid { grid-template-columns: 1fr; }
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
      tags$div(
        class = "nc-controls-heading",
        tags$h3("Shared glass settings"),
        tags$p("These presentation choices apply to every glasstabs example below.")
      ),
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
      checkboxInput(
        "compare_label_bold",
        "Use bold glass field labels",
        value = TRUE
      ),
      selectInput(
        "compare_label_size", "Glass field-title size",
        choices = c("Compact (12px)" = "12px", "Default (14px)" = "14px", "Large (16px)" = "16px"),
        selected = "14px",
        selectize = FALSE
      ),
      selectInput(
        "compare_shape", "Glass shape",
        choices = c("Rounded" = "rounded", "Square" = "square"),
        selected = "rounded",
        selectize = FALSE
      ),
      sliderInput(
        "compare_width", "Shared field width",
        min = 160, max = 360, value = 260, step = 20,
        post = " px"
      )
    ),
    tabsetPanel(
      id = "comparison_tab",
      tabPanel(
        "Single-select", value = "single",
        tags$section(
          class = "nc-feature-controls",
          tags$div(
            class = "nc-feature-controls-heading",
            tags$h3("Single-select features"),
            tags$p("These settings affect only the glassSelect() demonstration in this tab.")
          ),
          checkboxInput("single_searchable", "Show dropdown search", TRUE),
          checkboxInput("single_search_ring", "Show blue search focus ring", FALSE),
          checkboxInput("single_overflow_tooltip", "Explain truncated trigger text", TRUE),
          checkboxInput("single_clearable", "Show clear action", TRUE),
          selectInput(
            "single_check_style", "Selection marker",
            c("Checkbox" = "checkbox", "Check only" = "check-only", "Filled" = "filled"),
            selected = "checkbox", selectize = FALSE
          )
        ),
        call_preview_output("single_call_preview"),
        uiOutput("single_compare")
      ),
      tabPanel(
        "Search and multi-select", value = "enhanced",
        tags$section(
          class = "nc-feature-controls",
          tags$div(
            class = "nc-feature-controls-heading",
            tags$h3("Search and multi-select features"),
            tags$p("Search controls sit with search; marker, summary, and color controls sit with the multi-select example.")
          ),
          checkboxInput("enhanced_searchable", "Show dropdown search", TRUE),
          checkboxInput("enhanced_search_ring", "Show blue search focus ring", FALSE),
          checkboxInput("enhanced_overflow_tooltip", "Explain truncated trigger text", TRUE),
          selectInput(
            "enhanced_check_style", "Selection marker",
            c("Checkbox" = "checkbox", "Check only" = "check-only", "Filled" = "filled"),
            selected = "filled", selectize = FALSE
          ),
          selectInput(
            "enhanced_selection_display", "Multi-select trigger text",
            c("Automatic" = "auto", "Count" = "count", "Summary" = "summary", "Labels" = "labels"),
            selected = "summary", selectize = FALSE
          ),
          selectInput(
            "enhanced_fill_colors", "Filled selection colors",
            c("One accent color" = "single", "Different option colors" = "multi"),
            selected = "single", selectize = FALSE
          )
        ),
        call_preview_output("enhanced_call_preview"),
        uiOutput("enhanced_compare")
      ),
      tabPanel(
        "Use both", value = "coexist",
        tags$section(
          class = "nc-feature-controls",
          tags$div(
            class = "nc-feature-controls-heading",
            tags$h3("Mixed-form glass features"),
            tags$p("These options affect only the glass multi-select beside the native Team field.")
          ),
          checkboxInput("coexist_searchable", "Show dropdown search", TRUE),
          checkboxInput("coexist_search_ring", "Show blue search focus ring", FALSE),
          checkboxInput("coexist_overflow_tooltip", "Explain truncated trigger text", TRUE),
          selectInput(
            "coexist_check_style", "Selection marker",
            c("Checkbox" = "checkbox", "Check only" = "check-only", "Filled" = "filled"),
            selected = "checkbox", selectize = FALSE
          ),
          selectInput(
            "coexist_selection_display", "Multi-select trigger text",
            c("Automatic" = "auto", "Count" = "count", "Summary" = "summary", "Labels" = "labels"),
            selected = "summary", selectize = FALSE
          ),
          selectInput(
            "coexist_fill_colors", "Filled selection colors",
            c("One accent color" = "single", "Different option colors" = "multi"),
            selected = "single", selectize = FALSE
          )
        ),
        call_preview_output("coexist_call_preview"),
        uiOutput("coexist_compare")
      ),
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
              tags$li("The signature tongue remains the default but can be disabled per input with tongue = FALSE."),
              tags$li("Field titles default to 14px semibold; label_size and label_bold expose both choices."),
              tags$li("Search uses a quiet neutral focus state by default; search_focus_ring = TRUE restores the blue ring."),
              tags$li("Filled multi-selects use one accent by default; fill_colors = \"multi\" restores categorical colors.")
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
  bold_labels <- reactive(isTRUE(input$compare_label_bold))
  label_size <- reactive(value_or(input$compare_label_size, "14px"))
  glass_shape <- reactive(value_or(input$compare_shape, "rounded"))

  output$single_call_preview <- renderText({
    paste0(
      "glassSelect(..., width = \"", field_width(), "\", tongue = ",
      toupper(as.character(use_tongue())),
      ", label_bold = ", toupper(as.character(bold_labels())),
      ", label_size = \"", label_size(), "\", searchable = ",
      toupper(as.character(isTRUE(input$single_searchable))),
      ", search_focus_ring = ", toupper(as.character(isTRUE(input$single_search_ring))),
      ", overflow_tooltip = \"", if (isTRUE(input$single_overflow_tooltip)) "auto" else "never", "\"",
      ", clearable = ", toupper(as.character(isTRUE(input$single_clearable))),
      ", shape = \"", glass_shape(), "\", check_style = \"",
      value_or(input$single_check_style, "checkbox"), "\")"
    )
  })

  output$enhanced_call_preview <- renderText({
    paste0(
      "glassMultiSelect(..., searchable = ",
      toupper(as.character(isTRUE(input$enhanced_searchable))),
      ", search_focus_ring = ", toupper(as.character(isTRUE(input$enhanced_search_ring))),
      ", overflow_tooltip = \"", if (isTRUE(input$enhanced_overflow_tooltip)) "auto" else "never", "\"",
      ", check_style = \"", value_or(input$enhanced_check_style, "filled"),
      "\", selection_display = \"", value_or(input$enhanced_selection_display, "summary"),
      "\", fill_colors = \"", value_or(input$enhanced_fill_colors, "single"),
      "\", label_size = \"", label_size(), "\", width = \"", field_width(), "\")"
    )
  })

  output$coexist_call_preview <- renderText({
    paste0(
      "selectInput(\"team\", \"Team\", short_choices, selectize = FALSE, width = \"",
      field_width(), "\")\n",
      "glassMultiSelect(..., searchable = ",
      toupper(as.character(isTRUE(input$coexist_searchable))),
      ", search_focus_ring = ", toupper(as.character(isTRUE(input$coexist_search_ring))),
      ", overflow_tooltip = \"", if (isTRUE(input$coexist_overflow_tooltip)) "auto" else "never", "\"",
      ", check_style = \"", value_or(input$coexist_check_style, "checkbox"),
      "\", selection_display = \"", value_or(input$coexist_selection_display, "summary"),
      "\", fill_colors = \"", value_or(input$coexist_fill_colors, "single"), "\")"
    )
  })

  output$single_compare <- renderUI({
    width <- field_width()
    theme <- glass_theme()
    tongue <- use_tongue()
    label_bold <- bold_labels()
    title_size <- label_size()
    searchable <- isTRUE(input$single_searchable)
    search_ring <- isTRUE(input$single_search_ring)
    overflow_tooltip <- if (isTRUE(input$single_overflow_tooltip)) "auto" else "never"
    clearable <- isTRUE(input$single_clearable)
    shape <- glass_shape()
    check_style <- value_or(input$single_check_style, "checkbox")

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
            searchable = searchable,
            clearable = clearable,
            check_style = check_style,
            shape = shape,
            width = width,
            tongue = tongue,
            label_bold = label_bold,
            label_size = title_size,
            search_focus_ring = search_ring,
            overflow_tooltip = overflow_tooltip,
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
    label_bold <- bold_labels()
    title_size <- label_size()
    searchable <- isTRUE(input$enhanced_searchable)
    search_ring <- isTRUE(input$enhanced_search_ring)
    overflow_tooltip <- if (isTRUE(input$enhanced_overflow_tooltip)) "auto" else "never"
    shape <- glass_shape()
    check_style <- value_or(input$enhanced_check_style, "filled")
    selection_display <- value_or(input$enhanced_selection_display, "summary")
    fill_color_mode <- value_or(input$enhanced_fill_colors, "single")

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
              searchable = searchable,
              check_style = check_style,
              shape = shape,
              width = width,
              tongue = tongue,
              label_bold = label_bold,
              label_size = title_size,
              search_focus_ring = search_ring,
              overflow_tooltip = overflow_tooltip,
              theme = theme
            ),
            glassMultiSelect(
              "glass_multi", choices,
              label = "Select several",
              selected = isolate(value_or(input$glass_multi, c("industry-down", "healthcare"))),
              searchable = searchable,
              check_style = check_style,
              shape = shape,
              selection_display = selection_display,
              fill_colors = fill_color_mode,
              width = width,
              tongue = tongue,
              label_bold = label_bold,
              label_size = title_size,
              search_focus_ring = search_ring,
              overflow_tooltip = overflow_tooltip,
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
    label_bold <- bold_labels()
    title_size <- label_size()
    searchable <- isTRUE(input$coexist_searchable)
    search_ring <- isTRUE(input$coexist_search_ring)
    overflow_tooltip <- if (isTRUE(input$coexist_overflow_tooltip)) "auto" else "never"
    shape <- glass_shape()
    check_style <- value_or(input$coexist_check_style, "checkbox")
    selection_display <- value_or(input$coexist_selection_display, "summary")
    fill_color_mode <- value_or(input$coexist_fill_colors, "single")

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
            searchable = searchable,
            check_style = check_style,
            shape = shape,
            selection_display = selection_display,
            fill_colors = fill_color_mode,
            width = width,
            tongue = tongue,
            label_bold = label_bold,
            label_size = title_size,
            search_focus_ring = search_ring,
            overflow_tooltip = overflow_tooltip,
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
