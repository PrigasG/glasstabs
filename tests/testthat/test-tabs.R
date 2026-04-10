# tests/testthat/test-tabs.R

# ── glassTabPanel ─────────────────────────────────────────────────────────────

test_that("glassTabPanel() returns correct class", {
  expect_s3_class(glassTabPanel("a", "Tab A"), "glassTabPanel")
})

test_that("glassTabPanel() stores value and label", {
  p <- glassTabPanel("my_tab", "My Label")
  expect_equal(p$value, "my_tab")
  expect_equal(p$label, "My Label")
})

test_that("glassTabPanel() selected defaults to FALSE", {
  expect_false(glassTabPanel("a", "A")$selected)
})

test_that("glassTabPanel() selected = TRUE is stored", {
  expect_true(glassTabPanel("a", "A", selected = TRUE)$selected)
})

test_that("glassTabPanel() stores content elements", {
  p <- glassTabPanel("a", "A", shiny::p("Hello"), shiny::p("World"))
  expect_length(p$content, 2)
})

test_that("glassTabPanel() accepts empty content", {
  expect_length(glassTabPanel("a", "A")$content, 0)
})

# ── glassTabsUI ───────────────────────────────────────────────────────────────

test_that("glassTabsUI() returns an htmltools object", {
  ui <- glassTabsUI("nav",
                    glassTabPanel("a", "A", selected = TRUE),
                    glassTabPanel("b", "B"))
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

test_that("glassTabsUI() errors with no panels", {
  expect_error(glassTabsUI("nav"), "at least one")
})

test_that("glassTabsUI() errors if non-glassTabPanel passed", {
  expect_error(glassTabsUI("nav", "not a panel"), "glassTabPanel")
})

test_that("glassTabsUI() accepts dark theme string", {
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = "dark"))
})

test_that("glassTabsUI() accepts light theme string", {
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = "light"))
})

test_that("glassTabsUI() accepts glass_tab_theme() object", {
  t <- glass_tab_theme(halo_bg = "rgba(255,0,0,0.1)")
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = t))
})

test_that("glassTabsUI() errors on invalid theme string", {
  expect_error(glassTabsUI("nav",
                           glassTabPanel("a", "A", selected = TRUE), theme = "hot-pink"))
})

test_that("glassTabsUI() renders HTML containing all tab values", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("overview", "Overview", selected = TRUE),
                                   glassTabPanel("details",  "Details")))
  expect_true(grepl("overview", html))
  expect_true(grepl("details",  html))
})

test_that("glassTabsUI() scoped CSS block contains the widget id", {
  html <- as.character(glassTabsUI("mynav",
                                   glassTabPanel("a", "A", selected = TRUE)))
  expect_true(grepl("mynav-wrap", html))
})

test_that("glassTabsUI() injects all eight CSS variables", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE)))
  for (v in c("--gt-tab-text:", "--gt-tab-active-text:", "--gt-halo-bg:",
              "--gt-halo-border:", "--gt-content-bg:", "--gt-content-border:",
              "--gt-card-bg:", "--gt-card-text:")) {
    expect_true(grepl(v, html, fixed = TRUE), info = v)
  }
})

test_that("glassTabsUI() custom halo_bg appears in scoped CSS", {
  t    <- glass_tab_theme(halo_bg = "rgba(1,2,3,0.5)")
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE), theme = t))
  expect_true(grepl("rgba(1,2,3,0.5)", html, fixed = TRUE))
})

test_that("glassTabsUI() wrap = TRUE adds gt-container class", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE), wrap = TRUE))
  expect_true(grepl("gt-container", html))
})

test_that("glassTabsUI() wrap = FALSE omits gt-container class", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE), wrap = FALSE))
  expect_false(grepl("gt-container", html))
})

test_that("glassTabsUI() first panel is active by default", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("first",  "First"),
                                   glassTabPanel("second", "Second")))
  expect_true(grepl("gt-tab-pane active", html))
})

test_that("glassTabsUI() respects explicit selected argument", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("first",  "First"),
                                   glassTabPanel("second", "Second"),
                                   selected = "second"))
  # second pane should be active, not first
  expect_true(grepl('data-value="second"', html, fixed = TRUE))
})

# ── updateGlassTabsUI ─────────────────────────────────────────────────────────

test_that("updateGlassTabsUI() sends correct custom message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    },
    ns = shiny::NS(NULL)
  )

  updateGlassTabsUI(fake_session, "tabs", selected = "b")

  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$type, "glasstabs_update_tabs")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$selected, "b")
})

test_that("updateGlassTabsUI() namespaces id via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    },
    ns = shiny::NS("mymodule")
  )

  updateGlassTabsUI(fake_session, "tabs", selected = "overview")

  expect_equal(msgs[[1]]$message$ns, "mymodule-tabs")
  expect_equal(msgs[[1]]$message$selected, "overview")
})

# ── showGlassTab / hideGlassTab ───────────────────────────────────────────────

test_that("showGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  showGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$type, "glasstabs_show_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "b")
})

test_that("hideGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  hideGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$type, "glasstabs_hide_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "b")
})

test_that("showGlassTab() and hideGlassTab() namespace via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  showGlassTab(fake_session, "tabs", "b")
  hideGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$message$ns, "mod-tabs")
  expect_equal(msgs[[2]]$message$ns, "mod-tabs")
})

# ── appendGlassTab / removeGlassTab ──────────────────────────────────────────

test_that("appendGlassTab() errors on non-glassTabPanel input", {
  fake_session <- list(
    sendCustomMessage = function(...) NULL,
    ns = shiny::NS(NULL)
  )
  expect_error(appendGlassTab(fake_session, "tabs", "not a panel"), "glassTabPanel")
})

test_that("appendGlassTab() sends correct message fields", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  tab <- glassTabPanel("new", "New Tab", shiny::p("Content"))
  appendGlassTab(fake_session, "tabs", tab)

  expect_equal(msgs[[1]]$type, "glasstabs_append_tab")
  expect_equal(msgs[[1]]$message$value, "new")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_false(msgs[[1]]$message$select)
  expect_true(nchar(msgs[[1]]$message$link_html) > 0)
  expect_true(nchar(msgs[[1]]$message$pane_html) > 0)
})

test_that("appendGlassTab() select = TRUE is passed through", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("x", "X"), select = TRUE)
  expect_true(msgs[[1]]$message$select)
})

test_that("appendGlassTab() link_html contains correct data-value", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("mytab", "My Tab"))
  expect_true(grepl('data-value="mytab"', msgs[[1]]$message$link_html, fixed = TRUE))
})

test_that("appendGlassTab() pane_html contains namespaced id", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("mytab", "My Tab"))
  expect_true(grepl("mod-tabs-pane-mytab", msgs[[1]]$message$pane_html, fixed = TRUE))
})

test_that("removeGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  removeGlassTab(fake_session, "tabs", "old")
  expect_equal(msgs[[1]]$type, "glasstabs_remove_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "old")
})

test_that("removeGlassTab() namespaces via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  removeGlassTab(fake_session, "tabs", "old")
  expect_equal(msgs[[1]]$message$ns, "mod-tabs")
})
