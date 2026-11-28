## Release summary

This is glasstabs 0.4.2. The previous CRAN release is 0.4.1.

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

- Local Windows 11 x64, R 4.5.1, `R CMD check --as-cran --no-manual`
  on the final source archive: 0 errors, 0 warnings, 0 notes
  (November 27, 2026).
- The source-package archive was inspected: no private Regression Lab,
  roadmap, deployment manifest, stress worksheet, benchmarks, or generated
  website files, or website MP4/GIF media; all required runtime,
  documentation, examples, and test fixtures were present.
- The pkgdown site built with `install = FALSE`; `pkgdown::check_pkgdown()`
  found no problems.
- GitHub Actions passed on Windows, macOS, Ubuntu R release, Ubuntu R
  oldrel-1, and Ubuntu R devel; lint, test coverage, pkgdown build, and
  website deployment also passed.
