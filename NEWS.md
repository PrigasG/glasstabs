# glasstabs 0.3.4.9000

## Responsive and accessible navigation

* Development toward 0.4.0 now focuses on dependable tabs on small screens,
  complete keyboard and screen-reader behavior, reduced-motion support, and
  solid fallbacks when glass effects are unavailable.
* `glassTabsUI()` gains `overflow` and opt-in `swipe` controls. The selected
  tab stays visible in a scrolling strip, wrapped tabs remain available, and
  menu mode provides a compact native chooser.
* Tabs now use roving keyboard focus, Home/End navigation, and explicit ARIA
  relationships between each tab and its panel.
* `glassPage()` is an experimental, lightweight wrapper around
  `bslib::page_fillable()` that loads the glasstabs dependency automatically.
* The Posit Connect workflow example is now a v0.4.0 test lab for responsive
  overflow, swipes, keyboard behavior, dynamic tabs, badges, theming, and the
  experimental page wrapper. Its in-app checklist keeps repeat testing clear.
* Tab clicks and keyboard activation no longer pass through a second fallback
  initialization, so the glass halo keeps its full movement in vertical and
  horizontal layouts. The arrival pulse also preserves the halo's settled
  alignment with the active tab in both orientations.
* Compact-menu options now use an explicit native dark or light colour scheme,
  keeping option text readable when the operating system opens the select menu.

# glasstabs 0.3.4

## Internal consistency and diagnostics

* Refactored internal rendering, theme CSS, hue generation, serialization, and
  validation without changing exported signatures, rendered HTML contracts,
  or Shiny message formats.
* Package-generated errors now inherit from `glasstabs_error`, with the leaf
  classes `glasstabs_error_bad_argument`, `glasstabs_error_bad_choice`,
  `glasstabs_error_bad_theme`, and `glasstabs_error_no_session`. This makes
  errors easier to catch programmatically while retaining instructive messages.
* Side-effect update helpers now consistently return `NULL` invisibly, as
  documented.
* `glassTabCondition()` now emits valid single-backslash JavaScript escapes for
  carriage returns, newlines, tabs, and Unicode line separators in tab values.
* Added golden HTML and message-payload regression tests, lint configuration,
  and a coverage workflow.

## Vertical orientation

* New `orientation` argument for `glassTabsUI()`: `"vertical"` stacks the
  tab buttons in a left-hand rail beside the content pane. ArrowUp/ArrowDown
  navigate in vertical mode, `aria-orientation` is set on the tablist, and
  `indicator = "underline"` renders as a slim side bar adjacent to the
  content. Falls back to stacked layout under 760px.
* New `tab_align` argument for `glassTabsUI()`: `"center"` (default),
  `"left"`, or `"right"` aligns tab button text and icons.

## bslib / Bootstrap 5 auto theming

* New `theme = "auto"` preset bridges to Bootstrap 5 color modes: light
  variables apply by default and dark variables apply under
  `data-bs-theme="dark"`, toggled live in the browser (works with
  `bslib::input_dark_mode()` / `toggle_dark_mode()` with no server code).
* `glassSelect()` and `glassMultiSelect()` also support `theme = "auto"` so
  their triggers and dropdown panels keep the glass look in both light and
  dark Bootstrap 5 color modes.

## New example and article

* `runGlassExample("indicators")` demos the three indicator styles,
  vertical orientation, and auto theming side by side.
* New "Indicator Styles, Vertical Tabs, and Auto Theming" article.
* `runGlassExample("connect-workflow")` provides a Posit Connect-ready
  workflow review page showing filters, badges, server-driven tab changes,
  horizontal/vertical tabs, tab text alignment, and auto theming in one
  deployable Shiny app.
* The Connect workflow example now has stronger dark-mode contrast, auto-themed
  glass select dropdowns, neutral quick-action buttons with selected state,
  indicator and tab shape controls, and a
  responsive controls grid for narrower browsers. Closed `glassSelect()` and
  `glassMultiSelect()` fields remain readable when the page is in dark mode.
