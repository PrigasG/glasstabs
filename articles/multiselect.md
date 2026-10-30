# Multi-Select with glasstabs

## Why multi-select is the centerpiece

Most Shiny dashboards are, at heart, a filter problem: pick a set of
categories, regions, or products, and everything downstream — tables,
plots, summaries — follows that set.
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
is the widget built for exactly that job. It is a searchable, themeable,
animated multi-select dropdown that behaves like a standard Shiny input
while adding the pieces a filter UI usually needs bolted on afterwards:
a compact trigger summary, removable tag pills, a select-all row,
server-side search for large choice sets, and transactional server
updates.

If you only learn one glasstabs widget, learn this one. The
single-select
([`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md))
shares its dropdown engine, themes, and animations, so much of this
transfers—but the multi-select is where the package’s filtering story
lives. See the [single-select
guide](https://prigasg.github.io/glasstabs/articles/glassSelect.md) when
one value is the right contract.

## A complete app in one page

``` r

library(shiny)
library(glasstabs)

fruits <- c(Apple = "apple",
            Banana = "banana",
            Cherry = "cherry",
            Mango = "mango",
            Peach = "peach")

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("pick", fruits),
  glassFilterTags("pick"),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)
}

if (interactive()) shinyApp(ui, server)
```

Two things to notice. First,
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
is called once in the UI: it loads the package CSS and JavaScript. The
multi-select does **not** need a tab layout — it works standalone in any
Shiny page. Second, the widget is an ordinary Shiny input: `input$pick`
is a character vector of the selected values, and it updates as the user
selects and deselects options.

## What the widget produces

| Input | Type | Value |
|----|----|----|
| `input$<inputId>` | character vector | Currently selected values |
| `input$<inputId>_style` | character | Active checkbox style |
| `input$<inputId>_open` | logical | Whether the dropdown is open |
| `input$<inputId>_ready` | logical | Whether the widget has finished initializing |

`input$<inputId>_ready` becomes `TRUE` once the widget’s JavaScript has
booted and synced its initial state. Gate observers that depend on the
widget being initialized on it, rather than on session start:

``` r

server <- function(input, output, session) {
  observeEvent(input$pick_ready, {
    # Safe to read input$pick and drive downstream outputs here.
  }, ignoreInit = FALSE)
}
```

## The selection model: all, some, or none

The default surprises people coming from
[`selectizeInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html), so
say it plainly: **when `selected = NULL` (the default), every choice
starts selected.** That is the filter-friendly default — an untouched
filter means “everything”, not “nothing”.

``` r

# All selected (default)
glassMultiSelect("f", fruits)

# A subset pre-selected
glassMultiSelect("f", fruits, selected = c("apple", "cherry"))

# Nothing pre-selected — the trigger shows the placeholder instead
glassMultiSelect("f", fruits, selected = character(0))
```

Two labels control the trigger text at the extremes. `placeholder`
(default `"Filter by Category"`) shows when nothing is selected;
`all_label` (default `"All categories"`) shows when everything is
selected. Set them to match the domain — `"Filter by region"` and
`"All regions"` read better than the generics in a real app.

### How a partial selection is shown

`selection_display` controls the trigger when some, but not all, options
are selected:

``` r

# "auto" — the familiar single-label / "Multiple selection" behavior
glassMultiSelect("f", fruits, selection_display = "auto")

# "3 selected" — compact, always the same width
glassMultiSelect("f", fruits, selection_display = "count")

# First labels, then "+N" — the dashboard default
glassMultiSelect("f", fruits,
  selection_display = "summary",
  selection_max_items = 2
)

# Every selected label, comma-separated
glassMultiSelect("f", fruits, selection_display = "labels")
```

`selection_max_items` (default `2`) sets how many labels `summary` shows
before the `+N` remainder. For a filter bar with several multi-selects
side by side, `count` or `summary` keeps triggers from jumping around as
selections change.

## Check styles, and the style switcher

Three indicator styles are available via `check_style`:

``` r

# Bordered box + animated tick (default)
glassMultiSelect("f", fruits, check_style = "checkbox")

# Tick only — minimal, no box border
glassMultiSelect("f", fruits, check_style = "check-only")

# Solid coloured box
glassMultiSelect("f", fruits, check_style = "filled")
```

