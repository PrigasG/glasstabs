# Shiny tag helper for a filter-tags display area tied to a glassMultiSelect

Renders a `<div>` that the JS engine will populate with colored tag
pills whenever the corresponding
[`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
selection changes.

## Usage

``` r
glassFilterTags(inputId, class = NULL)
```

## Arguments

- inputId:

  The `inputId` of the
  [`glassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/glassMultiSelect.md)
  this display should reflect.

- class:

  Additional CSS classes for the container.

## Value

An `htmltools` tag.
