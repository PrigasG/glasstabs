choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# ── width ──────────────────────────────────────────────────────────────────

test_that("glassSelect(width=) sets the field width", {
  html <- as.character(glassSelect("f", choices, width = "240px"))
  expect_match(html, "width:240px")
})

test_that("glassMultiSelect(width=) accepts a percentage", {
  html <- as.character(glassMultiSelect("f", choices, width = "100%"))
  expect_match(html, "width:100%", fixed = TRUE)
})

test_that("selects omit width styling by default", {
  gs <- as.character(glassSelect("f", choices))
  expect_false(grepl("max-width:100%;", gs, fixed = TRUE))
})

# ── whole-widget disabled ──────────────────────────────────────────────────

test_that("glassSelect(disabled=TRUE) adds gt-disabled and removes tab focus", {
  html <- as.character(glassSelect("f", choices, disabled = TRUE))
  expect_match(html, "gt-gs-wrap[^\"]*gt-disabled")
  expect_match(html, 'aria-disabled="true"')
  expect_match(html, 'tabindex="-1"')
})

test_that("glassMultiSelect(disabled=TRUE) adds gt-disabled", {
  html <- as.character(glassMultiSelect("f", choices, disabled = TRUE))
  expect_match(html, "gt-ms-wrap[^\"]*gt-disabled")
})

test_that("selects are enabled (tabindex 0) by default", {
  expect_match(as.character(glassSelect("f", choices)), 'tabindex="0"')
})

# ── per-option disabled ────────────────────────────────────────────────────

test_that("glassSelect(disabled_choices=) marks rows disabled", {
  html <- as.character(glassSelect("f", choices, disabled_choices = "banana"))
  expect_match(html, "gt-gs-option[^\"]*disabled")
  expect_match(html, 'aria-disabled="true"')
})

test_that("glassMultiSelect(disabled_choices=) marks rows disabled", {
  html <- as.character(glassMultiSelect("f", choices, disabled_choices = c("apple", "cherry")))
  expect_match(html, "gt-ms-option[^\"]*disabled")
})

test_that("glassMultiSelect() default selection skips disabled choices", {
  html <- as.character(glassMultiSelect("f", choices, disabled_choices = "banana"))
  expect_false(grepl('&quot;banana&quot;', html, fixed = TRUE))
  expect_false(grepl('gt-ms-option checked disabled" data-value="banana"', html, fixed = TRUE))
})

test_that("glassMultiSelect() explicit selection may include disabled choices", {
  html <- as.character(glassMultiSelect("f", choices, selected = "banana", disabled_choices = "banana"))
  expect_true(grepl('&quot;banana&quot;', html, fixed = TRUE))
  expect_match(html, "gt-ms-option checked disabled")
})

test_that("update fns can send the whole-widget disabled flag", {
  gs <- mockery::mock()
  updateGlassSelect(list(sendInputMessage = gs), "f", disabled = TRUE)
  expect_true(mockery::mock_args(gs)[[1]][[2]]$disabled)

  ms <- mockery::mock()
  updateGlassMultiSelect(list(sendInputMessage = ms), "f", disabled = FALSE)
  expect_false(mockery::mock_args(ms)[[1]][[2]]$disabled)
})

test_that("update fns can send disabled choices without replacing choices", {
  gs <- mockery::mock()
  updateGlassSelect(list(sendInputMessage = gs), "f", disabled_choices = "banana")
  gs_msg <- mockery::mock_args(gs)[[1]][[2]]
  expect_null(gs_msg$choices)
  expect_equal(gs_msg$disabled_choices, "banana")

  ms <- mockery::mock()
  updateGlassMultiSelect(list(sendInputMessage = ms), "f", disabled_choices = c("apple", "cherry"))
  ms_msg <- mockery::mock_args(ms)[[1]][[2]]
  expect_null(ms_msg$choices)
  expect_equal(ms_msg$disabled_choices, c("apple", "cherry"))
})

test_that("update choices payload carries disabled flags", {
  gs <- mockery::mock()
  updateGlassSelect(
    list(sendInputMessage = gs), "f",
    choices = choices, disabled_choices = "banana"
  )
  payload <- mockery::mock_args(gs)[[1]][[2]]$choices
  flags <- vapply(payload, function(x) isTRUE(x$disabled), logical(1))
  values <- vapply(payload, function(x) x$value, character(1))
  expect_true(flags[values == "banana"])
  expect_false(flags[values == "apple"])
})

# ── grouped choices (named list, selectInput-style) ─────────────────────────

