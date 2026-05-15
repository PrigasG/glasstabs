# Download Tracker

This is a maintainer-facing Shiny app for checking daily CRAN downloads
for `glasstabs`.

## Run locally

```r
shiny::runApp("tools/download-tracker")
```

## Data source

The app reads the public daily download feed from
`https://cranlogs.r-pkg.org`.

## Scheduled updates

The GitHub Actions workflow
`.github/workflows/download-stats.yaml` refreshes cached download data
weekly on Mondays and stores it in `tools/download-tracker/data/`.

The whole `tools/` directory is excluded from CRAN source builds by
`.Rbuildignore`.
