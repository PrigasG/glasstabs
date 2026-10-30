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
  server_min_chars = 0L,
  searchable = TRUE,
  search_threshold = 15L,
  selection_display = c("auto", "count", "summary", "labels"),
  selection_max_items = 2L,
  dropdown_max_height = "260px",
  no_matches_text = "No matches",
  tongue = TRUE,
  label_bold = TRUE,
  fill_colors = c("single", "multi"),
  label_size = "14px",
  search_focus_ring = FALSE,
  overflow_tooltip = c("auto", "never")
)
```

## Arguments

- inputId:

  Shiny input id.

- choices:

  Named or unnamed character vector of choices, or a named list for
  grouped choices (selectInput()-style). A one-element named list such
  as `list(Group = "x")` is treated as a flat, ungrouped choice,
  mirroring
  [`shiny::selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html).

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

  Color theme. One of `"dark"` (default), `"light"`, `"auto"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object. `"auto"` uses the light preset by default and switches to the
  dark preset when an ancestor carries `data-bs-theme="dark"`.

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
  e.g. `100%` or `240px`. When `NULL` (default) the trigger uses a
  stable compact width of `160px`. Explicit widths continue to be capped
  by the container.

- disabled:

  Logical. When `TRUE` the whole widget is greyed out and
  non-interactive. Default `FALSE`.

- disabled_choices:

  Optional character vector of choice values to render as disabled
  (non-selectable) rows. Default `NULL`.

- hues:

  Optional named integer vector of HSL hue angles (0 to 360) for the
  `"filled"` style when `fill_colors = "multi"`. Auto-assigned if
  `NULL`.

- dark_selector:

  Optional CSS selector that signals dark mode (e.g. `"body.dark-mode"`
  for bs4Dash). When provided, emits an extra scoped `<style>` block
  that reverts colors to the dark-mode defaults whenever that selector
  is active.

- server:

  Logical. If `TRUE`, render only an initial slice of choices and use
  [`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
  to search the full choice set from the Shiny server. Default `FALSE`.

- server_limit:

  Maximum number of choices rendered initially. Search results are
  bounded separately by the `limit` argument of the `*Server()` helper.
  Default `50`. Explicitly selected values that fall outside the initial
  slice are still rendered as extra rows so they stay visible and
  checked.

- server_min_chars:

  Minimum search characters required before server-side matching filters
  choices. Default `0`.

- searchable:

  Search visibility. Use `TRUE` (default) to always show search, `FALSE`
  to hide it, or `"auto"` to show it only when the choice count reaches
  `search_threshold`.

- search_threshold:

  Choice count at which `searchable = "auto"` shows the search field.
  Default `15`.

- selection_display:

  How partial selections are summarized in the trigger: `"auto"` (the
  existing behavior), `"count"`, `"summary"`, or `"labels"`.

- selection_max_items:

  Number of labels shown by `selection_display = "summary"` before the
  remaining count is shown.

- dropdown_max_height:

  Maximum height of the scrolling option area as a CSS unit, such as
  `"18rem"` or `"320px"`. The default is `"260px"`.

- no_matches_text:

  Text shown when a search matches no choices. Default `"No matches"`.

- tongue:

  Logical. When `TRUE` (default), the dropdown attaches to the trigger
  and uses the signature tongue unfurl/retract animation. Set to `FALSE`
  for a detached panel with a short fade that sits more naturally beside
  native Shiny inputs.

- label_bold:

  Logical. Use a semibold field label, matching native Shiny inputs,
  when `TRUE` (default). Set to `FALSE` for regular-weight label text.

- fill_colors:

  Color treatment for `check_style = "filled"`. `"single"` (default)
  uses the theme accent for every selected row; `"multi"` keeps the
  categorical per-option colors.

- label_size:

  CSS size for the field label. The default, `"14px"`, keeps the title
  visually distinct from the dropdown options.

- search_focus_ring:

  Logical. When `TRUE`, focusing the dropdown search field adds the
  accent-colored outline. The default, `FALSE`, uses a quieter
  background and border change without the outer ring.

- overflow_tooltip:

  Tooltip behavior for long option text inside the open dropdown.
  `"auto"` (default) shows one tooltip for the truncated option
  currently under the pointer; `"never"` disables it. The multi-value
  trigger keeps its complete accessible label without showing a combined
  visual tooltip for every selection.

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

## See also

Other glass select widgets:
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md),
[`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md),
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
[`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md),
[`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md),
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md),
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)

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
