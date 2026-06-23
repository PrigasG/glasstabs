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
  disabled_choices = NULL
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
