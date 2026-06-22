test_that("runGlassExample() lists the server-select example", {
  expect_true("server-select" %in% runGlassExample())
})


test_that("all built-in examples have app files and README coverage", {
  examples <- runGlassExample()
  example_root <- system.file("examples", package = "glasstabs")
  app_files <- file.path(example_root, examples, "app.R")

  expect_true(all(file.exists(app_files)))
  expect_no_error(lapply(app_files, parse))
  expect_true(all(examples %in% c("basic", "bs4dash", "bslib", "dashboard", "server-select", "smoke-test", "square-corners")))

  readme_path <- test_path("..", "..", "README.md")
  if (file.exists(readme_path)) {
    readme <- paste(readLines(readme_path, warn = FALSE), collapse = "\n")
    expect_true(all(vapply(examples, grepl, logical(1), x = readme, fixed = TRUE)))
  }
})

test_that("bslib example app exists, parses, and demonstrates square selects", {
  app <- system.file("examples", "bslib", "app.R", package = "glasstabs")
  expect_true(nzchar(app) && file.exists(app))
  expect_no_error(parse(app))

  app_src <- paste(readLines(app, warn = FALSE), collapse = "\n")
  expect_match(app_src, "bslib::bs_theme", fixed = TRUE)
  expect_match(app_src, "bslib::navset_card_tab", fixed = TRUE)
  expect_gte(lengths(regmatches(app_src, gregexpr('shape = "square"', app_src, fixed = TRUE))), 2L)
})

test_that("pkgdown reference includes server select helpers", {
  pkgdown_path <- test_path("..", "..", "_pkgdown.yml")
  if (file.exists(pkgdown_path)) {
    pkgdown <- paste(readLines(pkgdown_path, warn = FALSE), collapse = "\n")
    expect_match(pkgdown, "glassSelectServer", fixed = TRUE)
    expect_match(pkgdown, "glassMultiSelectServer", fixed = TRUE)
  }
})

test_that("server-side select APIs are documented in top-level docs", {
  expect_true("glassSelectServer" %in% getNamespaceExports("glasstabs"))
  expect_true("glassMultiSelectServer" %in% getNamespaceExports("glasstabs"))
  expect_true(file.exists(system.file("examples", "server-select", "app.R", package = "glasstabs")))

  readme_path <- test_path("..", "..", "README.md")
  if (file.exists(readme_path)) {
    readme <- paste(readLines(readme_path, warn = FALSE), collapse = "\n")
    expect_match(readme, "glassSelectServer", fixed = TRUE)
    expect_match(readme, "glassMultiSelectServer", fixed = TRUE)
    expect_match(readme, 'runGlassExample("server-select")', fixed = TRUE)
  }
})

test_that("server select status UI hooks are shipped", {
  js <- paste(readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE), collapse = "\n")
  css <- paste(readLines(system.file("www", "glass.css", package = "glasstabs"), warn = FALSE), collapse = "\n")

  expect_true(grepl("gt-select-status", js, fixed = TRUE))
  expect_true(grepl("Searching...", js, fixed = TRUE))
  expect_true(grepl("No matches", js, fixed = TRUE))
  expect_true(grepl("gt-select-status", css, fixed = TRUE))
  expect_true(grepl("gt-select-spin", css, fixed = TRUE))
})

test_that("server selects keep a bounded renderUI-friendly contract", {
  many <- stats::setNames(sprintf("value-%03d", 1:100), sprintf("Choice %03d", 1:100))

  dynamic_single <- function() {
    glassSelect("remote_single", many, selected = "value-099", server = TRUE, server_limit = 10)
  }
  dynamic_multi <- function() {
    glassMultiSelect("remote_multi", many, server = TRUE, server_limit = 10)
  }

  single_html <- as.character(dynamic_single())
  multi_html <- as.character(dynamic_multi())

  expect_true(grepl('data-server="true"', single_html, fixed = TRUE))
  expect_true(grepl('data-server="true"', multi_html, fixed = TRUE))
  expect_true(grepl('data-server-total="100"', single_html, fixed = TRUE))
  expect_true(grepl('data-server-total="100"', multi_html, fixed = TRUE))

  single_rows <- lengths(regmatches(single_html, gregexpr("gt-gs-option", single_html, fixed = TRUE)))
  multi_rows <- lengths(regmatches(multi_html, gregexpr("gt-ms-option", multi_html, fixed = TRUE)))

  expect_equal(single_rows, 11L)
  expect_equal(multi_rows, 10L)
  expect_true(grepl('data-selected-values="[&quot;value-001&quot;', multi_html, fixed = TRUE))
  expect_true(grepl('&quot;value-100&quot;]"', multi_html, fixed = TRUE))
})
