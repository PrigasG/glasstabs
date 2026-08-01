# glasstabs roadmap

This is the working plan for upcoming releases. It records what is promised,
what is experimental, and what is still only an idea. A feature moves to
`NEWS.md` when it ships.

## v0.4.0 — responsive and accessible navigation

The 0.4.0 release is about making tabs feel dependable on small screens and
for people who use a keyboard, screen reader, reduced-motion setting, or high
contrast mode.

| Area | Scope | Status |
|---|---|---|
| Tab semantics | Roving focus, `aria-controls`, `aria-labelledby`, Home/End keys, and correct focus after dynamic updates | Implemented |
| Mobile overflow | `overflow = "scroll"`, `"wrap"`, or `"menu"`; selected tabs remain visible | Implemented |
| Reduced motion | CSS and JavaScript follow `prefers-reduced-motion` without delaying content changes | Implemented |
| Glass fallback | Solid surfaces when backdrop blur is unavailable; retain the existing forced-colors mode | Implemented |
| Swipe | Optional horizontal pane gestures that avoid interactive and scrollable content | Implemented |
| Badge feedback | A small update pulse that respects reduced motion and never moves focus | Implemented |
| Select keyboard use | Arrow-key, Home/End, Enter/Space, Escape, and active-option behavior | Implemented |
| Documentation | Friendly examples in the README, reference site, and vignettes | Implemented |

### API direction

```r
glassTabsUI(
  "reports",
  ...,
  overflow = c("scroll", "wrap", "menu"),
  swipe = FALSE
)
```

`wrap` keeps its existing meaning: it controls whether glasstabs supplies the
outer content container. `overflow` controls the tab strip itself.

`overflow = "scroll"` is the default and keeps one row of tabs. `"wrap"` is
useful when every tab should remain visible. `"menu"` uses a compact native
select and stays in step with dynamic tab updates.

## Experimental: `glassPage()`

`glassPage()` will be a small optional wrapper around `bslib`. It should load
the glasstabs dependency, create a fillable page, and leave normal `bslib`
page features available. It is experimental during the 0.4.x cycle so its API
can settle before becoming a stable part of the package.

The wrapper will not replace `fluidPage()`, `bslib::page_fillable()`, or
dashboard layouts. Existing widgets remain usable in all of them.

## Deferred ideas

These remain worthwhile, but they are outside the focused 0.4.0 release:

- lazy pane rendering;
- tab groups;
- additional pane transition styles;
- local-storage persistence;
- a hidden-navigation mode;
- content-area header and footer slots;
- global Ctrl+1–9 shortcuts;
- tab-level loading states.

## Shipped foundations

| Version | Highlights |
|---|---|
| 0.3.4 | Indicator styles, vertical tabs, automatic bslib theming, square controls, server-side select search, dynamic tab management, close helpers, improved diagnostics, and broader accessibility fallbacks |
| 0.3.1 | `glassTabCondition()`, `glasstabs_news()`, clearer errors, and container/theme fixes |
| 0.3.0 | Icons, badges, disable/enable, URL bookmarking, reactive rendering, and compact layouts |
| 0.2.1 | First CRAN release with tabs and single- and multi-select widgets |

## Implementation record

- 2026-07-31: agreed on a responsive and accessibility-focused 0.4.0 scope.
- 2026-07-31: moved the full-page concept out of the stable milestone and
  renamed the experimental thin wrapper to `glassPage()`.
- 2026-07-31: kept existing CRAN submission artifacts intact and opened the
  `codex/v0.4.0-responsive-accessibility` development branch.
- 2026-07-31: implemented the stable responsive and accessibility scope,
  including all three overflow modes, guarded swipe gestures, motion and blur
  fallbacks, tab and select keyboard behavior, and accessible dynamic tabs.
- 2026-07-31: added the experimental `glassPage()` wrapper with classed,
  user-facing errors and optional `bslib` integration.
- 2026-07-31: added unit and real-browser coverage, refreshed the README and
  pkgdown reference, and added a responsive-accessibility vignette.
- 2026-07-31: verified the pkgdown article at desktop and phone widths; the
  narrow layout has no page-level overflow or browser errors.
- 2026-07-31: built the source package and ran `R CMD check --as-cran` with
  no errors or warnings. The only note is expected while the package uses the
  development version `0.3.4.9000`; release builds will use `0.4.0`.
