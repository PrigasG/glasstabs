library(shiny)
library(glasstabs)

choices <- c(Provider = "provider", Staffing = "staffing",
             "Population estimates with a deliberately long label" = "population",
             Finance = "finance", Quality = "quality")
county_names <- c("Atlantic", "Bergen", "Burlington", "Camden", "Cape May",
                  "Cumberland", "Essex", "Gloucester", "Hudson", "Hunterdon",
                  "Mercer", "Middlesex", "Monmouth", "Morris", "Ocean",
                  "Passaic", "Salem", "Somerset", "Sussex", "Union", "Warren")
counties <- stats::setNames(tolower(county_names), county_names)

ui <- fluidPage(
  useGlassTabs(),
  tags$head(tags$style(HTML("
    body{padding:18px;background:#f8fafc;color:#243244;}
    body[data-bs-theme=dark]{background:#18202a;color:#e2e8f0;}
    body[data-bs-theme=dark] .well,body[data-bs-theme=dark] pre{
      background:#242e3b;color:#e2e8f0;border-color:#485568;}
    .gt-lab-panel{padding:14px;border:1px solid #9ca3af;border-radius:10px;margin-bottom:16px;}
    .gt-lab-layer{position:relative;min-height:78px;}
    #host_menu{display:none;position:absolute;top:22px;left:42px;width:180px;
      padding:10px;z-index:20;background:#fff;color:#243244;border:1px solid #64748b;
      border-radius:6px;box-shadow:0 3px 10px #0002;}
    #host_menu.visible{display:block;}
    #layer_veil{position:fixed;inset:0;z-index:1100;background:#0008;
      display:flex;align-items:center;justify-content:center;}
    .gt-lab-actions .btn{margin:2px;}
  "))),
  tags$h2("glasstabs modernization lab"),
  tags$p("Change configuration to rebuild the preview. Use the lifecycle buttons to test state without rebuilding."),
  fluidRow(
    column(3,
      wellPanel(
        selectInput("nav_style", "Tab style", c("floating", "attached", "segmented"), "attached"),
        selectInput("indicator", "Indicator", c("glass", "solid", "underline"), "underline"),
        selectInput("transition", "Transition", c("fade", "slide", "none"), "none"),
        selectInput("orientation", "Orientation", c("horizontal", "vertical")),
        selectInput("overflow", "Overflow", c("scroll", "multiline", "menu")),
        sliderInput("strength", "Glass strength", 0, 1, 0.25, step = 0.05),
        selectInput("density", "Select size", c("sm", "md", "lg"), "sm"),
        selectInput("shape", "Shape", c("rounded", "square")),
        checkboxInput("fill", "Fill fixed-height preview", FALSE),
        checkboxInput("reorder", "Reorderable tabs", TRUE),
        checkboxInput("equal", "Equal widths", FALSE),
        checkboxInput("hide_single", "Hide single tab", TRUE),
        checkboxInput("spacing", "Custom spacing", TRUE),
        checkboxInput("surfaces", "Custom select surfaces", FALSE),
        tags$button(type = "button", class = "btn btn-default", id = "toggle_mode",
                    "Toggle light/dark")
      )
    ),
    column(9,
      div(class = "gt-lab-panel", uiOutput("preview")),
      div(class = "gt-lab-panel gt-lab-actions",
          tags$h4("Lifecycle operations"),
          actionButton("append", "Append tab"), actionButton("remove", "Remove last added"),
          actionButton("hide", "Hide Settings"), actionButton("show", "Show Settings"),
          actionButton("disable", "Disable Data"), actionButton("enable", "Enable Data"),
          actionButton("select_b", "Select Data"), actionButton("refresh_choices", "Update choices"),
          actionButton("modal", "Open modal"),
          tags$button(type = "button", class = "btn btn-default", id = "delayed_veil",
                      "Show host overlay after 2s"),
          tags$p("Drag tabs on desktop, or focus a tab and use Alt+Shift+arrow. Try a cancelled drag.")),
      div(class = "gt-lab-panel", tags$h4("Closed-field layering probe"),
          tags$p("Open the host menu over the closed selects. It must remain on top and clickable."),
          tags$button(type = "button", class = "btn btn-default", id = "toggle_host_menu", "Toggle host menu"),
          div(class = "gt-lab-layer",
              glassSelect("layer_single", choices, theme = "auto", width = "220px"),
              glassMultiSelect("layer_multi", choices, theme = "auto", width = "220px"),
              div(id = "host_menu", tags$button(type = "button", id = "host_click", "Host menu button")))),
      div(class = "gt-lab-panel", tags$h4("Long-list scrolling"),
          tags$p("Open a county list, then scroll or search. The cue appears only while more choices remain below."),
          fluidRow(
            column(6, glassSelect("county_single", counties, label = "County",
                                  searchable = "auto", width = "100%",
                                  dropdown_max_height = "180px", theme = "auto")),
            column(6, glassMultiSelect("county_multi", counties, label = "Counties",
                                       selected = character(), searchable = "auto",
                                       width = "100%", dropdown_max_height = "180px",
                                       theme = "auto"))
          )),
      div(class = "gt-lab-panel", tags$h4("Diagnostics"),
          tags$button(type = "button", class = "btn btn-default", id = "snapshot", "Capture browser diagnostics"),
          tags$p("Capture once before and after reproducing an issue. Browser errors and Shiny values are shown below."),
          verbatimTextOutput("diagnostics"), verbatimTextOutput("browser_diagnostics"),
          tags$h4("Current configuration"), verbatimTextOutput("configuration"))
    )
  ),
  tags$script(HTML("
    (function(){
      var errors=[];
      function record(e){
        errors.push(String(e.message || e.reason || 'Unknown browser error'));
        if(errors.length>30) errors.shift();
      }
      window.addEventListener('error',record);
      window.addEventListener('unhandledrejection',record);
      document.body.setAttribute('data-bs-theme','light');
      document.getElementById('toggle_mode').addEventListener('click',function(){
        var b=document.body;
        b.setAttribute('data-bs-theme',b.getAttribute('data-bs-theme')==='dark'?'light':'dark');
      });
      document.getElementById('toggle_host_menu').addEventListener('click',function(){
        document.getElementById('host_menu').classList.toggle('visible');
      });
      document.getElementById('host_click').addEventListener('click',function(){
        this.textContent='Host click registered';
      });
      document.getElementById('delayed_veil').addEventListener('click',function(){
        setTimeout(function(){
          if(document.getElementById('layer_veil')) return;
          var d=document.createElement('div');d.id='layer_veil';
          var button=document.createElement('button');button.textContent='Dismiss host overlay';
          button.addEventListener('click',function(){d.remove();});d.appendChild(button);
          document.body.appendChild(d);
        },2000);
      });
      document.getElementById('snapshot').addEventListener('click',function(){
        var widgets=Array.from(document.querySelectorAll('.gt-gs-wrap,.gt-ms-wrap')).map(function(w){
          var t=w.querySelector('.gt-gs-trigger,.gt-ms-trigger');
          var d=w._gtDropdown || w.querySelector('.gt-gs-dropdown,.gt-ms-dropdown');
          var r=t.getBoundingClientRect(), c=getComputedStyle(t), z=getComputedStyle(w).zIndex;
          var top=document.elementFromPoint(r.left+r.width/2,r.top+r.height/2);
          return {id:w.id,expanded:t.getAttribute('aria-expanded'),wrapperZ:z,
            triggerBlur:c.backdropFilter,triggerHeight:Math.round(r.height),
            topAtCenter:top ? top.id || (typeof top.className === 'string' ? top.className : top.tagName) : null,
            portal:!!d && d.parentElement===document.body,
            panelZ:d?getComputedStyle(d).zIndex:null,
            panelBackground:d?getComputedStyle(d).backgroundColor:null,
            panelBlur:d?getComputedStyle(d).backdropFilter:null};
        });
        var root=document.getElementById('workspace-wrap');
        var tabs=root?Array.from(root.querySelectorAll(':scope > .gt-topbar > .gt-tab-viewport > .gt-navbar > .gt-tab-link')).map(function(t){
          return {value:t.getAttribute('data-value'),active:t.classList.contains('active'),
            hidden:t.classList.contains('gt-tab-hidden'),disabled:t.classList.contains('gt-tab-disabled')};
        }):[];
        if(window.Shiny) Shiny.setInputValue('browser_report',{
          viewport:[innerWidth,innerHeight],mode:document.body.getAttribute('data-bs-theme'),
          agent:navigator.userAgent,widgets:widgets,tabs:tabs,errors:errors.slice()
        },{priority:'event'});
      });
    })();
  "))
)

server <- function(input, output, session) {
  added <- reactiveVal(character())
  counter <- reactiveVal(0L)
  settings <- reactive({
    req(input$nav_style, input$indicator, input$transition, input$orientation,
        input$overflow, input$density, input$shape, input$strength)
    list(style = input$nav_style, indicator = input$indicator,
         transition = input$transition, orientation = input$orientation,
         overflow = if (input$orientation == "vertical" && input$overflow == "menu") "scroll" else input$overflow,
         glass_strength = input$strength, fill = isTRUE(input$fill),
         reorderable = isTRUE(input$reorder), equal_width = isTRUE(input$equal),
         hide_single = isTRUE(input$hide_single), shape = input$shape,
         tab_gap = if (isTRUE(input$spacing)) "4px" else NULL,
         tab_padding = if (isTRUE(input$spacing)) "8px 12px" else NULL,
         nav_padding = if (isTRUE(input$spacing)) "6px" else NULL,
         content_padding = if (isTRUE(input$spacing)) "12px" else NULL)
  })
  output$preview <- renderUI({
    opts <- settings()
    select_theme <- if (isTRUE(input$surfaces)) {
      glass_select_theme(mode = "light", trigger_bg = "#f1f5f9", dropdown_bg = "#ffffff")
    } else "auto"
    # Explicit custom surfaces use a fixed light palette; auto mode follows the host.
    panels <- list(
      glassTabPanel("overview", "Overview",
                    textInput("retained_text", "Input to preserve", "Keep me"),
                    glassSelect("live_single", choices, selected = "provider", clearable = TRUE,
                                theme = select_theme, size = input$density,
                                shape = input$shape, glass_strength = input$strength,
                                dropdown_max_height = "180px", width = "100%"),
                    glassMultiSelect("live_multi", choices, selected = c("staffing", "finance"),
                                     theme = select_theme, size = input$density,
                                     shape = input$shape, glass_strength = input$strength, width = "100%")),
      glassTabPanel("data", "Data and validation", plotOutput("plot", height = "180px"),
                    tags$p("Scroll the filled pane to the bottom."),
                    tableOutput("sample")),
      glassTabPanel("settings", "Settings",
                    glassTabsUI("nested", glassTabPanel("a", "Nested A", p("Independent nested tabs")),
                                glassTabPanel("b", "Nested B", p("This widget retains the default animation.")),
                                theme = "auto"))
    )
    div(style = if (opts$fill) "height:400px;" else NULL,
        do.call(glassTabsUI, c(list(id = "workspace", theme = "auto"), panels, opts)))
  })
  observeEvent(settings(), added(character()), ignoreInit = TRUE)
  observeEvent(list(input$density, input$surfaces), added(character()), ignoreInit = TRUE)
  observeEvent(input$append, {
    n <- counter() + 1L; counter(n)
    value <- paste0("added", n)
    appendGlassTab(session, "workspace", glassTabPanel(value, paste("Added", n),
                   textInput(paste0(value, "_text"), "Dynamic input", value)), select = TRUE)
    added(c(added(), value))
  })
  observeEvent(input$remove, {
    values <- added(); if (!length(values)) return()
    removeGlassTab(session, "workspace", tail(values, 1L)); added(head(values, -1L))
  })
  observeEvent(input$hide, hideGlassTab(session, "workspace", "settings"))
  observeEvent(input$show, showGlassTab(session, "workspace", "settings"))
  observeEvent(input$disable, disableGlassTab(session, "workspace", "data"))
  observeEvent(input$enable, enableGlassTab(session, "workspace", "data"))
  observeEvent(input$select_b, updateGlassTabsUI(session, "workspace", "data"))
  observeEvent(input$refresh_choices, {
    revised <- c(choices, "New category" = "new")
    updateGlassSelect(session, "live_single", choices = revised)
    updateGlassMultiSelect(session, "live_multi", choices = revised)
  })
  observeEvent(input$modal, showModal(modalDialog(
    title = "Modal dropdowns", glassSelect("modal_select", choices, theme = "auto", size = "sm"),
    glassMultiSelect("modal_multi", choices, theme = "auto", glass_strength = 0.25), easyClose = TRUE
  )))
  output$plot <- renderPlot(plot(seq_len(10), type = "b", col = "#2563eb"))
  output$sample <- renderTable(utils::head(iris, 12))
  output$diagnostics <- renderPrint({
    list(package = as.character(utils::packageVersion("glasstabs")),
         active = input[["workspace-active_tab"]], order = input[["workspace-tab_order"]],
         retained_text = input$retained_text, single = input$live_single,
         multi = input$live_multi, single_open = input$live_single_open,
         multi_open = input$live_multi_open, dynamic_tabs = added())
  })
  output$browser_diagnostics <- renderPrint({
    if (is.null(input$browser_report)) cat("No browser snapshot yet.\n")
    else cat(jsonlite::toJSON(input$browser_report, auto_unbox = TRUE, pretty = TRUE))
  })
  output$configuration <- renderPrint({
    print(c(settings(), list(select_size = input$density, custom_surfaces = input$surfaces)))
  })
}

shinyApp(ui, server)
