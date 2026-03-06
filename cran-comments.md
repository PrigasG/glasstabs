## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- macOS (local): R 4.4.x
- GitHub Actions: ubuntu-latest, windows-latest, macOS-latest × R release + devel
- win-builder: R release + devel

## New submission

This is a new package — no previous CRAN versions exist.

## Notes for reviewers

* The package provides two Shiny HTML widgets (`glassTabsUI`, `glassMultiSelect`).
  No external API calls, no internet access at runtime.
* All JavaScript is original, hand-written, and bundled in `inst/www/`.
* Examples that launch a Shiny app are wrapped in `if (interactive())`.
* The `Suggests` field lists `spelling` (used only via `devtools::spell_check()`)
  and `testthat` (test suite, 67 tests, 0 failures).
* `inst/WORDLIST` contains package-specific technical terms for `spelling::spell_check_package()`.
