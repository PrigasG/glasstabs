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

## Examples

``` r
# Plain text label
glassTabPanel("overview", "Overview",
  shiny::h3("Welcome"),
  shiny::p("This is the overview tab.")
)
#> $value
#> [1] "overview"
#> 
#> $label
#> [1] "Overview"
#> 
#> $icon
#> NULL
#> 
#> $content
#> $content[[1]]
#> <h3>Welcome</h3>
#> 
#> $content[[2]]
#> <p>This is the overview tab.</p>
#> 
#> 
#> $selected
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "glassTabPanel"

# With a Shiny icon
glassTabPanel("data", "Data",
  icon = shiny::icon("table"),
  shiny::p("Data content here.")
)
#> $value
#> [1] "data"
#> 
#> $label
#> [1] "Data"
#> 
#> $icon
#> 
#> $content
#> $content[[1]]
#> <p>Data content here.</p>
#> 
#> 
#> $selected
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "glassTabPanel"
```
