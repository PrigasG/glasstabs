#' Abort with a classed glasstabs condition
#'
#' @param message Error message passed to [cli::cli_abort()].
#' @param class Leaf condition class.
#' @param ... Metadata attached to the condition.
#' @noRd
.gt_abort <- function(message, class, ...) {
  cli::cli_abort(
    message,
    class = c(class, "glasstabs_error"),
    ...,
    .internal = FALSE
  )
}

#' @noRd
.gt_check_string <- function(x, argument, message = NULL) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    .gt_abort(
      message %||% sprintf("`%s` must be a single non-empty string.", argument),
      class = "glasstabs_error_bad_argument",
      argument = argument,
      value = x,
      expected = "a single non-empty character string"
    )
  }
  invisible(x)
}

#' @noRd
.gt_check_flag <- function(x, argument) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    .gt_abort(
      sprintf("`%s` must be `TRUE` or `FALSE`.", argument),
      class = "glasstabs_error_bad_argument",
      argument = argument,
      value = x,
      expected = "a single non-missing logical value"
    )
  }
  invisible(x)
}

#' @noRd
.gt_check_session <- function(session, method) {
  if (is.null(session) || !is.function(session[[method]])) {
    .gt_abort(
      sprintf("`session` must be a Shiny session with %s().", method),
      class = "glasstabs_error_no_session",
      argument = "session",
      value = session,
      expected = sprintf("a Shiny session with %s()", method)
    )
  }
  invisible(session)
}

#' @noRd
.gt_match_arg <- function(x, choices, argument) {
  matched <- tryCatch(
    match.arg(x, choices),
    error = function(error) NULL
  )
  if (is.null(matched)) {
    .gt_abort(
      sprintf(
        "`%s` must be one of %s.",
        argument,
        paste(sprintf('"%s"', choices), collapse = ", ")
      ),
      class = "glasstabs_error_bad_argument",
      argument = argument,
      value = x,
      expected = choices
    )
  }

  matched
}
