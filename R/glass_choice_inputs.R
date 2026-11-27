#' Glass-styled standard Shiny choice inputs
#'
#' These controls retain the native Shiny input bindings and update functions.
#' Call [useGlassTabs()] once in the page UI. The default theme follows the
#' nearest Bootstrap color mode; a custom dark selector is optional.
#'
#' @param inputId Shiny input identifier.
#' @param label Input label.
#' @param value Initial logical switch value.
#' @param choices Choices accepted by the corresponding Shiny input.
#' @param selected Initially selected value(s).
#' @param inline Logical. Arrange group choices inline.
#' @param theme One of `"auto"`, `"light"`, or `"dark"`.
#' @param size One of `"md"`, `"sm"`, or `"lg"`.
#' @param glass_strength Decorative glass intensity, from 0 to 1.
#' @param width Optional Shiny CSS width.
#' @param dark_selector Optional ancestor selector indicating dark mode.
#' @return A Shiny UI tag. The server receives a logical switch, a single
#'   character radio value, or a character vector of checked choices.
#' @details Use [shiny::updateCheckboxInput()], [shiny::updateRadioButtons()],
#'   and [shiny::updateCheckboxGroupInput()] respectively for server updates.
#' @examples
#' glassSwitch("enabled", "Enabled", TRUE)
#' glassRadioGroup("mode", "Mode", c("Edit", "Preview"), inline = TRUE)
#' glassCheckboxGroup("fields", "Fields", c("Name", "County"))
#' @export
glassSwitch <- function(inputId, label, value = FALSE, theme = c("auto", "light", "dark"),
                        size = c("md", "sm", "lg"), glass_strength = 1,
                        width = NULL, dark_selector = NULL) {
  .gt_check_flag(value, "value")
  .gt_choice_shell(shiny::checkboxInput(inputId, label, value = value, width = "100%"),
                   "switch", theme, size, glass_strength, width, dark_selector)
}

#' @rdname glassSwitch
#' @export
glassRadioGroup <- function(inputId, label, choices, selected = NULL, inline = FALSE,
                            theme = c("auto", "light", "dark"), size = c("md", "sm", "lg"),
                            glass_strength = 1, width = NULL, dark_selector = NULL) {
  .gt_check_flag(inline, "inline")
  .gt_choice_shell(shiny::radioButtons(inputId, label, choices = choices, selected = selected,
                                      inline = inline, width = "100%"),
                   "radio", theme, size, glass_strength, width, dark_selector)
}

#' @rdname glassSwitch
#' @export
glassCheckboxGroup <- function(inputId, label, choices, selected = NULL, inline = FALSE,
                               theme = c("auto", "light", "dark"), size = c("md", "sm", "lg"),
                               glass_strength = 1, width = NULL, dark_selector = NULL) {
  .gt_check_flag(inline, "inline")
  .gt_choice_shell(shiny::checkboxGroupInput(inputId, label, choices = choices,
                                            selected = selected, inline = inline, width = "100%"),
                   "checkbox", theme, size, glass_strength, width, dark_selector)
}

.gt_choice_shell <- function(content, type, theme, size, glass_strength, width, dark_selector) {
  theme <- .gt_match_arg(theme, c("auto", "light", "dark"), "theme")
  size <- .gt_match_arg(size, c("md", "sm", "lg"), "size")
  strength <- .gt_glass_strength(glass_strength)
  if (!is.null(dark_selector)) .gt_check_string(dark_selector, "dark_selector")
  if (!is.null(width)) width <- shiny::validateCssUnit(width)
  cls <- paste(c("gt-choice-family", paste0("gt-choice-", type), paste0("gt-choice-", size),
                 if (theme == "auto") "theme-auto", if (theme != "dark") "theme-light"),
               collapse = " ")
  shiny::div(class = cls,
             style = paste0("--gt-choice-strength:", strength, ";max-width:100%;",
                            if (!is.null(width)) paste0("width:", width, ";")),
             `data-gt-dark-selector` = if (theme != "dark") dark_selector,
             content)
}
