# Update a glassMultiSelect widget

Update the available choices and/or current selection of an existing
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
input.

## Usage

``` r
updateGlassMultiSelect(
  session,
  inputId,
  choices = NULL,
  selected = NULL,
  check_style = NULL,
  shape = NULL,
  disabled = NULL,
  disabled_choices = NULL,
  preserve_selection = TRUE,
  drop_invalid = TRUE,
  notify = c("changed", "always", "never"),
  searchable = NULL,
  search_threshold = NULL,
  selection_display = NULL,
  selection_max_items = NULL,
  dropdown_max_height = NULL
)
```

## Arguments

- session:

  Shiny session.

- inputId:

  Input id of the widget.

- choices:

  New choices, or `NULL` to keep current choices.

- selected:

  New selected values, or `NULL` to keep current selection. Use
  `character(0)` to clear.

- check_style:

  Optional new style string. One of `"checkbox"`, `"check-only"`, or
  `"filled"`. Defaults to `NULL`, which keeps the current style
  unchanged.

- shape:

  Optional new corner style. One of `"rounded"` or `"square"`. Defaults
  to `NULL`, which keeps the current shape unchanged.

- disabled:

  Optional logical. `TRUE`/`FALSE` toggles the whole-widget disabled
  state. Defaults to `NULL`, which leaves it unchanged.

- disabled_choices:

  Optional character vector of choice values to render as disabled.
  Defaults to `NULL`, which leaves disabled choices unchanged.

- preserve_selection:

  Keep the current selection when choices change. Default `TRUE`.
  Ignored when `selected` is supplied.

- drop_invalid:

  Drop selected values that are absent from new choices. Default `TRUE`.
  Set to `FALSE` for server-backed or staged choice updates where
  selected values may be temporarily absent.

- notify:

  When to notify Shiny after the transaction: `"changed"` (default),
  `"always"`, or `"never"`.

- searchable:

  Optional new search visibility: `TRUE`, `FALSE`, or `"auto"`. `NULL`
  keeps the current setting.

- search_threshold:

  Optional new threshold used by automatic search.

- selection_display:

  Optional new trigger summary mode.

- selection_max_items:

  Optional new summary label limit.

- dropdown_max_height:

  Optional new option-area maximum height as a CSS unit. `NULL` keeps
  the current height.

## Value

No return value. Called for its side effect of updating the client-side
widget.

## Details

This function now follows Shiny-style update semantics more closely:

- `choices = NULL` leaves choices unchanged

- `selected = NULL` leaves selection unchanged

- `selected = character(0)` clears the selection

When `choices` is supplied and `selected` is not, the browser side keeps
the intersection of the current selection and the new set of choices.

## See also

Other glass select widgets:
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md),
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md),
[`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md),
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
[`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md),
[`glassSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassSelectValue.md),
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md)