* New "Publishing a glasstabs Workflow to Posit Connect" article.

## Select dropdown positioning

* Teleported `glassSelect()` and `glassMultiSelect()` dropdowns now clamp to
  the viewport, so narrow browser widths no longer cut off the left or right
  edge of the dropdown panel.

## Tab indicator

* New `indicator` argument for `glassTabsUI()`: `"glass"` (default),
  `"solid"` (flat opaque sliding pill, no `backdrop-filter` or shimmer -
  lighter on the GPU and better suited to plain dashboards), and
  `"underline"` (slim sliding bar under the active tab).

## Halo alignment fixes

* The halo now fits the active tab exactly from its rendered edges, avoiding
  the right-side spill that could appear after initial load or tab changes.
* Initial halo placement now starts at the full tab size instead of briefly
  rendering a smaller centered outline before the first tab change.
* Default and compact tab buttons are larger and easier to hit.
* Halo position now accounts for container borders
  (`clientLeft`/`clientTop`), fixing a horizontal shift inside bordered
  fallback containers such as bs4Dash `.card-body`.
* A `ResizeObserver` re-aligns the halo whenever tab geometry changes
  without a window resize: badge count updates, label changes via
  `renderUI`, font swaps, or sidebar collapse.

## Dropdown lifecycle

* Added `closeGlassSelect()`, `closeGlassMultiSelect()`, and
  `closeAllGlassSelects()` so apps can explicitly close dropdowns before tab
  switches, modal changes, or dynamic UI replacement.
* `glassSelect()` and `glassMultiSelect()` now expose open state as
  `input$<inputId>_open`.
* Open dropdowns now close on additional lifecycle events, including outside
  pointer-down, window resize, Bootstrap tab/modal/collapse hiding,
  sidebar/offcanvas transitions, Shiny value replacement, and Shiny disconnect.

# glasstabs 0.3.3

Released to CRAN.

## Native-layout parity

* `glassSelect()` and `glassMultiSelect()` gained a `width` argument
  (passed to `shiny::validateCssUnit()`) so the widgets can fill a column or
  match a fixed layout, like native `selectizeInput()`.
* Both selects now accept grouped choices as a named list, selectInput()-style
  (e.g. `list(Fruit = c(Apple = "apple"), Veg = c(...))`), rendering
  non-interactive group headers. Search hides headers whose options are all
  filtered out.
* Added disabled support: `disabled = TRUE` greys out and blocks the whole
  widget, and `disabled_choices` renders individual options as non-selectable.
  Both are also reachable at runtime via `updateGlassSelect()` /
  `updateGlassMultiSelect()` (`disabled`, `disabled_choices`). Disabled options
  are skipped by "Select all".
* `glassTabsUI()` gained a `shape` argument (`"rounded"` default or
  `"square"`) so the tab bar and content corners can match
  `shape = "square"` selects for a cohesive, selectize-style layout.

## Square corners

* Added a `shape` argument to `glassSelect()` and `glassMultiSelect()`. The
  default `shape = "rounded"` keeps the signature glass look, while
  `shape = "square"` applies crisp, selectize-style corners so the widgets sit
  flush next to native `selectizeInput()` controls without looking out of
  place.
* `updateGlassSelect()` and `updateGlassMultiSelect()` gained a `shape`
  argument so the corner style can be switched at runtime from the server
  without re-rendering the widget (open dropdowns and selection state are
  preserved).
* Added a `runGlassExample("square-corners")` example app that demonstrates the
  square shape live alongside native `selectizeInput()`, including a
  runtime rounded-vs-square toggle via `update*()` and a light-theme variant.
* Added a `runGlassExample("bslib")` example app that shows square
  `glassSelect()` and `glassMultiSelect()` controls inside a Bootstrap 5
  `bslib` layout.