test_that(".gt_normalize_choices() flattens a named list into group metadata", {
  norm <- glasstabs:::.gt_normalize_choices(list(
    Fruit = c(Apple = "apple", Banana = "banana"),
    Veg   = c(Carrot = "carrot", Pea = "pea")
  ))
  expect_equal(norm$values, c("apple", "banana", "carrot", "pea"))
  expect_equal(norm$labels, c("Apple", "Banana", "Carrot", "Pea"))
  expect_equal(norm$groups, c("Fruit", "Fruit", "Veg", "Veg"))
})

test_that("scalar list elements stay ungrouped (flat), like selectInput()", {
  norm <- glasstabs:::.gt_normalize_choices(list(a = "A", b = "B"))
  expect_equal(norm$groups, c("", ""))
})

test_that("atomic vector choices have empty groups", {
  norm <- glasstabs:::.gt_normalize_choices(choices)
  expect_equal(norm$groups, rep("", 3))
})

test_that("glassSelect() renders group headers for named-list choices", {
  html <- as.character(glassSelect("f", list(
    Fruit = c(Apple = "apple", Banana = "banana"),
    Veg   = c(Carrot = "carrot", Pea = "pea")
  )))
  expect_match(html, "gt-gs-optgroup")
  expect_match(html, 'data-group="Fruit"')
  expect_match(html, 'data-group="Veg"')
})

test_that("glassMultiSelect() renders group headers for named-list choices", {
  html <- as.character(glassMultiSelect("f", list(
    Fruit = c(Apple = "apple"),
    Veg   = c(Carrot = "carrot", Pea = "pea")
  )))
  # 'Fruit' has a single option so it is a scalar -> flat; 'Veg' is a group
  expect_match(html, "gt-ms-optgroup")
  expect_match(html, 'data-group="Veg"')
})

test_that("update choices payload carries group labels", {
  gs <- mockery::mock()
  updateGlassSelect(
    list(sendInputMessage = gs), "f",
    choices = list(Fruit = c(Apple = "apple", Pear = "pear"))
  )
  payload <- mockery::mock_args(gs)[[1]][[2]]$choices
  groups <- vapply(payload, function(x) x$group, character(1))
  expect_equal(groups, c("Fruit", "Fruit"))
})

test_that("server-side choice filtering preserves group labels", {
  filtered <- glasstabs:::.gt_filter_choices(
    list(
      Fruit = c(Apple = "apple", Pear = "pear"),
      Veg = c(Carrot = "carrot", Pea = "pea")
    ),
    query = "carrot",
    limit = 10
  )
  expect_equal(filtered$values, "carrot")
  expect_equal(filtered$groups, "Veg")

  payload <- glasstabs:::.gt_choice_payload(filtered$labels, filtered$values, groups = filtered$groups)
  expect_equal(payload[[1]]$group, "Veg")
})

# ── glassTabsUI shape ──────────────────────────────────────────────────────

test_that("glassTabsUI(shape='square') adds the shape-square container class", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("x")),
    glassTabPanel("b", "B", shiny::p("y")),
    shape = "square"
  ))
  expect_match(html, "shape-square")
})

test_that("glassTabsUI defaults to rounded (no shape-square)", {
  html <- as.character(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("x"))
  ))
  expect_false(grepl("shape-square", html, fixed = TRUE))
})

test_that("glassTabsUI rejects an invalid shape", {
  expect_error(glassTabsUI(
    "tabs",
    glassTabPanel("a", "A", shiny::p("x")),
    shape = "oval"
  ))
})

# ── shipped CSS/JS hooks ───────────────────────────────────────────────────

test_that("stylesheet ships optgroup, per-option disabled, and square-tab rules", {
  css <- paste(
    readLines(system.file("www", "glass.css", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )
  expect_true(grepl(".gt-gs-optgroup", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-optgroup", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-option.disabled", css, fixed = TRUE))
  expect_true(grepl(".gt-container.shape-square .gt-tab-link", css, fixed = TRUE))
})

test_that("script ships group + disabled handling", {
  js <- paste(
    readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )
  expect_true(grepl("syncOptgroupHeaders", js, fixed = TRUE))
  expect_true(grepl("buildOptgroupNode", js, fixed = TRUE))
  expect_true(grepl("setDisabled", js, fixed = TRUE))
  expect_true(grepl("setDisabledChoices", js, fixed = TRUE))
  expect_true(grepl("disabled_choices", js, fixed = TRUE))
})