By default a Check / Box / Fill switcher row sits inside the dropdown so
users can change the style at runtime; the active style is readable at
`input$<inputId>_style`. Hide it with `show_style_switcher = FALSE` to
lock the style silently.

### Filled rows: one accent, or one hue per option

`fill_colors` controls the `filled` style, and the default matters:

``` r

# One theme accent for every selected row (the default)
glassMultiSelect("f", fruits,
  check_style = "filled",
  fill_colors = "single"
)

# Per-option hues — categorical colour per choice
glassMultiSelect("f", fruits,
  check_style = "filled",
  fill_colors = "multi"
)
```

With `fill_colors = "multi"`, hues are auto-assigned evenly around the
colour wheel. Override them with a named integer vector of HSL hue
angles (0–360); the `hues` argument only applies when
`fill_colors = "multi"`:

``` r

glassMultiSelect("f", fruits,
  check_style = "filled",
  fill_colors = "multi",
  hues = c(apple = 0, banana = 50, cherry = 340, mango = 30, peach = 20)
)
```

## Search: always, automatic, or never

Search is shown by default. Three modes cover the real cases:

``` r

# Always show the search box (the default)
glassMultiSelect("f", fruits, searchable = TRUE)

# Hide it entirely — right for a small, fixed list
glassMultiSelect("f", fruits, searchable = FALSE)

# Show it only once the list is big enough to need it
glassMultiSelect("f", fruits,
  searchable = "auto",
  search_threshold = 12
)
```

With `searchable = "auto"`, the search box appears only when the choice
count reaches `search_threshold` (default `15`). Five categories stay
uncluttered; fifty get a search box without any extra code. The
threshold is a choice count, not a character count, and it can be
changed at runtime with
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md).

Two smaller search controls: `no_matches_text` (default `"No matches"`)
is the empty-result message, and `dropdown_max_height` (default
`"260px"`) caps the scrolling option area. `search_focus_ring = TRUE`
opts into an accent outline when the search field is focused; the
default `FALSE` uses a quieter background and border change.

## Long labels, wrapping, and tooltips

The open dropdown always matches the trigger width — it never stretches
a short field to fit a long label. Longer labels wrap inside that shared
width instead, and the trigger itself uses a stable compact width
(`160px`) unless you pass `width` explicitly (fixed or fluid widths are
supported and stay capped by the containing layout):

``` r

glassMultiSelect("f", fruits, width = "100%")
glassMultiSelect("f", fruits, width = "240px")
```

A wrapped option is still fully readable. With the default
`overflow_tooltip = "auto"`, hovering a truncated option—or reaching it
with keyboard navigation—reveals a capped text preview; only one option
tooltip appears at a time. The complete option text remains in the DOM
and accessible name. The trigger itself does not combine every selection
into one visual tooltip—for a multi-select, that combined tooltip would
just be noise. On touch devices, the wrapped option text inside the open
dropdown is the fallback. Set `overflow_tooltip = "never"` to disable
option tooltips.

``` r

glassMultiSelect(
  "long_filters",
  c(
    "Commercial real estate development and property management services" = "property",
    Healthcare = "healthcare"
  ),
  selected = "property",
  width = "240px",
  selection_display = "summary",
  overflow_tooltip = "auto"
)
```

## Select all, clear all, and the chrome rows

Three chrome rows sit inside the dropdown, each independently toggleable
(all default `TRUE`):

``` r

glassMultiSelect("f", fruits,
  show_style_switcher = FALSE,   # hide the Check / Box / Fill row
  show_select_all     = FALSE,   # hide the "Select all" row
  show_clear_all      = FALSE    # hide the "Clear all" footer link
)
```

The select-all row acts only on **enabled, visible** options: it selects
everything currently matching the search (skipping disabled rows), or
clears them if all are already selected, and it shows an indeterminate
state for a partial selection. In server mode the row acts on the
currently loaded page: options that have not arrived from the server yet
are not part of the toggle set, and
`glassMultiSelectServer(..., disabled_choices)` marks values disabled as
they arrive in search responses. “Clear all” clears the whole selection.
Note there is no `clearable` argument on
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
— clearing is `show_clear_all`, which is `TRUE` by default. (`clearable`
belongs to the single-select and does not exist here; passing it would
be an unused-argument error.)

