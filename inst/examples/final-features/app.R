library(shiny)
pkg_root <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = "")
if (nzchar(pkg_root) && file.exists(file.path(pkg_root, "DESCRIPTION")) &&
    requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(pkg_root, quiet = TRUE)
} else {
  library(glasstabs)
}

ui <- fluidPage(
  useGlassTabs(),
  tags$h2("Final features lab"),
  tags$p("Arrange the tabs, reload the page, and request closure of editable tabs. The Home tab remains pinned."),
  glassSwitch("allow_close", "Allow closure", TRUE, glass_strength = 0.25),
  actionButton("add", "Append a closable tab"),
  actionButton("reset", "Reset choice inputs"),
  tags$button(type = "button", id = "clear_order", class = "btn btn-default", "Clear saved order and reload"),
  glassTabsUI("workspace",
    glassTabPanel("home", "Home",
      glassSwitch("enabled", "Enable filtering", TRUE),
      glassRadioGroup("mode", "Mode", c(Edit = "edit", Preview = "preview"), inline = TRUE),
      glassCheckboxGroup("fields", "Fields", c(Name = "name", County = "county", Rating = "rating"),
                         selected = c("name", "county"), inline = TRUE),
      verbatimTextOutput("values")),
    glassTabPanel("report", "Report", textInput("retained", "Retained text", "Keep me"), closable = TRUE),
    glassTabPanel("data", "Data", plotOutput("plot", height = "180px"), closable = TRUE),
    glassTabPanel("settings", "Settings", p("Try dragging the handle on a touch screen."), closable = TRUE),
    glassTabPanel("quality", "Quality indicators", p("Overflow testing"), closable = TRUE),
    glassTabPanel("operations", "Operations dashboard", p("Overflow testing"), closable = TRUE),
    theme = "auto", style = "segmented", transition = "none", reorderable = TRUE,
    touch_reorder = TRUE, persist_order = "local", order_key = "final-features-example",
    initial_order = c("home", "report", "data")),
  tags$h3("Select scrolling"),
  glassSelect("scroll_test", paste("Choice", 1:50), width = "240px",
              dropdown_max_height = "150px"),
  tags$h3("Empty workspace recovery"),
  actionButton("disable_only", "Disable last tab"), actionButton("enable_only", "Enable last tab"),
  actionButton("hide_only", "Hide last tab"), actionButton("show_only", "Show last tab"),
  actionButton("remove_only", "Remove last tab"), actionButton("append_only", "Append after empty"),
  glassTabsUI("empty_demo", glassTabPanel("only", "Only", p("Remove me")),
              reorderable = TRUE, transition = "none", theme = "auto"),
  tags$h3("Menu overflow closure"),
  glassTabsUI("menu_demo", glassTabPanel("a", "Pinned", p("Pinned")),
              glassTabPanel("b", "Closable", p("Use the external close button."), closable = TRUE),
              overflow = "menu", theme = "auto", transition = "none"),
  verbatimTextOutput("events"),
  tags$script(HTML("document.getElementById('clear_order').addEventListener('click',function(){
    try{localStorage.removeItem('glasstabs:order:v1:'+JSON.stringify([location.pathname,'final-features-example']));}catch(e){}
    location.reload();
  });"))
)

server <- function(input, output, session) {
  available <- reactiveVal(c("home", "report", "data", "settings", "quality", "operations"))
  counter <- reactiveVal(0L)
  last_close <- reactiveVal("None")
  observeEvent(input[["workspace-close_request"]], {
    value <- input[["workspace-close_request"]]
    if (!isTRUE(input$allow_close) || !value %in% setdiff(available(), "home")) {
      last_close(paste("Rejected:", value)); return()
    }
    removeGlassTab(session, "workspace", value)
    available(setdiff(available(), value)); last_close(paste("Accepted:", value))
  })
  observeEvent(input[["menu_demo-close_request"]], {
    if (identical(input[["menu_demo-close_request"]], "b")) removeGlassTab(session, "menu_demo", "b")
  })
  observeEvent(input$add, {
    n <- counter() + 1L; counter(n); value <- paste0("added", n)
    appendGlassTab(session, "workspace", glassTabPanel(value, paste("Added", n), p("Dynamic pane"), closable = TRUE))
    available(c(available(), value))
  })
  observeEvent(input$reset, {
    updateCheckboxInput(session, "enabled", value = TRUE)
    updateRadioButtons(session, "mode", selected = "edit")
    updateCheckboxGroupInput(session, "fields", selected = c("name", "county"))
  })
  observeEvent(input$disable_only, disableGlassTab(session, "empty_demo", "only"))
  observeEvent(input$enable_only, enableGlassTab(session, "empty_demo", "only"))
  observeEvent(input$hide_only, hideGlassTab(session, "empty_demo", "only"))
  observeEvent(input$show_only, showGlassTab(session, "empty_demo", "only"))
  observeEvent(input$remove_only, removeGlassTab(session, "empty_demo", "only"))
  observeEvent(input$append_only, appendGlassTab(session, "empty_demo",
    glassTabPanel("new", "New", textInput("recovered", "Recovered")), select = FALSE))
  output$plot <- renderPlot(plot(1:10, type = "b"))
  output$values <- renderPrint(list(enabled = input$enabled, mode = input$mode, fields = input$fields))
  output$events <- renderPrint(list(active = input[["workspace-active_tab"]],
                                    order = input[["workspace-tab_order"]],
                                    close = last_close(), available = available(),
                                    empty_active = input[["empty_demo-active_tab"]]))
}
shinyApp(ui, server)
