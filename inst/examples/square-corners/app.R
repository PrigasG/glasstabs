library(shiny)
library(glasstabs)

# ---------------------------------------------------------------------------
# glasstabs "square corners" smoke test
#
# Exercises the shape = c("rounded", "square") argument added to
# glassSelect() and glassMultiSelect(). The "square" shape ships crisp,
# selectize-style corners so the glass widgets can sit flush beside native
# Shiny selectizeInput() controls without looking out of place.
#
# The live row also exercises the runtime shape switch added to
# updateGlassSelect() / updateGlassMultiSelect().
#
# Run with:  if (interactive()) glasstabs::runGlassExample("square-corners")
# ---------------------------------------------------------------------------

fruits <- c(
  Apple      = "apple",
  Banana     = "banana",
  Cherry     = "cherry",
  Date       = "date",
  Elderberry = "elderberry",
  Fig        = "fig",
  Grape      = "grape"
)

metrics <- c(
  Revenue = "revenue",
  Orders  = "orders",
  Returns = "returns",
  Refunds = "refunds"
)

page_css <- "
body {
  background: linear-gradient(135deg, #07111f 0%, #0c1728 100%);
  color: #dcecff;
  font-family: Inter, system-ui, sans-serif;
}
.sq-wrap {
  max-width: 1040px;
  margin: 0 auto;
  padding: 32px 24px 56px;
}
.sq-head h1 {
  margin: 0 0 8px;
  font-size: 26px;
  color: #d9ecff;
}
.sq-head p {
  margin: 0 0 4px;
  color: rgba(200, 225, 255, 0.72);
}
.sq-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 18px;
  align-items: center;
  margin: 20px 0 8px;
}
.sq-controls .form-group,
.sq-controls .shiny-input-radiogroup {
  margin: 0;
}
.sq-panel {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 12px;
  padding: 16px 18px;
  margin-top: 18px;
}
.sq-panel > h4 {
  margin: 0 0 14px;
  font-size: 15px;
  color: #cfe6ff;
}
.sq-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
  align-items: start;
}
.sq-col > span.sq-label {
  display: block;
  font-size: 12px;
  letter-spacing: .04em;
  text-transform: uppercase;
  color: rgba(180, 210, 245, 0.65);
  margin-bottom: 8px;
}
.sq-col .selectize-input {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.18);
  color: #dcecff;
  border-radius: 3px;
  box-shadow: none;
}
.sq-col .selectize-input input { color: #dcecff; }
.sq-col .selectize-dropdown {
  background: #0c1728;
  border: 1px solid rgba(255,255,255,0.18);
  color: #dcecff;
  border-radius: 3px;
}
.sq-col .selectize-dropdown .active { background: rgba(126,195,247,0.18); }
.sq-state-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
.sq-note {
  color: rgba(200, 225, 255, 0.72);
  font-size: 13px;
  line-height: 1.65;
}
.sq-note code {
  background: rgba(126,195,247,0.14);
  color: #bfe0ff;
  padding: 1px 5px;
  border-radius: 4px;
}
@media (max-width: 880px) {
  .sq-grid { grid-template-columns: 1fr; }
  .sq-state-grid { grid-template-columns: 1fr; }
}
"

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(page_css)),
  tags$div(
    class = "sq-wrap",
    tags$div(
      class = "sq-head",
      tags$h1("glasstabs - square corners smoke test"),
      tags$p("Verifies the new shape argument on glassSelect() and glassMultiSelect()."),
      tags$p("Square mode mirrors selectize's crisp corners so the widgets blend into native layouts.")
    ),

    # --- Live toggle: switches shape at runtime via update*() -------------
    tags$div(
      class = "sq-controls",
      radioButtons(
        "shape",
        "Live shape (switched at runtime - no re-render):",
        choices = c("Rounded" = "rounded", "Square" = "square"),
        selected = "square",
        inline = TRUE
      )
    ),
    tags$div(
      class = "sq-panel",
      tags$h4("Live shape - glass beside native selectize"),
      tags$div(
        class = "sq-grid",
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "glassSelect (single)"),
          glassSelect(
            "live_single_val", fruits,
            selected = "banana", clearable = TRUE,
            shape = "square"
          )
        ),
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "glassMultiSelect"),
          glassMultiSelect(
            "live_multi_val", metrics,
            selected = c("revenue", "orders"),
            show_style_switcher = FALSE,
            shape = "square"
          )
        ),
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "native selectizeInput"),
          selectizeInput(
            "native_single", NULL,
            choices = fruits, selected = "banana",
            options = list(placeholder = "Select an option")
          ),
          selectizeInput(
            "native_multi", NULL,
            choices = metrics, selected = c("revenue", "orders"),
            multiple = TRUE
          )
        )
      )
    ),

    # --- Static A/B: rounded vs square rendered together -------------------
    tags$div(
      class = "sq-panel",
      tags$h4("Static comparison - rounded vs square (same widgets, both shapes)"),
      tags$div(
        class = "sq-grid",
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "Rounded (default)"),
          glassSelect(
            "ab_single_round", fruits,
            selected = "cherry", clearable = TRUE,
            shape = "rounded"
          ),
          tags$div(style = "height:12px;"),
          glassMultiSelect(
            "ab_multi_round", metrics,
            selected = c("revenue", "orders"),
            show_style_switcher = FALSE,
            shape = "rounded"
          )
        ),
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "Square (selectize-style)"),
          glassSelect(
            "ab_single_square", fruits,
            selected = "cherry", clearable = TRUE,
            shape = "square"
          ),
          tags$div(style = "height:12px;"),
          glassMultiSelect(
            "ab_multi_square", metrics,
            selected = c("revenue", "orders"),
            show_style_switcher = FALSE,
            shape = "square"
          )
        ),
        tags$div(
          class = "sq-col",
          tags$span(class = "sq-label", "Square + light theme"),
          glassSelect(
            "ab_single_light", fruits,
            selected = "cherry",
            theme = "light", shape = "square"
          ),
          tags$div(style = "height:12px;"),
          glassMultiSelect(
            "ab_multi_light", metrics,
            selected = c("revenue", "orders"),
            theme = "light",
            show_style_switcher = FALSE,
            shape = "square"
          )
        )
      )
    ),

    # --- State + checklist -------------------------------------------------
    tags$div(
      class = "sq-state-grid",
      tags$div(
        class = "sq-panel",
        tags$h4("Live state"),
        verbatimTextOutput("state")
      ),
      tags$div(
        class = "sq-panel",
        tags$h4("What to verify"),
        tags$div(
          class = "sq-note",
          tags$p("1. On load the live widgets default to shape = \"square\" - their trigger corners should look as crisp as the native selectize beside them."),
          tags$p("2. Flip the radio to Rounded and back; the corners change live via updateGlassSelect() / updateGlassMultiSelect() - the widgets are NOT re-rendered, so any open dropdown or selection state is preserved."),
          tags$p("3. Open every dropdown (live, static, and light). The dropdown panel, search box, and option rows should also be square - confirming the teleported panel keeps its shape."),
          tags$p("4. Open a glass dropdown and a native selectize dropdown together and eyeball that the corners match."),
          tags$p("5. Select / clear values in each widget and confirm the live state below updates and stays in sync."),
          tags$p("6. The light-theme square column should stay square in both light styling and after teleport.")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  shape <- reactive({
    s <- input$shape
    if (is.null(s) || !nzchar(s)) "square" else s
  })

  # Runtime shape switching - no re-render, just an update message.
  observeEvent(shape(), {
    updateGlassSelect(session, "live_single_val", shape = shape())
    updateGlassMultiSelect(session, "live_multi_val", shape = shape())
  })

  live_single  <- glassSelectValue(input, "live_single_val")
  live_multi   <- glassMultiSelectValue(input, "live_multi_val")
  ab_single_sq <- glassSelectValue(input, "ab_single_square")
  ab_multi_sq  <- glassMultiSelectValue(input, "ab_multi_square")

  output$state <- renderPrint({
    list(
      shape                = shape(),
      live_single          = live_single(),
      live_multi           = live_multi$selected(),
      static_square_single = ab_single_sq(),
      static_square_multi  = ab_multi_sq$selected(),
      native_single        = input$native_single,
      native_multi         = input$native_multi
    )
  })
}

if (interactive()) shinyApp(ui, server)
