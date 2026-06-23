# glasstabs Roadmap

Living document tracking completed features and planned work. Updated with each release.

## Legend

- ✅ Done — shipped
- 🔄 In progress
- 📋 Planned — committed to next cycle
- 💡 Under consideration

---

## Phase 1 — Usability & compatibility (v0.3.x)

| # | Feature | Status |
|---|---------|--------|
| 1 | `glassTabCondition()` — `conditionalPanel()` helper | ✅ v0.3.1 |
| 2 | Hidden navbar mode (`show_navbar = FALSE`) | 📋 |
| 3 | `header` / `footer` args for content area | 📋 |
| 4 | `localStorage` tab persistence (`persist = "local"`) | 📋 |
| 5 | `glasstabs_news()` — in-console changelog utility | ✅ v0.3.1 |
| 6 | Improved, actionable error messages across all functions | ✅ v0.3.1 |

---

## Phase 2 — Differentiation (v0.4.0)

| # | Feature | Status |
|---|---------|--------|
| 7  | Lazy tab rendering (render pane content on first visit only) | 💡 |
| 8  | Pane transition styles (`transition = "slide"` / `"fade"` / `"scale"`) | 💡 |
| 9  | Tab groups (`glassTabGroup("label", ...)`) | 💡 |
| 10 | Swipe gesture support (mobile left/right swipe) | 💡 |
| 11 | `glassNavPage()` — full-page glassmorphism nav shell | 💡 |

---

## Phase 3 — Power features (v0.5.0)

| # | Feature | Status |
|---|---------|--------|
| 12 | Keyboard shortcuts — `Ctrl+1–9` jump to tab N (`shortcuts = TRUE`) | 💡 |
| 13 | Tab-level loading states (`setGlassTabLoading()`) | 💡 |
| 14 | Vertical tab orientation (`orientation = "vertical"`) | 💡 |
| 15 | bslib CSS variable bridging (auto light/dark from Bootstrap theme) | 💡 |
| 16 | `updateGlassMultiSelect(choices = ...)` — dynamic choice list update | ✅ shipped |

---

## Selectize parity (dev)

| # | Feature | Status |
|---|---------|--------|
| 17 | `width` argument on `glassSelect()` / `glassMultiSelect()` | ✅ |
| 18 | Grouped choices via named list (`selectInput()`-style) | ✅ |
| 19 | Whole-widget + per-option `disabled` / `disabled_choices` | ✅ |
| 20 | `shape = "square"` for selects and `glassTabsUI()` | ✅ |
| 21 | Full in-dropdown keyboard navigation (arrow keys, type-ahead) | 📋 |

---

## Completed

| Version | Highlights |
|---------|-----------|
| dev     | `shape = "square"` for selects + tabs, `width`, grouped choices, `disabled` / `disabled_choices`, server-side select search |
| v0.3.1  | `glassTabCondition()`, `glasstabs_news()`, actionable error messages, examples for theme helpers, container spacing fix, light-mode halo shadow |
| v0.3.0  | Icons on tabs, numeric badges, disable/enable, URL bookmarking, `renderGlassTabs` / `glassTabsOutput`, `compact` mode, light theme CSS fix, z-index fix for bs4Dash |
| v0.2.1  | CRAN release — `glassTabsUI`, `glassMultiSelect`, `glassSelect`, full theming API |

---

## Known limitations vs. native Shiny

| Area | Gap | Planned fix |
|------|-----|-------------|
| `conditionalPanel()` | `input[["id-active_tab"]]` key is non-obvious | Phase 1: `glassTabCondition()` |
| Tab bar hiding | No `type="hidden"` equivalent | Phase 1: `show_navbar = FALSE` |
| Module id pattern | `ns("tabs")` in UI, bare in server — asymmetric | Document clearly; consider future auto-detect |
| Large choice sets | ~~Choices sent to browser upfront~~ | ✅ Resolved: opt-in server-side search (`server = TRUE`) |
| Keyboard nav | Select dropdowns lack arrow-key / type-ahead navigation | Planned: in-dropdown keyboard support (item 21) |
| Screen readers | Custom divs, not native `<select>`; ARIA roles present | Ongoing ARIA audit |
