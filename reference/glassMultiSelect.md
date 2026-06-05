# Animated glass multi-select dropdown filter

A stylized multi-select Shiny input with optional search, style
switching, select-all behavior, and programmatic updates via
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md).

## Usage

``` r
glassMultiSelect(
  inputId,
  choices,
  selected = NULL,
  label = NULL,
  placeholder = "Filter by Category",
  all_label = "All categories",
  check_style = c("checkbox", "check-only", "filled"),
  show_style_switcher = TRUE,
  show_select_all = TRUE,
  show_clear_all = TRUE,
  theme = "dark",
  hues = NULL,
  dark_selector = NULL
)
```

## Arguments

- inputId:

  Shiny input id.

- choices:

  Named or unnamed character vector of choices.

- selected:

  Initially selected values. Defaults to all choices when `NULL`.

- label:

  Optional field label shown above the widget.

- placeholder:

  Trigger label when nothing is selected.

- all_label:

  Label shown when all choices are selected.

- check_style:

  One of `"checkbox"` (default), `"check-only"`, or `"filled"`.

- show_style_switcher:

  Show the Check / Box / Fill switcher row inside the dropdown? Default
  `TRUE`.

- show_select_all:

  Show the "Select all" row? Default `TRUE`.

- show_clear_all:

  Show the "Clear all" footer link? Default `TRUE`.

- theme:

  Color theme. One of `"dark"` (default) or `"light"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object.

- hues:

  Optional named integer vector of HSL hue angles (0 to 360) for the
  `"filled"` style. Auto-assigned if `NULL`.

- dark_selector:

  Optional CSS selector that signals dark mode (e.g. `"body.dark-mode"`
  for bs4Dash). When provided and `theme = "light"`, emits an extra
  scoped `<style>` block that reverts colors to the dark-mode defaults
  whenever that selector is active.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing the trigger button, dropdown panel, and scoped `<style>`
block.

## Details

The widget registers two Shiny inputs:

- `input$<inputId>` : character vector of selected values

- `input$<inputId>_style` : active style string (`"checkbox"`,
  `"check-only"`, or `"filled"`)

By default, when `selected = NULL`, all choices are initially selected.
This preserves the existing package behavior.

## Examples

``` r
fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# Minimal
fruit_filter <- glassMultiSelect("f", fruits)

# Lock style, hide extra controls
locked_filter <- glassMultiSelect(
  "f",
  fruits,
  check_style = "check-only",
  show_style_switcher = FALSE,
  show_select_all = FALSE,
  show_clear_all = FALSE
)

# Light theme
light_filter <- glassMultiSelect("f", fruits, theme = "light")
```
