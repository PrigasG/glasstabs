tracker_path <- test_path("..", "..", "tools", "download-tracker", "app.R")

load_tracker <- function() {
  skip_if(
    !file.exists(tracker_path),
    "download tracker source is intentionally excluded from the package tarball"
  )
  skip_if_not_installed("bs4Dash")
  tracker <- new.env(parent = globalenv())
  sys.source(tracker_path, envir = tracker)
  tracker
}

test_that("download tracker returns successful live data without reading cache", {
  tracker <- load_tracker()
  live <- data.frame(
    date = as.Date(c("2026-10-20", "2026-10-21")),
    package = "glasstabs",
    count = c(4, 7)
  )

  result <- tracker$load_downloads(
    fetcher = function(...) live,
    cache_path = tempfile(fileext = ".csv")
  )

  expect_equal(attr(result, "data_source"), "live")
  expect_equal(result, live, ignore_attr = TRUE)
})

test_that("download tracker falls back to a valid cache when cranlogs fails", {
  tracker <- load_tracker()

  cache <- tempfile(fileext = ".csv")
  on.exit(unlink(cache), add = TRUE)
  utils::write.csv(
    data.frame(
      date = as.Date(c("2026-10-20", "2026-10-21")),
      package = "glasstabs",
      count = c(10, 12)
    ),
    cache,
    row.names = FALSE
  )
  failing_fetcher <- function(...) stop("temporary outage", call. = FALSE)

  result <- tracker$load_downloads(
    from = as.Date("2026-10-01"),
    to = as.Date("2026-10-28"),
    fetcher = failing_fetcher,
    cache_path = cache
  )

  expect_equal(attr(result, "data_source"), "cache")
  expect_match(attr(result, "live_error"), "temporary outage")
  expect_equal(result$count, c(10, 12))
})

test_that("download tracker cache fallback filters package and date", {
  tracker <- load_tracker()
  cache <- tempfile(fileext = ".csv")
  on.exit(unlink(cache), add = TRUE)
  utils::write.csv(
    data.frame(
      date = as.Date(c("2026-10-19", "2026-10-20", "2026-10-21", "2026-10-20")),
      package = c("glasstabs", "glasstabs", "glasstabs", "other"),
      count = c(1, 2, 3, 99)
    ),
    cache,
    row.names = FALSE
  )

  result <- tracker$load_downloads(
    package = "glasstabs",
    from = as.Date("2026-10-20"),
    to = as.Date("2026-10-20"),
    fetcher = function(...) stop("offline", call. = FALSE),
    cache_path = cache
  )

  expect_equal(result$date, as.Date("2026-10-20"))
  expect_equal(result$package, "glasstabs")
  expect_equal(result$count, 2)
})

test_that("download tracker validates malformed caches and summarises windows", {
  tracker <- load_tracker()
  cache <- tempfile(fileext = ".csv")
  on.exit(unlink(cache), add = TRUE)
  utils::write.csv(data.frame(date = "2026-10-20", count = 1), cache, row.names = FALSE)
  expect_error(tracker$read_cached_downloads(cache), "missing required columns")

  stats <- data.frame(
    date = as.Date("2026-10-01") + 0:30,
    package = "glasstabs",
    count = 1:31
  )
  summary <- tracker$summarise_downloads(stats)
  expect_equal(summary$latest_date, as.Date("2026-10-31"))
  expect_equal(summary$latest_downloads, 31)
  expect_equal(summary$total_downloads, sum(1:31))
  expect_equal(summary$downloads_7, sum(25:31))
  expect_equal(summary$downloads_30, sum(2:31))
})

test_that("download tracker reports failure when live and cached data are unavailable", {
  tracker <- load_tracker()
  missing_cache <- tempfile(fileext = ".csv")

  expect_error(
    tracker$load_downloads(
      fetcher = function(...) stop("offline", call. = FALSE),
      cache_path = missing_cache
    ),
    "no matching cache"
  )
})
