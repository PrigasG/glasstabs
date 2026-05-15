test_that("glass.css has no color-mix dependency", {
  css_path <- file.path("inst", "www", "glass.css")
  if (!file.exists(css_path)) {
    css_path <- system.file("www", "glass.css", package = "glasstabs")
  }

  css <- paste(readLines(css_path, warn = FALSE), collapse = "\n")
  expect_false(grepl("color-mix\\(", css))
  expect_true(grepl("@media (forced-colors: active)", css, fixed = TRUE))
  expect_true(grepl('[dir="rtl"]', css, fixed = TRUE))
})

test_that("select widgets render ARIA combobox/listbox semantics", {
  gs <- as.character(glassSelect("pick", c(Apple = "apple"), selected = "apple"))
  expect_true(grepl('role="combobox"', gs, fixed = TRUE))
  expect_true(grepl('aria-haspopup="listbox"', gs, fixed = TRUE))
  expect_true(grepl('aria-expanded="false"', gs, fixed = TRUE))
  expect_true(grepl('role="listbox"', gs, fixed = TRUE))
  expect_true(grepl('role="option"', gs, fixed = TRUE))
  expect_true(grepl('aria-selected="true"', gs, fixed = TRUE))

  ms <- as.character(glassMultiSelect("filter", c(Apple = "apple"), selected = "apple"))
  expect_true(grepl('role="combobox"', ms, fixed = TRUE))
  expect_true(grepl('aria-controls="filter-dropdown"', ms, fixed = TRUE))
  expect_true(grepl('role="listbox"', ms, fixed = TRUE))
  expect_true(grepl('role="option"', ms, fixed = TRUE))
  expect_true(grepl('aria-selected="true"', ms, fixed = TRUE))
})

test_that("scoped select CSS contains precomputed alpha variables", {
  html <- as.character(glassSelect("pick", c(Apple = "apple")))

  expect_true(grepl("--ms-ac-12:", html, fixed = TRUE))
  expect_true(grepl("--ms-ac-75:", html, fixed = TRUE))
  expect_true(grepl("--ms-tx-03:", html, fixed = TRUE))
  expect_true(grepl("--ms-tx-80:", html, fixed = TRUE))
  expect_true(grepl("--ms-ac-tx-75:", html, fixed = TRUE))
})

test_that("inline style tags honor glasstabs.csp_nonce option", {
  old <- getOption("glasstabs.csp_nonce")
  on.exit(options(glasstabs.csp_nonce = old), add = TRUE)

  options(glasstabs.csp_nonce = "nonce-123")
  html <- as.character(glassSelect("pick", c(Apple = "apple")))

  expect_true(grepl('nonce="nonce-123"', html, fixed = TRUE))
})

test_that("glass.js keeps ARIA and focus state in sync", {
  js_path <- file.path("inst", "www", "glass.js")
  if (!file.exists(js_path)) {
    js_path <- system.file("www", "glass.js", package = "glasstabs")
  }

  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")
  expect_true(grepl("aria-expanded", js, fixed = TRUE))
  expect_true(grepl("aria-selected", js, fixed = TRUE))
  expect_true(grepl("--ms-ac-12", js, fixed = TRUE))
  expect_true(grepl("--ms-tx-80", js, fixed = TRUE))
  expect_true(grepl("glassTabsBinding", js, fixed = TRUE))
  expect_true(grepl("MutationObserver", js, fixed = TRUE))
  expect_true(grepl("closeAndReturnFocus", js, fixed = TRUE))
  expect_true(grepl("e.key === 'Escape' || e.key === 'Tab'", js, fixed = TRUE))
  expect_true(grepl("trigger.focus()", js, fixed = TRUE))
})
