# Theme-specific coverage lives here; generic glassTabsUI() behavior is tested
# in test-tabs.R.

test_that("glassTabsUI() custom focus ring appears in scoped CSS", {
  theme <- glass_tab_theme(focus_ring = "#f97316")
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    theme = theme
  ))
  expect_match(html, "--gt-focus-ring:#f97316", fixed = TRUE)
})

test_that("glass_tab_theme() stores mode", {
  expect_equal(glass_tab_theme()$mode, "dark")
  expect_equal(glass_tab_theme(mode = "light")$mode, "light")
})

test_that("glass_tab_theme(mode = 'light') inherits light defaults", {
  theme <- glass_tab_theme(mode = "light")
  vals <- glasstabs:::.tab_resolve_theme(theme)
  expect_equal(vals$tab_text, "#374151")
})

test_that("glass_tab_theme() defaults to dark base preset", {
  vals <- glasstabs:::.tab_resolve_theme(glass_tab_theme())
  expect_equal(vals$tab_text, "rgba(207,230,255,0.78)")
})

test_that("glassTabsUI() adds theme-light class for light-mode custom themes", {
  ui <- glassTabsUI(
    "nav",
    glassTabPanel("a", "A"),
    theme = glass_tab_theme(mode = "light")
  )
  html <- as.character(ui)
  expect_true(grepl("theme-light", html, fixed = TRUE))
})

test_that(".tab_resolve_theme() rejects 'auto' (resolved earlier by glassTabsUI)", {
  expect_error(
    glasstabs:::.tab_resolve_theme("auto"),
    class = "glasstabs_error_bad_theme"
  )
})


test_that(".parse_css_color() clamps out-of-range rgb() components", {
  rgba <- glasstabs:::.parse_css_color("rgb(300, 999, 0)")
  expect_equal(rgba$r, 255)
  expect_equal(rgba$g, 255)
  expect_equal(rgba$b, 0)
})

test_that(".parse_css_color() returns NULL for malformed components", {
  expect_null(glasstabs:::.parse_css_color("rgba(1.2.3, 0, 0)"))
})

test_that("content area has subtle glass defaults (not transparent)", {
  dark <- glasstabs:::.tab_resolve_theme("dark")
  light <- glasstabs:::.tab_resolve_theme("light")

  expect_equal(dark$content_bg, "rgba(255,255,255,0.03)")
  expect_equal(dark$content_border, "rgba(255,255,255,0.08)")
  expect_equal(light$content_bg, "rgba(15,23,42,0.03)")
  expect_equal(light$content_border, "rgba(15,23,42,0.10)")
})

test_that("explicit transparent content_bg still overrides the default", {
  vals <- glasstabs:::.tab_resolve_theme(
    glass_tab_theme(content_bg = "transparent", content_border = "transparent")
  )

  expect_equal(vals$content_bg, "transparent")
  expect_equal(vals$content_border, "transparent")
})
