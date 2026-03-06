# Define a single glass tab panel

Used as child arguments inside
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).
Each call defines one tab button and its associated content pane.

## Usage

``` r
glassTabPanel(value, label, ..., selected = FALSE)
```

## Arguments

- value:

  A unique string identifier for this tab (e.g. `"A"`).

- label:

  The text shown on the tab button.

- ...:

  UI elements for the pane content.

- selected:

  Logical. Whether this tab starts selected. Only the first
  `selected = TRUE` tab takes effect; defaults to `FALSE`.

## Value

A list of class `"glassTabPanel"` consumed by
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md).

## Examples

``` r
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
```
