# Example gallery

Every example below runs with one command:

``` r

runGlassExample("basic")
```

[`runGlassExample()`](https://prigasg.github.io/glasstabs/reference/runGlassExample.md)
with no argument lists all available apps. Source for each app lives
under `inst/examples/<name>/app.R` in the package repository. Start with
`basic`; reach for the others when the question is specific.

## The apps

| Example | What you learn | Launch |
|----|----|----|
| `basic` | The smallest complete app: tabs with Overview, Details, Extras, and Final panels | `runGlassExample("basic")` |
| `native-comparison` | glasstabs versus built-in Shiny controls, side by side, including a deliberately truncated selected label and live controls for width, tongue motion, labels, search focus, filled colors, and overflow tooltips | `runGlassExample("native-comparison")` |
| `server-select` | Server-side glass selects: bounded search over a large choice set | `runGlassExample("server-select")` |
| `bslib` | Integration with modern Bootstrap themes, with square corners | `runGlassExample("bslib")` |
| `bs4dash` | Dashboard layout integration | `runGlassExample("bs4dash")` |
| `dashboard` | A Store Analytics dashboard built with the widgets | `runGlassExample("dashboard")` |
| `indicators` | Indicator styles, vertical orientation, and automatic theming | `runGlassExample("indicators")` |
| `light-mode` | Light themes and long labels: a bright, everyday app showing adaptive dropdown sizing | `runGlassExample("light-mode")` |
| `theme-switcher` | Dynamic theming: one switch flips every select between dark and light, with long labels, wide text in a narrow phone frame, and a bottom-of-page dropdown that must flip above the field | `runGlassExample("theme-switcher")` |
| `connect-workflow` | A deployable Posit Connect workflow showing responsive layouts, keyboard and touch interaction, dynamic tabs, badges, themes, and the page wrapper | `runGlassExample("connect-workflow")` |
| `smoke-test` | A broad widget smoke test across Overview, Details, Admin, and Compare panels | `runGlassExample("smoke-test")` |
| `square-corners` | Square-corner styling as a smoke test | `runGlassExample("square-corners")` |
| `stress-test` | **Diagnostic, not a starter template.** Pushes both selects to their limits, including a 100,000-choice set and complex interaction scenarios — use it to check performance and edge cases, not to copy for ordinary apps | `runGlassExample("stress-test")` |

## Choosing one

- **First run:** `basic`.
- **“Will it fit my dashboard?”** `bs4dash` or `bslib`, then `dashboard`
  for a full-page example.
- **“Will it handle my data?”** `server-select` for bounded search,
  `stress-test` for the upper limits (diagnostic only).
- **“Will it look right in light mode?”** `light-mode`, then
  `theme-switcher` to watch one switch flip everything.
- **“Should I switch from native controls?”** `native-comparison`.
- **“Will it deploy?”** `connect-workflow`, plus the Posit Connect
  article.
