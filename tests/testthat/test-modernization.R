test_that("modernization options are opt-in and validated", {
  panel <- glassTabPanel("a", "A")
  original <- as.character(glassTabsUI("nav", panel))
  expect_identical(original, as.character(glassTabsUI("nav", panel,
    glass_strength = 1, fill = FALSE, reorderable = FALSE)))
  modern <- as.character(glassTabsUI("nav", panel,
    style = "segmented", transition = "none", glass_strength = 0,
    tab_gap = "4px", tab_padding = "8px 12px", nav_padding = "6px",
    content_padding = "0", fill = TRUE, hide_single = TRUE,
    equal_width = TRUE, reorderable = TRUE))
  for (token in c("style-segmented", "transition-none", "gt-no-glass",
                  "gt-fill", "gt-hide-single", "gt-single-tab",
                  "gt-equal-width", "gt-reorderable", "--gt-tab-gap:4px",
                  "--gt-tab-padding:8px 12px", "--gt-content-padding:0")) {
    expect_match(modern, token, fixed = TRUE)
  }
  for (bad in list(-0.1, 1.1, NA_real_, Inf, NULL, "0.5", c(0, 1))) {
    expect_error(glassTabsUI("nav", panel, glass_strength = bad),
                 class = "glasstabs_error_bad_argument")
    expect_error(glassSelect("s", c(A = "a"), glass_strength = bad),
                 class = "glasstabs_error_bad_argument")
    expect_error(glassMultiSelect("m", c(A = "a"), glass_strength = bad),
                 class = "glasstabs_error_bad_argument")
  }
  for (arg in c("fill", "hide_single", "equal_width", "reorderable")) {
    args <- list(id = "nav", panel); args[[arg]] <- "yes"
    expect_error(do.call(glassTabsUI, args), class = "glasstabs_error_bad_argument")
  }
  expect_error(glassTabsUI("nav", panel, tab_padding = "1px; color:red"),
               class = "glasstabs_error_bad_argument")
  expect_error(glassTabsUI("nav", panel, tab_gap = "-1px"),
               class = "glasstabs_error_bad_argument")
})

test_that("select density, strength and custom surfaces preserve legacy defaults", {
  choices <- c(A = "a", B = "b")
  theme <- glass_select_theme(mode = "light", trigger_bg = "#f8fafc", dropdown_bg = "#fff")
  for (constructor in list(glassSelect, glassMultiSelect)) {
    expect_identical(as.character(constructor("x", choices)),
      as.character(constructor("x", choices, size = "md", glass_strength = 1)))
    refined <- as.character(constructor("x", choices, size = "sm",
                                       glass_strength = 0.25, theme = theme))
    for (token in c("gt-size-sm", "gt-refined-glass", "--gt-glass-strength:0.25",
                    "--gt-trigger-bg:#f8fafc", "--gt-panel-bg:#fff")) {
      expect_match(refined, token, fixed = TRUE)
    }
    expect_match(as.character(constructor("x", choices, size = "lg")), "gt-size-lg")
    expect_error(constructor("x", choices, size = "huge"), class = "glasstabs_error_bad_argument")
  }
  expect_match(as.character(glassSelect("x", choices, dropdown_max_height = "180px")),
               "--ms-dropdown-max-height:180px", fixed = TRUE)
  expect_error(glass_select_theme(trigger_bg = "red;position:fixed"),
               class = "glasstabs_error_bad_argument")
})

test_that("custom mode selector is retained for structural theme synchronization", {
  for (constructor in list(glassSelect, glassMultiSelect)) {
    html <- as.character(constructor("x", c(A = "a"), theme = "light",
                                     dark_selector = "body.dark-mode"))
    expect_match(html, 'data-gt-dark-selector="body.dark-mode"', fixed = TRUE)
  }
  html <- as.character(glassTabsUI("nav", glassTabPanel("a", "A"),
                                   theme = "light", dark_selector = "body.dark-mode"))
  expect_match(html, 'data-gt-dark-selector="body.dark-mode"', fixed = TRUE)
})
