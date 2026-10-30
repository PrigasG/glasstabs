test_that("select-all initial indicator uses the enabled-only toggle scope", {
  # Four enabled options selected, one disabled: the toggle set is complete,
  # so the indicator reads checked -- not indeterminate, as the old
  # total-based math reported.
  html <- as.character(glassMultiSelect(
    "scope_a",
    c(A = "a", B = "b", C = "c", D = "d", E = "e"),
    selected = c("a", "b", "c", "d"),
    disabled_choices = "e"
  ))
  expect_match(html, "gt-ms-all checked", fixed = TRUE)
  expect_match(html, 'aria-checked="true"', fixed = TRUE)

  # Only the disabled value selected: nothing in the toggle set is selected.
  html <- as.character(glassMultiSelect(
    "scope_b",
    c(A = "a", B = "b"),
    selected = "b",
    disabled_choices = "b"
  ))
  expect_match(html, 'aria-checked="false"', fixed = TRUE)
  expect_no_match(html, "gt-ms-all checked", fixed = TRUE)
  expect_no_match(html, "gt-ms-all indeterminate", fixed = TRUE)

  # Only the enabled option selected: the toggle set is complete.
  html <- as.character(glassMultiSelect(
    "scope_c",
    c(A = "a", B = "b"),
    selected = "a",
    disabled_choices = "b"
  ))
  expect_match(html, "gt-ms-all checked", fixed = TRUE)
  expect_match(html, 'aria-checked="true"', fixed = TRUE)

  # All choices disabled: nothing to toggle, indicator unchecked.
  html <- as.character(glassMultiSelect(
    "scope_d",
    c(A = "a", B = "b"),
    disabled_choices = c("a", "b")
  ))
  expect_match(html, 'aria-checked="false"', fixed = TRUE)
  expect_no_match(html, "gt-ms-all checked", fixed = TRUE)

  # Partially selected enabled set: mixed.
  html <- as.character(glassMultiSelect(
    "scope_e",
    c(A = "a", B = "b", C = "c"),
    selected = "a",
    disabled_choices = "c"
  ))
  expect_match(html, "gt-ms-all indeterminate", fixed = TRUE)
  expect_match(html, 'aria-checked="mixed"', fixed = TRUE)
})

test_that("server choice payload carries disabled flags only when specified", {
  payload <- glasstabs:::.gt_choice_payload
  rows <- payload(c("Alpha", "Zeta"), c("alpha", "zeta"), disabled_choices = "zeta")
  expect_false(rows[[1]]$disabled)
  expect_true(rows[[2]]$disabled)

  # NULL omits the field so the client keeps previously loaded state.
  rows <- payload(c("Alpha", "Zeta"), c("alpha", "zeta"))
  expect_null(rows[[1]]$disabled)
  expect_null(rows[[2]]$disabled)

  # An explicit empty set is authoritative: every row enabled.
  rows <- payload(
    c("Alpha", "Zeta"),
    c("alpha", "zeta"),
    hues = c(alpha = 10L, zeta = 20L),
    disabled_choices = character(0)
  )
  expect_false(rows[[1]]$disabled)
  expect_false(rows[[2]]$disabled)
  expect_equal(rows[[1]]$hue, 10L)

  # A disabled value not in this page is no error; it just matches nothing.
  rows <- payload(c("Alpha"), c("alpha"), disabled_choices = "zeta")
  expect_false(rows[[1]]$disabled)
})

test_that("single-select wrap carries the include_all flag for All-row restore", {
  html <- as.character(glassSelect(
    "inc_true", c(A = "a"), selected = "a", include_all = TRUE
  ))
  expect_match(html, 'data-include-all="true"', fixed = TRUE)
  expect_match(html, 'data-all-choice-value="__all__"', fixed = TRUE)

  html <- as.character(glassSelect(
    "inc_false", c(A = "a"), selected = "a", include_all = FALSE
  ))
  expect_match(html, 'data-include-all="false"', fixed = TRUE)
})
