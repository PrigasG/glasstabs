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
server_full_choices <- c(
  Alpha = "alpha", Beta = "beta", Gamma = "gamma", Delta = "delta",
  Epsilon = "epsilon", Zeta = "zeta", Eta = "eta", Theta = "theta",
  Iota = "iota", Kappa = "kappa"
)
five_choices <- stats::setNames(letters[1:5], paste("Category", 1:5))
short_field_choices <- c(
  One = "one",
  "A longer option label that should wrap cleanly" = "long_words",
  "FacilityIdentifierWithoutNaturalBreakPoints123456789" = "long_token",
  stats::setNames("pathological", paste(rep("Very long label ", 700), collapse = ""))
)

ui <- fluidPage(
  useGlassTabs(),
  tags$style(HTML("
    body { padding: 24px; }
    .test-row { max-width: 700px; display: grid; gap: 18px; }
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
      search_focus_ring = TRUE,
      theme = glass_select_theme(focus_ring = "#a21caf")
    ),
    glassSelect(
      "auto_single",
      five_choices,
      label = "Automatic single search",
      searchable = "auto",
      search_threshold = 6
    ),
    actionButton("auto_single_show", "Show automatic single search"),
    actionButton("auto_single_hide", "Hide automatic single search"),
    glassSelect(
      "disabled_update_single",
      choices,
      selected = "apple",
      disabled_choices = "banana"
    ),
    glassMultiSelect(
      "disabled_update_multi",
      choices,
      selected = "apple",
      disabled_choices = "banana",
      show_style_switcher = FALSE
    ),
    actionButton("refresh_disabled_choices", "Refresh choices without disabled override"),
    glassSelect(
      "all_update_single",
      choices,
      selected = "apple",
      include_all = TRUE
    ),
    actionButton("all_update_single_change", "Update all-row choices"),
    glassMultiSelect(
      "server_disabled",
      server_full_choices,
      server = TRUE,
      server_limit = 3,
      selected = "alpha"
    ),
    glassMultiSelect(
      "scope_check",
      c(A = "a", B = "b", C = "c", D = "d", E = "e"),
      selected = c("a", "b", "c", "d"),
      disabled_choices = "e",
      show_style_switcher = FALSE
    ),
    glassSelect(
      "value_search",
      c("Red fruit" = "apple", "Yellow fruit" = "banana", "Green fruit" = "cherry"),
      selected = "apple"
    ),
    glassMultiSelect(
      "value_search_multi",
      c("Red fruit" = "apple", "Yellow fruit" = "banana", "Green fruit" = "cherry"),
      selected = "apple",
      show_style_switcher = FALSE
    ),
    # Intentionally unregistered: searches for this widget never receive a
    # response, which exercises the loading-timeout guard (the "Searching..."
    # status must clear on its own instead of sticking forever).
    glassSelect(
      "server_hung",
      choices,
      server = TRUE
    ),
    # Stale-response fixture: searches for "alpha" answer late, searches
    # for "beta" never answer (see the server observer below).
    glassSelect(
      "server_stale",
      c(One = "one", Two = "two"),
      server = TRUE,
      server_limit = 2,
      selected = "one"
    ),
    # Empty-string fixture: "" is a real choice value, distinct from
    # clearing the field (which yields NULL).
    glassSelect(
      "empty_val",
      c("All statuses" = "", "Active" = "active"),
      selected = "",
      clearable = TRUE
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
    actionButton("adaptive_show_search", "Show adaptive search"),
    actionButton("adaptive_hide_search", "Hide adaptive search"),
    tags$div(
      style = "width:600px;max-width:100%",
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
        selection_display = "summary",
        selection_max_items = 1,
        show_style_switcher = TRUE
      )
    ),
    tags$div(
      style = "width:176px",
      glassSelect(
        "never_single",
        short_field_choices,
        selected = "pathological",
        searchable = FALSE,
        overflow_tooltip = "never"
      ),
      glassMultiSelect(
        "never_multi",
        short_field_choices,
        selected = "one",
        show_style_switcher = FALSE,
        overflow_tooltip = "never"
      )
    ),
    glassSelect(
      "detached_single",
      short_field_choices,
      label = "Detached single",
      selected = "one",
      searchable = FALSE,
      tongue = FALSE,
      label_bold = FALSE,
      width = "240px"
    ),
    glassMultiSelect(
      "detached_multi",
      choices,
      label = "Detached multi",
      selected = "apple",
      show_style_switcher = FALSE,
      tongue = FALSE,
      width = "240px"
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
    glassSelect(
      "fruit_light",
      choices,
      selected = "apple",
      shape = "rounded",
      theme = "light"
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

  observeEvent(input$auto_single_show, {
    updateGlassSelect(session, "auto_single", search_threshold = 5)
  })

  observeEvent(input$auto_single_hide, {
    updateGlassSelect(session, "auto_single", search_threshold = 6)
  })

  observeEvent(input$refresh_disabled_choices, {
    refreshed <- c(Apple = "apple", Banana = "banana", Cherry = "cherry", Date = "date")
    updateGlassSelect(session, "disabled_update_single", choices = refreshed)
    updateGlassMultiSelect(session, "disabled_update_multi", choices = refreshed)
  })

  observeEvent(input$all_update_single_change, {
    updateGlassSelect(
      session,
      "all_update_single",
      choices = c(Durian = "durian", Elderberry = "elderberry", Fig = "fig")
    )
  })

  glassMultiSelectServer(
    "server_disabled",
    choices = server_full_choices,
    session = session,
    disabled_choices = "zeta"
  )

  # Stale-response fixture: the first search answers after a 2 s delay,
  # the second never answers. The client must drop the late first
  # response (it no longer matches the latest issued search) and keep
  # the second search's loading guard armed until it fires.
  observeEvent(session$input$server_stale_search, {
    search <- session$input$server_stale_search
    query <- if (is.list(search) && !is.null(search$query)) search$query else search
    seq <- if (is.list(search)) search$seq else NULL
    if (identical(query, "beta")) return()
    if (identical(query, "alpha")) Sys.sleep(2)
    session$sendCustomMessage(
      "glasstabs_server_choices",
      list(
        inputId = session$ns("server_stale"),
        type = "single",
        seq = seq,
        choices = glasstabs:::.gt_choice_payload(
          c("Alpha stale"),
          c("alpha_stale")
        ),
        total = 2L,
        matched = 1L
      )
    )
  }, ignoreInit = TRUE)

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

  observeEvent(input$adaptive_show_search, {
    updateGlassMultiSelect(session, "adaptive", search_threshold = 3)
  })

  observeEvent(input$adaptive_hide_search, {
    updateGlassMultiSelect(session, "adaptive", search_threshold = 4)
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
