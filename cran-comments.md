## Submission

This is glasstabs 0.4.1. The previous CRAN version is 0.4.0.

## Changes in this version (0.4.1)

This is a focused minor update to the select widgets.

- `glassSelect()` and `glassMultiSelect()` dropdown panels now follow the
  rendered trigger width instead of imposing a wider fixed minimum.
- Long labels and unbroken identifiers wrap within the available panel width.
- `glassMultiSelect()` now supports automatic search visibility, compact
  selection summaries, and a configurable option-list height.
- Multi-select server updates are transactional and can notify Shiny only when
  the effective value changes, always, or never. Selection preservation and
  invalid-value handling are explicit.
- `glassMultiSelectValue()` can resolve an empty selection as none, all
  available choices, or `NULL`, while preserving the raw input value.
- Added real-browser regression coverage for both widget types at narrow field
  widths, long labels, resizing, viewport-edge placement, adaptive search,
  quiet updates, summaries, and list height.

See NEWS.md for the full list.

## R CMD check results

0 errors | 0 warnings | 1 note

The note reports that only five days have passed since the 0.4.0 update.
Version 0.4.1 corrects a visible dropdown sizing issue found after release and
groups closely related multi-select refinements requested by users testing the
same filter workflow.

In addition to the package test suite, the release candidate was checked with
JavaScript and R linters and with real-browser interaction tests covering both
select widget types and the existing interaction suite.

