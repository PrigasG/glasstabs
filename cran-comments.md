## Submission

This is glasstabs 0.4.1. The previous CRAN version is 0.4.0.

## Changes in this version (0.4.1)

This is a focused patch release correcting select dropdown panel sizing.

- `glassSelect()` and `glassMultiSelect()` dropdown panels now follow the
  rendered trigger width instead of imposing a wider fixed minimum.
- Long labels and unbroken identifiers wrap within the available panel width.
- Added real-browser regression coverage for both widget types at narrow field
  widths, long labels, resizing, and viewport-edge placement.

See NEWS.md for the full list.

## R CMD check results

0 errors | 0 warnings | 1 note

The note reports that only three days have passed since the 0.4.0 update.
Version 0.4.1 is intentionally small and corrects a visible dropdown sizing
issue found after release; it contains no broader API or feature changes.

In addition to the package test suite, the release candidate was checked with
JavaScript and R linters and with real-browser interaction tests covering both
select widget types and the existing interaction suite.

