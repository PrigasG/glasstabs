# glasstabs example: Posit Connect workflow page
#
# A deployable Shiny app for Posit Connect that demonstrates:
#   - indicator = "glass" / "solid" / "underline" for tab motion styles
#   - orientation = "horizontal" / "vertical" for workflow navigation
#   - tab_align = "center" / "left" / "right" for tab button alignment
#   - shape = "rounded" / "square" for matching tab corner styles
#   - theme = "auto" for Bootstrap 5 / bslib light-dark mode
#   - glassSelect(), glassMultiSelect(), badges, and server-driven tab changes
#
# Deploy the folder with rsconnect::deployApp("inst/examples/connect-workflow")
# or run locally with glasstabs::runGlassExample("connect-workflow").

library(shiny)
library(glasstabs)

has_bslib <- requireNamespace("bslib", quietly = TRUE)
glassTabsUI_args <- names(formals(glassTabsUI))
select_theme <- if (isTRUE(tryCatch({
  as.character(glassSelect(
    "gt_auto_probe",
    c(Probe = "probe"),
    selected = "probe",
    theme = "auto"
  ))
  TRUE
}, error = function(e) FALSE))) "auto" else "light"

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

workflow_tabs <- function(
    orientation = "horizontal",
    tab_align = "center",
    shape = "rounded",
    indicator = "glass"
) {
  orientation <- match.arg(orientation, c("horizontal", "vertical"))
  tab_align <- match.arg(tab_align, c("center", "left", "right"))
  shape <- match.arg(shape, c("rounded", "square"))
  indicator <- match.arg(indicator, c("glass", "solid", "underline"))

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
      tableOutput("order_table")
    ),
    glassTabPanel(
      "approve", "Approve",
      div(
        class = "approval-panel",
        h3("Approval checklist"),
        checkboxInput("owner_checked", "Owner reviewed filtered queue", value = TRUE),
        checkboxInput("metrics_checked", "Metrics match Connect snapshot", value = FALSE),
        checkboxInput("publish_checked", "Ready to publish summary", value = FALSE),
        verbatimTextOutput("approval_summary", placeholder = TRUE)
      )
    )
  )

  args <- c(
    list(
      id = "workflow",
      compact = TRUE,
      theme = if ("indicator" %in% glassTabsUI_args) "auto" else "light"
    ),
    panels
  )
  if ("indicator" %in% glassTabsUI_args) args$indicator <- indicator
  if ("orientation" %in% glassTabsUI_args) args$orientation <- orientation
  if ("tab_align" %in% glassTabsUI_args) args$tab_align <- tab_align
  if ("shape" %in% glassTabsUI_args) args$shape <- shape

  do.call(glassTabsUI, args)
}

