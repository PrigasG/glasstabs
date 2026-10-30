test_that("pkgdown exposes both select guides with multi-select first", {
  pkgdown_path <- test_path("..", "..", "_pkgdown.yml")
  skip_if_not(file.exists(pkgdown_path), "pkgdown config is excluded from the package tarball")

  pkgdown <- paste(readLines(pkgdown_path, warn = FALSE), collapse = "\n")
  expect_match(pkgdown, "title: Select widgets", fixed = TRUE)
  expect_match(pkgdown, "navbar: Selects", fixed = TRUE)
  multi_position <- regexpr("- multiselect", pkgdown, fixed = TRUE)[[1]]
  single_position <- regexpr("- glassSelect", pkgdown, fixed = TRUE)[[1]]
  expect_gt(multi_position, 0)
  expect_gt(single_position, multi_position)

  for (article in c("multiselect.Rmd", "glassSelect.Rmd")) {
    expect_true(
      file.exists(test_path("..", "..", "vignettes", article)),
      info = article
    )
  }
})

test_that("select documentation keeps both widget families discoverable", {
  root <- test_path("..", "..")
  shared_docs <- c(
    "README.md",
    file.path("vignettes", "getting-started.Rmd"),
    file.path("vignettes", "cheatsheet.Rmd")
  )
  guide_docs <- file.path(
    "vignettes",
    c("glassSelect.Rmd", "multiselect.Rmd")
  )
  skip_if_not(
    all(file.exists(file.path(root, c(shared_docs, guide_docs)))),
    "repository documentation is excluded from the installed test bundle"
  )

  for (relative in shared_docs) {
    text <- paste(readLines(file.path(root, relative), warn = FALSE), collapse = "\n")
    expect_match(text, "glassSelect", fixed = TRUE, info = relative)
    expect_match(text, "glassMultiSelect", fixed = TRUE, info = relative)
  }

  single <- paste(
    readLines(file.path(root, guide_docs[[1]]), warn = FALSE),
    collapse = "\n"
  )
  multi <- paste(
    readLines(file.path(root, guide_docs[[2]]), warn = FALSE),
    collapse = "\n"
  )
  expect_match(single, "multiselect.html", fixed = TRUE)
  expect_match(multi, "glassSelect.html", fixed = TRUE)
})

test_that("pkgdown reference lists the complete multi-select API", {
  pkgdown_path <- test_path("..", "..", "_pkgdown.yml")
  skip_if_not(file.exists(pkgdown_path), "pkgdown config is excluded from the package tarball")
  pkgdown <- paste(readLines(pkgdown_path, warn = FALSE), collapse = "\n")

  multi_api <- c(
    "glassMultiSelect",
    "updateGlassMultiSelect",
    "glassMultiSelectValue",
    "glassMultiSelectServer",
    "closeGlassMultiSelect",
    "glassFilterTags"
  )
  for (name in multi_api) {
    expect_match(pkgdown, name, fixed = TRUE, info = name)
  }
})

test_that("pkgdown exposes the recipe articles", {
  pkgdown_path <- test_path("..", "..", "_pkgdown.yml")
  skip_if_not(file.exists(pkgdown_path), "pkgdown config is excluded from the package tarball")
  pkgdown <- paste(
    readLines(pkgdown_path, warn = FALSE),
    collapse = "\n"
  )
  expect_match(pkgdown, "modules", fixed = TRUE)
  expect_match(pkgdown, "linked-filters", fixed = TRUE)
})

test_that("server-limit wording agrees across roxygen, Rd, and guides", {
  wrong <- "returned for each server-side search"
  files <- c(
    test_path("..", "..", "R", "glass_multiselect.R"),
    test_path("..", "..", "R", "glassSelect.R"),
    test_path("..", "..", "man", "glassSelect.Rd"),
    test_path("..", "..", "man", "glassMultiSelect.Rd"),
    test_path("..", "..", "vignettes", "multiselect.Rmd"),
    test_path("..", "..", "vignettes", "glassSelect.Rmd")
  )
  skip_if_not(
    all(file.exists(files)),
    "repository sources are excluded from the installed test bundle"
  )
  for (file in files) {
    text <- paste(readLines(file, warn = FALSE), collapse = "\n")
    expect_no_match(text, wrong, fixed = TRUE, label = basename(file))
  }
  guide <- paste(
    readLines(
      test_path("..", "..", "vignettes", "multiselect.Rmd"),
      warn = FALSE
    ),
    collapse = "\n"
  )
  expect_match(guide, "bounded, not paginated", fixed = TRUE)
  expect_match(guide, "server_limit", fixed = TRUE)
})
