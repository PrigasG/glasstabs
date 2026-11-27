## Release candidate

This is glasstabs 0.4.2. The previous CRAN release is 0.4.1.
No 0.4.2 submission date or CRAN acceptance is claimed here.

## Changes in this version

- Add optional browser persistence for tab order, server-approved tab close
  requests, and touch or pen reorder handles.
- Add glass-styled switches, radio groups, and checkbox groups that retain
  standard Shiny input bindings and update functions.
- Improve dropdown placement in tight visible viewports and repair tab state
  when the last available tab is hidden, disabled, or removed.
- Expand examples, reference material, vignettes, and the PDF cheatsheet.

See NEWS.md for the full release history.

## Checks

- Local Windows 11 x64, R 4.5.1, `R CMD check --as-cran` through
  `devtools::check(document = FALSE)`: 0 errors, 0 warnings, 0 notes
  (November 27, 2026).
- The source-package archive was inspected: no private Regression Lab,
  roadmap, deployment manifest, stress worksheet, benchmarks, or generated
  website files; all required runtime, documentation, examples, and test
  fixtures were present.
- The pkgdown site built and `pkgdown::check_pkgdown()` found no problems.