## Disabled options — and what survives a choices update

Disable the whole widget, or individual options:

``` r

glassMultiSelect("filters_d", fruits, disabled = TRUE)
glassMultiSelect("filters_dc", fruits, disabled_choices = "banana")
```

Disabled rows cannot be selected, and “Select all” skips them. A
disabled choice is also excluded from the default all-selected state:
with `disabled_choices = "banana"` and no explicit `selected`, banana
starts unselected while everything else starts selected.

One update subtlety is worth knowing: when choices are replaced without
passing `disabled_choices`, the widget **keeps** the previous disabled
rows. To change the disabled set, pass it explicitly in the same update
(see “Updating from the server” below).

## Grouped choices

Grouped choices use the
[`selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html)-style
named list:

``` r

glassMultiSelect("food", list(
  Fruit = c(Apple = "apple", Banana = "banana"),
  Veg   = c(Carrot = "carrot", Pea = "pea")
))
```

As with
[`selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html), a
one-element named list such as `list(Group = "x")` is treated as a flat,
ungrouped choice.

## Tag pills with `glassFilterTags()`

Place a
[`glassFilterTags()`](https://prigasg.github.io/glasstabs/reference/glassFilterTags.md)
container anywhere on the page to show the active selections as
removable tag pills. The JavaScript engine keeps them in sync
automatically — clicking the x on a tag deselects that option:

``` r

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("cat", fruits, show_style_switcher = FALSE),
  glassFilterTags("cat")    # can be placed anywhere, even in a different tab pane
)
```

You can place several `glassFilterTags("cat")` containers for the same
filter — all stay in sync. This is the pattern that makes the
multi-select feel like a filter system rather than a single input: the
dropdown lives in a sidebar, the pills live next to the results, and
both reflect the same `input$cat`.

## Reading values on the server

Read the selection directly from `input$<inputId>` and the style from
`input$<inputId>_style`:

``` r

server <- function(input, output, session) {
  observe({
    message("Selected: ", paste(input$pick, collapse = ", "))
    message("Style: ", input$pick_style)
  })
}
```

### The `glassMultiSelectValue()` helper

For filtering code,
[`glassMultiSelectValue()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectValue.md)
wraps the raw input with one genuinely useful idea: an empty selection
is ambiguous. Does empty mean “match nothing” or “match everything”? The
raw input stays honest (`character(0)`), and `resolved()` answers the
question separately:

``` r

server <- function(input, output, session) {
  ms <- glassMultiSelectValue(input, "pick")

  observe({
    message("Selected: ", paste(ms$selected(), collapse = ", "))
    message("Style: ", ms$style())
  })
}
```

``` r

rows <- data.frame(
  fruit = c("apple", "banana", "cherry"),
  n = c(12, 7, 9)
)

server <- function(input, output, session) {
  ms <- glassMultiSelectValue(
    input,
    "pick",
    choices = fruits,
    empty_behavior = "all"
  )

  filtered <- reactive({
    rows[rows$fruit %in% ms$resolved(), , drop = FALSE]
  })
}
```

`empty_behavior` has three modes: `"none"` (the default — `resolved()`
is `character(0)`), `"all"` (empty resolves to every choice value, so an
untouched filter matches everything), and `"null"` (empty resolves to
`NULL`, for downstream code that expects it). `empty_behavior = "all"`
requires `choices` — pass the same choices used by
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md),
or a reactive returning them. `is_empty()` is also available for UI
messages or validation.

## Understanding selection behavior: All, Some, and None

The multi-select default surprises developers who expect an empty
starting state: `selected = NULL` selects **every enabled choice**
initially. Disabled choices are never in that default, and they are
never part of the Select-all set either — the Select-all row and its
indicator act on enabled, visible choices only (see the server-mode note
below for how that scope works with bounded results). Three states,
three meanings:

| State | Widget value | What the app usually does with it |
|----|----|----|
| All choices selected | Character vector of all selected values | Show all matching records |
| Some choices selected | Character vector of those values | Show matching records only |
| Nothing selected | `character(0)` | Show no records — or, if the app chooses, no filter |

The last row is where bugs hide. An app that treats empty as “no filter”
is valid when chosen deliberately — but if the example is copied without
that choice, pressing Clear all makes every record reappear even though
the dropdown visibly holds no selection. Decide which meaning empty has,
and write it down in the filter:

Approach A: empty means no records. Note that
[`req()`](https://rdrr.io/pkg/shiny/man/req.html) on an empty selection
also stops the calculation, so the explicit version below is the one to
copy:

``` r

rows <- data.frame(
  fruit = c("apple", "banana", "cherry"),
  n = c(12, 7, 9)
)

filter_none <- function(selected) {
  if (is.null(selected) || length(selected) == 0L) {
    return(rows[0, , drop = FALSE])
  }
  rows[rows$fruit %in% selected, , drop = FALSE]
}

stopifnot(nrow(filter_none(character(0))) == 0L)
stopifnot(nrow(filter_none("apple")) == 1L)
```

Approach B: empty means all records:

``` r

filter_all <- function(selected) {
  if (is.null(selected) || length(selected) == 0L) {
    return(rows)
  }
  rows[rows$fruit %in% selected, , drop = FALSE]
}

stopifnot(nrow(filter_all(character(0))) == 3L)
stopifnot(nrow(filter_all("banana")) == 1L)
```

The same decision applies at three moments: on initial load (default
`selected = NULL` starts at All, while `selected = character(0)` starts
at None), after Clear all (the widget returns `character(0)`), and after
a reset (whatever the reset writes back — see the linked-filters article
for the three reset meanings). The
`glassMultiSelectValue(..., empty_behavior = "all")` helper changes how
the *app* resolves an empty selection; it does not change what the
widget returns, which is always `character(0)` when empty.

## Server-side search for large choice sets

For hundreds or thousands of choices, keep the full vector on the server
and send a small bounded set of matches to the browser. Set
`server = TRUE` in the UI and register
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
in the server function:

``` r

many_choices <- stats::setNames(
  sprintf("value-%04d", 1:2000),
  sprintf("Choice %04d", 1:2000)
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect(
    "pick",
    many_choices,
    server = TRUE,
    server_limit = 30,
    show_style_switcher = FALSE
  ),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  glassMultiSelectServer("pick", many_choices, session = session, limit = 30)
  output$out <- renderPrint(length(input$pick))
}

if (interactive()) shinyApp(ui, server)
```

Two independent limits bound what the browser renders. They are set in
different places and nothing ties them together — setting one does not
change the other:

| Setting | Where it lives | What it bounds |
|----|----|----|
| `server_limit` (default `50`) | [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md) / [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md) | Choices rendered initially, excluding explicitly included selections |
| `limit` (default `50`) | [`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md) / [`glassSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassSelectServer.md) | Matches returned for each search |

So `server_limit = 25` with `limit = 100` shows 25 choices on open and
up to 100 per search. `server_min_chars` (default `0`) sets how many
characters must be typed before server-side matching filters choices,
and `ignore_case = TRUE` (the default in
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md))
matches labels and values case-insensitively. Two details that make this
safe: explicitly selected values that fall outside the initial slice are
still rendered as extra rows, so they stay visible and checked; and the
control keeps the selected values on the client while only the current
bounded set of matches is rendered.

Results are bounded, not paginated: the helper returns the first N
matches for each search. There is no next-page cursor and no built-in
Load more mechanism, so “page” is the wrong word for what comes back.

In server mode the Select-all row acts on the currently loaded page:
with 20,000 facilities and 30 matches on screen, Select all selects
those 30, not all 20,000. The full selection stays represented in Shiny
— selected values persist on the client across searches — but only the
current matches are rendered. The same scope rule applies to the
indicator: it reports the enabled, visible set, not the whole dataset.

### Performance and limitations

Server mode reduces what is rendered in the browser, not what R holds:
the complete choices vector is still supplied to the constructor and to
the server helper, so this is not database-backed lazy search. And
because the default multi-select selection contains all enabled choice
values, a large selection still creates a large input payload even with
bounded DOM rendering — pass `selected = character(0)` when the app does
not need everything selected up front.

One unsupported configuration: `server = TRUE` with search disabled
(`searchable = FALSE` or `"never"`). Without a search input the user
cannot query beyond the initial slice, so choices outside it are
unreachable through the dropdown. Keep search enabled in server mode.

This pattern also suits controls inserted by
[`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html): register
[`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
once for the same `inputId`, and the newly rendered control receives
search results through Shiny.

## Updating from the server

[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md)
updates choices, selection, style, shape, disabled state, search
visibility and threshold, summary mode, and dropdown height — in one
transaction:

``` r

ui <- fluidPage(
  useGlassTabs(),
  actionButton("subset", "Keep first 3 fruits"),
  actionButton("pick2", "Select 2 fruits"),
  actionButton("clear", "Clear"),
  actionButton("fill", "Switch to filled style"),
  glassMultiSelect("pick", fruits),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(input$pick)

  observeEvent(input$subset, {
    updateGlassMultiSelect(session, "pick", choices = fruits[1:3])
  })

  observeEvent(input$pick2, {
    updateGlassMultiSelect(
      session, "pick",
      selected = c("apple", "cherry")
    )
  })

  observeEvent(input$clear, {
    updateGlassMultiSelect(session, "pick", selected = character(0))
  })

  observeEvent(input$fill, {
    updateGlassMultiSelect(session, "pick", check_style = "filled")
  })
}

if (interactive()) shinyApp(ui, server)
```

The `NULL` semantics follow Shiny conventions and are worth memorizing:

- `choices = NULL` leaves choices unchanged; `selected = NULL` leaves
  the selection unchanged.
- `selected = character(0)` clears the selection.
- When choices are updated without `selected`, the widget keeps the
  intersection of the current selection and the new choice set.

Three arguments control the transaction itself:

``` r

server <- function(input, output, session) {
  observeEvent(input$region, {
    updateGlassMultiSelect(
      session,
      "pick",
      choices = fruits[fruits %in% c("apple", "banana", "cherry")],
      preserve_selection = TRUE,
      drop_invalid = TRUE,
      searchable = "auto",
      notify = "changed"
    )
  })
}
```

- `preserve_selection = TRUE` (the default) keeps the current selection
  when choices change; `FALSE` starts the new choice set empty unless
  `selected` is supplied explicitly.
- `drop_invalid = TRUE` (the default) drops selected values absent from
  the new choices; `FALSE` keeps them around for when they reappear,
  which is what a bounded server search wants.
- `notify = "changed"` (the default) avoids rerunning observers when the
  effective selection and style did not change; `"always"` forces an
  event; `"never"` makes a quiet update for one input only — it does not
  sync other inputs, so every input whose server value must sync needs
  its own notification (see the linked-filters recipe).

## Closing dropdowns and dynamic layouts

For dynamic layouts, modals, sidebars, or tab changes, close an open
dropdown explicitly from the server:

``` r

server <- function(input, output, session) {
  observeEvent(input$change_layout, {
    closeGlassMultiSelect(session, "pick")
  })
}
```

Use `closeAllGlassSelects(session)` when a layout change should close
any open glasstabs select dropdown. Dropdowns also dismiss themselves
when a full-screen overlay appears — a modal, a spinner, or a
hand-rolled overlay — so an open panel never floats above a dialog.

## Theming

### Built-in presets

``` r

glassMultiSelect("f", fruits, theme = "dark")   # default
glassMultiSelect("f", fruits, theme = "light")  # white panel, dark text
glassMultiSelect("f", fruits, theme = "auto")   # follows Bootstrap/bslib color mode
```

`theme = "auto"` follows the Bootstrap/bslib color mode: it uses the
light preset by default and switches to the dark preset when an ancestor
carries `data-bs-theme = "dark"`. For apps that announce dark mode some
other way — a `body.dark-mode` class in bs4Dash, for example — pass that
selector as `dark_selector`, and the widget emits an extra scoped style
block that reverts colors to the dark defaults whenever the selector is
active:

``` r

glassMultiSelect("f", fruits,
  theme = "auto",
  dark_selector = "body.dark-mode"
)
```

### Custom themes with `glass_select_theme()`

Supply only the colors you want to change; everything else inherits from
the `mode` base preset:

``` r

# One field — accent colour only
glassMultiSelect("f", fruits,
  theme = glass_select_theme(accent_color = "#f59e0b")
)

# Two fields
glassMultiSelect("f", fruits,
  theme = glass_select_theme(
    text_color   = "#1e293b",
    accent_color = "#2563eb"
  )
)

# Four commonly customized fields
glassMultiSelect("f", fruits,
  theme = glass_select_theme(
    bg_color     = "#1a0a2e",
    border_color = "#a855f7",
    text_color   = "#ede9fe",
    accent_color = "#a855f7"
  )
)
```

| Argument       | What it controls                                      |
|----------------|-------------------------------------------------------|
| `bg_color`     | Dropdown panel and trigger button background          |
| `border_color` | Border colour                                         |
| `text_color`   | Main text and label colour                            |
| `accent_color` | Tick marks, badge, checked highlights, Clear all link |
| `focus_ring`   | Keyboard focus indicator                              |
| `label_color`  | Field-title colour                                    |
| `mode`         | Theme mode metadata (`"dark"` or `"light"`)           |

### Presentation: tongue, labels, corners, width

``` r

glassMultiSelect("f", fruits,
  tongue = TRUE,              # attached unfurl (default); FALSE = detached short fade
  label_bold = TRUE,          # semibold field label, matching native inputs
  label_size = "14px",        # keeps the title distinct from the options
  search_focus_ring = FALSE,  # quiet search focus (default); TRUE = accent outline
  shape = "square"            # crisp corners beside native selectize inputs
)
```

`tongue = TRUE` (the default) attaches the dropdown flush to the trigger
and unfurls it with the signature animation; `FALSE` detaches the panel
with a short fade, which sits more naturally beside native Shiny inputs.
Either way the panel matches the trigger width, long labels wrap, and
reduced-motion preferences collapse the transitions.

## Placement: standalone, in tabs, in dashboards

The multi-select is fully independent of the tab widget — only
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
(for the CSS and JavaScript) is required. It works inside a
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
layout, in a plain
[`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html), in a
`bslib` page with `theme = "auto"`, and in a `bs4Dash` dashboard with
`dark_selector` for the dashboard’s dark-mode class. Each instance is
scoped to its own `inputId` and works independently; when one dropdown
is open it floats above the others:

``` r

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("a", c(X = "x", Y = "y", Z = "z")),
  glassMultiSelect("b", c(P = "p", Q = "q", R = "r"),
                   check_style = "filled",
                   show_style_switcher = FALSE)
)
```

## Keyboard and pointer interaction

- **Trigger:** Enter or Space opens and closes the dropdown. Arrow Down
  / Arrow Up / Home / End open it and move to an option. Escape closes
  it and returns focus to the trigger; Tab closes it and continues
  normal keyboard navigation.
- **Open dropdown:** Arrow Down / Arrow Up / Home / End move between
  options; Enter or Space toggles the active option; Escape returns
  focus to the trigger, while Tab closes the panel and moves onward.
- **Chrome rows:** Arrow Down past the last option moves focus to the
  style switcher, then the “Select all” row, then “Clear all” (Arrow Up
  reverses); Enter or Space activates the focused button. Tab and Escape
  behave as above from any focused row. The rows are buttons, not Tab
  stops, so Tab never gets trapped inside the dropdown.
- **Search:** typing filters options (debounced); the “Select all” row
  follows the filtered, enabled set.
- **Pointer and keyboard:** a truncated active option reveals a capped
  text preview unless `overflow_tooltip = "never"`; clicking a tag
  pill’s x deselects that option.
- **Motion:** transitions collapse when the device asks for reduced
  motion, and the widget carries full accessible labels for assistive
  technology.

## A worked dashboard: linked filters

This is the pattern most apps end up with — two filters, one driving the
other, tags beside the results, and a reset that clears both:

``` r

library(shiny)
library(glasstabs)

sales <- data.frame(
  region  = c("North", "North", "South", "South", "East", "West"),
  product = c("Alpha", "Beta", "Alpha", "Gamma", "Beta", "Alpha"),
  revenue = c(42000, 31000, 27000, 55000, 38000, 61000)
)

products_by_region <- list(
  North = c(Alpha = "Alpha", Beta = "Beta"),
  South = c(Alpha = "Alpha", Gamma = "Gamma"),
  East  = c(Beta = "Beta"),
  West  = c(Alpha = "Alpha")
)

ui <- fluidPage(
  useGlassTabs(),
  glassMultiSelect("region",
    c(North = "North", South = "South", East = "East", West = "West"),
    show_style_switcher = FALSE
  ),
  glassMultiSelect("product",
    c(Alpha = "Alpha", Beta = "Beta", Gamma = "Gamma"),
    show_style_switcher = FALSE,
    check_style = "check-only"
  ),
  glassFilterTags("region"),
  glassFilterTags("product"),
  actionButton("reset", "Reset filters"),
  tableOutput("tbl")
)

server <- function(input, output, session) {
  fallback <- function(x, default) {
    if (is.null(x) || length(x) == 0) default else x
  }

  # Region drives the product list; keep what still applies.
  observeEvent(input$region, {
    available <- unique(unlist(
      products_by_region[fallback(input$region, names(products_by_region))],
      use.names = FALSE
    ))
    updateGlassMultiSelect(
      session, "product",
      choices = stats::setNames(available, available),
      preserve_selection = TRUE,
      drop_invalid = TRUE,
      notify = "changed"
    )
  }, ignoreNULL = FALSE)

  observeEvent(input$reset, {
    updateGlassMultiSelect(session, "region", selected = character(0))
    updateGlassMultiSelect(session, "product", selected = character(0))
  })

  filtered <- reactive({
    sales[
      sales$region %in% fallback(input$region, unique(sales$region)) &
      sales$product %in% fallback(input$product, unique(sales$product)),
    ]
  })

  output$tbl <- renderTable(filtered())
}

if (interactive()) shinyApp(ui, server)
```

Note the two update choices that make linked filters behave: the product
update keeps the current selection where it still applies
(`preserve_selection = TRUE`) and drops values the new region no longer
offers (`drop_invalid = TRUE`), and `notify = "changed"` means the table
only recomputes when the effective selection actually moved.

## Compared with `selectizeInput(multiple = TRUE)`

If you are migrating a native multi-select, this is what changes:

- **You gain:** glass theming with dark / light / auto presets and
  custom themes; trigger summaries (`count`, `summary`, `labels`) that
  keep a filter bar compact; tag pills placeable anywhere on the page; a
  runtime style switcher; filled rows with per-option hues; server-side
  search that still renders out-of-slice selections; option tooltips for
  long labels; and transactional updates with `preserve_selection`,
  `drop_invalid`, and `notify` modes.
- **The server contract stays familiar:** it is still a Shiny input
  returning a character vector. Native selectize-only extensions such as
  creating new choices are outside its scope. The main migration
  adjustments are defaults: an untouched glasstabs filter means
  “everything” (pass `selected = character(0)` for an empty start), the
  default width is a compact `160px` (pass `width = "100%"` for a
  full-width filter), and clearing is `show_clear_all`, not a
  `clearable` argument.

## Gotchas, collected

- `selected = NULL` means **all** choices selected. For an empty start,
  pass `selected = character(0)` explicitly.
- There is **no `clearable` argument** on
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  — that belongs to the single-select. Clearing is `show_clear_all`.
- `search_threshold` only matters when `searchable = "auto"`.
- `server = TRUE` without a registered
  [`glassMultiSelectServer()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelectServer.md)
  for the same `inputId` leaves search with nothing to answer it.
- A choices-only update **keeps** the previous disabled rows; pass
  `disabled_choices` explicitly in the same update to change them.
- An empty filter is `character(0)` at `input$<inputId>`. If “empty
  means everything” in your app, resolve it with
  `glassMultiSelectValue(..., empty_behavior = "all")` instead of
  special-casing `length(input$pick) == 0` everywhere.
- `hues` only applies when `check_style = "filled"` **and**
  `fill_colors = "multi"`; with the default `"single"`, every filled row
  uses the theme accent.
