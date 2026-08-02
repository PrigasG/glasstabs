# Responsive and Accessible Tabs

Tabs often begin with three short labels and grow with the app. This
article keeps that larger version comfortable on a phone, with a
keyboard, and under system accessibility settings.

## A complete responsive app

``` r

library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "reports",
    glassTabPanel("summary", "Summary", selected = TRUE,
      h3("Summary"), p("A quick view of the current reporting period.")
    ),
    glassTabPanel("activity", "Recent activity",
      h3("Recent activity"), tableOutput("activity_table")
    ),
    glassTabPanel("quality", "Data quality",
      h3("Data quality"), plotOutput("quality_plot")
    ),
    glassTabPanel("settings", "Team settings",
      h3("Team settings"), textInput("team_name", "Team name")
    ),
    overflow = "scroll",
    theme = "auto"
  )
)

server <- function(input, output, session) {
  output$activity_table <- renderTable(head(mtcars))
  output$quality_plot <- renderPlot(plot(mtcars$wt, mtcars$mpg))
}

shinyApp(ui, server)
```

On a narrow screen, the labels remain in a touch-scrollable row.
Keyboard focus follows the selected tab, and a server update brings its
destination back into view.

## Choosing the overflow style

`"scroll"` is a natural fit for most tab bars. `"multiline"` is useful
when every label should be visible at once. In a horizontal layout,
`"menu"` keeps the header compact and uses a native select control.
Vertical tabs already have a dedicated rail, so compact menu mode is not
available there.

``` r

glassTabsUI(
  "wrapped",
  glassTabPanel("one", "First report", selected = TRUE, p("First")),
  glassTabPanel("two", "Second report", p("Second")),
  glassTabPanel("three", "Third report", p("Third")),
  overflow = "multiline"
)

glassTabsUI(
  "menu",
  glassTabPanel("one", "First report", selected = TRUE, p("First")),
  glassTabPanel("two", "Second report", p("Second")),
  overflow = "menu"
)
```

## Touch swipes without surprises

`swipe = TRUE` adds left and right gestures to ordinary panel content.
Inputs, links, buttons, Shiny outputs, HTML widgets, and horizontal
scrollers keep their own touch behavior.

``` r

glassTabsUI(
  "story",
  glassTabPanel("opening", "Opening", selected = TRUE, p("The first part.")),
  glassTabPanel("middle", "Middle", p("The middle part.")),
  glassTabPanel("ending", "Ending", p("The final part.")),
  swipe = TRUE
)
```

Add `data-gt-no-swipe` to any custom region that should always keep its
own gesture:

``` r

tags$div(`data-gt-no-swipe` = "", custom_touch_component)
```

## Motion and contrast

No R setting is needed for reduced motion. The browser preference
removes the transfer trace and badge pulse, shortens CSS transitions,
and shows the next panel without an animation delay.

Windows forced-colors mode uses system colors and visible focus
outlines. When backdrop blur is unsupported, the controls use solid
surfaces instead of losing contrast. Custom themes can set `focus_ring`
in
[`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
and
[`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md);
the colour follows select dropdowns when they move to the document body,
so search focus remains visible.

## Experimental fillable page

[`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
keeps a small full-page app pleasantly short:

``` r

ui <- glassPage(
  title = "Operations",
  glassTabsUI(
    "main",
    glassTabPanel("overview", "Overview", selected = TRUE, overview_ui),
    glassTabPanel("alerts", "Alerts", alerts_ui),
    overflow = "scroll",
    theme = "auto"
  )
)
```

It is an experimental wrapper around
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).
Plain [`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html),
[`page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html),
and dashboard layouts remain first-class homes for every glasstabs
widget.
