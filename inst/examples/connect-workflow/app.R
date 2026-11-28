# glasstabs example: Posit Connect workflow page
#
# A deployable Shiny app for Posit Connect that demonstrates:
#   - indicator = "glass" / "solid" / "underline" for tab motion styles
#   - orientation = "horizontal" / "vertical" for workflow navigation
#   - tab_align = "center" / "left" / "right" for tab group alignment
#   - text_align = "center" / "left" / "right" for labels and icons
#   - shape = "rounded" / "square" for matching tab corner styles
#   - theme = "auto" for Bootstrap 5 / bslib light-dark mode
#   - overflow = "scroll" / "multiline" / "menu" on narrow screens
#   - optional swipe gestures with interactive-content guards
#   - glassSelect(), glassMultiSelect(), glassSwitch(), badges, and server-driven tab changes
#   - session-persisted tab order, touch reorder, and server-approved closure
#   - dynamic append/remove, show/hide, and disable/enable tab helpers
#   - keyboard, reduced-motion, high-contrast, and blur-fallback checks
#
# Deploy the folder with rsconnect::deployApp("inst/examples/connect-workflow")
# or run locally with glasstabs::runGlassExample("connect-workflow").

library(shiny)
library(glasstabs)
library(bslib)

orders <- data.frame(
  region = c("North", "North", "South", "West", "East", "East", "West", "South"),
  status = c("Ready", "Ready", "Review", "Approved", "Review", "Ready", "Approved", "Ready"),
  channel = c("Retail", "Partner", "Retail", "Direct", "Partner", "Direct", "Retail", "Partner"),
  value = c(18400, 22100, 12800, 30100, 16700, 24500, 33200, 14600),
  stringsAsFactors = FALSE
)

kpi <- function(label, value, tone = "blue") {
  div(
    class = paste("connect-kpi", paste0("tone-", tone)),
    span(class = "connect-kpi-label", label),
    strong(value)
  )
}

stage_card <- function(title, body, state) {
  div(
    class = "stage-card",
    span(class = paste("stage-state", paste0("state-", tolower(state))), state),
    h4(title),
    p(body)
  )
}

live_panel <- function() {
  glassTabPanel(
    "live", "Live tab", closable = TRUE,
    div(
      class = "stage-card",
      h3("Added while the app is running"),
      p("Drag this tab to reorder it, or request closure with its close control."),
      actionButton("live_action", "A real button inside the new panel")
    )
  )
}

workflow_tabs <- function(
    orientation = "horizontal",
    tab_align = "center",
    text_align = "center",
    shape = "rounded",
    indicator = "glass",
    overflow = "scroll",
    swipe = FALSE,
    selected = "intake",
    show_live = FALSE,
    approval_values = list(),
    swipe_guard_value = "Typing here should never change tabs"
) {
  orientation <- match.arg(orientation, c("horizontal", "vertical"))
  tab_align <- match.arg(tab_align, c("center", "left", "right"))
  text_align <- match.arg(text_align, c("center", "left", "right"))
  shape <- match.arg(shape, c("rounded", "square"))
  indicator <- match.arg(indicator, c("glass", "solid", "underline"))
  overflow <- match.arg(overflow, c("scroll", "multiline", "menu"))

  panels <- list(
    glassTabPanel(
      "intake", "Intake", selected = TRUE,
      div(
        class = "pane-grid",
        stage_card("Source refresh", "Connect schedules can refresh this page before the morning standup.", "Ready"),
        stage_card("Data quality", "Filters and badges keep review queues visible without leaving the workflow.", "Review"),
        stage_card("Handoff", "Use server-side tab updates to move reviewers to the next stage.", "Ready")
      )
    ),
    glassTabPanel(
      "explore", "Explore",
      h3("Filtered order queue"),
      div(class = "table-scroll", tableOutput("order_table"))
    ),
    glassTabPanel(
      "approve", "Approve",
      div(
        class = "approval-panel",
        h3("Approval checklist"),
        glassSwitch("owner_checked", "Owner reviewed filtered queue",
                    value = if (is.null(approval_values$owner)) TRUE else isTRUE(approval_values$owner)),
        glassSwitch("metrics_checked", "Metrics match Connect snapshot",
                    value = isTRUE(approval_values$metrics)),
        glassSwitch("publish_checked", "Ready to publish summary",
                    value = isTRUE(approval_values$publish)),
        verbatimTextOutput("approval_summary", placeholder = TRUE)
      )
    ),
    glassTabPanel(
      "test_lab", "Test lab",
      div(
        class = "test-lab",
        h3("A safe place to try the interactions"),
        p("Swipe across this open space, use the keyboard on the tabs, and try the controls above. Inputs and the scroll box below should keep their own touch behavior."),
        textInput("swipe_guard_input", "Interactive swipe guard", swipe_guard_value),
        div(
          class = "touch-scroll-test",
          `data-gt-no-swipe` = "",
          span("This box scrolls sideways without changing the active tab."),
          span("Keep dragging to confirm the tab remains on Test lab.")
        )
      )
    )
  )
  if (isTRUE(show_live)) panels <- c(panels, list(live_panel()))
  if (!selected %in% vapply(panels, function(panel) panel$value, character(1))) {
    selected <- "intake"
  }

  args <- c(
    list(
      id = "workflow",
      compact = TRUE,
      selected = selected,
      theme = "auto"
    ),
    panels
  )
  args$indicator <- indicator
  args$orientation <- orientation
  args$tab_align <- tab_align
  args$text_align <- text_align
  args$shape <- shape
  args$overflow <- overflow
  args$swipe <- swipe
  args$reorderable <- TRUE
  args$touch_reorder <- TRUE
  args$persist_order <- "session"
  args$order_key <- "connect-workflow-v1"

  do.call(glassTabsUI, args)
}