## Large choice sets

* Added opt-in server-side search support for large `glassSelect()` and
  `glassMultiSelect()` choice sets via `server = TRUE`, `glassSelectServer()`,
  and `glassMultiSelectServer()`.
* Added loading and no-results states for select search results, including
  server-backed search responses.
* Added a runnable `runGlassExample("server-select")` example and vignette
  sections for server-backed single- and multi-select controls.

## Bug fixes

* Fixed `updateGlassMultiSelect()` updates being lost when a multi-select is
  created or replaced by `renderUI()` in the same reactive flush. Dynamic
  updates now target the replacement widget and retry briefly while it binds.
* Fixed scalar `selected` values being interpreted as an empty selection by the
  multi-select JavaScript binding.

# glasstabs 0.3.2

## Public dashboard readiness

* Removed all `color-mix()` usage from the shipped stylesheet. Select widget
  alpha colors are now precomputed as CSS custom properties at render time for
  better compatibility with older embedded browsers.
* Added ARIA combobox/listbox/option semantics to `glassSelect()` and
  `glassMultiSelect()`, with JavaScript keeping `aria-expanded` and
  `aria-selected` in sync during interaction.
* Improved keyboard behavior for select widgets: Escape and Tab close open
  dropdowns and return focus to the trigger; single-select option clicks also
  return focus.
* Added CSP nonce support for inline style tags via the
  `glasstabs.csp_nonce` option.
* Added Windows High Contrast (`forced-colors`) CSS support and RTL layout
  support for tabs and select widgets.
* Improved narrow-screen select trigger behavior so labels truncate cleanly
  inside dashboard cards instead of overflowing.

## Bug fixes

* Fixed tab initialization for `glassTabsUI()` inserted by `renderUI()` or
  dashboard layouts after the initial page boot.
* Added a Shiny input binding and delegated activation fallback for tabs so
  click and keyboard activation remain reliable in public dashboards.
* Bumped the html dependency version so browsers request fresh CSS/JS assets.

# glasstabs 0.3.1

## New features

* Added `glassTabCondition(id, value)` — generates the correct JavaScript
  condition string for [shiny::conditionalPanel()] without needing to remember
  the `input[["id-active_tab"]]` key pattern.
* Added `glasstabs_news()` — prints the package changelog to the R console.
* Added `ROADMAP.md` tracking planned features and known limitations (not
  shipped in the package).

## Improvements

* Error messages across all functions are now actionable: they name the bad
  argument class, show what was received, and suggest the correct fix.
* `glass_tab_theme()` and `glass_select_theme()` now have full `@examples`
  with interactive app snippets.
* `.gt-container` no longer forces `max-width:960px` or `margin:48px auto` —
  the widget now behaves like a normal block element inside Shiny layouts.
* Light-mode halo box-shadow replaced with a soft blue-tinted shadow via the
  `--gt-halo-shadow` CSS variable, replacing the harsh dark drop shadow.

---

# glasstabs 0.3.0

## New features

### Tab widget

* Added `runGlassExample()` to launch any of the built-in example apps
  directly from the R console (`runGlassExample("smoke-test")`, etc.).
* Added `icon` argument to `glassTabPanel()` — accepts any htmltools-compatible
  tag (e.g. `shiny::icon("table")`). Renders with `gt-tab-icon` / `gt-tab-label`
  spans so icon and text can be styled independently.
* Added `disableGlassTab()` and `enableGlassTab()` — gray out a tab without
  hiding it. Completes the visibility/disabled/removal trio alongside
  `showGlassTab()` / `hideGlassTab()`.
* Added `updateGlassTabBadge()` — set a numeric count badge on any tab button.
  Pass `count = 0` or `count = NA` to hide the badge. Values above 99 display
  as `"99+"`.
