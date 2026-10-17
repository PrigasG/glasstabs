#' glasstabs dropdown stress tests
#'
#' Pushes glassSelect() and glassMultiSelect() to their limits: 100k-choice
#' scale, hostile label content, search torture, update barrages, disabled
#' choice armies, and layout gauntlets (modals, viewport edges, scroll traps).
#'
#' Run with: glasstabs::runGlassExample("stress-test")
#'
#' Each tab states what it is trying to break and what to watch for.
#' Server-side timings are printed where measurable; the rest needs eyeballs.

library(shiny)
library(glasstabs)

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---------------------------------------------------------------------------
# Choice factories
# ---------------------------------------------------------------------------

big_choices <- function(n, prefix = "Choice") {
  stats::setNames(
    sprintf("value-%06d", seq_len(n)),
    sprintf("%s %06d", prefix, seq_len(n))
  )
}

hostile_choices <- function() {
  labels <- c(
    "Normal choice",
    paste(rep("Very long label ", 700), collapse = ""),          # ~10k chars
    "Emoji storm \U0001F600\U0001F680\U0001F525\U0001F30A\U0001F914",
    "\u4e2d\u6587\u6807\u7bfe \u65e5\u672c\u8a9e \ud55c\uad6d\uc5b4",  # CJK
    "\u0645\u0631\u062d\u0628\u0627 \u0627\u0644\u0639\u0627\u0644\u0645",  # RTL Arabic
    "<script>alert('xss')</script>",                              # HTML injection
    "<img src=x onerror=alert('xss')>",                           # attr injection
    "<b>Bold label</b> & <i>italic</i>",                          # markup
    "Line one\nLine two\tTabbed",                                # whitespace
    "",                                                          # empty label
    "   ",                                                       # blank label
    "Duplicate label",                                           # dup 1
    "Duplicate label",                                           # dup 2
    "Trailing space ",
    " leading space",
    "Quote \"double\" and 'single'",
    "Back\\slash / forward",
    "100% < 200% & 300% > 0%",
    "Control chars \u0001\u0002\u0007\u001b embedded"
  )
  stats::setNames(
    sprintf("hostile-%02d", seq_along(labels)),
    labels
  )
}

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(HTML("
    body { background:#071026; color:#e6eef8; font-family:Inter,system-ui,sans-serif; }
    .stress-wrap { max-width:900px; margin:28px auto; display:grid; gap:16px; }
    .watch { background:rgba(255,180,60,.08); border:1px solid rgba(255,180,60,.25);
             border-radius:8px; padding:10px 14px; font-size:13px; }
    .watch b { color:#ffc46b; }
    pre.timing { background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.10);
                 border-radius:8px; color:#dbeafe; font-size:12px; }
    .scroll-trap { height:220px; overflow-y:auto; border:1px solid rgba(255,255,255,.15);
                   border-radius:8px; padding:12px; }
    .spacer-tall { height:1200px; }
  "))),
  div(
    class = "stress-wrap",
    h2("glasstabs dropdown stress tests"),
    p("Each tab tries to break something. Timings print server-side where measurable;",
      "the rest needs eyeballs and a stopwatch."),

    tabsetPanel(
      id = "scenario",
      type = "pills",

      # ---- 1. Scale: single select --------------------------------------
      tabPanel(
        "Scale: single",
        h3("100k choices, single select"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> time to first paint; tab-switch lag; search ",
          "responsiveness on the client-mode copy; whether the server-mode copy ",
          "stays usable. Compare client (all 100k in DOM) vs server (paged)."
        ))),
        fluidRow(
          column(
            6,
            h4("Client mode (100k in DOM)"),
            glassSelect(
              "scale_single_client",
              big_choices(100000),
              label = "Client 100k",
              server = FALSE,
              clearable = TRUE
            )
          ),
          column(
            6,
            h4("Server mode (100k, paged)"),
            glassSelect(
              "scale_single_server",
              big_choices(100000),
              label = "Server 100k",
              server = TRUE,
              server_limit = 50,
              clearable = TRUE
            )
          )
        ),
        verbatimTextOutput("scale_single_timing", placeholder = TRUE)
      ),

      # ---- 2. Scale: multi select ---------------------------------------
      tabPanel(
        "Scale: multi",
        h3("50k choices, multi select"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> initial render with 50k pre-selected; the selection ",
          "summary chip (\"50,000 selected\" vs label soup); select-all latency; ",
          "scroll performance inside the dropdown; chip rendering cost."
        ))),
        glassMultiSelect(
          "scale_multi",
          big_choices(50000),
          label = "Multi 50k (all pre-selected)",
          server = TRUE,
          server_limit = 50,
          selection_display = "auto",
          show_style_switcher = TRUE
        ),
        fluidRow(
          column(
            6,
            selectInput(
              "scale_multi_display", "Selection display mode",
              choices = c("auto", "count", "summary", "labels"),
              selected = "auto"
            )
          ),
          column(
            6,
            actionButton("scale_multi_reselect", "Re-select all 50k",
                        class = "btn-warning")
          )
        ),
        verbatimTextOutput("scale_multi_timing", placeholder = TRUE)
      ),

      # ---- 3. Hostile content -------------------------------------------
      tabPanel(
        "Hostile labels",
        h3("Labels that fight back"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> XSS (alerts = fail); broken layout from the 10k-char ",
          "label; invisible/empty rows; duplicate labels selecting the wrong value; ",
          "RTL text breaking alignment; control chars corrupting the DOM."
        ))),
        fluidRow(
          column(
            6,
            glassSelect(
              "hostile_single",
              hostile_choices(),
              label = "Single: hostile labels",
              searchable = TRUE,
              clearable = TRUE
            )
          ),
          column(
            6,
            glassMultiSelect(
              "hostile_multi",
              hostile_choices(),
              label = "Multi: hostile labels",
              show_style_switcher = FALSE
            )
          )
        ),
        verbatimTextOutput("hostile_values", placeholder = TRUE)
      ),

      # ---- 4. Search torture ---------------------------------------------
      tabPanel(
        "Search torture",
        h3("Search under fire"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> regex metachars (.*+?^${}()|[]\\) crashing or ",
          "misbehaving search; very long queries; unicode queries; lag while ",
          "typing fast; server_min_chars gating behavior."
        ))),
        fluidRow(
          column(
            6,
            glassSelect(
              "search_single",
              big_choices(20000),
              label = "Server search (min 0 chars)",
              server = TRUE,
              server_limit = 30,
              server_min_chars = 0L,
              searchable = TRUE
            )
          ),
          column(
            6,
            glassSelect(
              "search_single_gated",
              big_choices(20000),
              label = "Server search (min 3 chars)",
              server = TRUE,
              server_limit = 30,
              server_min_chars = 3L,
              searchable = TRUE
            )
          )
        ),
        p("Try typing: ", code(".*"), " ", code("[a-"), " ", code("(unclosed"),
          " a 500-char paste, and emoji."),
        verbatimTextOutput("search_timing", placeholder = TRUE)
      ),

      # ---- 5. Update barrage ---------------------------------------------
      tabPanel(
        "Update barrage",
        h3("Programmatic updates under fire"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> updates while the dropdown is OPEN; choice-set swaps ",
          "from 10 to 50k; selection preservation across updates; memory growth ",
          "over 60s of churn; stale server results racing fresh ones."
        ))),
        fluidRow(
          column(
            6,
            glassSelect(
              "barrage_single",
              big_choices(10),
              label = "Barrage target (single)",
              server = FALSE
            ),
            actionButton("barrage_go", "Start 500ms update barrage",
                         class = "btn-danger"),
            actionButton("barrage_stop", "Stop")
          ),
          column(
            6,
            glassMultiSelect(
              "barrage_multi",
              big_choices(10),
              label = "Barrage target (multi)",
              show_style_switcher = FALSE
            )
          )
        ),
        verbatimTextOutput("barrage_log", placeholder = TRUE)
      ),

      # ---- 6. Disabled army ----------------------------------------------
      tabPanel(
        "Disabled army",
        h3("5,000 disabled out of 10,000"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> disabled styling at scale; search skipping disabled ",
          "rows; select-all including/excluding disabled; keyboard nav jumping ",
          "over disabled; pre-selected values that are also disabled."
        ))),
        {
          ch <- big_choices(10000)
          dis <- unname(ch)[seq(2, 10000, by = 2)]
          tagList(
            glassSelect(
              "disabled_single",
              ch,
              label = "Single (even values disabled)",
              disabled_choices = dis,
              selected = "value-000002",
              searchable = TRUE
            ),
            glassMultiSelect(
              "disabled_multi",
              ch,
              label = "Multi (even values disabled)",
              disabled_choices = dis,
              show_style_switcher = FALSE
            )
          )
        },
        verbatimTextOutput("disabled_values", placeholder = TRUE)
      ),

      # ---- 7. Layout gauntlet --------------------------------------------
      tabPanel(
        "Layout gauntlet",
        h3("Dropdowns vs the page around them"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> panel clipped inside the scroll trap; dropdown near ",
          "the viewport bottom (does it flip?); modal open dismissing the ",
          "dropdown (MutationObserver); 25 selects on one page slowing input."
        ))),
        h4("Inside a scroll trap"),
        div(
          class = "scroll-trap",
          p("Scroll this box, then open the select:"),
          glassSelect(
            "trap_single",
            big_choices(200),
            label = "Trapped select",
            searchable = TRUE
          ),
          div(style = "height:300px;")
        ),
        h4("At the bottom of a tall page"),
        p("Scroll all the way down, then open:"),
        div(class = "spacer-tall"),
        glassSelect(
          "edge_single",
          big_choices(200),
          label = "Bottom-of-page select",
          searchable = TRUE
        ),
        h4("Inside a modal"),
        actionButton("open_modal", "Open modal with selects"),
        h4("25 selects, one page"),
        uiOutput("many_selects")
      ),

      # ---- 8. Overlay battle ----------------------------------------------
      tabPanel(
        "Overlay battle",
        h3("Dropdowns vs overlays"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> open a dropdown, then fire an overlay &mdash; does ",
          "the panel dismiss (MutationObserver) or linger on top? Loading ",
          "spinners, modals, and hand-rolled full-screen divs each get a round. ",
          "A dropdown that survives an overlay is a bug; one that can't be ",
          "reopened after is also a bug."
        ))),
        fluidRow(
          column(
            6,
            glassSelect(
              "overlay_single",
              big_choices(500),
              label = "Victim: single select",
              searchable = TRUE
            ),
            br(),
            actionButton("overlay_modal", "Fire modal overlay",
                         class = "btn-warning"),
            actionButton("overlay_spinner", "Fire loading overlay (3s)",
                         class = "btn-warning"),
            actionButton("overlay_div", "Fire hand-rolled full-screen div",
                         class = "btn-warning")
          ),
          column(
            6,
            glassMultiSelect(
              "overlay_multi",
              big_choices(500),
              label = "Victim: multi select",
              show_style_switcher = FALSE
            ),
            br(),
            actionButton("overlay_modal2", "Fire modal, then close it fast",
                         class = "btn-info"),
            p("Steps: open a dropdown, then fire each overlay in turn.")
          )
        ),
        verbatimTextOutput("overlay_log", placeholder = TRUE)
      ),

      # ---- 9. Display modes -----------------------------------------------
      tabPanel(
        "Display modes",
        h3("Selection display under load"),
        div(class = "watch", HTML(paste0(
          "<b>Watch for:</b> label-mode chip overflow with 1,000 selected; ",
          "summary truncation quality; count accuracy after select-all then ",
          "deselect-one; switching modes live via update."
        ))),
        glassMultiSelect(
          "display_multi",
          big_choices(5000),
          label = "Multi 5k (1k pre-selected)",
          selected = sprintf("value-%06d", 1:1000),
          selection_display = "auto",
          selection_max_items = 2L,
          show_style_switcher = TRUE
        ),
        selectInput(
          "display_mode", "Live-switch display mode",
          choices = c("auto", "count", "summary", "labels"),
          selected = "auto"
        ),
        verbatimTextOutput("display_values", placeholder = TRUE)
      )
    )
  )
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

