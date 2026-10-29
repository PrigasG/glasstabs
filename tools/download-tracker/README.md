# Download Tracker

This is a maintainer-facing Shiny app for checking daily CRAN downloads
for `glasstabs`.

## Run locally

```r
shiny::runApp("tools/download-tracker")
```

## Data source

The app retries the public daily download feed from
`https://cranlogs.r-pkg.org`. If the live request still fails, it falls back
to the most recent matching rows in `data/downloads-daily.csv` and labels the
dashboard as cached. It fails only when neither live nor cached data is
available for the requested period.

## Scheduled updates

The GitHub Actions workflow
`.github/workflows/download-stats.yaml` refreshes cached download data
weekly on Mondays and stores it in `tools/download-tracker/data/`. The updater
retries temporary API failures and fails without overwriting the existing
cache if fresh data cannot be retrieved.

The whole `tools/` directory is excluded from CRAN source builds by
`.Rbuildignore`.
