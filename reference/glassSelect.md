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
  theme = "dark"
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
