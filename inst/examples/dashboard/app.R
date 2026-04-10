# glasstabs — Store Analytics dashboard example
#
# Demonstrates:
#   glassTabsUI / glassTabPanel / glassTabsServer
#   updateGlassTabsUI  — Next button advances tabs programmatically
#   showGlassTab / hideGlassTab  — Admin tab revealed by checkbox
#   appendGlassTab / removeGlassTab  — Compare tab added/removed at runtime
#   glassSelect / glassSelectValue  — Region picker
#   glassMultiSelect / glassMultiSelectValue / glassFilterTags  — Metric filter
#
# Run with: shiny::runApp("inst/examples/dashboard")

library(shiny)
library(glasstabs)

# ── Static data ───────────────────────────────────────────────────────────────

regions <- c("All Regions" = "all", North = "north", South = "south",
             East = "east", West = "west")

metrics <- c(Revenue = "revenue", Footfall = "footfall",
             Returns = "returns", Conversion = "conversion")

store_stats <- list(
  all   = c(revenue = "$2.4 M",  footfall = "18,420", returns = "3.1%", conversion = "4.8%"),
  north = c(revenue = "$680 K",  footfall = "5,210",  returns = "2.8%", conversion = "5.2%"),
  south = c(revenue = "$510 K",  footfall = "4,890",  returns = "3.5%", conversion = "4.1%"),
  east  = c(revenue = "$720 K",  footfall = "5,610",  returns = "2.9%", conversion = "5.0%"),
  west  = c(revenue = "$490 K",  footfall = "2,710",  returns = "3.4%", conversion = "4.6%")
)

trend_notes <- c(
  all   = "All regions trending +4.2% vs last quarter.",
  north = "North up +6.1% — strongest performer this quarter.",
  south = "South down -1.3% — review Q3 promo strategy.",
  east  = "East steady at +3.8%, new location opening next month.",
  west  = "West recovering after supply disruption, up +2.1%."
)

inventory_levels <- c(all = 94, north = 97, south = 88, east = 96, west = 91)

# ── UI ────────────────────────────────────────────────────────────────────────

page_css <- "
body {
  background: linear-gradient(135deg, #060d1f 0%, #0a1628 55%, #071020 100%);
  color: #ddeeff; font-family: Inter, system-ui, sans-serif;
  margin: 0; min-height: 100vh;
}
.dash-wrap   { max-width: 900px; margin: 0 auto; padding: 36px 24px; }
.dash-head   { display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
               margin-bottom: 8px; }
.dash-title  { font-size: 20px; font-weight: 700; color: #c4deff;
               letter-spacing: -.3px; flex: 1; white-space: nowrap; }
.dash-tags   { min-height: 28px; margin-bottom: 10px; }
.dash-actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap;
                margin-bottom: 18px; }
.dash-actions label { color: rgba(180,210,255,.7); font-size: 13px; }
.dash-footer { margin-top: 18px; padding-top: 10px; font-size: 12px;
               color: rgba(160,200,255,.4);
               border-top: 1px solid rgba(255,255,255,.06); }
.metric-grid { display: grid;
               grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
               gap: 12px; margin-top: 10px; }
.metric-card { background: rgba(255,255,255,.04);
               border: 1px solid rgba(255,255,255,.08);
               border-radius: 10px; padding: 14px 16px; }
.metric-lbl  { font-size: 11px; color: rgba(180,210,255,.5);
               text-transform: uppercase; letter-spacing: .06em;
               margin-bottom: 4px; }
