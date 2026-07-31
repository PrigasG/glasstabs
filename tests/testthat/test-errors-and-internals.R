test_that("glasstabs errors have leaf and shared condition classes", {
  error <- tryCatch(
    glassSelect("", c(Apple = "apple")),
    glasstabs_error = identity
  )

  expect_s3_class(error, "glasstabs_error_bad_argument")
  expect_s3_class(error, "glasstabs_error")
  expect_equal(error$argument, "inputId")
  expect_match(conditionMessage(error), "inputId", fixed = TRUE)

  expect_error(
    glassSelect("fruit", NULL),
    "choices",
    class = "glasstabs_error_bad_choice"
  )
  expect_error(
    glassSelect("fruit", "apple", theme = "unknown"),
    "theme",
    class = "glasstabs_error_bad_theme"
  )
  expect_error(
    closeAllGlassSelects(NULL),
    "session",
    class = "glasstabs_error_no_session"
  )
})

test_that("shared validators preserve accepted and rejected inputs", {
  expect_invisible(.gt_check_string("value", "argument"))
  expect_invisible(.gt_check_flag(TRUE, "flag"))
  expect_invisible(.gt_check_flag(FALSE, "flag"))
  expect_invisible(.gt_check_session(
    list(sendInputMessage = function(...) NULL),
    "sendInputMessage"
  ))
  expect_identical(.gt_match_arg("rou", c("rounded", "square"), "shape"), "rounded")

  bad_strings <- list(NULL, "", NA_character_, character(0), c("a", "b"), 1)
  for (value in bad_strings) {
    expect_error(
      .gt_check_string(value, "argument"),
      class = "glasstabs_error_bad_argument"
    )
  }

  for (value in list(NULL, NA, logical(0), c(TRUE, FALSE), 1)) {
    expect_error(
      .gt_check_flag(value, "flag"),
      class = "glasstabs_error_bad_argument"
    )
  }
})

test_that("side-effect helpers return NULL invisibly", {
  session <- list(
    ns = shiny::NS("mod"),
    sendCustomMessage = function(...) NULL,
    sendInputMessage = function(...) NULL
  )
  tab <- glassTabPanel("new", "New")

  calls <- list(
    function() updateGlassTabsUI(session, "tabs", "new"),
    function() updateGlassTabBadge(session, "tabs", "new", 1L),
    function() showGlassTab(session, "tabs", "new"),
    function() hideGlassTab(session, "tabs", "new"),
    function() disableGlassTab(session, "tabs", "new"),
    function() enableGlassTab(session, "tabs", "new"),
    function() appendGlassTab(session, "tabs", tab),
    function() removeGlassTab(session, "tabs", "new"),
    function() updateGlassMultiSelect(session, "multi", selected = character(0)),
    function() updateGlassSelect(session, "single", selected = character(0))
  )

  for (call in calls) {
    result <- withVisible(call())
    expect_null(result$value)
    expect_false(result$visible)
  }
})

test_that("JSON and JavaScript string serialization cover edge cases", {
  expect_identical(.gt_json_array(c("a", "b")), '["a","b"]')
  expect_identical(.gt_json_array(character(0)), "[]")
  expect_identical(.gt_json_array('a"b'), '["a\\"b"]')
  expect_identical(.gt_json_array("café"), '["café"]')

  condition <- glassTabCondition(
    "x",
    paste0("a", "\r", "b", "\n", "c", "\t", "d", "\u2028", "e", "\u2029", "f")
  )
  expect_identical(
    condition,
    'input["x-active_tab"] === "a\\rb\\nc\\td\\u2028e\\u2029f"'
  )
})

test_that("choice filtering never matches across label-value boundaries", {
  choices <- c(Banana = "banana")

  expect_equal(.gt_filter_choices(choices, "Ban")$values, "banana")
  expect_equal(.gt_filter_choices(choices, "nana")$values, "banana")
  expect_length(.gt_filter_choices(choices, "na ba")$values, 0L)
})

test_that("dependency version follows DESCRIPTION", {
  expect_identical(
    useGlassTabs()$version,
    as.character(utils::packageVersion("glasstabs"))
  )
})
