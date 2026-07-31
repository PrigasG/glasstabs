# Define a single glass tab panel

Used as child arguments inside
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).
Each call defines one tab button and its associated content pane.

## Usage

``` r
glassTabPanel(value, label, ..., icon = NULL, selected = FALSE)
```

## Arguments

- value:

  A unique string identifier for this tab (e.g. `"A"`).

- label:

  The text shown on the tab button.

- ...:

  UI elements for the pane content.

- icon:

  Optional icon shown to the left of the tab label. Accepts any
  htmltools-compatible tag, e.g. `shiny::icon("table")` or
  `fontawesome::fa("house")`. Pass `NULL` (default) for no icon.

- selected:

  Logical. Whether this tab starts selected. Only the first
  `selected = TRUE` tab takes effect; defaults to `FALSE`.

## Value

A list of class `"glassTabPanel"` consumed by
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

## See also

Other glass tabs:
[`appendGlassTab()`](https://prigasg.github.io/glasstabs/reference/appendGlassTab.md),
[`disableGlassTab()`](https://prigasg.github.io/glasstabs/reference/disableGlassTab.md),
[`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md),
[`glassTabsOutput()`](https://prigasg.github.io/glasstabs/reference/glassTabsOutput.md),
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md),
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md),
[`renderGlassTabs()`](https://prigasg.github.io/glasstabs/reference/renderGlassTabs.md),
[`showGlassTab()`](https://prigasg.github.io/glasstabs/reference/showGlassTab.md),
[`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md),
[`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)

## Examples

``` r
# Plain text label
overview_tab <- glassTabPanel("overview", "Overview",
  shiny::h3("Welcome"),
  shiny::p("This is the overview tab.")
)

# With a Shiny icon
data_tab <- glassTabPanel("data", "Data",
  icon = shiny::icon("table"),
  shiny::p("Data content here.")
)
```