page_body <- function() {
  tagList(
    useGlassTabs(),
    tags$head(tags$style(HTML("
      body{background:#f5f7fb;}
      .connect-shell{max-width:1180px;margin:0 auto;padding:24px 16px 34px;}
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
      [data-bs-theme='dark'] .selectize-input,
      body[data-bs-theme='dark'] .selectize-input,
      body[data-bs-theme='dark'] .form-select,
      [data-bs-theme='dark'] .form-select{
        background:#111827;color:#f8fafc;border-color:rgba(148,163,184,.35);
        box-shadow:none;
      }
      [data-bs-theme='dark'] .selectize-dropdown,
      body[data-bs-theme='dark'] .selectize-dropdown{background:#111827;color:#f8fafc;border-color:rgba(148,163,184,.35);}
      [data-bs-theme='dark'] .selectize-dropdown .active,
      body[data-bs-theme='dark'] .selectize-dropdown .active{background:#1e293b;color:#f8fafc;}
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
      .stage-state{display:inline-flex;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700;}
      .state-ready{background:rgba(34,197,94,.14);color:#15803d;}
      .state-review{background:rgba(245,158,11,.16);color:#a16207;}
      .approval-panel{max-width:560px;}
      @media(max-width:780px){
        .connect-header,.connect-tools{grid-template-columns:1fr;display:block;}
        .connect-status{justify-content:flex-start;margin-top:12px;}
        .connect-grid,.pane-grid{grid-template-columns:1fr;}
        .connect-tools > *{margin-bottom:10px;}
      }
    "))),
    tags$script(HTML("
      document.addEventListener('click', function(e) {
        var btn = e.target.closest ? e.target.closest('[data-workflow-target]') : null;
        var tabClick = e.target.closest ? e.target.closest('#workflow-navbar .gt-tab-link') : null;
        if (!btn && !tabClick) return;
        var target = btn ? btn.getAttribute('data-workflow-target') : tabClick.getAttribute('data-value');
        var tabs = Array.prototype.slice.call(document.querySelectorAll('#workflow-navbar .gt-tab-link'));
        var tab = tabs.find(function(el) { return el.getAttribute('data-value') === target; });
        if (btn && tab) tab.click();
        setTimeout(function() {
          document.querySelectorAll('[data-workflow-target]').forEach(function(el) {
            el.classList.toggle('active', el.getAttribute('data-workflow-target') === target);
            el.setAttribute('aria-pressed', el.classList.contains('active') ? 'true' : 'false');
          });
        }, 0);
      });
    ")),
    div(
      class = "connect-shell",
      div(
        class = "connect-header",
        div(
          class = "connect-title",
          h1("Connect workflow review"),
          p("A compact Shiny page for Posit Connect: filters define the queue, glasstabs guides the workflow, and server actions move reviewers through intake, exploration, and approval.")
        ),
        div(
          class = "connect-status",
          span(class = "connect-pill", "Deployable app.R"),
          span(class = "connect-pill", "theme = auto")
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
          theme = select_theme,
          show_style_switcher = FALSE
        ),
        glassSelect(
          "status_filter",
          choices = c("All", sort(unique(orders$status))),
          selected = "All",
          label = "Status",
          theme = select_theme
        ),
        selectInput(
          "workflow_orientation",
          "Tab layout",
          choices = c("Horizontal" = "horizontal", "Vertical" = "vertical"),
          selected = "horizontal"
        ),
        selectInput(
          "workflow_tab_align",
          "Tab text",
          choices = c("Center" = "center", "Left" = "left", "Right" = "right"),
          selected = "center"
        ),
        selectInput(
          "workflow_tab_shape",
          "Tab shape",
          choices = c("Rounded" = "rounded", "Square" = "square"),
          selected = "rounded"
        ),
        selectInput(
          "workflow_indicator",
          "Indicator",
          choices = c("Glass" = "glass", "Solid" = "solid", "Underline" = "underline"),
          selected = "glass"
        ),
        actionButton("reset_filters", "Reset filters", class = "btn-secondary")
      ),
      div(
        class = "workflow-actions",
        actionButton("go_explore", "Explore", class = "btn-outline-primary", `data-workflow-target` = "explore"),
        actionButton("go_approve", "Approve", class = "btn-outline-primary", `data-workflow-target` = "approve")
      ),
      uiOutput("workflow_tabs_ui")
    )
  )
}

if (has_bslib) {
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5),
    div(
      style = "display:flex;justify-content:flex-end;padding:12px 16px 0;",
      bslib::input_dark_mode(id = "mode")
    ),
    page_body()
  )
} else {
  ui <- fluidPage(page_body())
}

server <- function(input, output, session) {
  filtered_orders <- reactive({
    dat <- orders
    selected_regions <- input$region_filter
    if (!is.null(selected_regions) && length(selected_regions) > 0) {
      dat <- dat[dat$region %in% selected_regions, , drop = FALSE]
    }
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

  observeEvent(input$go_approve, {
    updateGlassTabsUI(session, "workflow", selected = "approve")
  })

  observeEvent(input$reset_filters, {
    updateGlassMultiSelect(session, "region_filter", selected = sort(unique(orders$region)))
    updateGlassSelect(session, "status_filter", selected = "All")
  })

  output$workflow_tabs_ui <- renderUI({
    orientation <- input$workflow_orientation
    if (is.null(orientation) || !nzchar(orientation)) orientation <- "horizontal"
    tab_align <- input$workflow_tab_align
    if (is.null(tab_align) || !nzchar(tab_align)) tab_align <- "center"
    shape <- input$workflow_tab_shape
    if (is.null(shape) || !nzchar(shape)) shape <- "rounded"
    indicator <- input$workflow_indicator
    if (is.null(indicator) || !nzchar(indicator)) indicator <- "glass"

    workflow_tabs(
      orientation = orientation,
      tab_align = tab_align,
      shape = shape,
      indicator = indicator
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
  output$approval_summary <- renderText({
    paste(
      "Queue rows:", nrow(filtered_orders()),
      "\nChecklist:", sum(c(input$owner_checked, input$metrics_checked, input$publish_checked), na.rm = TRUE), "of 3 complete"
    )
  })
}

shinyApp(ui, server)
