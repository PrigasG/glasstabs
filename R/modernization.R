# Internal helpers for opt-in visual and layout controls.
.gt_glass_strength <- function(x) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < 0 || x > 1) {
    .gt_abort("`glass_strength` must be a number between 0 and 1.",
              class = "glasstabs_error_bad_argument", argument = "glass_strength",
              value = x, expected = "a finite number between 0 and 1")
  }
  # Decimal dot, independent of the R session's OutDec option.
  format(x, scientific = FALSE, trim = TRUE, decimal.mark = ".", digits = 15L)
}

.gt_layout_length <- function(x, argument, max_parts = 1L) {
  if (is.null(x)) return(NULL)
  .gt_check_string(x, argument)
  values <- strsplit(trimws(x), "[[:space:]]+")[[1L]]
  if (!length(values) || length(values) > max_parts ||
      any(!grepl("^(0|[0-9]+(\\.[0-9]+)?(px|rem|em|%|vh|vw|vmin|vmax|ch|pt))$", values))) {
    .gt_abort(sprintf("`%s` must contain 1 to %d non-negative CSS lengths.",
                      argument, max_parts),
              class = "glasstabs_error_bad_argument", argument = argument,
              value = x, expected = "non-negative CSS lengths")
  }
  paste(values, collapse = " ")
}

.gt_check_css_color <- function(x, argument) {
  .gt_check_string(x, argument)
  # Prevent a CSS value from terminating its declaration or style block.
  if (grepl("[;{}<>]", x)) {
    .gt_abort(sprintf("`%s` must be a single CSS color.", argument),
              class = "glasstabs_error_bad_argument", argument = argument,
              value = x, expected = "a CSS color")
  }
  invisible(x)
}

.gt_css_join <- function(existing, declarations) {
  if (!length(declarations)) return(existing)
  pieces <- c(existing, paste0(declarations, ";"))
  paste(pieces, collapse = " ")
}

.gt_select_classes <- function(strength, size, theme) {
  paste(c(if (strength != "1") "gt-refined-glass",
          if (strength == "0") "gt-no-glass",
          if (size != "md") paste0("gt-size-", size),
          if (inherits(theme, "glass_select_theme") && !is.null(theme$trigger_bg)) "gt-custom-trigger",
          if (inherits(theme, "glass_select_theme") && !is.null(theme$dropdown_bg)) "gt-custom-panel"),
        collapse = " ")
}

.gt_select_properties <- function(theme, strength, max_height = NULL) {
  # Keep the original generated HTML for existing calls.
  c(if (strength != "1") paste0("--gt-glass-strength:", strength),
    if (!is.null(max_height)) paste0("--ms-dropdown-max-height:", max_height),
    if (inherits(theme, "glass_select_theme") && !is.null(theme$trigger_bg))
      paste0("--gt-trigger-bg:", theme$trigger_bg),
    if (inherits(theme, "glass_select_theme") && !is.null(theme$dropdown_bg))
      paste0("--gt-panel-bg:", theme$dropdown_bg))
}
