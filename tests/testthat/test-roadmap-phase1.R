# tests/testthat/test-roadmap-phase1.R
# Tests for Phase 1 roadmap items:
#   - glassTabCondition()
#   - glasstabs_news()
#   - Improved error messages

# ── glassTabCondition() ───────────────────────────────────────────────────────

test_that("glassTabCondition() returns correct JS condition string", {
  cond <- glassTabCondition("main", "details")
  expect_equal(cond, "input['main-active_tab'] === 'details'")
})

test_that("glassTabCondition() works with namespaced id (module context)", {
  ns   <- shiny::NS("mymod")
  cond <- glassTabCondition(ns("tabs"), "summary")
  expect_equal(cond, "input['mymod-tabs-active_tab'] === 'summary'")
})

test_that("glassTabCondition() returns a single character string", {
  cond <- glassTabCondition("x", "y")
  expect_type(cond, "character")
  expect_length(cond, 1L)
})

test_that("glassTabCondition() errors on empty id", {
  expect_error(glassTabCondition("", "val"), "non-empty string")
})

test_that("glassTabCondition() errors on non-character id", {
  expect_error(glassTabCondition(123, "val"), "non-empty string")
})

test_that("glassTabCondition() errors on empty value", {
  expect_error(glassTabCondition("main", ""), "non-empty string")
})

test_that("glassTabCondition() errors on vector id", {
  expect_error(glassTabCondition(c("a", "b"), "val"), "non-empty string")
})

# ── glasstabs_news() ─────────────────────────────────────────────────────────

test_that("glasstabs_news() runs without error", {
  expect_no_error(glasstabs_news())
})

test_that("glasstabs_news() returns NULL invisibly", {
  result <- glasstabs_news()
  expect_null(result)
})

# ── Improved error messages: glassTabsUI() ────────────────────────────────────

test_that("glassTabsUI() error on empty panels mentions how to fix", {
  err <- tryCatch(glassTabsUI("x"), error = conditionMessage)
  expect_match(err, "glassTabPanel")
})

test_that("glassTabsUI() error on non-panel arg names the bad class", {
  err <- tryCatch(
    glassTabsUI("x", shiny::p("oops")),
    error = conditionMessage
  )
  expect_match(err, "shiny.tag|non-panel")
})

test_that("glassTabsUI() duplicate error mentions the duplicate value", {
  err <- tryCatch(
    glassTabsUI("x",
                glassTabPanel("dup", "One"),
                glassTabPanel("dup", "Two")),
    error = conditionMessage
  )
  expect_match(err, "dup")
  expect_match(err, "unique")
})

test_that("glassTabsUI() selected mismatch error shows valid values", {
  err <- tryCatch(
    glassTabsUI("x",
                glassTabPanel("a", "A"),
                glassTabPanel("b", "B"),
                selected = "zzz"),
    error = conditionMessage
  )
  expect_match(err, "zzz")
  expect_match(err, "a")
})

# ── Improved error messages: appendGlassTab() ────────────────────────────────

test_that("appendGlassTab() error names the bad class", {
  sess <- list(
    ns = shiny::NS(NULL),
    sendCustomMessage = function(...) {}
  )
  err <- tryCatch(
    appendGlassTab(sess, "tabs", "not_a_panel"),
    error = conditionMessage
  )
  expect_match(err, "character")
  expect_match(err, "glassTabPanel")
})

# ── Improved error messages: glassTabsServer() ───────────────────────────────

test_that("glassTabsServer() warning on namespaced id explains the fix", {
  expect_warning(
    tryCatch(glassTabsServer("mod-tabs"), error = function(e) NULL),
    regexp = "ns\\("
  )
})

# ── Improved error messages: theme validation ─────────────────────────────────

test_that("tab theme error on bad string mentions valid options", {
  err <- tryCatch(
    glassTabsUI("x",
                glassTabPanel("a", "A"),
                theme = "purple"),
    error = conditionMessage
  )
  expect_match(err, "dark")
  expect_match(err, "light")
})

test_that("select theme error on bad string mentions valid options", {
  err <- tryCatch(
    glassMultiSelect("x", c(A = "a"), theme = "ocean"),
    error = conditionMessage
  )
  expect_match(err, "dark")
  expect_match(err, "light")
})

# ── Improved error messages: choices validation ───────────────────────────────

test_that("glassMultiSelect() NULL choices error is actionable", {
  err <- tryCatch(
    glassMultiSelect("x", NULL),
    error = conditionMessage
  )
  expect_match(err, "NULL")
  expect_match(err, "character vector|c\\(")
})

test_that("glassMultiSelect() list choices error suggests vector", {
  err <- tryCatch(
    glassMultiSelect("x", list(a = "A", b = "B")),
    error = conditionMessage
  )
  expect_match(err, "atomic vector|vector")
})

test_that("glassSelect() multi-value selected error suggests glassMultiSelect", {
  err <- tryCatch(
    glassSelect("x", c(A = "a", B = "b"), selected = c("a", "b")),
    error = conditionMessage
  )
  expect_match(err, "glassMultiSelect")
})
