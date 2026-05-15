package_name <- "glasstabs"
output_dir <- file.path("tools", "download-tracker", "data")

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

fetch_downloads <- function(package = package_name, from = Sys.Date() - 365, to = Sys.Date()) {
  query <- sprintf(
    "https://cranlogs.r-pkg.org/downloads/daily/%s:%s/%s",
    format(as.Date(from), "%Y-%m-%d"),
    format(as.Date(to), "%Y-%m-%d"),
    utils::URLencode(package, reserved = TRUE)
  )

  empty_stats <- function() {
    data.frame(
      date = as.Date(character()),
      package = character(),
      count = numeric(),
      stringsAsFactors = FALSE
    )
  }

  tryCatch(
    {
      response <- jsonlite::fromJSON(query, simplifyVector = FALSE)
      stats <- response[[1]]
      downloads <- stats$downloads

      if (!length(downloads)) {
        return(empty_stats())
      }

      data.frame(
        date = as.Date(vapply(downloads, function(x) x$day, character(1))),
        package = stats$package %||% package,
        count = vapply(downloads, function(x) as.numeric(x$downloads), numeric(1)),
        stringsAsFactors = FALSE
      )
    },
    error = function(err) {
      warning(
        sprintf(
          "Could not fetch CRAN download data for %s from %s: %s",
          package,
          query,
          conditionMessage(err)
        ),
        call. = FALSE
      )

      empty_stats()
    }
  )
}

summarise_downloads <- function(stats) {
  if (!nrow(stats)) {
    return(list(
      package = package_name,
      latest_date = NA,
      latest_downloads = 0,
      total_downloads = 0,
      downloads_7 = 0,
      downloads_30 = 0,
      peak_date = NA,
      peak_downloads = 0,
      has_data = FALSE
    ))
  }

  latest_date <- max(stats$date, na.rm = TRUE)
  last_7_start <- latest_date - 6
  last_30_start <- latest_date - 29

  list(
    package = unique(stats$package)[1],
    latest_date = latest_date,
    latest_downloads = stats$count[stats$date == latest_date][1],
    total_downloads = sum(stats$count, na.rm = TRUE),
    downloads_7 = sum(stats$count[stats$date >= last_7_start], na.rm = TRUE),
    downloads_30 = sum(stats$count[stats$date >= last_30_start], na.rm = TRUE),
    peak_date = stats$date[which.max(stats$count)],
    peak_downloads = max(stats$count, na.rm = TRUE),
    has_data = TRUE
  )
}

write_summary_md <- function(summary, path) {
  if (!isTRUE(summary$has_data)) {
    lines <- c(
      sprintf("# %s CRAN Downloads", summary$package),
      "",
      sprintf("Updated: %s", format(Sys.time(), tz = "UTC", usetz = TRUE)),
      "",
      "CRAN download data is not available yet.",
      "",
      "This can happen before the package is available in CRAN logs, or while the CRAN logs service is temporarily unavailable."
    )
    writeLines(lines, path, useBytes = TRUE)
    return(invisible(path))
  }

  lines <- c(
    sprintf("# %s CRAN Downloads", summary$package),
    "",
    sprintf("Updated: %s", format(Sys.time(), tz = "UTC", usetz = TRUE)),
    "",
    sprintf("- Latest day: %s (%s downloads)", summary$latest_date, summary$latest_downloads),
    sprintf("- Last 7 days: %s downloads", summary$downloads_7),
    sprintf("- Last 30 days: %s downloads", summary$downloads_30),
    sprintf("- Total in tracked period: %s downloads", summary$total_downloads),
    sprintf("- Peak day: %s (%s downloads)", summary$peak_date, summary$peak_downloads)
  )
  writeLines(lines, path, useBytes = TRUE)
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

downloads <- fetch_downloads()
summary <- summarise_downloads(downloads)

utils::write.csv(
  downloads,
  file = file.path(output_dir, "downloads-daily.csv"),
  row.names = FALSE
)

write_summary_md(summary, file.path(output_dir, "download-summary.md"))

if (isTRUE(summary$has_data)) {
  cat("Updated download tracker data for", summary$package, "\n")
} else {
  cat("No CRAN download data available yet for", summary$package, "\n")
}
