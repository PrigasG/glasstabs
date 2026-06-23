# Animated glass single-select dropdown

A stylized single-select Shiny input with optional search, clear
control, selection-marker styling, and programmatic updates via
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md).

## Usage

``` r
glassSelect(
  inputId,
  choices,
  selected = NULL,
  label = NULL,
  placeholder = "Select an option",
  searchable = TRUE,
  clearable = FALSE,
  include_all = FALSE,
  all_choice_label = "All categories",
  all_choice_value = "__all__",
  check_style = c("checkbox", "check-only", "filled"),
  theme = "dark",
  shape = c("rounded", "square"),
  width = NULL,
  disabled = FALSE,
  disabled_choices = NULL,
  server = FALSE,
  server_limit = 50L,
  server_min_chars = 0L
)
```

## Arguments

- inputId:

  Shiny input id.

- choices:

  Named or unnamed character vector of choices.

- selected:

  Initially selected value. Defaults to `NULL`.

- label:

  Optional field label shown above the widget.

- placeholder:

  Trigger label when nothing is selected.

- searchable:

  Logical. Show search input inside dropdown? Default `TRUE`.

- clearable:

  Logical. Show clear control for removing the current selection?
  Default `FALSE`.

- include_all:

  Logical. Prepend an explicit "All" option. Default `FALSE`.

- all_choice_label:

  Label used for the explicit "All" option.

- all_choice_value:

  Value used for the explicit "All" option.

- check_style:

  One of `"checkbox"` (default), `"check-only"`, or `"filled"`.

- theme:

  Color theme. One of `"dark"` (default) or `"light"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object.

- shape:

  Corner style for the trigger and dropdown. One of `"rounded"`
  (default) for the signature glass look, or `"square"` for crisp,
  selectize-style corners so the widget sits neatly alongside native
  Shiny
  [`selectizeInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html)
  controls.

- width:

  Optional widget width passed to
  [`shiny::validateCssUnit()`](https://rstudio.github.io/htmltools/reference/validateCssUnit.html),
  e.g. `100%` or `240px`. When `NULL` (default) the trigger keeps its
  intrinsic width.

- disabled:

  Logical. When `TRUE` the whole widget is greyed out and
  non-interactive. Default `FALSE`.

- disabled_choices:

  Optional character vector of choice values to render as disabled
  (non-selectable) rows. Default `NULL`.

- server:

  Logical. If `TRUE`, render only an initial slice of choices and use
  [`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md)
  to search the full choice set from the Shiny server. Default `FALSE`.

- server_limit:

  Maximum number of choices rendered initially and returned for each
  server-side search. Default `50`.

- server_min_chars:

  Minimum search characters required before server-side matching filters
  choices. Default `0`.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing the single-select trigger, dropdown panel, and scoped
`<style>` block.

## Details

The widget registers one Shiny input:

- `input$<inputId>` : selected value as a length-1 character string, or
  `NULL` when nothing is selected

## Examples

``` r
fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

fruit_select <- glassSelect("fruit", fruits)

selected_fruit <- glassSelect(
  "fruit",
  fruits,
  selected = "banana",
  clearable = TRUE
)

all_fruits <- glassSelect(
  "fruit",
  fruits,
  include_all = TRUE,
  all_choice_label = "All fruits",
  all_choice_value = "__all__"
)

filled_fruit <- glassSelect(
  "fruit",
  fruits,
  check_style = "filled"
)
```
