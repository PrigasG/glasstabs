# Run a built-in glasstabs example app

Launches one of the example Shiny apps that ship with the package. A
list of available examples is printed when called with no arguments.

## Usage

``` r
runGlassExample(example = NULL, ...)
```

## Arguments

- example:

  Name of the example to run. One of `"smoke-test"`, `"basic"`,
  `"bs4dash"`, `"dashboard"`. When `NULL` (default), lists all available
  examples.

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

Called for its side-effect (launches a Shiny app).

## Examples

``` r
# List available examples
runGlassExample()
#> Available glasstabs examples:
#>   - basic
#>   - bs4dash
#>   - dashboard
#>   - smoke-test
#> 
#> Run one with: runGlassExample("basic")

# Run an example interactively
if (interactive()) {
  runGlassExample("smoke-test")
}
```
