# Chrome (via chromote/shinytest2) leaves `com.google.Chrome.*` scratch dirs in
# tempdir(). `app$stop()` only ends the Shiny session, so the shared browser
# lingers until R exits and R CMD check flags the leftovers as detritus.
# Snapshot what is already there at suite setup; at suite teardown, close the
# chromote browser (a clean shutdown reclaims Chrome's own scratch) and sweep
# any residue this run created.

.chrome_scratch_pattern <-
  "^com\\.google\\.Chrome(\\.|$)|^\\.org\\.chromium\\.Chromium"

.chrome_scratch_before <- list.files(
  tempdir(),
  pattern = .chrome_scratch_pattern,
  full.names = TRUE,
  all.files = TRUE
)

# Give Chrome longer to open its debugging port on loaded CI runners.
options(chromote.timeout = max(getOption("chromote.timeout", 10), 30))

withr::defer({
  if (requireNamespace("chromote", quietly = TRUE)) {
    chrome_ns <- asNamespace("chromote")
    if (exists("default_chromote_object", where = chrome_ns, inherits = FALSE)) {
      try(
        suppressWarnings(chromote::default_chromote_object()$close()),
        silent = TRUE
      )
    }
  }
  # Sweep only residue created by this run, so a shared tempdir keeps the
  # dirs it already had.
  residue <- setdiff(
    list.files(
      tempdir(),
      pattern = .chrome_scratch_pattern,
      full.names = TRUE,
      all.files = TRUE
    ),
    .chrome_scratch_before
  )
  unlink(residue, recursive = TRUE, force = TRUE)
}, envir = testthat::teardown_env())
