# What's new in glasstabs 0.4.2

Version 0.4.2 focuses on reliable navigation, reliable filters and
native-bound form controls. Existing behavior remains the default. This
guide describes the 0.4.2 development candidate; check
`packageVersion("glasstabs")` before using new arguments on a CRAN
installation.

## Modern workspaces

``` r

glassTabsUI("workspace",
  glassTabPanel("edit", "Edit", shiny::textInput("title", "Title")),
  glassTabPanel("preview", "Preview", shiny::p("Preview"), closable = TRUE),
  style = "segmented", indicator = "solid", transition = "none",
  reorderable = TRUE, persist_order = "session", touch_reorder = TRUE,
  equal_width = TRUE, glass_strength = 0.25, theme = "auto")
```

Desktop, keyboard and touch handles share the reorder controller.
`-tab_order` reports the order; `-close_request` asks the server to
remove a tab. See the [tabs
guide](https://prigasg.github.io/glasstabs/articles/tabs.md) for storage
precedence and closure authorization.

## Select dimensions and surfaces

``` r

glassSelect("month", month.abb, width = "130px", size = "sm",
            glass_strength = 0.25, theme = "auto")
glassMultiSelect("region", c("North", "South"), width = "100%",
                 dropdown_max_height = "18rem", size = "sm")
```

The original 160px width remains the default. Narrow fields respect
their parent. Panels respond to visible viewport changes and use a
scrolling fallback in very tight space.

## Native-bound form controls

``` r

glassSwitch("enabled", "Enable filters", TRUE)
glassRadioGroup("mode", "Mode", c("Edit", "Preview"))
glassCheckboxGroup("columns", "Columns", c("Name", "County"))
```

Use ordinary Shiny server input values and update functions. See the
[component
gallery](https://prigasg.github.io/glasstabs/articles/component-gallery.md)
for examples and the
[cheatsheet](https://prigasg.github.io/glasstabs/articles/cheatsheet.md)
for a compact reference.

## Reliability improvements

Dropdowns respect modal focus boundaries, dismiss when their pane goes
inactive, and scroll options without moving the page. Nested widgets own
their shape and theme. Appended panes load dependencies and bind before
their links are committed. Failed/cancelled appends clean up their
pending operation.

## Try the candidate

``` r

runGlassExample("modernization")
runGlassExample("final-features")
```

Review the
[changelog](https://prigasg.github.io/glasstabs/news/index.md),
[troubleshooting](https://prigasg.github.io/glasstabs/articles/troubleshooting.md)
and [deployment
guide](https://prigasg.github.io/glasstabs/articles/posit-connect.md)
before shipping. Physical mobile verification and third-party widget
integration remain release checks.
