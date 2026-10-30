# Responsive and Accessible Tabs

Tabs often begin with three short labels and grow with the app. This
article keeps that larger version comfortable on a phone, with a
keyboard, and under system accessibility settings.

## A complete responsive app

``` r

library(shiny)
library(glasstabs)

ui <- fluidPage(
  useGlassTabs(),
  glassTabsUI(
    "reports",
    glassTabPanel("summary", "Summary", selected = TRUE,
      h3("Summary"), p("A quick view of the current reporting period.")
    ),
    glassTabPanel("activity", "Recent activity",
      h3("Recent activity"), tableOutput("activity_table")
    ),
    glassTabPanel("quality", "Data quality",
      h3("Data quality"), plotOutput("quality_plot")
    ),
    glassTabPanel("settings", "Team settings",
      h3("Team settings"), textInput("team_name", "Team name")
    ),
    overflow = "scroll",
    theme = "auto"
  )
)

server <- function(input, output, session) {
  output$activity_table <- renderTable(head(mtcars))
  output$quality_plot <- renderPlot(plot(mtcars$wt, mtcars$mpg))
}

shinyApp(ui, server)
```

On a narrow screen, the labels remain in a touch-scrollable row.
Keyboard focus follows the selected tab, and a server update brings its
destination back into view.

## Long select labels on narrow screens

Select dropdowns match their trigger width and remain capped by the
containing layout. Start with the compact default and opt into a wider
field only where the content needs it:

``` r

glassSelect(
  "industry",
  long_industry_choices,
  width = "280px",
  overflow_tooltip = "auto"
)
```

For
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md),
an automatic overflow tooltip appears only when selected trigger text is
ellipsized. Inside either open dropdown, a truncated option reveals a
capped preview when hovered or reached with keyboard navigation. The
multi-select avoids a single combined tooltip for several selections. A
tap keeps its normal job—opening the dropdown—where option text wraps
inside the viewport.

## Choosing the overflow style

`"scroll"` is a natural fit for most tab bars. `"multiline"` is useful
when every label should be visible at once. In a horizontal layout,
`"menu"` keeps the header compact and uses a native select control.
Vertical tabs already have a dedicated rail, so compact menu mode is not
available there.

``` r

glassTabsUI(
  "wrapped",
  glassTabPanel("one", "First report", selected = TRUE, p("First")),
  glassTabPanel("two", "Second report", p("Second")),
  glassTabPanel("three", "Third report", p("Third")),
  overflow = "multiline"
)

glassTabsUI(
  "menu",
  glassTabPanel("one", "First report", selected = TRUE, p("First")),
  glassTabPanel("two", "Second report", p("Second")),
  overflow = "menu"
)
```

## Select keyboard and screen-reader behavior

Tabs have their own keyboard story; selects have a different one, and it
is worth stating plainly because the two widgets differ.

**Keyboard.** Tab reaches the trigger. Enter or Space opens the
dropdown; arrows then move through options and chrome rows — the
Select-all row, the Clear row, the style switcher — as one wrapping
cycle that skips hidden and disabled rows. Home and End jump to the
first and last rows. Enter or Space activates the focused row (selecting
and closing for a single-select, toggling for a multi-select). Escape
closes and returns focus to the trigger. Tab while open closes the
dropdown and exits: it never steps through options one by one. The
single-select clear button answers keys only while its dropdown is open.
Focus is always visible: chrome controls carry visible focus rings, and
`search_focus_ring = TRUE` strengthens the search field’s ring when the
quiet default is not enough.

**Screen reader.** The trigger is a `combobox` labeled by its field
label, with `aria-expanded` tracking the open state and
`aria-haspopup="listbox"`. The dropdown is a `listbox` (multi-selects
add `aria-multiselectable="true"`); options are `option` rows with
`aria-selected`, and the active row is exposed through
`aria-activedescendant` so announcements follow arrow-key movement
without moving DOM focus. The Select-all row is a `checkbox` with
tri-state `aria-checked` (`true`, `false`, or `mixed` for a partial
selection); style switcher buttons carry `aria-pressed`; search inputs
carry an `aria-label`. The status row (`role="status"`,
`aria-live="polite"`) announces “Searching…” and no-match states.
Disabled rows carry `aria-disabled="true"`, are skipped by keyboard
navigation, and ignore clicks.

**What this does not claim.** The matrix below separates what automated
tests cover from what nobody has verified yet. In particular, no
screen-reader pass (NVDA or VoiceOver) has been run: until one is, the
screen-reader rows stay “not yet verified” no matter how complete the
ARIA markup looks.

| Environment | Status | Notes |
|----|----|----|
| Chrome on Linux, macOS, Windows | Tested | Automated browser tests on CI: keyboard, pointer, positioning |
| Edge on Windows | Not yet verified | Chromium-based, but no CI run |
| Firefox | Not yet verified | Styling and keyboard behavior unconfirmed |
| Safari on macOS | Not yet verified | Focus and dropdown interaction unconfirmed |
| Android browsers | Not yet verified | Touch, scrolling, and viewport changes unconfirmed |
| iOS Safari | Not yet verified | Virtual keyboard and touch interactions unconfirmed |
| NVDA | Not yet verified | Manual screen-reader pass outstanding |
| VoiceOver | Not yet verified | Manual screen-reader pass outstanding |
| Reduced motion | Partially tested | Stylesheet rule plus automated tests for the dropdown close path; full manual pass pending |
| High contrast / forced colors | Partially tested | Stylesheet uses system colors and visible focus outlines; manual verification pending |

Supported dependency versions are exactly what `DESCRIPTION` states;
anything beyond that table is theoretically compatible, not tested.

## Touch swipes without surprises

`swipe = TRUE` adds left and right gestures to ordinary panel content.
Inputs, links, buttons, Shiny outputs, HTML widgets, and horizontal
scrollers keep their own touch behavior.

``` r

glassTabsUI(
  "story",
  glassTabPanel("opening", "Opening", selected = TRUE, p("The first part.")),
  glassTabPanel("middle", "Middle", p("The middle part.")),
  glassTabPanel("ending", "Ending", p("The final part.")),
  swipe = TRUE
)
```

Add `data-gt-no-swipe` to any custom region that should always keep its
own gesture:

``` r

tags$div(`data-gt-no-swipe` = "", custom_touch_component)
```

## Motion and contrast

No R setting is needed for reduced motion. The browser preference
removes the transfer trace and badge pulse, shortens CSS transitions,
and shows the next panel without an animation delay.

Windows forced-colors mode uses system colors and visible focus
outlines. When backdrop blur is unsupported, the controls use solid
surfaces instead of losing contrast. Custom themes can set `focus_ring`
in
[`glass_tab_theme()`](https://prigasg.github.io/glasstabs/reference/glass_tab_theme.md)
and
[`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md);
the colour follows select dropdowns when they move to the document body,
so search focus remains visible.

The dropdown search field uses a quiet border/background focus treatment
by default. Set `search_focus_ring = TRUE` when the stronger accent ring
is useful. All tongue and detached-panel transitions honor
reduced-motion preferences.

## Experimental fillable page

[`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
keeps a small full-page app pleasantly short:

``` r

ui <- glassPage(
  title = "Operations",
  glassTabsUI(
    "main",
    glassTabPanel("overview", "Overview", selected = TRUE, overview_ui),
    glassTabPanel("alerts", "Alerts", alerts_ui),
    overflow = "scroll",
    theme = "auto"
  )
)
```

It is an experimental wrapper around
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html).
Plain [`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html),
[`page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html),
and dashboard layouts remain first-class homes for every glasstabs
widget.
