# glasstabs roadmap

This is the working plan for upcoming releases. It records what is
promised, what is experimental, and what is still only an idea. A
feature moves to `NEWS.md` when it ships.

## v0.4.0 — responsive and accessible navigation

The 0.4.0 release is about making tabs feel dependable on small screens
and for people who use a keyboard, screen reader, reduced-motion
setting, or high contrast mode.

| Area | Scope | Status |
|----|----|----|
| Tab semantics | Roving focus, `aria-controls`, `aria-labelledby`, Home/End keys, and correct focus after dynamic updates | Implemented |
| Mobile overflow | `overflow = "scroll"` or `"multiline"`; horizontal layouts also support `"menu"`; selected tabs remain visible | Implemented |
| Tab alignment | Separate tab-group placement with `tab_align` from label and icon placement with `text_align` | Implemented |
| Reduced motion | CSS and JavaScript follow `prefers-reduced-motion` without delaying content changes | Implemented |
| Glass fallback | Solid surfaces when backdrop blur is unavailable; retain the existing forced-colors mode | Implemented |
| Swipe | Optional horizontal pane gestures that avoid interactive and scrollable content | Implemented |
| Badge feedback | A small update pulse that respects reduced motion and never moves focus | Implemented |
| Select keyboard use | Arrow-key, Home/End, Enter/Space, Escape, and active-option behavior | Implemented |
| Documentation | Friendly examples in the README, reference site, and vignettes | Implemented |

### API direction

``` r

glassTabsUI(
  "reports",
  ...,
  overflow = c("scroll", "multiline", "menu"),
  swipe = FALSE,
  text_align = c("center", "left", "right")
)
```

`wrap` keeps its existing meaning: it controls whether glasstabs
supplies the outer content container. `overflow` controls the tab strip
itself.

`overflow = "scroll"` is the default and keeps one row of tabs.
`"multiline"` is useful when every tab should remain visible. In
horizontal layouts, `"menu"` uses a compact native select and stays in
step with dynamic tab updates.

`tab_align` places the tab group within the available navigation area in
both orientations. `text_align` independently places text and icons
inside each tab button.

## Experimental: `glassPage()`

[`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
is a small optional wrapper around `bslib`. It loads the glasstabs
dependency, creates a fillable page, and leaves normal `bslib` page
features available. It is experimental during the 0.4.x cycle so its API
can settle before becoming a stable part of the package.

The wrapper will not replace `fluidPage()`,
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html),
or dashboard layouts. Existing widgets remain usable in all of them.

## Deferred ideas

These remain worthwhile, but they are outside the focused 0.4.0 release:

- lazy pane rendering;
- tab groups;
- additional pane transition styles;
- local-storage persistence;
- a hidden-navigation mode;
- content-area header and footer slots;
- global Ctrl+1–9 shortcuts;
- tab-level loading states;
- a custom compact-menu component if native `<option>` styling becomes
  too limiting for user-defined themes;
- modular JavaScript and CSS source files plus stylelint as the browser
  layer grows; the distributed assets remain single files for now;
- optional edge cues for desktop scroll overflow after testing them
  across left-to-right and right-to-left layouts.

## Shipped foundations

| Version | Highlights |
|----|----|
| 0.4.0 | Responsive overflow, optional swipe gestures, accessible tab semantics, reduced-motion and contrast fallbacks, independent tab and text alignment, themeable focus rings, and experimental [`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md) |
| 0.3.4 | Indicator styles, vertical tabs, automatic bslib theming, square controls, server-side select search, dynamic tab management, close helpers, improved diagnostics, and broader accessibility fallbacks |
| 0.3.1 | [`glassTabCondition()`](https://prigasg.github.io/glasstabs/reference/glassTabCondition.md), [`glasstabs_news()`](https://prigasg.github.io/glasstabs/reference/glasstabs_news.md), clearer errors, and container/theme fixes |
| 0.3.0 | Icons, badges, disable/enable, URL bookmarking, reactive rendering, and compact layouts |
| 0.2.1 | First CRAN release with tabs and single- and multi-select widgets |

## Implementation record

- 2026-07-31: agreed on a responsive and accessibility-focused 0.4.0
  scope.
- 2026-07-31: moved the full-page concept out of the stable milestone
  and renamed the experimental thin wrapper to
  [`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md).
- 2026-07-31: kept existing CRAN submission artifacts intact while
  developing the milestone on the repository’s main branch.
- 2026-07-31: implemented the stable responsive and accessibility scope,
  including all three overflow modes, guarded swipe gestures, motion and
  blur fallbacks, tab and select keyboard behavior, and accessible
  dynamic tabs.
- 2026-07-31: added the experimental
  [`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md)
  wrapper with classed, user-facing errors and optional `bslib`
  integration.
- 2026-07-31: added unit and real-browser coverage, refreshed the README
  and pkgdown reference, and added a responsive-accessibility vignette.
- 2026-07-31: verified the pkgdown article at desktop and phone widths;
  the narrow layout has no page-level overflow or browser errors.
- 2026-07-31: built the development source package and ran
  `R CMD check --as-cran` with no errors or warnings before release
  preparation.
- 2026-08-01: separated tab-group and tab-content alignment, documented
  the horizontal-only compact menu, and made browser CI respect reduced
  motion.
- 2026-08-01: made inactive panels inert, centralized halo realignment
  during scrolling and resizing, and kept disabled tabs discoverable by
  keyboard without allowing activation.
- 2026-08-01: renamed the developmental multiline overflow mode to avoid
  confusing it with the existing `wrap` container argument, exposed the
  page language in
  [`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md),
  hardened tab-value selectors and widget scoping, and added JavaScript
  linting plus browser regression coverage.
- 2026-08-01: made rapid tab changes transactional, suppressed abandoned
  intermediate server values, and added consistent themeable focus rings
  for tabs, select triggers, and teleported select search fields.
- 2026-08-01: prepared the local 0.4.0 release candidate, rebuilt the
  pkgdown site, passed all 748 package tests and both linters, and
  completed `R CMD check --as-cran` with no errors or warnings. The sole
  incoming NOTE records that the previous CRAN update was one day
  earlier.
- 2026-08-01: rebuilt the PDF and HTML cheatsheets for the complete
  0.4.0 API, with all exported functions and the responsive and
  accessibility behavior in one release reference.
- 2026-09-09: hardened teleported select dropdowns against immediate
  outside presses, event-blocking overlays, and programmatically opened
  Bootstrap modals or offcanvas panels; added browser regressions and
  Connect test-lab checks for the complete lifecycle.
- 2026-09-09: completed the pre-release cleanup by releasing browser
  resources when dynamic tab widgets are removed, hardening filter-tag
  selectors, and declaring the minimum `bslib` version used by
  [`glassPage()`](https://prigasg.github.io/glasstabs/reference/glassPage.md).
- 2026-09-14: aligned single- and multi-select dropdown panels with
  their rendered trigger width and added real-browser coverage for
  narrow fields.
- 2026-09-16: completed the 0.4.1 multi-select refinement set with
  adaptive search, compact selection summaries, configurable list
  height, explicit empty-value resolution, and transactional server
  updates that avoid unnecessary reactive work.
