local_browser_pkg_root <- function() {
  old <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = NA_character_)
  Sys.setenv(GLASSTABS_TEST_PKG_ROOT = normalizePath(test_path("..", "..")))
  withr::defer({
    if (is.na(old)) {
      Sys.unsetenv("GLASSTABS_TEST_PKG_ROOT")
    } else {
      Sys.setenv(GLASSTABS_TEST_PKG_ROOT = old)
    }
  }, testthat::teardown_env())
}

test_that("browser: glassSelect opens and clicking an option updates input", {
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassSelect-click",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  app$click(selector = "#fruit-dropdown .gt-gs-option[data-value='banana']")
  app$wait_for_idle()

  expect_equal(app$get_value(input = "fruit"), "banana")
})

test_that("browser: glassMultiSelect toggles choices and updates input", {
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassMultiSelect-toggle",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_equal(app$get_value(input = "cats"), "apple")

  app$click(selector = "#cats-trigger")
  app$wait_for_js("document.querySelector('#cats-dropdown.open') !== null")
  app$click(selector = "#cats-dropdown .gt-ms-option[data-value='cherry']")
  app$wait_for_idle()

  expect_equal(app$get_value(input = "cats"), c("apple", "cherry"))
})

test_that("browser: runtime setShape reaches wrapper and teleported dropdown", {
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-runtime-square-shape",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#shape_single-wrap');
      return !!wrap._gt && typeof wrap._gt.setShape === 'function';
    })()
  "))
  expect_true(app$get_js("
    document.querySelector('#shape_single-wrap')._gt.setShape('square');
    document.querySelector('#shape_single-wrap').classList.contains('shape-square');
  "))
  app$wait_for_js("document.querySelector('#shape_single-wrap').classList.contains('shape-square')")

  app$click(selector = "#shape_single-trigger")
  app$wait_for_js("
    (function() {
      var dd = document.querySelector('#shape_single-dropdown.open');
      return !!dd && dd.classList.contains('shape-square') && dd.parentElement === document.body;
    })()
  ")

  expect_true(app$get_js("
    document.querySelector('#shape_single-wrap').classList.contains('shape-square') &&
    document.querySelector('#shape_single-dropdown').classList.contains('shape-square') &&
    document.querySelector('#shape_single-dropdown').parentElement === document.body
  "))
})
