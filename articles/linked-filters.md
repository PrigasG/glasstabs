# Dependent dropdowns and dynamic UI

Filters rarely live alone: a region drives a county list, a facility
list refreshes overnight, a reset button must mean something precise.
This article covers the update scenarios the multi-select guide’s
transaction section summarizes, as full app policies rather than
argument definitions. The single-select rules differ in one place — its
updater has no preserve/drop options, so a vanished selection simply
clears — and that difference is called out below.

## The scenario table

| Scenario | The policy to write down |
|----|----|
| Region changes, county choices update | Preserve valid selections, remove invalid ones |
| Facility list refreshes | Keep selections that remain available |
| New choices arrive | Decide: keep available, or select every new choice |
| [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) replaces a dropdown | Keep the server registration outside the render |
| Several filters update together | Notify each filter whose value must sync |
| An existing choice becomes disabled | Update its disabled state consistently |
| A selected choice disappears | Know the resulting value and label |
| Reset button clicked | Define whether reset means all, default, or none |

## Keep what is still available

The default update already expresses the most common policy: keep the
current selection intersected with the new choices, drop the rest.

``` r

selected <- c("apple", "banana", "durian")
new_choices <- c("apple", "banana", "cherry")
kept <- intersect(selected, new_choices)
stopifnot(identical(kept, c("apple", "banana")))
```

``` r

updateGlassMultiSelect(
  session,
  "facility",
  choices = available_facilities,
  preserve_selection = TRUE,
  drop_invalid = TRUE,
  notify = "changed"
)
```

`preserve_selection = TRUE` (the default) keeps the current selection
when choices change; `drop_invalid = TRUE` (the default) drops selected
values absent from the new choices. Together they are “keep what is
still available.” `drop_invalid = FALSE` instead keeps absent values
around for when they reappear, which is what a bounded server search
wants — but then the widget can hold values no longer in the choice set,
so only use it when the app expects those values back.

## Select every newly available choice instead

Sometimes a refresh means “everything now available is in scope,” and
keeping the old selection would silently narrow the results. That is a
different policy, and it must be written as one:

``` r

updateGlassMultiSelect(
  session,
  "facility",
  choices = available_facilities,
  selected = unname(available_facilities),
  notify = "changed"
)
```

Neither policy is the default for the other. If the app sometimes keeps
and sometimes reselects, the branch belongs in the observer, not in a
shared helper that guesses.

## A selected choice disappears

For the multi-select, the two knobs above decide the outcome: dropped
(the default) or kept-but-absent (`drop_invalid = FALSE`). For the
single-select there are no knobs: updating `choices` without `selected`
keeps the current value if it still exists, and clears it to `NULL` if
it does not. There is no stale-value state in either widget, but there
is also no “invalid” marker — if the UI must show that a previously
selected item vanished, the app has to remember the old value itself
before updating.

## A choice becomes disabled

Disabled state is part of the choice set, not a separate widget
property. Update it with the same call that updates choices:

``` r

updateGlassMultiSelect(
  session,
  "facility",
  choices = available_facilities,
  disabled_choices = "durian",
  notify = "changed"
)
```

A disabled choice stays visible but cannot be selected, and it is never
part of the Select-all set. In server mode, pass `disabled_choices` to
the `*Server()` helper instead, and a disabled value takes effect when
it first arrives in a search response.

## renderUI replaces a dropdown

When [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html)
rebuilds a widget, the new control binds fresh and the old control’s
state is gone. Two rules keep this correct. First, keep server
registration outside the render: register
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
once in the server function for the input ID, and the newly rendered
control receives search results through Shiny. Second, re-apply the
intended selection after the render if the app must preserve it — the
rebuilt widget starts from its UI arguments, not from the previous
control’s state.

## Several filters settling at once

When one change cascades through several linked filters, each
intermediate update can rerun downstream observers for a state no user
will ever see. But a notification syncs only the input it belongs to:
notifying the region does not send the county’s or the facility’s
updated values to the server, so downstream reactives would keep seeing
their old selections. Notify every input whose server value must sync:

``` r

updateGlassMultiSelect(session, "county", choices = counties, notify = "changed")
updateGlassMultiSelect(session, "facility", choices = facilities, notify = "changed")
updateGlassMultiSelect(session, "region", choices = regions, notify = "changed")
```

`notify = "changed"` (the default) notifies only when the effective
selection actually changed; `"always"` forces an event.
`notify = "never"` makes a quiet update for one input only — use it when
that input’s server value genuinely does not matter yet, never as a way
to batch several inputs behind a single notification.

## Reset means one of three things

A reset button is ambiguous until the app defines it. The three
meanings, as the vectors to write back:

``` r

all_choices <- c("apple", "banana", "cherry")
initial_selection <- c("apple")
reset_all <- unname(all_choices)
reset_default <- initial_selection
reset_none <- character(0)
stopifnot(length(reset_all) == 3L)
stopifnot(identical(reset_default, "apple"))
stopifnot(length(reset_none) == 0L)
```

- **All:** `selected = unname(choices)` — every choice selected.
- **Default:** `selected = <the initial selection>` — the state the
  widget started in, which for a multi-select with `selected = NULL`
  means all enabled choices.
- **None:** `selected = character(0)` — empty. Pair this with the
  selection section’s empty-meaning decision: after a reset to none, the
  app must already know whether empty means no records or all records,
  or the reset will look broken.

Pick one, label the button with it (“Reset to all”, “Reset to defaults”,
“Clear filters”), and never let a bare “Reset” guess.
