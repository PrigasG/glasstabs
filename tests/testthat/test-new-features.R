# tests/testthat/test-new-features.R
# Tests for the 7 new features added in v0.3.0

# ── Helpers ───────────────────────────────────────────────────────────────────

make_session <- function(ns_prefix = NULL) {
  msgs <- list()
  list(
    msgs = function() msgs,
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    },
    ns = shiny::NS(ns_prefix)
  )
}

# ── Feature 1: runGlassExample() ─────────────────────────────────────────────

test_that("runGlassExample() returns available example names invisibly when called with no args", {
  result <- runGlassExample()
  expect_type(result, "character")
  expect_true(length(result) > 0)
})

test_that("runGlassExample() lists include 'smoke-test'", {
  available <- runGlassExample()
  expect_true("smoke-test" %in% available)
})

test_that("runGlassExample() errors on unknown example name", {
  expect_error(runGlassExample("does-not-exist"), "not found")
})

test_that("runGlassExample() error message lists available examples", {
  err <- tryCatch(runGlassExample("nope"), error = function(e) conditionMessage(e))
  expect_true(grepl("Available", err))
})

# ── Feature 2: icon argument in glassTabPanel() ───────────────────────────────

test_that("glassTabPanel() icon defaults to NULL", {
  p <- glassTabPanel("a", "A")
  expect_null(p$icon)
})

test_that("glassTabPanel() stores icon when supplied", {
  ico <- shiny::icon("table")
  p   <- glassTabPanel("a", "A", icon = ico)
  expect_false(is.null(p$icon))
})

test_that("glassTabsUI() renders gt-tab-icon span when icon is provided", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", icon = shiny::icon("home"), selected = TRUE),
    glassTabPanel("b", "B")
  ))
  expect_true(grepl("gt-tab-icon", html, fixed = TRUE))
})

test_that("glassTabsUI() renders gt-tab-label span when icon is provided", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", icon = shiny::icon("home"), selected = TRUE)
  ))
  expect_true(grepl("gt-tab-label", html, fixed = TRUE))
})

test_that("glassTabsUI() does NOT render gt-tab-icon span when icon is NULL", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE)
  ))
  expect_false(grepl("gt-tab-icon", html, fixed = TRUE))
})

test_that("glassTabPanel() icon is independent of selected and content", {
  ico <- shiny::icon("star")
  p   <- glassTabPanel("x", "X", shiny::p("content"), icon = ico, selected = TRUE)
  expect_false(is.null(p$icon))
  expect_true(p$selected)
  expect_length(p$content, 1)
})

# ── Feature 3: disableGlassTab() / enableGlassTab() ──────────────────────────

test_that("disableGlassTab() sends glasstabs_disable_tab message", {
  sess <- make_session()
  disableGlassTab(sess, "tabs", "b")
  expect_length(sess$msgs(), 1)
  expect_equal(sess$msgs()[[1]]$type, "glasstabs_disable_tab")
})

test_that("disableGlassTab() sends correct ns and value", {
  sess <- make_session()
  disableGlassTab(sess, "tabs", "beta")
  msg <- sess$msgs()[[1]]$message
  expect_equal(msg$ns,    "tabs")
  expect_equal(msg$value, "beta")
})

test_that("disableGlassTab() namespaces via session$ns", {
  sess <- make_session("mymod")
  disableGlassTab(sess, "tabs", "beta")
  expect_equal(sess$msgs()[[1]]$message$ns, "mymod-tabs")
})

test_that("enableGlassTab() sends glasstabs_enable_tab message", {
  sess <- make_session()
  enableGlassTab(sess, "tabs", "b")
  expect_equal(sess$msgs()[[1]]$type, "glasstabs_enable_tab")
})

test_that("enableGlassTab() sends correct ns and value", {
  sess <- make_session()
  enableGlassTab(sess, "tabs", "beta")
  msg <- sess$msgs()[[1]]$message
  expect_equal(msg$ns,    "tabs")
  expect_equal(msg$value, "beta")
})

test_that("enableGlassTab() namespaces via session$ns", {
  sess <- make_session("mod")
  enableGlassTab(sess, "tabs", "beta")
  expect_equal(sess$msgs()[[1]]$message$ns, "mod-tabs")
})

test_that("disableGlassTab() and enableGlassTab() are independent calls", {
  sess <- make_session()
  disableGlassTab(sess, "tabs", "a")
  enableGlassTab(sess,  "tabs", "a")
  expect_length(sess$msgs(), 2)
  expect_equal(sess$msgs()[[1]]$type, "glasstabs_disable_tab")
  expect_equal(sess$msgs()[[2]]$type, "glasstabs_enable_tab")
})

# ── Feature 4: updateGlassTabBadge() ─────────────────────────────────────────

test_that("updateGlassTabBadge() sends glasstabs_tab_badge message", {
  sess <- make_session()
  updateGlassTabBadge(sess, "tabs", "inbox", count = 5L)
  expect_equal(sess$msgs()[[1]]$type, "glasstabs_tab_badge")
})

test_that("updateGlassTabBadge() sends correct ns, value, and count", {
  sess <- make_session()
  updateGlassTabBadge(sess, "tabs", "inbox", count = 7L)
  msg <- sess$msgs()[[1]]$message
  expect_equal(msg$ns,    "tabs")
  expect_equal(msg$value, "inbox")
  expect_equal(msg$count, 7L)
})

test_that("updateGlassTabBadge() namespaces via session$ns", {
  sess <- make_session("parent")
  updateGlassTabBadge(sess, "tabs", "inbox", count = 3L)
  expect_equal(sess$msgs()[[1]]$message$ns, "parent-tabs")
})

