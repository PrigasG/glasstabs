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
