# CLAUDE.md — glasstabs development notes

## Package overview

`glasstabs` is an R Shiny package providing animated glass-morphism UI
widgets: - **Tab navigation** — sliding halo effect,
[`glassTabsUI()`](https://prigasg.github.io/glasstabs/reference/glassTabsUI.md)
/
[`glassTabPanel()`](https://prigasg.github.io/glasstabs/reference/glassTabPanel.md)
/
[`glassTabsServer()`](https://prigasg.github.io/glasstabs/reference/glassTabsServer.md) -
**Multi-select dropdown** —
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
with checkbox/check-only/filled styles - **Single-select dropdown** —
[`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
with optional search and clear

## Architecture

| Layer      | Files                                                                                                                                        |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| R API      | `R/glass_tabs.R`, `R/glass_multiselect.R`, `R/glassSelect.R`, `R/glass_tab_theme.R`, `R/glass_select_theme.R`, `R/dependencies.R`, `R/zzz.R` |
| JavaScript | `inst/www/glass.js` — vanilla JS, no jQuery dependency                                                                                       |
| CSS        | `inst/www/glass.css` — glassmorphism styles, CSS variable theming                                                                            |
| Tests      | `tests/testthat/`                                                                                                                            |

## JavaScript patterns

- **Tab engine** lives in `initTabs(navbar)`. It supports
  re-initialization: calling it on an already-initialized navbar cleans
  up old event listeners first (stored as `navbar._gtClickHandler`,
  `navbar._gtKeyHandler`, `navbar._gtResizeHandler`).
- Tab switching is exposed as `navbar._gtActivate(value, skipFromAnim)`
  — used by all server-side tab control handlers.
- Click handling uses **event delegation** on the navbar element (not
  per-link listeners), so dynamically appended tabs are handled
  automatically.
- Select widgets use Shiny input bindings (`registerBindings()`),
  registered once via a `_done` flag.
- All custom message handlers are registered inside
  `if (typeof Shiny !== 'undefined')` at boot.

## Tab server-side API (as of v0.2.0)

| R function                                 | JS message type         | What it does                                 |
|--------------------------------------------|-------------------------|----------------------------------------------|
| `updateGlassTabsUI(session, id, selected)` | `glasstabs_update_tabs` | Switch active tab                            |
| `showGlassTab(session, id, value)`         | `glasstabs_show_tab`    | Unhide a tab                                 |
| `hideGlassTab(session, id, value)`         | `glasstabs_hide_tab`    | Hide a tab; auto-switches if it was active   |
| `appendGlassTab(session, id, tab, select)` | `glasstabs_append_tab`  | Add a tab at runtime; triggers re-init       |
| `removeGlassTab(session, id, value)`       | `glasstabs_remove_tab`  | Remove a tab; auto-switches if it was active |

All functions use `session$ns(id)` to resolve the full namespaced id,
which matches the `data-ns` attribute on `.gt-navbar`.

## CRAN compliance

- No `T`/`F` — use `TRUE`/`FALSE`
- No [`library()`](https://rdrr.io/r/base/library.html) or
  [`require()`](https://rdrr.io/r/base/library.html) in package code
- All exported functions have roxygen docs with `@param`, `@return`,
  `@export`, `@examples`
- Examples wrapped in `if (interactive())`
- `_style` input from `glassMultiSelect` is a secondary input, not a
  primary binding — documented as such

## Running tests

``` r
devtools::load_all()
devtools::test()
# or a single file:
testthat::test_file("tests/testthat/test-tabs.R")
```

R path on this machine: `C:/Program Files/R/R-4.5.1/bin/Rscript.exe`

## Change history

### v0.2.0 (initial release)

- `glassTabsUI`, `glassTabPanel`, `glassTabsServer`
- `glassMultiSelect`, `updateGlassMultiSelect`, `glassMultiSelectValue`
- `glassSelect`, `updateGlassSelect`, `glassSelectValue`
- `glassFilterTags`, `useGlassTabs`
- `glass_tab_theme`, `glass_select_theme`

### Post-v0.2.0 additions (current branch)

- `updateGlassTabsUI()` — programmatic tab switching (Shiny
  `updateTabsetPanel` equivalent)
- `showGlassTab()` / `hideGlassTab()` — conditional tab visibility
- `appendGlassTab()` / `removeGlassTab()` — dynamic tab addition/removal
  at runtime
- Refactored `initTabs` to support re-initialization and use event
  delegation for clicks
- Added `.gt-tab-link.gt-tab-hidden { display: none; }` CSS rule
