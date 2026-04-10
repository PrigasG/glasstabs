# glasstabs - smoke test example
#
# Run with:
# shiny::runApp("inst/examples/smoke-test")
#
# What this covers:
# - initial active tab reported by glassTabsServer()
# - programmatic tab switching via updateGlassTabsUI()
# - hiding the currently active admin tab
# - appending and removing a dynamic compare tab
# - removing the last dynamic tab after selecting it

library(shiny)
library(glasstabs)

base_tabs <- c("overview", "details", "admin")

page_css <- "
body {
  background: linear-gradient(135deg, #07111f 0%, #0c1728 100%);
  color: #dcecff;
  font-family: Inter, system-ui, sans-serif;
}
.smoke-wrap {
  max-width: 980px;
  margin: 0 auto;
  padding: 32px 24px 48px;
}
.smoke-head {
  margin-bottom: 16px;
}
.smoke-head h1 {
  margin: 0 0 8px;
  font-size: 26px;
  color: #d9ecff;
}
.smoke-head p {
  margin: 0;
  color: rgba(200, 225, 255, 0.72);
}
.smoke-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin: 18px 0 20px;
}
.smoke-controls .checkbox {
  margin: 0 10px 0 0;
}
.smoke-panel {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 12px;
  padding: 16px 18px;
}
.smoke-grid {
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 16px;
  margin-top: 18px;
}
.smoke-note {
  color: rgba(200, 225, 255, 0.7);
  font-size: 13px;
  line-height: 1.6;
}
.smoke-debug {
  margin-top: 12px;
  font-size: 12px;
  color: rgba(190, 220, 255, 0.76);
}
@media (max-width: 820px) {
  .smoke-grid {
    grid-template-columns: 1fr;
  }
}
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$div(
    class = "smoke-wrap",
    tags$div(
      class = "smoke-head",
      tags$h1("glasstabs smoke test"),
      tags$p("Use the controls below to exercise the dynamic tab-management paths.")
    ),
    tags$div(
      class = "smoke-controls",
      checkboxInput("show_admin", "Show admin tab", value = TRUE),
      actionButton("next_tab", "Next visible tab"),
      actionButton("go_admin", "Go to admin"),
      actionButton("hide_admin_now", "Hide admin now"),
      actionButton("add_compare", "Add compare"),
      actionButton("remove_compare", "Remove compare"),
      actionButton("reset_tabs", "Reset")
    ),
    glassTabsUI(
      "main",
      selected = "overview",
      extra_ui = glassMultiSelect(
        "metric_filter",
        c(Revenue = "revenue", Orders = "orders", Returns = "returns"),
        selected = c("revenue", "orders", "returns"),
        show_style_switcher = FALSE
      ),
      glassTabPanel(
        "overview", "Overview", selected = TRUE,
        tags$h3("Overview"),
        tags$p("Baseline tab. Initial active-tab reporting should land here."),
        glassFilterTags("metric_filter")
      ),
      glassTabPanel(
        "details", "Details",
        tags$h3("Details"),
        tags$p("Use 'Next visible tab' to verify programmatic switching."),
        glassFilterTags("metric_filter")
      ),
      glassTabPanel(
        "admin", "Admin",
        tags$h3("Admin"),
        tags$p("Activate this tab, then hide it to confirm fallback activation."),
        verbatimTextOutput("admin_state")
      )
    ),
    tags$div(
      class = "smoke-grid",
      tags$div(
        class = "smoke-panel",
        tags$h4("Live state"),
        verbatimTextOutput("state"),
        tags$div(class = "smoke-debug", verbatimTextOutput("debug_state"))
      ),
      tags$div(
        class = "smoke-panel",
        tags$h4("What to verify"),
        tags$div(
          class = "smoke-note",
          tags$p("1. On load, active_tab should already be 'overview'."),
          tags$p("2. Click 'Go to admin', then 'Hide admin now' and confirm another visible tab activates."),
          tags$p("3. Click 'Add compare', switch to it, then click 'Remove compare'."),
          tags$p("4. Repeat add/remove a few times and confirm the app stays stable."),
          tags$p("5. Use the metric filter while switching tabs to make sure other widgets remain unaffected.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  active_tab <- glassTabsServer("main")
  metrics <- glassMultiSelectValue(input, "metric_filter")
  compare_present <- reactiveVal(FALSE)

  observeEvent(TRUE, {
    session$sendCustomMessage(
      "glasstabs_debug_ping",
      list(source = "smoke-test", ts = as.character(Sys.time()))
    )
  }, once = TRUE, ignoreInit = FALSE)

  visible_tabs <- reactive({
    tabs <- c("overview", "details")
    if (isTRUE(input$show_admin)) {
      tabs <- c(tabs, "admin")
    }
    if (compare_present()) {
      tabs <- c(tabs, "compare")
    }
    tabs
  })

  observeEvent(input$show_admin, {
    if (isTRUE(input$show_admin)) {
      showGlassTab(session, "main", "admin")
    } else {
      hideGlassTab(session, "main", "admin")
    }
  }, ignoreInit = FALSE)

  observeEvent(input$go_admin, {
    if (isTRUE(input$show_admin)) {
      updateGlassTabsUI(session, "main", "admin")
    }
  })

  observeEvent(input$hide_admin_now, {
    updateCheckboxInput(session, "show_admin", value = FALSE)
  })

  observeEvent(input$add_compare, {
    if (compare_present()) {
      return()
    }

    appendGlassTab(
      session,
      "main",
      glassTabPanel(
        "compare", "Compare",
        tags$h3("Compare"),
        tags$p("Dynamic tab added at runtime."),
        tags$p("Select this tab, then remove it to exercise the fallback path.")
      ),
      select = TRUE
    )
    compare_present(TRUE)
  })

  observeEvent(input$remove_compare, {
    if (!compare_present()) {
      return()
    }
    removeGlassTab(session, "main", "compare")
    compare_present(FALSE)
  })

  observeEvent(input$next_tab, {
    tabs <- visible_tabs()
    cur <- active_tab() %||% tabs[[1]]
    idx <- match(cur, tabs)
    if (is.na(idx)) {
      idx <- 1L
    }
    next_idx <- if (idx < length(tabs)) idx + 1L else 1L
    updateGlassTabsUI(session, "main", tabs[[next_idx]])
  })

  observeEvent(input$reset_tabs, {
    if (!isTRUE(input$show_admin)) {
      updateCheckboxInput(session, "show_admin", value = TRUE)
    }
    if (compare_present()) {
      removeGlassTab(session, "main", "compare")
      compare_present(FALSE)
    }
    updateGlassTabsUI(session, "main", "overview")
  })

  output$state <- renderPrint({
    list(
      active_tab = active_tab(),
      visible_tabs = visible_tabs(),
      compare_present = compare_present(),
      selected_metrics = metrics$selected(),
      metric_style = metrics$style()
    )
  })

  output$admin_state <- renderPrint({
    list(
      active_tab = active_tab(),
      admin_visible = isTRUE(input$show_admin),
      compare_present = compare_present()
    )
  })

  output$debug_state <- renderPrint({
    list(
      handlers_registered = input$glasstabs_debug_handlers_registered %||% FALSE,
      debug_ping_payload = input$glasstabs_debug_ping_payload %||% NULL
    )
  })
}

shinyApp(ui, server)
