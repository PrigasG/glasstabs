## Submission

This is glasstabs 0.4.0. The previous CRAN version is 0.3.4.

## Changes in this version (0.4.0)

This release improves responsive navigation, keyboard and screen-reader use,
motion preferences, and focus visibility.

- Added scrolling, multiline, and compact-menu overflow modes for horizontal
  tabs, plus optional guarded swipe gestures.
- Added roving keyboard focus, Home/End navigation, explicit tab/panel ARIA
  relationships, inert inactive panes, and discoverable disabled tabs.
- Added reduced-motion, forced-color, and unsupported-blur fallbacks.
- Separated tab-group placement from label alignment with `tab_align` and
  `text_align`.
- Added themeable focus rings for tabs and select widgets, including search
  fields in dropdowns moved to the document body.
- Added the experimental `glassPage()` helper, a thin optional wrapper around
  `bslib::page_fillable()`.
- Hardened halo alignment, rapid tab changes, compact-menu theming, widget
  scoping, and tab values used in browser selectors.
- Added real-browser regression tests for focus behavior, responsive layouts,
  rapid interactions, dropdown teleporting, and theme changes.

See NEWS.md for the full list.

## R CMD check results

0 errors | 0 warnings | 1 note

The note reports that the current time could not be verified. This is an
environmental clock/network check and is unrelated to the package contents.

In addition to the package test suite, the release candidate was checked with
JavaScript and R linters and with real-browser interaction tests covering tab
navigation, dynamic rendering, select dropdown lifecycle, and accessibility
state.

