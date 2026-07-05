# Publishing a glasstabs Workflow to Posit Connect

## Overview

`runGlassExample("connect-workflow")` opens a Shiny page designed to be
published to Posit Connect. It demonstrates a practical review workflow:

- filters define the active queue with
  [`glassSelect()`](https://prigasg.github.io/glasstabs/reference/glassSelect.md)
  and
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
- `glassTabsUI(orientation = "vertical", indicator = "solid")` guides
  users through intake, exploration, and approval
- [`updateGlassTabBadge()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabBadge.md)
  keeps tab badges aligned with the filtered data
- [`updateGlassTabsUI()`](https://prigasg.github.io/glasstabs/reference/updateGlassTabsUI.md)
  moves reviewers to the next stage from server actions
- `theme = "auto"` follows Bootstrap 5 / bslib light and dark modes

## Run locally

``` r

library(glasstabs)

if (interactive()) {
  runGlassExample("connect-workflow")
}
```

## Deploy to Posit Connect

The example is a self-contained Shiny app folder. In a package checkout,
deploy it directly:

``` r

rsconnect::deployApp(
  appDir = "inst/examples/connect-workflow",
  appName = "glasstabs-connect-workflow",
  appTitle = "glasstabs Connect Workflow"
)
```

If you are deploying from an installed package, copy the example folder
first:

``` r

example_dir <- system.file("examples", "connect-workflow", package = "glasstabs")
file.copy(example_dir, "connect-workflow", recursive = TRUE)

rsconnect::deployApp(
  appDir = "connect-workflow",
  appName = "glasstabs-connect-workflow",
  appTitle = "glasstabs Connect Workflow"
)
```

## Workflow pattern

The page uses a common Connect pattern: make the first screen the actual
work surface, keep controls near the content they affect, and expose
state through badges and compact metrics. That makes the app useful as a
scheduled report, review queue, or operational handoff page without
adding a separate landing screen.
