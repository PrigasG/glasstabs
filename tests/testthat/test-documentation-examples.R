# Documentation examples: every R chunk in the recipe articles must
# parse, and every chunk whose label starts with "run-" must execute.
# Vignettes render with eval = FALSE (most chunks are interactive
# shinyApp() examples), so this test — not the render — is what keeps
# the runnable logic examples honest. Convention: a "run-" chunk is
# pure R (base + shiny:: helpers + package constructors) and may use
# stopifnot() to assert its own result; chunks are evaluated in file
# order sharing one environment per article, like knitr.

extract_rmd_chunks <- function(path) {
  lines <- readLines(path, warn = FALSE)
  chunks <- list()
  i <- 1L
  while (i <= length(lines)) {
    open <- regmatches(
      lines[i],
      regexec("^```\\{r[[:space:]]+([^, }]+)", lines[i])
    )[[1]]
    if (length(open) >= 2) {
      label <- open[2]
      j <- i + 1L
      while (j <= length(lines) && !grepl("^```\\s*$", lines[j])) {
        j <- j + 1L
      }
      code <- if (j > i + 1L) lines[(i + 1L):(j - 1L)] else character(0)
      chunks[[length(chunks) + 1L]] <- list(label = label, code = code)
      i <- j + 1L
    } else {
      i <- i + 1L
    }
  }
  chunks
}

test_that("documentation example chunks parse and runnable chunks execute", {
  articles <- c(
    "modules.Rmd",
    "linked-filters.Rmd",
    "multiselect.Rmd",
    "troubleshooting.Rmd",
    "migrating.Rmd",
    "examples-gallery.Rmd"
  )
  paths <- test_path("..", "..", "vignettes", articles)
  skip_if_not(
    all(file.exists(paths)),
    "vignettes are excluded from the installed test bundle"
  )
  for (k in seq_along(articles)) {
    article <- articles[k]
    path <- paths[k]
    chunks <- extract_rmd_chunks(path)
    expect_gt(length(chunks), 0L, label = paste(article, "has chunks"))
    env <- new.env(parent = globalenv())
    for (chunk in chunks) {
      parsed <- tryCatch(
        parse(text = chunk$code),
        error = function(e) e
      )
      expect_false(
        inherits(parsed, "error"),
        label = paste(article, chunk$label, "parses")
      )
      if (startsWith(chunk$label, "run-") && !inherits(parsed, "error")) {
        expect_no_error(eval(parsed, envir = env))
      }
    }
  }
})
