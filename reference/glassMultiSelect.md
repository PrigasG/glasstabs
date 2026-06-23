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
  shape = c("rounded", "square"),
  width = NULL,
  disabled = FALSE,
  disabled_choices = NULL,
  hues = NULL,
  dark_selector = NULL,
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

- hues:

  Optional named integer vector of HSL hue angles (0 to 360) for the
  `"filled"` style. Auto-assigned if `NULL`.

- dark_selector:

  Optional CSS selector that signals dark mode (e.g. `"body.dark-mode"`
  for bs4Dash). When provided and `theme = "light"`, emits an extra
  scoped `<style>` block that reverts colors to the dark-mode defaults
  whenever that selector is active.

- server:

  Logical. If `TRUE`, render only an initial slice of choices and use
  [`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
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
