# Manual real-time case studies

These are interactive review scripts, following the same pattern as the
`gtregression` manual case studies. Together they exercise every meaningful
public analysis branch and presentation route in `gtstats`.

Run a script section by section in RStudio. The scripts deliberately leave
tables, plots, numeric results, methods and notes visible so reviewers can
judge the user experience and provide feedback. They are not replacements for
the automated `testthat` suite.

- `01-birthweight-descriptive-case-study.R` reviews data inspection,
  distributions, the incremental summary-table builder, comparisons,
  correlation, rendering, styling and export.
- `02-birthweight-epidemiology-case-study.R` reviews proportions, generic
  cross-tabs (including 2×2 measures) and illustrative rate workflows.
- `03-independent-inference-test-matrix.R` covers every independent inferential
  test, automatic selection, assumption checks, effect sizes and overrides.
- `04-paired-inference-test-matrix.R` covers paired t, signed-rank and McNemar
  workflows, identifier alignment and paired-data validation.
- `05-summary-builder-combinations.R` covers grouped/ungrouped/overall builders,
  every continuous summary, totals, custom rows, proportions, rates, p-values,
  and missing-data/denominator audits.
- `06-output-rendering-and-validation.R` covers compact/full outputs, all
  rendering themes, flextable conversion, plot branches and expected errors.
- `07-teaching-datasets.R` loads every built-in dataset and demonstrates the
  intended automatic-test branches for real clinical, independent-group, and
  paired data.

The two birthweight case studies use the labelled `gtstats::birthwt` dataset,
so peers can run them without installing another package.

During package development:

```r
devtools::load_all(".")
```

After installation:

```r
library(gtstats)
```

Then open one case study and run it section by section. Lines marked
`FEEDBACK` identify outputs that are especially useful to comment on.

## Review convention

Each scenario states:

- **Indication** — the question the method answers.
- **Default/check** — what `gtstats` selects or verifies.
- **Assumptions to confirm** — matters that software cannot establish from the
  columns alone.
- **Expected** — the test, object class, output or error a reviewer should see.
- **FEEDBACK** — a specific usability or interpretation question.

The manual scripts intentionally do not use `stopifnot()`. Reviewers should see
the same tables, plots, notes and errors as an ordinary user. Automated
correctness assertions remain in `tests/testthat/`.

## Coverage matrix

| Area | Covered branches |
|---|---|
| Exploration | compact/full, selected/all variables, missingness and distribution guidance |
| Continuous summaries | recommended, mean (SD), median (IQR), both |
| Table structure | ungrouped, grouped, grouped + overall, column/row/overall/count-only percentages, missing rows, total first/last, repeated additions, custom rows |
| Independent continuous inference | Student t, Welch t, Wilcoxon rank-sum, classical ANOVA, Welch ANOVA, Kruskal-Wallis |
| Independent categorical inference | chi-square, Fisher exact, automatic expected-count switch, continuity correction, raw and adjusted p-values |
| Paired inference | paired t, Wilcoxon signed-rank, McNemar, alignment by identifier |
| Correlation | automatic, Pearson, Spearman |
| Epidemiology | overall/grouped proportion, risk, RR, OR, Newcombe RD, zero-cell strategies, chi-square/Fisher, grouped rates |
| Rendering | gt, flextable, all five themes, continuous/categorical plots |
| Transparency | assumptions, diagnostics and denominator audits as tibbles and gt tables |
| Validation | missing variables, incompatible tests, invalid levels, duplicate pairs, invalid builder combinations |
