library(shiny)
library(shinyjs)
library(glasstabs)

GLASS_LIGHT <- "light"

ui <- fluidPage(
  useShinyjs(),
  useGlassTabs(),

  div(
    style = "max-width:520px;margin:24px auto;padding:18px;background:white;border-radius:14px;",
    h3("Glasstabs filter test"),

    glassSelect(
      "data_category",
      choices = c(
        "None" = "none",
        "ACS Demographics" = "acs_demo",
        "Decennial" = "decennial"
      ),
      selected = "none",
      searchable = FALSE,
      theme = GLASS_LIGHT
    ),

    conditionalPanel(
      "input.data_category != 'none'",
      uiOutput("main_year_ui"),

      actionButton(
        "toggle_data_filters",
        "Show more filters",
        style = "width:100%;margin-top:8px;"
      ),

      shinyjs::hidden(
        div(
          id = "data_filters_wrap",
          style = "margin-top:10px;",
          uiOutput("data_specific_filters_ui")
        )
      ),

      actionButton(
        "load_btn",
        "Load census data",
        style = "width:100%;margin-top:8px;"
      )
    ),

    hr(),
    verbatimTextOutput("debug_out")
  )
)

server <- function(input, output, session) {
  data_filters_visible <- reactiveVal(FALSE)

  output$main_year_ui <- renderUI({
    cat_val <- input$data_category %||% "none"

    if (identical(cat_val, "acs_demo")) {
      glassSelect(
        "census_year",
        label = "ACS year",
        choices = c("2024" = "2024", "2023" = "2023"),
        selected = "2024",
        searchable = FALSE,
        theme = GLASS_LIGHT
      )
    } else if (identical(cat_val, "decennial")) {
      glassSelect(
        "census_year",
        label = "Census year",
        choices = c("2020" = "2020", "2010" = "2010"),
        selected = "2020",
        searchable = FALSE,
        theme = GLASS_LIGHT
      )
    } else {
      tags$div()
    }
  })

  output$data_specific_filters_ui <- renderUI({
    cat_val <- input$data_category %||% "none"

    if (identical(cat_val, "acs_demo")) {
      tagList(
        glassSelect(
          "acs_demo_section",
          label = "Section",
          choices = c(
            "Race and Ethnicity" = "race",
            "Age and Sex" = "age"
          ),
          selected = "race",
          searchable = FALSE,
          theme = GLASS_LIGHT
        ),
        uiOutput("acs_demo_section_ui")
      )
    } else if (identical(cat_val, "decennial")) {
      tagList(
        glassSelect(
          "dec_age_grouping_filter",
          label = "Age grouping",
          choices = c(
            "Single year" = "1",
            "5-year" = "5",
            "10-year" = "10"
          ),
          selected = "5",
          searchable = FALSE,
          theme = GLASS_LIGHT
        ),
        glassMultiSelect(
          "dec_age_filter",
          label = "Age filter",
          choices = c("Under 5", "5-9", "10-14", "15-19"),
          selected = character(0),
          check_style = "check-only",
          show_style_switcher = FALSE,
          show_select_all = TRUE,
          theme = GLASS_LIGHT
        )
      )
    } else {
      tags$div()
    }
  })

  output$acs_demo_section_ui <- renderUI({
    sec <- input$acs_demo_section %||% "race"

    if (identical(sec, "race")) {
      glassMultiSelect(
        "acs_demo_race_filter",
        label = "Race groups",
        choices = c(
          "All races" = "all",
          "White alone" = "white",
          "Black alone" = "black"
        ),
        selected = "all",
        check_style = "check-only",
        show_style_switcher = FALSE,
        show_select_all = FALSE,
        theme = GLASS_LIGHT
      )
    } else {
      glassSelect(
        "acs_demo_sex",
        label = "Sex",
        choices = c("Both" = "Both", "Male" = "Male", "Female" = "Female"),
        selected = "Both",
        searchable = FALSE,
        theme = GLASS_LIGHT
      )
    }
  })

  observeEvent(input$toggle_data_filters, {
    if (isTRUE(data_filters_visible())) {
      shinyjs::hide("data_filters_wrap")
      data_filters_visible(FALSE)
      updateActionButton(session, "toggle_data_filters", label = "Show more filters")
    } else {
      shinyjs::show("data_filters_wrap")
      data_filters_visible(TRUE)
      updateActionButton(session, "toggle_data_filters", label = "Hide filters")
    }
  }, ignoreInit = TRUE)

  observeEvent(input$data_category, {
    shinyjs::hide("data_filters_wrap")
    data_filters_visible(FALSE)
    updateActionButton(session, "toggle_data_filters", label = "Show more filters")
  }, ignoreInit = TRUE)

  observeEvent(input$dec_age_grouping_filter, {
    group_size <- suppressWarnings(as.integer(input$dec_age_grouping_filter %||% "1"))
    if (is.na(group_size)) group_size <- 1L

    if (group_size <= 1L) {
      choices <- c("Under 1", "1", "2", "3", "4", "5+")
    } else {
      choices <- if (group_size == 5L) {
        c("Under 5", "5-9", "10-14", "15-19")
      } else {
        c("Under 10", "10-19")
      }
    }

    updateGlassMultiSelect(
      session,
      "dec_age_filter",
      choices = choices,
      selected = character(0)
    )
  }, ignoreInit = FALSE)

  observeEvent(input$load_btn, {
    yr_val <- input$census_year %||% NULL
    cat_val <- input$data_category %||% "none"

    if (identical(cat_val, "none")) {
      showNotification("Select a dataset first.", type = "warning")
      return()
    }

    if (is.null(yr_val) || length(yr_val) == 0 || !nzchar(as.character(yr_val)[1])) {
      showNotification("Choose a year or vintage before loading census data.", type = "warning")
      return()
    }

    showNotification(
      paste("Load works. Category:", cat_val, "| Year:", as.character(yr_val)[1]),
      type = "message"
    )
  }, ignoreInit = TRUE)

  output$debug_out <- renderPrint({
    list(
      data_category = input$data_category,
      census_year = input$census_year,
      toggle_visible = data_filters_visible(),
      acs_demo_section = input$acs_demo_section,
      acs_demo_race_filter = input$acs_demo_race_filter,
      acs_demo_sex = input$acs_demo_sex,
      dec_age_grouping_filter = input$dec_age_grouping_filter,
      dec_age_filter = input$dec_age_filter
    )
  })
}

shinyApp(ui, server)
