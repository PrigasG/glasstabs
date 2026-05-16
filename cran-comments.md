## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local Windows 11: R 4.5.1

Command used locally:
- `R CMD check --no-manual glasstabs_0.3.2.tar.gz`
- local CRAN incoming check: `checking CRAN incoming feasibility ... OK`

CRAN pretest note:

- One CRAN pretest reported `checking for detritus in the temp directory ...
  NOTE` with a `calibre-*` directory. This appears to be temporary-directory
  residue from the CRAN pretest machine, not from this package. The package
  source contains no `calibre` files or references, and the source tarball
  excludes development, GitHub workflow, and release-only files.

## Changes in this version (0.3.2)

This release focuses on public-dashboard readiness for `glassTabsUI()`,
`glassSelect()`, and `glassMultiSelect()`.

Browser compatibility:

- Removed all `color-mix()` usage from the shipped stylesheet. Select widget
  alpha colors are now precomputed as CSS custom properties at render time.
- Bumped the html dependency version so browsers request fresh CSS/JS assets.

Accessibility and keyboard behavior:

- Added ARIA combobox/listbox/option semantics to `glassSelect()` and
  `glassMultiSelect()`.
- JavaScript now keeps `aria-expanded` and `aria-selected` in sync.
- Escape and Tab close open select dropdowns and return focus to the trigger.
- Single-select option clicks return focus to the trigger.

Dashboard and layout fixes:

- Fixed tab initialization for `glassTabsUI()` inserted by `renderUI()` or
  dashboard layouts after the initial page boot.
- Added a Shiny input binding and delegated activation fallback for tabs so
  click and keyboard activation remain reliable in public dashboards.
- Added Windows High Contrast (`forced-colors`) CSS support.
- Added RTL layout support.
- Improved narrow-screen select trigger behavior to avoid overflow in dashboard
  cards.

Security:

- Added CSP nonce support for inline style tags via the `glasstabs.csp_nonce`
  option.

Internal/release preparation:

- Added public-readiness tests covering browser compatibility, ARIA output,
  focus management hooks, CSP nonce support, and release-facing CSS/JS checks.
- Moved non-shipping stress-test apps out of `inst/examples/`; they are excluded
  from the CRAN source package.
