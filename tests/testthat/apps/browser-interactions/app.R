library(shiny)

pkg_root <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = "")
if (!nzchar(pkg_root)) {
  pkg_root <- normalizePath(file.path(getwd(), "..", "..", ".."), mustWork = FALSE)
}
if (file.exists(file.path(pkg_root, "DESCRIPTION")) &&
    requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(pkg_root, quiet = TRUE)
} else {
  library(glasstabs)
}

choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
short_field_choices <- c(
  One = "one",
  "A longer option label that should wrap cleanly" = "long_words",
  "FacilityIdentifierWithoutNaturalBreakPoints123456789" = "long_token"
)

ui <- fluidPage(
  useGlassTabs(),
  tags$style(HTML("
    body { padding: 24px; }
    .test-row { max-width: 420px; display: grid; gap: 18px; }
    .mobile-frame { width: 300px; }
    .alignment-frame { width: 480px; }
  ")),
  tags$div(
    class = "test-row",
    glassSelect(
      "fruit",
      choices,
      selected = "apple",
      clearable = TRUE,
      shape = "rounded",
      theme = glass_select_theme(focus_ring = "#a21caf")
    ),
    glassMultiSelect(
      "cats",
      choices,
      selected = "apple",
      show_style_switcher = FALSE,
      shape = "rounded"
    ),
    glassMultiSelect(
      "adaptive",
      choices,
      selected = c("apple", "banana"),
      searchable = "auto",
      search_threshold = 4,
      selection_display = "summary",
      selection_max_items = 1,
      dropdown_max_height = "120px",
      show_style_switcher = FALSE
    ),
    actionButton("adaptive_expand", "Expand adaptive choices"),
    actionButton("adaptive_silent", "Silently select cherry"),
    tags$div(
      style = "width:176px",
      glassSelect(
        "short_single",
        short_field_choices,
        selected = "one",
        searchable = FALSE
      )
    ),
    tags$div(
      style = "width:176px",
      glassMultiSelect(
        "short_multi",
        short_field_choices,
        selected = "one",
        show_style_switcher = FALSE
      )
    ),
    radioButtons(
      "shape",
      "Shape",
      choices = c(Rounded = "rounded", Square = "square"),
      selected = "rounded",
      inline = TRUE
    ),
    verbatimTextOutput("fruit_open_state"),
    actionButton("ping_output", "Ping unrelated output"),
    textOutput("ping_text"),
    glassSelect(
      "shape_single",
      choices,
      selected = "apple",
      shape = "rounded"
    ),
    tags$div(
      class = "mobile-frame",
      glassTabsUI(
        "mobile_tabs",
        glassTabPanel("summary", "Summary", p("Summary content")),
        glassTabPanel(
          "activity",
          "Recent activity",
          actionButton("inactive_action", "Inactive action")
        ),
        glassTabPanel("quality", "Data quality", p("Quality content")),
        glassTabPanel("settings", "Team settings", p("Settings content")),
        overflow = "scroll",
        swipe = TRUE,
        theme = glass_tab_theme(focus_ring = "#f97316")
      )
    ),
    glassTabsUI(
      "menu_tabs",
      glassTabPanel("queue", "Queue", p("Queue content")),
      glassTabPanel("complete", "Complete", p("Complete content")),
      overflow = "menu"
    ),
    glassTabsUI(
      "vertical_tabs",
      glassTabPanel("first", "First", p("First vertical pane")),
      glassTabPanel("second", "Second", p("Second vertical pane")),
      glassTabPanel("third", "Third", p("Third vertical pane")),
      orientation = "vertical",
      tab_align = "right",
      text_align = "left"
    ),
    glassTabsUI(
      "special_tabs",
      glassTabPanel("plain", "Plain", p("Plain content")),
      glassTabPanel('team"review', "Quoted value", p("Quoted value content"))
    ),
    glassTabsUI(
      "race_return",
      glassTabPanel("a", "Return A", p("Return A pane")),
      glassTabPanel("b", "Return B", p("Return B pane"))
    ),
    glassTabsUI(
      "race_forward",
      glassTabPanel("a", "Forward A", p("Forward A pane")),
      glassTabPanel("b", "Forward B", p("Forward B pane")),
      glassTabPanel("c", "Forward C", p("Forward C pane"))
    ),
    tags$div(
      style = "display:none",
      textOutput("race_return_events"),
      textOutput("race_forward_events"),
      textOutput("adaptive_events")
    ),
    tags$div(
      class = "alignment-frame",
      glassTabsUI(
        "right_tabs",
        glassTabPanel("one", "One", p("One")),
        glassTabPanel("two", "A longer label", p("Two")),
        tab_align = "right",
        text_align = "left"
      ),
      glassTabsUI(
        "center_tabs",
        glassTabPanel("one", "One", p("One")),
        glassTabPanel("two", "Two", p("Two")),
        tab_align = "center"
      )
    ),
    actionButton("append_tab", "Append tab"),
    actionButton("show_test_modal", "Show test modal")
  )
)

server <- function(input, output, session) {
  session$onFlushed(function() {
    disableGlassTab(session, "mobile_tabs", "activity")
  }, once = TRUE)

  observe({
    req(input$shape)
    updateGlassSelect(session, "shape_single", shape = input$shape)
  })

  output$fruit_open_state <- renderText({
    if (isTRUE(input$fruit_open)) "open" else "closed"
  })

  # Unrelated output used to prove that ordinary Shiny updates do not disturb
  # open select dropdowns (regression: a global shiny:value handler used to
  # close every dropdown on any output update).
  ping_n <- reactiveVal(0L)
  observeEvent(input$ping_output, {
    ping_n(ping_n() + 1L)
  })
  output$ping_text <- renderText(paste("ping", ping_n()))

  adaptive_events <- reactiveVal(0L)
  observeEvent(input$adaptive, {
    adaptive_events(adaptive_events() + 1L)
  }, ignoreInit = TRUE)
  output$adaptive_events <- renderText(as.character(adaptive_events()))
  outputOptions(output, "adaptive_events", suspendWhenHidden = FALSE)

  observeEvent(input$adaptive_expand, {
    updateGlassMultiSelect(
      session,
      "adaptive",
      choices = c(
        Apple = "apple", Banana = "banana", Cherry = "cherry",
        Date = "date", Elderberry = "elderberry"
      ),
      notify = "changed"
    )
  })

  observeEvent(input$adaptive_silent, {
    updateGlassMultiSelect(
      session,
      "adaptive",
      selected = "cherry",
      notify = "never"
    )
  })

  race_return_events <- reactiveVal(character())
  observeEvent(input[["race_return-active_tab"]], {
    race_return_events(c(race_return_events(), input[["race_return-active_tab"]]))
  }, ignoreInit = TRUE)
  output$race_return_events <- renderText(paste(race_return_events(), collapse = ","))
  outputOptions(output, "race_return_events", suspendWhenHidden = FALSE)

  race_forward_events <- reactiveVal(character())
  observeEvent(input[["race_forward-active_tab"]], {
    race_forward_events(c(race_forward_events(), input[["race_forward-active_tab"]]))
  }, ignoreInit = TRUE)
  output$race_forward_events <- renderText(paste(race_forward_events(), collapse = ","))
  outputOptions(output, "race_forward_events", suspendWhenHidden = FALSE)

  observeEvent(input$append_tab, {
    appendGlassTab(
      session,
      "mobile_tabs",
      glassTabPanel("archive", "Archive", p("Archive content")),
      select = TRUE
    )
  }, once = TRUE)

  observeEvent(input$show_test_modal, {
    showModal(modalDialog(
      title = "Lifecycle test modal",
      "An open glasstabs dropdown should close before this modal appears.",
      easyClose = TRUE
    ))
  })
}

shinyApp(ui, server)