* `glassTabsServer()` now integrates with Shiny's URL bookmarking: the active
  tab is automatically saved and restored when `enableBookmarking = "url"` is
  set on the app. Opt out per widget with `bookmark = FALSE`.
* Added `glassTabsOutput()` / `renderGlassTabs()` for server-driven tab
  rendering. The JavaScript engine re-initialises automatically after each
  render via a scoped `shiny:value` listener, so no manual `glasstabs_reinit`
  calls are needed.

## Improvements

* `glassTabsUI()` now errors early on duplicate `glassTabPanel()` values,
  reporting the offending value(s) by name.
* `glassTabsUI()` gains a `compact = FALSE` argument. Setting `compact = TRUE`
  applies the `.gt-compact` CSS modifier which reduces margins, tab-link padding,
  font size, and content area padding — ideal for embedding inside bs4Dash cards
  or any tight dashboard layout.
* `glassTabsServer()` emits a `warning()` when the `id` argument contains `"-"`,
  which is the most common sign that `ns("tabs")` was passed instead of the bare
  `"tabs"` id. The warning includes corrective guidance.
* CSS: added `.gt-tab-disabled`, `.gt-tab-icon`, `.gt-tab-label`, and
  `.gt-tab-badge` rules. Badges adapt their background to the active halo colour
  via the existing CSS custom property.
* CSS: all color values are now consumed via `var(--gt-xxx, fallback)` instead
  of being hardcoded — this was the root cause of light theme appearing invisible.
  Light theme defaults were also strengthened for better contrast.
* CSS: dropdown active-state z-index raised to 9000/9001 so glasstabs dropdowns
  render above bs4Dash card stacking contexts.
* `shiny:value` listener limits bootAll re-initialisation to outputs that
  actually contain glasstabs elements, so ordinary Shiny outputs are unaffected.
* Added `inst/cheatsheet/glasstabs-cheatsheet.tex` — a printable four-column
  LaTeX reference card covering the full API, module pattern, bs4Dash integration,
  theming, and common gotchas.

## Documentation

* Cheatsheet vignette (`vignettes/cheatsheet.Rmd`) extended with new sections:
  "Tabs inside a Shiny module", "Dynamic tab values and selected",
  "Tabs inside bs4Dash", and updated common gotchas.
* All new functions have full roxygen docs, `@examples`, and cross-links.

---

# glasstabs 0.2.1

## New features

### Tab widget

* Added `updateGlassTabsUI()` for programmatic tab switching from the server.
* Added `showGlassTab()` and `hideGlassTab()` for dynamically showing and
  hiding tabs at runtime.
* Added `appendGlassTab()` and `removeGlassTab()` for adding and removing tabs
  at runtime.

## Improvements

* `glassTabsUI()` now validates `selected` against the available
  `glassTabPanel()` values and errors early on invalid tab ids.
* The tab widget now reports its initial active tab to Shiny immediately after
  session startup, so `glassTabsServer()` is populated on first render.
* Added ARIA roles and selected-state attributes to tab navigation markup.
* Improved tab re-initialization and transition handling for dynamic tab
  changes, including show/hide, append/remove, and rapid successive updates.
* Improved halo and transfer-trace positioning after runtime tab layout
  changes.

## Bug fixes

* Opening a dropdown now closes any other open glasstabs dropdown, fixing
  a visual stacking issue where multiple dropdowns appeared simultaneously.

* Improved widget lifecycle in dynamic UI (`renderUI()`, `conditionalPanel()`).
  Widgets initialize more reliably and clean up properly when removed.

* Widgets now emit their initial value to Shiny immediately after rendering,
  fixing timing issues with `conditionalPanel()` and dynamic UI.

## Internal improvements

* JavaScript engine refactored to use internal state instead of DOM scanning.
  No changes to the R API — all existing code works without modification.

* Added scroll containers for long option lists, debounced search, and
  `.gt-loading` / `.gt-disabled` CSS utility classes.

## Documentation

