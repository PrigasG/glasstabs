# Run deliberately in a standalone formatting commit, not as part of behavior
# changes. The package keeps the tidyverse transformer and a two-space indent.
styler::style_pkg(
  transformers = styler::tidyverse_style(indent_by = 2L),
  filetype = "R"
)