page_body <- function() {
  tagList(
    tags$head(tags$style(HTML("
      body{background:#f5f7fb;}
      .connect-shell{box-sizing:border-box;width:100%;min-width:0;max-width:1180px;margin:0 auto;padding:24px 16px 34px;}
      .connect-header{display:flex;justify-content:space-between;gap:18px;align-items:flex-start;margin-bottom:18px;}
      .connect-title h1{font-size:30px;line-height:1.15;margin:0 0 8px;font-weight:700;}
      .connect-title p{margin:0;color:#475569;max-width:720px;}
      [data-bs-theme='dark'] body,
      body[data-bs-theme='dark']{background:#0b1020;color:#e5edf8;}
      [data-bs-theme='dark'] .connect-title h1,
      body[data-bs-theme='dark'] .connect-title h1{color:#f8fafc;}
      [data-bs-theme='dark'] .connect-title p,
      body[data-bs-theme='dark'] .connect-title p{color:#cbd5e1;}
      .connect-status{display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end;}
      .connect-pill{border:1px solid rgba(37,99,235,.22);background:rgba(37,99,235,.08);color:#1d4ed8;border-radius:999px;padding:6px 10px;font-size:13px;font-weight:600;}
      [data-bs-theme='dark'] .connect-pill,
      body[data-bs-theme='dark'] .connect-pill{border-color:rgba(125,211,252,.28);background:rgba(125,211,252,.10);color:#bae6fd;}
      .connect-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin:18px 0;}
      .connect-kpi{border:1px solid rgba(15,23,42,.10);background:#fff;border-radius:8px;padding:14px;box-shadow:0 10px 30px rgba(15,23,42,.06);}
      .connect-kpi-label{display:block;font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:#64748b;margin-bottom:4px;}
      .connect-kpi strong{font-size:24px;line-height:1.1;color:#0f172a;}
      [data-bs-theme='dark'] .connect-kpi,
      body[data-bs-theme='dark'] .connect-kpi{background:#111827;border-color:rgba(148,163,184,.20);}
      [data-bs-theme='dark'] .connect-kpi strong,
      body[data-bs-theme='dark'] .connect-kpi strong{color:#f8fafc;}
      .connect-tools{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;align-items:end;margin:18px 0;}
      .connect-tools > *{min-width:0;}
      .connect-tools .form-group{margin-bottom:0;}
      [data-bs-theme='dark'] .connect-tools label,
      body[data-bs-theme='dark'] .connect-tools label{color:#dbeafe;}
      .workflow-actions{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin:2px 0 12px;}
      .workflow-actions .btn{text-align:center;background:transparent;color:#0d6efd;border-color:#0d6efd;}
      .workflow-actions .btn.active,
      .workflow-actions .btn:active{
        color:#fff;background:#0d6efd;border-color:#0d6efd;box-shadow:none;
      }
      [data-bs-theme='dark'] .workflow-actions .btn-outline-primary,
      body[data-bs-theme='dark'] .workflow-actions .btn-outline-primary{
        color:#93c5fd;border-color:#38bdf8;background:transparent;
      }
      [data-bs-theme='dark'] .workflow-actions .btn-outline-primary.active,
      body[data-bs-theme='dark'] .workflow-actions .btn-outline-primary.active{
        color:#07111f;background:#93c5fd;border-color:#93c5fd;
      }
      [data-bs-theme='dark'] .workflow-actions .btn-outline-primary:hover,
      body[data-bs-theme='dark'] .workflow-actions .btn-outline-primary:hover{
        color:#0b1020;background:#93c5fd;border-color:#93c5fd;
      }
      .pane-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;}
      .stage-card{border:1px solid rgba(15,23,42,.10);border-radius:8px;padding:14px;background:rgba(255,255,255,.72);}
      .stage-card h4{margin:8px 0 6px;font-size:16px;}
      .stage-card p{margin:0;color:#475569;}
      [data-bs-theme='dark'] .stage-card,
      body[data-bs-theme='dark'] .stage-card{background:#111827;border-color:rgba(148,163,184,.22);}
      [data-bs-theme='dark'] .stage-card p,
      body[data-bs-theme='dark'] .stage-card p{color:#cbd5e1;}
      [data-bs-theme='dark'] .table,
      body[data-bs-theme='dark'] .table{color:#f8fafc;}
      .table-scroll{width:100%;max-width:100%;overflow-x:auto;}
      .stage-state{display:inline-flex;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700;}
      .state-ready{background:rgba(34,197,94,.14);color:#15803d;}
      .state-review{background:rgba(245,158,11,.16);color:#a16207;}
      .approval-panel{max-width:560px;}
      .test-checklist{margin:18px 0;border:1px solid rgba(15,23,42,.12);border-radius:10px;background:rgba(255,255,255,.72);padding:14px 16px;}
      .test-checklist summary{cursor:pointer;font-size:17px;font-weight:700;color:#0f172a;}
      .test-checklist ol{margin:12px 0 0;padding-left:22px;columns:2;column-gap:32px;}
      .test-checklist li{break-inside:avoid;margin:0 0 9px;color:#334155;}
      .test-lab{max-width:760px;}
      .touch-scroll-test{display:flex;gap:18px;overflow-x:auto;white-space:nowrap;border:1px dashed #64748b;border-radius:8px;padding:14px;margin-top:12px;touch-action:pan-x;}
      .touch-scroll-test span{display:inline-block;min-width:430px;}
      [data-bs-theme='dark'] .test-checklist,
      body[data-bs-theme='dark'] .test-checklist{background:#111827;border-color:rgba(148,163,184,.22);}
      [data-bs-theme='dark'] .test-checklist summary,
      body[data-bs-theme='dark'] .test-checklist summary{color:#f8fafc;}
      [data-bs-theme='dark'] .test-checklist li,
      body[data-bs-theme='dark'] .test-checklist li{color:#cbd5e1;}
      @media(max-width:780px){
        .connect-header,.connect-tools{grid-template-columns:1fr;display:block;}
        .connect-status{justify-content:flex-start;margin-top:12px;}
        .connect-grid,.pane-grid{grid-template-columns:1fr;}
        .test-checklist ol{columns:1;}
        .connect-tools > *{margin-bottom:10px;}
      }
    "))),
    tags$script(HTML("
      Shiny.addCustomMessageHandler('connect_workflow_active', function(message) {
        document.querySelectorAll('[data-workflow-target]').forEach(function(button) {
          var active = button.getAttribute('data-workflow-target') === message.value;
          button.classList.toggle('active', active);
          button.setAttribute('aria-pressed', active ? 'true' : 'false');
        });
      });
    ")),
    div(
      class = "connect-shell",
      div(
        class = "connect-header",
        div(
          class = "connect-title",
          h1("Connect workflow showcase"),
          p("A review workflow showing responsive, touch, keyboard, accessibility, and dynamic-tab features together.")
        ),
        div(
          class = "connect-status",
          span(class = "connect-pill", "Deployable app.R"),
          span(class = "connect-pill", "theme = auto"),
          span(class = "connect-pill", paste0("glasstabs ", as.character(packageVersion("glasstabs"))))
        )
      ),
      div(
        class = "connect-grid",
        kpi("Open value", textOutput("open_value", inline = TRUE)),
        kpi("Ready orders", textOutput("ready_count", inline = TRUE), "green"),
        kpi("Review orders", textOutput("review_count", inline = TRUE), "amber"),
        kpi("Active tab", textOutput("active_tab", inline = TRUE))
      ),
      div(
        class = "connect-tools",
        glassMultiSelect(
          "region_filter",
          choices = sort(unique(orders$region)),
          selected = sort(unique(orders$region)),
          label = "Regions",
          searchable = "auto",
          theme = "auto",
          show_style_switcher = FALSE
        ),
        glassSelect(
          "status_filter",
          choices = c("All", sort(unique(orders$status))),
          selected = "All",
          label = "Status",
          searchable = "auto",
          theme = "auto"
        ),
        glassSelect(
          "workflow_orientation",
          choices = c("Horizontal" = "horizontal", "Vertical" = "vertical"),
          selected = "horizontal",
          label = "Tab layout",
          searchable = "auto",
          theme = "auto"
        ),
        glassSelect(
          "workflow_tab_align",
          choices = c("Center" = "center", "Left" = "left", "Right" = "right"),
          selected = "center",
          label = "Tab alignment",
          searchable = "auto",
          theme = "auto"
        ),
        glassSelect(
          "workflow_text_align",
          choices = c("Center" = "center", "Left" = "left", "Right" = "right"),
          selected = "center",
          label = "Text alignment",
          searchable = "auto",
          theme = "auto"
        ),
        glassSelect(
          "workflow_tab_shape",
          choices = c("Rounded" = "rounded", "Square" = "square"),
          selected = "rounded",
          label = "Tab shape",
          searchable = "auto",
          theme = "auto"
        ),
        glassSelect(
          "workflow_indicator",
          choices = c("Glass" = "glass", "Solid" = "solid", "Underline" = "underline"),
          selected = "glass",
          label = "Indicator",
          searchable = "auto",
          theme = "auto"
        ),
        conditionalPanel(
          condition = "input.workflow_orientation === 'horizontal'",
          glassSelect(
            "workflow_overflow",
            choices = c(
              "Scroll" = "scroll",
              "Multiline" = "multiline",
              "Compact menu" = "menu"
            ),
            selected = "scroll",
            label = "Narrow-screen tabs",
            searchable = "auto",
            theme = "auto"
          )
        ),
        glassSwitch("workflow_swipe", "Swipe between tabs", value = TRUE),
        actionButton("reset_filters", "Reset filters", class = "btn-secondary")
      ),
      div(
        class = "workflow-actions",
        actionButton("go_intake", "Intake", class = "btn-outline-primary", `data-workflow-target` = "intake", `aria-pressed` = "false"),
        actionButton("go_explore", "Explore", class = "btn-outline-primary", `data-workflow-target` = "explore", `aria-pressed` = "false"),
        actionButton("go_approve", "Approve", class = "btn-outline-primary", `data-workflow-target` = "approve", `aria-pressed` = "false"),
        actionButton("go_test_lab", "Test lab", class = "btn-outline-primary", `data-workflow-target` = "test_lab", `aria-pressed` = "false")
      ),
      div(
        class = "workflow-actions",
        actionButton("append_live_tab", "Add live tab"),
        actionButton("remove_live_tab", "Remove live tab"),
        actionButton("hide_approve", "Hide Approve"),
        actionButton("show_approve", "Show Approve"),
        actionButton("disable_explore", "Disable Explore"),
        actionButton("enable_explore", "Enable Explore"),
        actionButton("pulse_badge", "Update badge")
      ),
      tags$details(
        class = "test-checklist",
        open = NA,
        tags$summary("What this app is testing"),
        tags$ol(
          tags$li("Resize the window and compare Scroll, Multiline, and Compact menu."),
          tags$li("On a phone, swipe across empty panel space in both directions."),
          tags$li("Confirm inputs, buttons, tables, and the sideways scroll box do not trigger a swipe."),
          tags$li("Use arrow keys plus Home and End on the tab bar; focus should follow the active tab."),
          tags$li("Open the glass selects and use arrows, Home, End, Enter, Space, and Escape."),
          tags$li("Open a glass select and immediately press outside it; the dropdown should close cleanly."),
          tags$li("Check that a loading veil or modal never leaves a glass select floating above it."),
          tags$li("Press inside the multi-select dropdown and confirm it stays open for the next choice."),
          tags$li("Reorder tabs with a pointer, Alt+Shift+arrows, or a touch handle, then reload to check session storage."),
          tags$li("Add the Live tab, close it with its tab control, and check that the server removes it."),
          tags$li("Change layout while a pane is active; its selection and entered values should remain."),
          tags$li("Clear every region; the queue and metrics should become empty."),
          tags$li("Hide and show Approve; disable and enable Explore."),
          tags$li("Update the badge and confirm the pulse is subtle and never moves focus."),
          tags$li("Switch light and dark mode and try each indicator, shape, alignment, and orientation."),
          tags$li("Turn on reduced motion or high contrast in the operating system and reload the app."),
          tags$li("Confirm the experimental glassPage layout fills the browser without clipping."),
          tags$li("Refresh the published app and repeat the controls to catch Connect-only asset or session issues.")
        )
      ),
      uiOutput("workflow_tabs_ui")
    )
  )
}

ui <- glassPage(
  title = "glasstabs Connect test lab",
  theme = bs_theme(version = 5),
  padding = 0,
  div(
    style = "display:flex;justify-content:flex-end;padding:12px 16px 0;",
    input_dark_mode(id = "mode")
  ),
  page_body()
)

server <- function(input, output, session) {
  live_present <- reactiveVal(FALSE)
  approve_hidden <- reactiveVal(FALSE)
  explore_disabled <- reactiveVal(FALSE)
  badge_test_value <- reactiveVal(0L)

  filtered_orders <- reactive({
    dat <- orders
    selected_regions <- input$region_filter
    dat <- dat[dat$region %in% selected_regions, , drop = FALSE]
    if (!is.null(input$status_filter) && input$status_filter != "All") {
      dat <- dat[dat$status == input$status_filter, , drop = FALSE]
    }
    dat
  })

  observe({
    dat <- filtered_orders()
    updateGlassTabBadge(session, "workflow", "intake", nrow(dat))
    updateGlassTabBadge(session, "workflow", "explore", sum(dat$status == "Review"))
    updateGlassTabBadge(session, "workflow", "approve", sum(dat$status == "Approved"))
  })

  observeEvent(input$go_explore, {
    updateGlassTabsUI(session, "workflow", selected = "explore")
  })

  observeEvent(input$go_intake, {
    updateGlassTabsUI(session, "workflow", selected = "intake")
  })

  observeEvent(input$go_approve, {
    updateGlassTabsUI(session, "workflow", selected = "approve")
  })

  observeEvent(input$go_test_lab, {
    updateGlassTabsUI(session, "workflow", selected = "test_lab")
  })

  observeEvent(input$append_live_tab, {
    if (isTRUE(live_present())) return()
    appendGlassTab(session, "workflow", live_panel(), select = TRUE)
    live_present(TRUE)
  })

  observeEvent(input$remove_live_tab, {
    if (!isTRUE(live_present())) return()
    removeGlassTab(session, "workflow", "live")
    live_present(FALSE)
  })

  observeEvent(input[["workflow-close_request"]], {
    if (!identical(input[["workflow-close_request"]], "live") ||
        !isTRUE(live_present())) return()
    removeGlassTab(session, "workflow", "live")
    live_present(FALSE)
  })

  observeEvent(input$hide_approve, {
    hideGlassTab(session, "workflow", "approve")
    approve_hidden(TRUE)
  })

  observeEvent(input$show_approve, {
    showGlassTab(session, "workflow", "approve")
    approve_hidden(FALSE)
  })

  observeEvent(input$disable_explore, {
    disableGlassTab(session, "workflow", "explore")
    explore_disabled(TRUE)
  })

  observeEvent(input$enable_explore, {
    enableGlassTab(session, "workflow", "explore")
    explore_disabled(FALSE)
  })

  observeEvent(input$pulse_badge, {
    next_value <- badge_test_value() + 1L
    badge_test_value(next_value)
    updateGlassTabBadge(session, "workflow", "test_lab", next_value)
  })

  observeEvent(input$reset_filters, {
    updateGlassMultiSelect(session, "region_filter", selected = sort(unique(orders$region)))
    updateGlassSelect(session, "status_filter", selected = "All")
  })

  observeEvent(list(
    input$workflow_orientation, input$workflow_tab_align,
    input$workflow_text_align, input$workflow_tab_shape,
    input$workflow_indicator, input$workflow_overflow, input$workflow_swipe
  ), {
    session$onFlushed(function() {
      if (isTRUE(isolate(approve_hidden()))) hideGlassTab(session, "workflow", "approve")
      if (isTRUE(isolate(explore_disabled()))) disableGlassTab(session, "workflow", "explore")
      badge <- isolate(badge_test_value())
      if (badge > 0L) {
        updateGlassTabBadge(session, "workflow", "test_lab", badge)
      }
    }, once = TRUE)
  }, ignoreInit = TRUE)

  output$workflow_tabs_ui <- renderUI({
    orientation <- input$workflow_orientation
    if (is.null(orientation) || !nzchar(orientation)) orientation <- "horizontal"
    tab_align <- input$workflow_tab_align
    if (is.null(tab_align) || !nzchar(tab_align)) tab_align <- "center"
    text_align <- input$workflow_text_align
    if (is.null(text_align) || !nzchar(text_align)) text_align <- "center"
    shape <- input$workflow_tab_shape
    if (is.null(shape) || !nzchar(shape)) shape <- "rounded"
    indicator <- input$workflow_indicator
    if (is.null(indicator) || !nzchar(indicator)) indicator <- "glass"
    overflow <- input$workflow_overflow
    if (is.null(overflow) || !nzchar(overflow)) overflow <- "scroll"
    if (identical(orientation, "vertical") && identical(overflow, "menu")) {
      overflow <- "scroll"
    }
    swipe <- isTRUE(input$workflow_swipe)
    selected <- isolate(input[["workflow-active_tab"]])
    if (is.null(selected) || !nzchar(selected)) selected <- "intake"
    approval_values <- isolate(list(
      owner = input$owner_checked,
      metrics = input$metrics_checked,
      publish = input$publish_checked
    ))
    swipe_guard_value <- isolate(input$swipe_guard_input)
    if (is.null(swipe_guard_value)) swipe_guard_value <- "Typing here should never change tabs"

    workflow_tabs(
      orientation = orientation,
      tab_align = tab_align,
      text_align = text_align,
      shape = shape,
      indicator = indicator,
      overflow = overflow,
      swipe = swipe,
      selected = selected,
      show_live = isolate(live_present()),
      approval_values = approval_values,
      swipe_guard_value = swipe_guard_value
    )
  })

  output$order_table <- renderTable(filtered_orders(), striped = TRUE, bordered = FALSE)
  output$open_value <- renderText(format(sum(filtered_orders()$value), big.mark = ","))
  output$ready_count <- renderText(sum(filtered_orders()$status == "Ready"))
  output$review_count <- renderText(sum(filtered_orders()$status == "Review"))
  output$active_tab <- renderText({
    active <- input[["workflow-active_tab"]]
    if (is.null(active) || !nzchar(active)) "intake" else active
  })
  observeEvent(input[["workflow-active_tab"]], {
    session$sendCustomMessage(
      "connect_workflow_active",
      list(value = input[["workflow-active_tab"]])
    )
  }, ignoreNULL = FALSE)
  output$approval_summary <- renderText({
    paste(
      "Queue rows:", nrow(filtered_orders()),
      "\nChecklist:", sum(c(input$owner_checked, input$metrics_checked, input$publish_checked), na.rm = TRUE), "of 3 complete"
    )
  })
}

shinyApp(ui, server)
