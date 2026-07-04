# glasstabs example: indicator styles, vertical orientation, auto theming
#
# Demonstrates the features added in the development version:
#   - indicator = "glass" / "solid" / "underline"
#   - orientation = "vertical" (with underline side-bar + Up/Down keys)
#   - theme = "auto" (follows Bootstrap 5 / bslib data-bs-theme live)
#
# Run with: glasstabs::runGlassExample("indicators")

library(shiny)
library(glasstabs)

has_bslib <- requireNamespace("bslib", quietly = TRUE)

demo_tabs <- function(id, ...) {
  glassTabsUI(
    id,
    glassTabPanel("overview", "Overview",
      p("The sliding indicator now fits the active tab exactly - no spill."),
      p("Switch tabs to compare the animation across styles.")
    ),
    glassTabPanel("data", "Data",
      p("Badge, icon, and disable APIs work identically in every style.")
    ),
    glassTabPanel("settings", "Settings",
      p("Colors follow glass_tab_theme(): halo_bg / halo_border drive all three indicators.")
    ),
    compact = TRUE,
    ...
  )
}

section <- function(title, code, ui) {
  tagList(
    h4(title, style = "margin-top:28px;"),
    tags$code(code),
    div(style = "margin-top:10px;", ui)
  )
}

core_ui <- tagList(
  useGlassTabs(),

  h3("Indicator styles"),
  p("Same animation, three renderings. Use arrow keys when a tab is focused."),

  section('indicator = "glass" (default)',
          'glassTabsUI(id, ..., indicator = "glass")',
          demo_tabs("demo_glass", indicator = "glass", theme = "auto")),

  section('indicator = "solid"',
          'glassTabsUI(id, ..., indicator = "solid")',
          demo_tabs("demo_solid", indicator = "solid", theme = "auto")),

  section('indicator = "underline"',
          'glassTabsUI(id, ..., indicator = "underline")',
          demo_tabs("demo_underline", indicator = "underline", theme = "auto")),

  h3("Vertical orientation", style = "margin-top:36px;"),
  p("Tabs stack in a rail; ArrowUp/ArrowDown navigate; the underline becomes a side bar."),

  section('orientation = "vertical", indicator = "underline"',
          'glassTabsUI(id, ..., orientation = "vertical", indicator = "underline")',
          demo_tabs("demo_vertical",
                    orientation = "vertical",
                    indicator = "underline",
                    theme = "auto"))
)

if (has_bslib) {
  ui <- bslib::page_fluid(
    theme = bslib::bs_theme(version = 5),
    div(
      style = "max-width:900px;margin:0 auto;padding:24px 12px;",
      div(
        style = "display:flex;justify-content:space-between;align-items:center;",
        h2("glasstabs: indicators demo"),
        bslib::input_dark_mode(id = "mode")
      ),
      p(
        "All widgets below use ", tags$code('theme = "auto"'),
        " - toggle dark mode (top right) and they follow instantly, in the browser."
      ),
      core_ui
    )
  )
} else {
  # Fallback without bslib: plain dark page
  ui <- fluidPage(
    tags$head(tags$style("body{background:#0f172a;color:#e2e8f0;}")),
    div(
      style = "max-width:900px;margin:0 auto;padding:24px 12px;",
      h2("glasstabs: indicators demo"),
      p("Install the bslib package to also try the dark-mode toggle with theme = \"auto\"."),
      core_ui
    )
  )
}

server <- function(input, output, session) {
  # Show that server APIs work regardless of indicator style
  updateGlassTabBadge(session, "demo_solid", "data", 3)
  updateGlassTabBadge(session, "demo_underline", "settings", 12)
}

shinyApp(ui, server)
