# Run a built-in glasstabs example app

Launches one of the example Shiny apps that ship with the package. A
list of available examples is printed when called with no arguments.
Example apps are launched only in interactive sessions.

## Usage

``` r
runGlassExample(example = NULL, ...)
```

## Arguments

- example:

  Name of the example to run, such as `"basic"`, `"bslib"`,
  `"dashboard"`, `"server-select"`, `"smoke-test"`, or
  `"square-corners"`. When `NULL` (default), lists all available
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
#>   - bslib
#>   - dashboard
#>   - server-select
#>   - smoke-test
#>   - square-corners
#> 
#> Run one with: runGlassExample("basic")

# Run an example interactively
if (interactive()) {
  runGlassExample("bslib")
  runGlassExample("smoke-test")
  runGlassExample("server-select")
}
```
