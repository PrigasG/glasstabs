# Component gallery

Browse the public components and copy the examples into a Shiny UI with
[`library(shiny)`](https://shiny.posit.co/),
[`library(glasstabs)`](https://github.com/PrigasG/glasstabs) and
[`useGlassTabs()`](https://prigasg.github.io/glasstabs/reference/useGlassTabs.md)
at the root. The following code is for 0.4.2. The pkgdown page is
static; launch the example for actual rendered widgets, theme changes
and interactions.

## Navigation

![Closable glass tabs in a compact
workspace](https://prigasg.github.io/glasstabs/reference/figures/tabs-closable.png)

Closable glass tabs in a compact workspace

``` r

glassTabsUI("tabs",
  glassTabPanel("data", "Data", p("Data")),
  glassTabPanel("preview", "Preview", p("Preview"), closable = TRUE),
  style = "segmented", indicator = "solid", theme = "auto",
  transition = "none", glass_strength = 0.25)
```

## Single and multiple selections

![Multi-select with colored choices and a selection
count](https://prigasg.github.io/glasstabs/reference/figures/select-multiselect.png)

Multi-select with colored choices and a selection count

``` r

glassSelect("dataset", c("Providers", "Population"), width = "240px")
glassMultiSelect("region", c("North", "South"), width = "100%")
```

## Switch, radio and checkbox group

![Glass switch, radio buttons, and checkbox
group](https://prigasg.github.io/glasstabs/reference/figures/form-inputs.png)

Glass switch, radio buttons, and checkbox group

``` r

glassSwitch("enabled", "Enable filtering", TRUE, theme = "auto")
glassRadioGroup("mode", "Mode", c("Edit", "Preview"), inline = TRUE)
glassCheckboxGroup("fields", "Fields", c("Name", "County"),
                   selected = "Name", inline = TRUE)
```

## Try each component in a real app

``` r

runGlassExample("final-features")
```

## Watch the demos

[Open the dashboard workflow
recording](https://prigasg.github.io/glasstabs/media/dashboard-workflow.mp4).

[Open the configurable navigation
recording](https://prigasg.github.io/glasstabs/media/configurable-navigation.mp4).

See [navigation](https://prigasg.github.io/glasstabs/articles/tabs.md),
[single-select](https://prigasg.github.io/glasstabs/articles/glassSelect.md),
[multi-select](https://prigasg.github.io/glasstabs/articles/multiselect.md),
[form
inputs](https://prigasg.github.io/glasstabs/reference/glassSwitch.md)
and [the example
gallery](https://prigasg.github.io/glasstabs/articles/examples-gallery.md).
The built-in example renders these controls together in a working Shiny
app.
