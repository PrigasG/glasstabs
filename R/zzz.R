#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0) b else a
}

#' @noRd
.make_style_tag <- function(css) {
  tag <- shiny::tags$style(css)
  nonce <- getOption("glasstabs.csp_nonce", NULL)

  if (is.character(nonce) && length(nonce) == 1L && nzchar(nonce)) {
    tag$attribs$nonce <- nonce
  }

  tag
}

#' @noRd
.parse_css_color <- function(color) {
  color <- trimws(color %||% "")

  rgba_match <- regexec(
    "^rgba?\\(\\s*([0-9.]+)\\s*,\\s*([0-9.]+)\\s*,\\s*([0-9.]+)(?:\\s*,\\s*([0-9.]+))?\\s*\\)$",
    color,
    ignore.case = TRUE
  )
  rgba_parts <- regmatches(color, rgba_match)[[1]]
  if (length(rgba_parts) > 0) {
    return(list(
      r = as.numeric(rgba_parts[[2]]),
      g = as.numeric(rgba_parts[[3]]),
      b = as.numeric(rgba_parts[[4]]),
      a = if (length(rgba_parts) >= 5L && nzchar(rgba_parts[[5]])) as.numeric(rgba_parts[[5]]) else 1
    ))
  }

  rgb <- tryCatch(grDevices::col2rgb(color, alpha = TRUE), error = function(e) NULL)
  if (is.null(rgb)) {
    return(NULL)
  }

  list(
    r = as.numeric(rgb[1, 1]),
    g = as.numeric(rgb[2, 1]),
    b = as.numeric(rgb[3, 1]),
    a = as.numeric(rgb[4, 1]) / 255
  )
}

#' @noRd
.rgba_css <- function(color, alpha = 1) {
  rgba <- .parse_css_color(color)
  if (is.null(rgba)) {
    return(color)
  }

  sprintf(
    "rgba(%d,%d,%d,%.3f)",
    round(rgba$r),
    round(rgba$g),
    round(rgba$b),
    max(0, min(1, rgba$a * alpha))
  )
}

#' @noRd
.blend_css <- function(foreground, background, weight = 1) {
  fg <- .parse_css_color(foreground)
  bg <- .parse_css_color(background)
  if (is.null(fg) || is.null(bg)) {
    return(foreground)
  }

  weight <- max(0, min(1, weight))
  alpha <- fg$a * weight + bg$a * (1 - weight)

  sprintf(
    "rgba(%d,%d,%d,%.3f)",
    round(fg$r * weight + bg$r * (1 - weight)),
    round(fg$g * weight + bg$g * (1 - weight)),
    round(fg$b * weight + bg$b * (1 - weight)),
    max(0, min(1, alpha))
  )
}

#' @noRd
.to_rgba_vars <- function(colors) {
  accent_alphas <- c(12, 16, 18, 22, 28, 32, 40, 55, 60, 75)
  text_alphas <- c(3, 4, 5, 6, 8, 35, 45, 50, 80)

  accent_vars <- vapply(
    accent_alphas,
    function(a) sprintf("--ms-ac-%02d:%s;", a, .rgba_css(colors$accent, a / 100)),
    character(1)
  )
  text_vars <- vapply(
    text_alphas,
    function(a) sprintf("--ms-tx-%02d:%s;", a, .rgba_css(colors$text, a / 100)),
    character(1)
  )

  paste0(
    paste(accent_vars, collapse = ""),
    paste(text_vars, collapse = ""),
    sprintf("--ms-ac-tx-75:%s;", .blend_css(colors$accent, colors$text, 0.75))
  )
}

#' @noRd
.is_light_theme <- function(theme) {
  isTRUE(
    (is.character(theme) && length(theme) == 1 && identical(theme, "light")) ||
      (inherits(theme, "glass_select_theme") && identical(theme$mode, "light"))
  )
}

#' Label helper for glassSelect
#'
#' @param vals Choice values.
#' @param labels Choice labels.
#' @param selected Selected value or \code{NULL}.
#' @param placeholder Placeholder label when nothing is selected.
#'
#' @return A single character string used for the trigger label.
#' @noRd
.gs_label <- function(vals, labels, selected, placeholder) {
  if (is.null(selected) || length(selected) == 0) {
    return(placeholder)
  }

  idx <- match(selected[[1]], vals)
  if (is.na(idx)) {
    return(placeholder)
  }

  labels[[idx]]
}

#' Shiny tag helper for a filter-tags display area tied to a glassMultiSelect
#'
#' Renders a \code{<div>} that the JS engine will populate with colored tag pills
#' whenever the corresponding [glassMultiSelect()] selection changes.
#'
#' @param inputId The \code{inputId} of the [glassMultiSelect()] this display
#'   should reflect.
#' @param class Additional CSS classes for the container.
#'
#' @return An \code{htmltools} tag (\code{shiny.tag}). A \code{<div>} container
#'   that renders the current selection of the paired \code{glassMultiSelect()}
#'   as dismissible pill tags, kept in sync with the widget automatically via
#'   JavaScript.
#' @export
glassFilterTags <- function(inputId, class = NULL) {
  if (!is.character(inputId) || length(inputId) != 1L || !nzchar(inputId)) {
    stop(
      "glassFilterTags(): `inputId` must be a single non-empty string matching ",
      "the inputId of the glassMultiSelect() widget.",
      call. = FALSE
    )
  }
  classes <- c("gt-filter-tags", class)
  classes <- classes[!is.na(classes) & nzchar(classes)]

  shiny::div(
    class = paste(classes, collapse = " "),
    `data-tags-for` = inputId
  )
}
