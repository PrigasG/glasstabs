# Update a glassSelect widget

Update the available choices, current selection, and/or selection-marker
style of an existing
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
input.

## Usage

``` r
updateGlassSelect(
  session,
  inputId,
  choices = NULL,
  selected = NULL,
  check_style = NULL
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

  New selected value, or `NULL` to keep the current selection. Use
  `character(0)` to clear.

- check_style:

  Optional new style string. One of `"checkbox"`, `"check-only"`, or
  `"filled"`. Defaults to `NULL`, which keeps the current style
  unchanged.

## Value

No return value. Called for its side effect of updating the client-side
widget.

## Details

This function follows Shiny-style update semantics:

- `choices = NULL` leaves choices unchanged

- `selected = NULL` leaves selection unchanged

- `selected = character(0)` clears the selection

- `check_style = NULL` leaves the current style unchanged

When `choices` is supplied and `selected` is not, the browser side keeps
the current selection if it is still present in the new choices.