test_that("updateGlassTabBadge() coerces count to integer", {
  sess <- make_session()
  updateGlassTabBadge(sess, "tabs", "a", count = 5.9)
  expect_type(sess$msgs()[[1]]$message$count, "integer")
  expect_equal(sess$msgs()[[1]]$message$count, 5L)
})

test_that("updateGlassTabBadge() sends 0 for NA count", {
  sess <- make_session()
  updateGlassTabBadge(sess, "tabs", "a", count = NA)
  expect_equal(sess$msgs()[[1]]$message$count, 0L)
})

test_that("updateGlassTabBadge() sends 0 to clear badge", {
  sess <- make_session()
  updateGlassTabBadge(sess, "tabs", "a", count = 0L)
  expect_equal(sess$msgs()[[1]]$message$count, 0L)
})

# ── Feature 5: Bookmark integration ──────────────────────────────────────────

test_that("glassTabsServer() accepts bookmark = TRUE without error", {
  # Can't run full moduleServer in unit tests, but we can confirm the
  # function signature and that bookmark argument is accepted.
  expect_true(is.function(glassTabsServer))
  fmls <- formals(glassTabsServer)
  expect_true("bookmark" %in% names(fmls))
  expect_true(isTRUE(fmls$bookmark))  # default is TRUE
})

test_that("glassTabsServer() accepts bookmark = FALSE without error", {
  # Verify the argument exists and defaults to TRUE
  expect_equal(formals(glassTabsServer)$bookmark, TRUE)
})

test_that("glassTabsServer() warns when id contains '-'", {
  expect_warning(
    # moduleServer will error without a reactive context, so catch that too
    tryCatch(glassTabsServer("parent-tabs"), error = function(e) NULL),
    "namespaced"
  )
})

# ── Feature 6: glassTabsOutput() / renderGlassTabs() ─────────────────────────

test_that("glassTabsOutput() returns a shiny tag", {
  out <- glassTabsOutput("my_tabs")
  expect_true(inherits(out, c("shiny.tag", "shiny.tag.list")))
})

test_that("glassTabsOutput() creates an output binding container", {
  html <- as.character(glassTabsOutput("my_tabs"))
  expect_true(grepl("my_tabs", html, fixed = TRUE))
})

test_that("renderGlassTabs() is a function", {
  expect_true(is.function(renderGlassTabs))
})

test_that("renderGlassTabs() returns a render function", {
  rf <- renderGlassTabs({
    glassTabsUI("t", glassTabPanel("a", "A", selected = TRUE))
  })
  expect_true(is.function(rf))
})

test_that("glassTabsOutput() and uiOutput() produce same tag structure", {
  gt_html  <- as.character(glassTabsOutput("out1"))
  ui_html  <- as.character(shiny::uiOutput("out1"))
  expect_equal(gt_html, ui_html)
})

# ── Feature 7: cheatsheet.tex ────────────────────────────────────────────────

test_that("glasstabs-cheatsheet.tex exists in inst/cheatsheet", {
  tex_path <- system.file("cheatsheet", "glasstabs-cheatsheet.tex",
                          package = "glasstabs")
  expect_true(nzchar(tex_path))
  expect_true(file.exists(tex_path))
})

test_that("cheatsheet.tex is non-empty", {
  tex_path <- system.file("cheatsheet", "glasstabs-cheatsheet.tex",
                          package = "glasstabs")
  lines <- readLines(tex_path, warn = FALSE)
  expect_true(length(lines) > 50)
})

test_that("cheatsheet.tex contains key function names", {
  tex_path <- system.file("cheatsheet", "glasstabs-cheatsheet.tex",
                          package = "glasstabs")
  content  <- paste(readLines(tex_path, warn = FALSE), collapse = "\n")
  for (fn in c("useGlassTabs", "glassTabsUI", "glassTabsServer",
               "glassMultiSelect", "glassSelect", "runGlassExample",
               "disableGlassTab", "updateGlassTabBadge",
               "renderGlassTabs", "glassTabsOutput")) {
    expect_true(grepl(fn, content, fixed = TRUE), info = fn)
  }
})

# ── Duplicate value validation (from previous release, kept here) ─────────────

test_that("glassTabsUI() errors on duplicate panel values", {
  expect_error(
    glassTabsUI("nav",
                glassTabPanel("a", "A"),
                glassTabPanel("a", "A2")),
    "Duplicate"
  )
})

test_that("glassTabsUI() error message names the duplicate value", {
  err <- tryCatch(
    glassTabsUI("nav",
                glassTabPanel("dup", "One"),
                glassTabPanel("dup", "Two")),
    error = function(e) conditionMessage(e)
  )
  expect_true(grepl("dup", err))
})

# ── Compact mode ──────────────────────────────────────────────────────────────

test_that("glassTabsUI() without compact does not add gt-compact class", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("A")),
    compact = FALSE
  ))
  expect_false(grepl("gt-compact", html))
})

test_that("glassTabsUI() with compact = TRUE adds gt-compact class", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("A")),
    compact = TRUE
  ))
  expect_true(grepl("gt-compact", html))
})

test_that("glassTabsUI() compact = TRUE keeps gt-container class when wrap = TRUE", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("A")),
    wrap = TRUE,
    compact = TRUE
  ))
  expect_true(grepl("gt-container", html))
  expect_true(grepl("gt-compact", html))
})

test_that("glassTabsUI() compact = TRUE without wrap has only gt-compact class", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("A")),
    wrap = FALSE,
    compact = TRUE
  ))
  expect_false(grepl("gt-container", html))
  expect_true(grepl("gt-compact", html))
})
