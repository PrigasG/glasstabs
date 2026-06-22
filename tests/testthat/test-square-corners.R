choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

test_that("runGlassExample() lists the square-corners example", {
  expect_true("square-corners" %in% runGlassExample())
})

test_that("square-corners example app exists and parses", {
  app <- system.file("examples", "square-corners", "app.R", package = "glasstabs")
  expect_true(nzchar(app) && file.exists(app))
  expect_no_error(parse(app))
})

test_that("default shape emits no shape-square class on either widget", {
  gs <- as.character(glassSelect("f", choices))
  ms <- as.character(glassMultiSelect("f", choices))
  expect_false(grepl("shape-square", gs, fixed = TRUE))
  expect_false(grepl("shape-square", ms, fixed = TRUE))
})

test_that("shape = 'square' tags both wrappers with shape-square", {
  gs <- as.character(glassSelect("f", choices, shape = "square"))
  ms <- as.character(glassMultiSelect("f", choices, shape = "square"))
  expect_match(gs, "gt-gs-wrap[^\"]*shape-square")
  expect_match(ms, "gt-ms-wrap[^\"]*shape-square")
})

test_that("square shape composes with light theme and check styles", {
  html <- as.character(
    glassSelect("f", choices, shape = "square", theme = "light",
                check_style = "filled")
  )
  expect_match(html, "shape-square")
  expect_match(html, "theme-light")
  expect_match(html, "style-filled")
})

test_that("invalid shape is rejected for both widgets", {
  expect_error(glassSelect("f", choices, shape = "oval"))
  expect_error(glassMultiSelect("f", choices, shape = "oval"))
})

test_that("stylesheet ships square-corner rules and JS teleports the class", {
  css <- paste(
    readLines(system.file("www", "glass.css", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )
  js <- paste(
    readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )

  expect_true(grepl(".gt-gs-wrap.shape-square .gt-gs-trigger", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-wrap.shape-square .gt-ms-trigger", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-dropdown.shape-square", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-dropdown.shape-square", css, fixed = TRUE))
  # The teleported dropdown must carry the shape class so it stays square
  expect_true(grepl("'shape-square'", js, fixed = TRUE))
})

test_that("client controllers expose runtime setShape and route the message", {
  js <- paste(
    readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )

  # Both controllers expose a setShape method
  expect_gte(lengths(regmatches(js, gregexpr("setShape:", js, fixed = TRUE))), 2L)
  # The binding + custom-message handlers act on data.shape
  expect_true(grepl("hasOwn(data, 'shape')", js, fixed = TRUE))
})

test_that("shape-only updates do not commit selection changes", {
  js <- paste(
    readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )

  expect_gte(lengths(regmatches(js, gregexpr("var shouldCommit = false;", js, fixed = TRUE))), 3L)
  expect_false(grepl("hasOwn\\(data, 'shape'\\)[\\s\\S]{0,140}shouldCommit = true", js, perl = TRUE))
})

test_that("server choice refreshes do not commit current selections", {
  js <- paste(
    readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE),
    collapse = "\n"
  )
  server_handler <- sub(
    "^[\\s\\S]*Shiny\\.addCustomMessageHandler\\('glasstabs_server_choices', function \\(msg\\) \\{",
    "",
    js,
    perl = TRUE
  )
  server_handler <- sub(
    "\\n    \\}\\);[\\s\\S]*$",
    "",
    server_handler,
    perl = TRUE
  )

  expect_true(grepl("ctrl.setChoices", server_handler, fixed = TRUE))
  expect_false(grepl("commitSelection", server_handler, fixed = TRUE))
})

test_that("update*() can switch shape at runtime via a message field", {
  gs_send <- mockery::mock()
  updateGlassSelect(list(sendInputMessage = gs_send), "pick", shape = "square")
  expect_equal(mockery::mock_args(gs_send)[[1]][[2]]$shape, "square")

  ms_send <- mockery::mock()
  updateGlassMultiSelect(list(sendInputMessage = ms_send), "pick", shape = "rounded")
  expect_equal(mockery::mock_args(ms_send)[[1]][[2]]$shape, "rounded")
})
