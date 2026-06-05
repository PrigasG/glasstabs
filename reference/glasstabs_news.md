# Display the glasstabs changelog

Prints the package NEWS to the R console. Useful for quickly checking
what changed between versions without leaving your R session.

## Usage

``` r
glasstabs_news()
```

## Value

Called for its side effect; returns `NULL` invisibly.

## Examples

``` r
if (interactive()) {
  glasstabs_news()
}
```