* Added a dedicated cheatsheet vignette for common widget patterns and
  server-side helpers.
* Added a smoke-test example app covering programmatic tab switching, dynamic
  tab visibility, runtime tab insertion/removal, and rapid interaction paths.
* Expanded README and pkgdown navigation to surface the new server-side tab
  controls and cheatsheet more clearly.

---

# glasstabs 0.1.1

## New features

### Single-select widget

* Added `glassSelect()`, an animated single-select dropdown for Shiny.
* Added `updateGlassSelect()` for server-side updates to choices and selection.
* Added `glassSelectValue()` as a convenience reactive helper for reading the selected value.

### Multi-select widget

* Added `updateGlassMultiSelect()` for server-side updates to choices, selection, and checkbox style.
* Added `glassMultiSelectValue()` as a convenience reactive helper for reading selected values and active style.
* Added optional `label` support to `glassMultiSelect()`.
* Added configurable `all_label` support to control the trigger text shown when all choices are selected.

## Improvements

* Aligned `glassSelect()` and `glassMultiSelect()` more closely with standard Shiny input behavior.
* Added client-side input bindings so select widgets now support `session$sendInputMessage()` update patterns.
* Preserved current `glassMultiSelect()` default behavior where `selected = NULL` initializes all choices as selected.
* Improved choice normalization so named choices retain display labels correctly.
* Improved hue normalization for the `"filled"` multi-select style.
* Updated vignettes and examples to show direct Shiny input usage and server-side update patterns.

## Documentation

* Added a new vignette for `glassSelect()`.
* Updated the getting started vignette to include `glassSelect()`.
* Updated the multi-select vignette to document `updateGlassMultiSelect()` and `glassMultiSelectValue()`.

## Internal changes

* Added tests for `glassSelect()`, `updateGlassSelect()`, and `glassSelectValue()`.
* Expanded tests for `glassMultiSelect()` server-side updates and helper utilities.

---

# glasstabs 0.1.0

Initial release.

## New features

### Tab widget

* `glassTabsUI()` — animated glassmorphism-style tab navigation with a sliding
  glass halo and transfer trace between tabs.
* `glassTabPanel()` — defines a single tab button and its content pane.
* `glassTabsServer()` — reactive helper that tracks the active tab value.
* `glass_tab_theme()` — custom color theme for `glassTabsUI()` with eight
  independent handles: `tab_text`, `tab_active_text`, `halo_bg`,
  `halo_border`, `content_bg`, `content_border`, `card_bg`, `card_text`.
* Built-in `"dark"` (default) and `"light"` presets for `glassTabsUI()`.
* Keyboard navigation using the Left and Right arrow keys.
* Full `bs4Dash` compatibility via `wrap = FALSE`.

### Multi-select filter widget

* `glassMultiSelect()` — dropdown filter with live search,
  select-all with indeterminate state, and three checkbox indicator styles:
  `"checkbox"`, `"check-only"`, and `"filled"`.
* `glassFilterTags()` — tag-pill display area that stays in sync with a
  `glassMultiSelect()` automatically via JavaScript; clicking × on a pill
  deselects that option.
* `glass_select_theme()` — custom color theme with four handles: `bg_color`,
  `border_color`, `text_color`, `accent_color`.
* Built-in `"dark"` and `"light"` presets for `glassMultiSelect()`.
* `show_style_switcher`, `show_select_all`, `show_clear_all` flags to hide
  UI chrome (all default `TRUE`).
* Per-option HSL hue angles for the `"filled"` style via the `hues` argument
  (auto-assigned if omitted).

### General

* `useGlassTabs()` — injects CSS and JavaScript via
  `htmltools::htmlDependency`, which is deduplicated automatically by Shiny.
* All theming uses pre-computed CSS variables (no `color-mix()`), ensuring
  compatibility with Shiny's embedded browser.
* Multiple instances of either widget on the same page work independently;
  each instance is scoped to its own `id`.
