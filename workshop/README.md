# gtstats beginner workshop

`descriptive-statistics-workshop.qmd` is a 120-minute workshop: a 30-minute
orientation to R/RStudio followed by 90 minutes of hands-on descriptive and
inferential statistics.

The workshop is written to work in two settings:

- **self-paced:** short explanations, runnable examples, and expandable
  “Check yourself” cards;
- **live teaching:** the same cards become natural pause points for discussion
  without requiring a separate set of notes.

## Teaching flow

1. Meet the study question and the data.
2. Use `describe_data()` and `assess_distribution()` before analysis.
3. Build Table 1 as a recipe: data, group, rows, then Overall.
4. Tailor summaries, percentage display, and precision.
5. Add p-values only after the descriptive table is right.
6. Use `compare_groups()` for a focused question and `crosstabs()` for a 2 × 2
   question.

## Package availability for webR

The page currently declares `gtstats` as a webR package in its YAML. Keep the
workshop content independent of the installation route while that route is
finalised. When gtstats is on CRAN or an R-universe that supplies a compatible
WebAssembly binary, update the website's webR configuration/repository and
test the first `library(gtstats)` cell in a fresh browser session.

## Local content review

The document can be rendered or previewed through the Quarto setup used by the
website:

```sh
quarto preview workshop/descriptive-statistics-workshop.qmd
```

Before publishing, test every interactive cell in a private/incognito browser
window. A successful static render does not prove that the browser can load the
package.