.metric-val  { font-size: 24px; font-weight: 700; color: #cce8ff; }
.stat-row    { display: flex; gap: 10px; align-items: baseline;
               margin-top: 14px; }
.stat-label  { font-size: 13px; color: rgba(180,210,255,.55); width: 90px; }
.stat-bar-bg { flex: 1; height: 6px; background: rgba(255,255,255,.08);
               border-radius: 3px; }
.stat-bar-fg { height: 6px; border-radius: 3px;
               background: linear-gradient(90deg, #3b82f6, #60a5fa); }
.note-box    { background: rgba(255,255,255,.03);
               border: 1px solid rgba(255,255,255,.07);
               border-radius: 10px; padding: 16px 18px; margin-top: 10px;
               font-size: 14px; line-height: 1.6; color: #b8d4f0; }
.admin-badge { display: inline-block; background: rgba(239,68,68,.15);
               border: 1px solid rgba(239,68,68,.3); color: #fca5a5;
               border-radius: 6px; padding: 2px 10px; font-size: 12px;
               margin-bottom: 10px; }
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),

  tags$div(
    class = "dash-wrap",

    # ── Header ──────────────────────────────────────────────────────────────
    tags$div(
      class = "dash-head",
      tags$div(class = "dash-title", "Store Analytics"),
      glassSelect(
        "region", regions,
        selected  = "all",
        label     = "Region",
        clearable = FALSE
      ),
      glassMultiSelect(
        "metrics", metrics,
        label               = "Metrics",
        selected            = unname(metrics),
        show_style_switcher = FALSE,
        show_select_all     = FALSE
      )
    ),

    # ── Filter tag pills ─────────────────────────────────────────────────────
    tags$div(class = "dash-tags", glassFilterTags("metrics")),

    # ── Action bar ───────────────────────────────────────────────────────────
    tags$div(
      class = "dash-actions",
      checkboxInput("show_admin", "Admin view", value = FALSE),
      actionButton("add_compare",    "Add Compare",    class = "btn btn-sm"),
      actionButton("remove_compare", "Remove Compare", class = "btn btn-sm"),
      actionButton("next_tab",       "Next \u2192",    class = "btn btn-sm btn-primary")
    ),

    # ── Tabs ─────────────────────────────────────────────────────────────────
    glassTabsUI(
      "main",
      selected = "overview",
      wrap     = FALSE,

      glassTabPanel("overview", "Overview",
        tags$h3("Overview"),
        uiOutput("overview_cards"),
        uiOutput("overview_trend")
      ),

      glassTabPanel("trends", "Trends",
        tags$h3("Trends"),
        uiOutput("trends_chart")
      ),

      glassTabPanel("inventory", "Inventory",
        tags$h3("Inventory"),
        uiOutput("inventory_ui")
      ),

      glassTabPanel("admin", "Admin",
        tags$div(class = "admin-badge", "Restricted"),
        tags$h3("Admin Panel"),
        verbatimTextOutput("admin_debug")
      )
    ),

    # ── Footer ───────────────────────────────────────────────────────────────
    tags$div(class = "dash-footer", textOutput("footer_txt", inline = TRUE))
  )
)

# ── Server ────────────────────────────────────────────────────────────────────

server <- function(input, output, session) {

  active_tab  <- glassTabsServer("main")
  region_sel  <- glassSelectValue(input, "region")
  metrics_sel <- glassMultiSelectValue(input, "metrics")

  # Convenience shorthands
  region  <- reactive(region_sel()  %||% "all")
  sel_met <- reactive(metrics_sel$selected() %||% character(0))

  # ── Admin tab: show / hide ─────────────────────────────────────────────────
  observeEvent(input$show_admin, {
    if (isTRUE(input$show_admin)) showGlassTab(session, "main", "admin")
    else                          hideGlassTab(session, "main", "admin")
  }, ignoreInit = FALSE)

  # ── Compare tab: append / remove ──────────────────────────────────────────
  compare_present <- reactiveVal(FALSE)

  observeEvent(input$add_compare, {
    if (compare_present()) return()
    appendGlassTab(
      session, "main",
      glassTabPanel("compare", "Compare",
        tags$h3("Compare"),
        uiOutput("compare_ui")
      ),
      select = TRUE
    )
    compare_present(TRUE)
  })

  observeEvent(input$remove_compare, {
    if (!compare_present()) return()
    removeGlassTab(session, "main", "compare")
    compare_present(FALSE)
  })

  # ── Next button: advance through visible tabs ──────────────────────────────
  observeEvent(input$next_tab, {
    base  <- c("overview", "trends", "inventory")
    extra <- c(
      if (isTRUE(input$show_admin)) "admin"   else NULL,
      if (compare_present())        "compare" else NULL
    )
    all_tabs <- c(base, extra)
    cur <- active_tab() %||% "overview"
    idx <- match(cur, all_tabs)
    if (!is.na(idx) && idx < length(all_tabs)) {
      updateGlassTabsUI(session, "main", selected = all_tabs[[idx + 1L]])
    }
  })

  # ── Overview ──────────────────────────────────────────────────────────────
  output$overview_cards <- renderUI({
    met <- sel_met()
    if (length(met) == 0L) return(tags$p("No metrics selected."))
    s     <- store_stats[[region()]]
    cards <- lapply(met, function(m) {
      tags$div(
        class = "metric-card",
        tags$div(class = "metric-lbl", m),
        tags$div(class = "metric-val", s[[m]])
      )
    })
    tags$div(class = "metric-grid", cards)
  })

  output$overview_trend <- renderUI({
    tags$div(class = "note-box", trend_notes[[region()]])
  })

  # ── Trends ────────────────────────────────────────────────────────────────
  output$trends_chart <- renderUI({
    met  <- sel_met()
    r    <- region()
    s    <- store_stats[[r]]
    rows <- lapply(met, function(m) {
      raw <- gsub("[^0-9.]", "", s[[m]])
      pct <- suppressWarnings(min(100, max(5, as.numeric(raw))))
      if (is.na(pct)) pct <- 50
      tags$div(
        class = "stat-row",
        tags$div(class = "stat-label", m),
        tags$div(
          class = "stat-bar-bg",
          tags$div(class = "stat-bar-fg", style = paste0("width:", pct, "%"))
        ),
        tags$div(style = "font-size:13px;color:#90b8e0;width:70px;text-align:right;",
                 s[[m]])
      )
    })
    tagList(rows, tags$div(class = "note-box", style = "margin-top:14px;",
                           trend_notes[[r]]))
  })

  # ── Inventory ─────────────────────────────────────────────────────────────
  output$inventory_ui <- renderUI({
    r   <- region()
    lvl <- inventory_levels[[r]]
    tagList(
      tags$div(
        class = "stat-row",
        tags$div(class = "stat-label", "Stock level"),
        tags$div(
          class = "stat-bar-bg",
          tags$div(class = "stat-bar-fg", style = paste0("width:", lvl, "%"))
        ),
        tags$div(style = "font-size:13px;color:#90b8e0;width:70px;text-align:right;",
                 paste0(lvl, "%"))
      ),
      tags$div(class = "note-box", style = "margin-top:14px;",
        sprintf("Region: %s  |  Stock at %d%%  |  Replenishment cycle: weekly.",
                r, lvl))
    )
  })

  # ── Admin ─────────────────────────────────────────────────────────────────
  output$admin_debug <- renderPrint({
    list(
      active_tab   = active_tab(),
      region       = region(),
      metrics      = sel_met(),
      compare_open = compare_present(),
      admin_on     = isTRUE(input$show_admin)
    )
  })

  # ── Compare (appended dynamically) ────────────────────────────────────────
  output$compare_ui <- renderUI({
    r <- region()
    s <- store_stats[[r]]
    s_all <- store_stats[["all"]]
    met   <- sel_met()
    if (length(met) == 0L) return(tags$p("No metrics selected."))

    rows <- lapply(met, function(m) {
      tags$div(
        class = "stat-row",
        tags$div(class = "stat-label", m),
        tags$div(
          style = "flex:1;display:flex;gap:10px;font-size:13px;color:#90b8e0;",
          tags$span(paste("Selected:", s[[m]])),
          tags$span(style = "color:rgba(180,210,255,.4);", "|"),
          tags$span(paste("All:", s_all[[m]]))
        )
      )
    })
    tagList(
      tags$p(style = "font-size:13px;color:rgba(180,210,255,.55);margin-bottom:8px;",
             paste("Comparing", r, "vs all regions")),
      rows
    )
  })

  # ── Footer ────────────────────────────────────────────────────────────────
  output$footer_txt <- renderText({
    met <- sel_met()
    sprintf(
      "Tab: %s  |  Region: %s  |  Metrics: %s",
      active_tab() %||% "overview",
      region(),
      if (length(met)) paste(met, collapse = ", ") else "none"
    )
  })
}

shinyApp(ui, server)
