tracker_path <- test_path("..", "..", "tools", "download-tracker", "app.R")

test_that("download tracker falls back to a valid cache when cranlogs fails", {
  skip_if_not_installed("bs4Dash")
  tracker <- new.env(parent = globalenv())
  sys.source(tracker_path, envir = tracker)

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

test_that("download tracker reports failure when live and cached data are unavailable", {
  skip_if_not_installed("bs4Dash")
  tracker <- new.env(parent = globalenv())
  sys.source(tracker_path, envir = tracker)
  missing_cache <- tempfile(fileext = ".csv")

  expect_error(
    tracker$load_downloads(
      fetcher = function(...) stop("offline", call. = FALSE),
      cache_path = missing_cache
    ),
    "no matching cache"
  )
})