server <- function(input, output, session) {
  # ---- 1. Scale: single ------------------------------------------------
  t0 <- Sys.time()
  glassSelectServer("scale_single_server", big_choices(100000),
                    session = session, limit = 50)
  output$scale_single_timing <- renderPrint({
    list(
      server_init_s = round(as.numeric(Sys.time() - t0), 3),
      client_value = input$scale_single_client,
      server_value = input$scale_single_server,
      note = "Client copy ships 100k rows to the DOM; watch paint + tab-switch."
    )
  })

  # ---- 2. Scale: multi --------------------------------------------------
  t1 <- Sys.time()
  glassMultiSelectServer("scale_multi", big_choices(50000),
                         session = session, limit = 50)
  observeEvent(input$scale_multi_display, {
    updateGlassMultiSelect(session, "scale_multi",
                           selection_display = input$scale_multi_display)
  })
  observeEvent(input$scale_multi_reselect, {
    t <- Sys.time()
    updateGlassMultiSelect(session, "scale_multi",
                           selected = sprintf("value-%06d", seq_len(50000)))
    output$scale_multi_timing <- renderPrint({
      list(
        reselect_msg_s = round(as.numeric(Sys.time() - t), 3),
        selected_n = length(input$scale_multi %||% character(0))
      )
    })
  })
  output$scale_multi_timing <- renderPrint({
    list(
      server_init_s = round(as.numeric(Sys.time() - t1), 3),
      selected_n = length(input$scale_multi %||% character(0))
    )
  })

  # ---- 3. Hostile labels ------------------------------------------------
  output$hostile_values <- renderPrint({
    list(
      single = input$hostile_single,
      multi_n = length(input$hostile_multi %||% character(0)),
      multi = head(input$hostile_multi %||% character(0), 5)
    )
  })

  # ---- 4. Search torture ------------------------------------------------
  glassSelectServer("search_single", big_choices(20000),
                    session = session, limit = 30)
  glassSelectServer("search_single_gated", big_choices(20000),
                    session = session, limit = 30)
  output$search_timing <- renderPrint({
    list(
      ungated = input$search_single,
      gated = input$search_single_gated
    )
  })

  # ---- 5. Update barrage ------------------------------------------------
  barrage_on <- reactiveVal(FALSE)
  barrage_n <- reactiveVal(0)
  observeEvent(input$barrage_go, barrage_on(TRUE))
  observeEvent(input$barrage_stop, barrage_on(FALSE))
  observe({
    if (!barrage_on()) return()
    invalidateLater(500, session)
    n <- isolate(barrage_n()) + 1
    barrage_n(n)
    # Alternate between tiny and huge choice sets
    ch <- if (n %% 2 == 1) big_choices(10) else big_choices(50000)
    updateGlassSelect(session, "barrage_single", choices = ch)
    updateGlassMultiSelect(session, "barrage_multi", choices = ch)
  })
  output$barrage_log <- renderPrint({
    list(
      updates_sent = barrage_n(),
      running = barrage_on(),
      single_value = input$barrage_single,
      multi_n = length(input$barrage_multi %||% character(0))
    )
  })

  # ---- 6. Disabled army -------------------------------------------------
  output$disabled_values <- renderPrint({
    list(
      single = input$disabled_single,
      multi = input$disabled_multi
    )
  })

  # ---- 7. Layout gauntlet -----------------------------------------------
  output$many_selects <- renderUI({
    lapply(seq_len(25), function(i) {
      glassSelect(
        paste0("many_", i),
        big_choices(50),
        label = sprintf("Select #%02d", i),
        searchable = FALSE
      )
    })
  })
  observeEvent(input$open_modal, {
    showModal(modalDialog(
      title = "Modal with selects",
      glassSelect(
        "modal_single",
        big_choices(200),
        label = "Modal single",
        searchable = TRUE
      ),
      glassMultiSelect(
        "modal_multi",
        big_choices(200),
        label = "Modal multi",
        show_style_switcher = FALSE
      ),
      footer = modalButton("Close"),
      size = "l"
    ))
  })

  # ---- 8. Overlay battle ------------------------------------------------
  overlay_events <- reactiveVal(character(0))
  log_overlay <- function(msg) {
    overlay_events(c(isolate(overlay_events()),
                     sprintf("[%s] %s", format(Sys.time(), "%H:%M:%S"), msg)))
  }
  observeEvent(input$overlay_modal, {
    log_overlay("modal overlay fired")
    showModal(modalDialog(
      title = "Overlay modal",
      p("Did the open dropdown dismiss when this appeared?"),
      footer = modalButton("Close modal"), size = "m"
    ))
  })
  observeEvent(input$overlay_modal2, {
    log_overlay("modal fired + auto-closed after 1.5s")
    showModal(modalDialog(
      title = "Flash modal",
      p("This closes itself in 1.5 seconds."),
      footer = NULL, size = "m"
    ))
    later <- reactiveTimer(1500, session)
    observeEvent(later(), {
      removeModal()
      log_overlay("flash modal removed")
    }, once = TRUE, ignoreInit = TRUE)
  })
  observeEvent(input$overlay_spinner, {
    log_overlay("loading overlay shown for 3s")
    showNotification(
      "Loading overlay active (3s) - dropdown should be gone",
      duration = 3, type = "message", id = "overlay_spinner_note"
    )
    # Full-screen spinner-style overlay div
    insertUI(
      selector = "body", where = "beforeEnd",
      ui = tags$div(
        id = "stress-spinner-overlay",
        style = paste0(
          "position:fixed;inset:0;z-index:9999;",
          "background:rgba(0,0,0,0.55);display:flex;",
          "align-items:center;justify-content:center;"
        ),
        tags$div(
          style = paste0(
            "width:56px;height:56px;border-radius:50%;",
            "border:6px solid rgba(255,255,255,0.25);",
            "border-top-color:#fff;animation:stress-spin 1s linear infinite;"
          )
        ),
        tags$style(HTML(paste0(
          "@keyframes stress-spin{to{transform:rotate(360deg);}}"
        )))
      )
    )
    later <- reactiveTimer(3000, session)
    observeEvent(later(), {
      removeUI("#stress-spinner-overlay")
      log_overlay("loading overlay removed")
    }, once = TRUE, ignoreInit = TRUE)
  })
  observeEvent(input$overlay_div, {
    log_overlay("hand-rolled full-screen div fired (click it to dismiss)")
    insertUI(
      selector = "body", where = "beforeEnd",
      ui = tags$div(
        id = "stress-hand-overlay",
        onclick = "this.remove()",
        style = paste0(
          "position:fixed;inset:0;z-index:9500;cursor:pointer;",
          "background:rgba(120,20,20,0.45);display:flex;",
          "align-items:center;justify-content:center;color:#fff;",
          "font-size:20px;"
        ),
        "Hand-rolled overlay - click anywhere to dismiss"
      )
    )
  })
  output$overlay_log <- renderPrint({
    list(
      events = overlay_events(),
      single = input$overlay_single,
      multi_n = length(input$overlay_multi %||% character(0))
    )
  })

  # ---- 9. Display modes -------------------------------------------------
  observeEvent(input$display_mode, {
    updateGlassMultiSelect(session, "display_multi",
                           selection_display = input$display_mode)
  })
  output$display_values <- renderPrint({
    vals <- input$display_multi %||% character(0)
    list(
      n_selected = length(vals),
      mode = input$display_mode,
      head = head(vals, 3)
    )
  })
}


if (interactive()) shinyApp(ui, server)
