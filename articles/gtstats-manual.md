# Using the gtstats App

## gtstats App Manual

The `gtstats` app is a menu-driven companion to the package. It is
designed for users who want to understand a dataset, create
publication-ready tables, run common group comparisons, and generate
reproducible R code without first memorising every argument.

The app does not replace a reproducible analysis script. Its best use
is:

1.  Load or upload data.
2.  Work through the analysis one tab at a time.
3.  Review the publication-ready result and its audit information.
4.  Copy or download the generated R code.
5.  Run and save that code in RStudio or a Quarto document.

Each analysis includes a **Code** panel with **Copy code** and
**Download .R** buttons. The app is intended to teach the workflow while
making the final analysis reproducible and shareable.

### Launch the app

Install and load gtstats, then run:

``` r

library(gtstats)
gtstats_app()
```

When started from RStudio, the default is the RStudio Viewer. Outside
RStudio, the app opens in a browser during an interactive R session. To
explicitly use your browser:

``` r

gtstats_app(launch.browser = TRUE)
```

To start the local app without opening a window automatically:

``` r

gtstats_app(launch.browser = FALSE)
```

### Close the app safely

While a Shiny app is open, the R console displays text such as:

``` text
Listening on http://127.0.0.1:6783
```

This is normal: R is running the local app server. Use the **Close app**
button in the bottom-right corner of the app to end it cleanly and
return to the R prompt. Avoid interrupting it with RStudio’s Stop
button.

If R ever enters a `Browse[1]>` prompt after an interrupted session,
type:

``` r

Q
```

and press Enter.

### App dependencies

The app is only launched when
[`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
is called, so users who prefer ordinary R code do not need its optional
dependencies.

| Purpose                  | Package                      |
|--------------------------|------------------------------|
| App interface            | `shiny`                      |
| RStudio Viewer support   | `rstudioapi` where available |
| Table display and export | `gt`, `flextable`            |
| Excel upload             | `rio` (optional)             |

For Excel input, install `rio` once:

``` r

install.packages("rio")
```

## Recommended app workflow

The tabs are deliberately ordered to follow a safe statistical workflow.

1.  **Data** — choose a teaching dataset or upload your own data.
2.  **Data Prep** — optionally make safe, reversible changes before
    analysis.
3.  **Understand** — inspect types, completeness, distribution, and
    spread.
4.  **Table 1** — create the descriptive table for a report.
5.  **Compare groups** — answer one focused inferential question.
6.  **Crosstabs** — inspect categorical association and 2×2 measures.
7.  **History** — see which analyses were run during this session.
8.  **Help** — revisit the safe beginner workflow.

The app will not run Table 1, comparisons, or cross-tabs until you press
the relevant action button. This prevents accidental analysis while the
app is loading or while a browser restores an earlier session.

On a phone or narrow screen, use the menu icon in the top-right to open
the full tab list. The numbered workflow strip remains visible below it
and can be swiped sideways; no analysis tab is hidden or removed on
smaller screens.

## Data tab

Use the **Data** tab first. You can select one of three labelled
teaching datasets from one compact dropdown, or upload your own data.
Uploads support CSV, Excel (`.xlsx`/`.xls`), R data (`.rds`), Stata
(`.dta`), and SPSS (`.sav`). Excel, Stata, and SPSS files use the
optional `rio` package.

## Data Prep tab

**Data Prep** is optional. It is for small, auditable changes before
analysis, not a replacement for a full data-management workflow. The
imported dataset is kept unchanged; each action changes an independent
working copy.

The command bar lists every available action explicitly. Click the task
you need, complete the structured fields that appear, then click **Apply
this change**. The current version provides eight common operations:

| Operation | Use it for | Safety check |
|----|----|----|
| Rename variable | Clearer variable names | Blank, duplicate, and invalid R names are rejected |
| Recode values | Give every recorded value a clear label, for example `0/1` to `No/Yes` | The mapping grid shows source and new labels side by side; ordered mode uses the displayed order |
| Set type and order | Make values categorical, ordered categorical, numeric, or text | The display-order grid appears only for ordered categorical values; every level must have one different position |
| Manage missing values | Convert recorded codes such as `999` or `Unknown` to `NA`, or show existing `NA` values as a labelled category | The app reports affected cells and warns that a Missing category changes analysis |
| Create calculation | Adjust one variable, combine two numeric variables, or calculate a ratio with a powered denominator (for example BMI) | Source variables are retained; preview shows usable rows |
| Create groups | Build a two-, three-, or four-group variable from one source variable | Give every group a label; conditions are checked top to bottom and the first match wins |
| Filter observations | Keep records meeting one or two inclusion criteria | A second condition is optional; preview shows kept, excluded, and unknown counts |
| Keep variables | Choose the columns for a smaller analysis dataset | Searchable multi-select, Keep all, and Clear selection controls; Undo restores removed columns |

The **Quick starts** buttons are fill-only helpers. **Age groups**
proposes a two-group age variable using a 65-year cut-off; **0/1 to
No/Yes** opens a matching binary recode when a variable coded exactly
`0` and `1` is found; **BMI-style calculation** sets up
`numerator / (denominator ^ 2)`; and **99/999 to missing** opens the
missing-code workflow. None of these buttons applies a change. They are
deliberately starting points, so verify the selected variable, coding,
units, cut-offs, and labels before pressing **Apply this change**.

For numeric grouping, choose equal to, not equal to, greater/less than,
greater/less than or equal to, **between (inclusive)**, or **outside a
range**. Range rules show a second field for the upper bound. Between
means `x >= lower & x <= upper`; outside means `x < lower | x > upper`.
Both bounds must be numeric, the lower bound cannot exceed the upper
bound, and range rules are unavailable for non-numeric variables. The
preview shows each proposed group’s count and blocks an Apply action if
any group would be empty. The final group is always everyone else, and
rules are evaluated from top to bottom.

Before applying, the panel states the expected impact: for example, how
many values will be recoded, how many codes will become missing, or how
many rows a filter will keep. For recoding, missing-value changes, group
creation, and filtering, it also shows a compact **Before you apply**
table with the exact values or row counts expected to change. The
right-hand preview and the **Change log** update immediately after you
click **Apply this change**. Use **Undo**, **Redo**, or **Reset all** to
reverse work safely.

When an action uses a categorical variable, the panel also shows its
exact recorded values and offers **Copy values**. Recode values creates
a mapping grid with one row per observed value and pre-fills each new
label with its existing value. Edit only the labels that need changing.
This avoids guessing whether a dataset records a value as `Yes`, `yes`,
`Y`, or `1`. Tick **Treat as ordered categorical, in the order shown**
only if that order has a genuine meaning. For numeric variables, it
shows the range, number of unique values, and any short list of observed
values.

When ready, choose one of these deliberately:

- **Continue without changes** makes all later tabs use the original
  data.
- **Use prepared data** makes all later tabs use the working copy.

The **Reusable code** panel records the applied actions. Copy or
download this code and use it as the starting point for a reproducible R
script. Data Prep does not evaluate arbitrary user-supplied R code.

Use **Download prepared data** to save the current working dataset as
CSV, Excel, RDS, or Stata. CSV and RDS work without additional packages;
Excel and Stata export use the optional `rio` package.

The **History** tab also provides **Download complete R script**. It
combines the data import, applied Data Prep changes, and only the
analyses run during that session. For an uploaded file, it uses a clear
file-path placeholder rather than the temporary upload path used by the
app.

| Choice | Best use |
|----|----|
| Birth-weight example | Table 1, independent group comparisons, and 2×2 epidemiology |
| Three-arm trial | Three-group comparisons, rates, and categorical outcomes |
| Paired-data example | Learning the structure of paired analyses |
| Upload a CSV or Excel file | Your own analysis dataset |

### Uploading files

For CSV files, select the file and, if needed, use **Keep text columns
as text**. For Excel files (`.xlsx` or `.xls`), enter a worksheet name
or number when the relevant data are not on the first sheet.

Uploaded data remain in the current browser session only. They are not
written to the package or to a remote server.

### Preview and data dictionary

The **Preview** panel shows the first eight rows. Check it before
proceeding:

- Are column names correct?
- Did numeric variables import as numeric values?
- Are Yes/No and category labels readable?
- Are blank strings actually meaningful categories, or should they be
  recoded?

The **Data dictionary** panel is a concise working overview. It shows
the source name, label, detected type, completeness, number of unique
values, and range or observed levels.

The app displays an observed empty category (`""`) as **`(blank)`** in
tables. This is distinct from missing data (`NA`). It is safe for
exploration, but a meaningful label should usually be created before
final reporting.

### Reusable data code

The bottom code card shows the matching data-loading code. For example,
the birth-weight example generates:

``` r

data("birthwt", package = "gtstats")
data <- birthwt
```

Copy this code first when creating a permanent R script.

## Understand tab

The **Understand** tab has two jobs: give a compact overview of the data
and inspect selected continuous variables before choosing their
descriptive display.

### Describe data

Click **Describe data** to run
[`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md).
The result identifies likely continuous, binary, categorical, ordinal,
and possible coded variables. It also gives completeness and a compact
value summary.

Start here before making a Table 1 or a comparison. In particular,
confirm that a numerical code is really continuous rather than a
category or an ordinal scale.

### Assess distribution

Select one or more continuous variables under **Distribution / spread**,
then optionally choose a grouping variable and click **Assess
distribution**.

The result reports:

- usable observations, missing values, and non-finite values;
- sample skewness and a readable shape band;
- Shapiro-Wilk p-values as supporting information; and
- a suggested descriptive presentation.

The recommendation is for **descriptive reporting**, not test selection.
Shapiro-Wilk is sensitive to sample size; interpret it alongside
skewness, plots, and subject-matter knowledge.

### Show spread by group

Check **Also show spread by group** only when a grouping variable is
selected. The app will also run
[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
and show group SDs, variances, and spread ratios. These are descriptive
diagnostics. They do not impose an equal-variance requirement: Welch
methods are the package’s parametric default for independent groups.

### Code panel

The Understand code card contains the exact
[`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md),
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md),
and, when selected,
[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
calls. Copy this into a script if these checks informed a reporting
decision.

## Table 1 tab

The **Table 1** tab creates a descriptive, publication-ready table.
Think of the left-hand controls as a recipe:

1.  Choose whether to split columns by a group variable.
2.  Tick the variables to include.
3.  Choose the overall column and display style.
4.  Click **Create Table 1**.

### Choose a group

**Group columns by** is optional. Select `low` in the birth-weight
example to create one column per birth-weight outcome. The selected
group is automatically removed from the variable tickboxes; it should
define the columns, not appear as one of the rows.

### Select variables

Tick variables individually, or use **Select all** / **Clear**. You can
mix continuous, binary, categorical, and ordered variables in one
selection. The app calls
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
once and lets gtstats detect their types.

There is no need to separately select “continuous variables” and
“categorical variables.” Use one meaningful set of Table 1 variables.

### Presentation controls

| Control | Meaning |
|----|----|
| Overall column | No overall column, or an Overall column first/last |
| Continuous display | Recommended, mean (SD), mean (95% CI), median (IQR), or both |
| Categorical display | n (%), n/N (%), n only, or percentage only |
| Percentage denominator | Column, row, or the entire dataset |
| Missing values | Show if present, always, or never |
| Decimal places | Number of displayed decimal places |

Choose the percentage denominator intentionally. **Within each column**
answers “what percentage of this group has this level?” and is the usual
Table 1 choice. **Within each row** answers a different question: how a
level is distributed across the displayed groups.

### Add p-values

Check **Add p-values (when grouped)** if a p-value for each selected
variable is appropriate for your table. A grouping variable is required.
The app uses
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
with its documented automatic selection policy. For an analysis plan
that prespecifies tests, use the generated code in RStudio and supply a
named `method` vector.

### Preview, export, and code

Every visible table in the app—data preview, data dictionary, dataset
description, diagnostics, Table 1, comparison audits, crosstabs, and
history—has download buttons for DOCX, HTML, PDF, and RTF. PDF needs a
working browser/webshot setup; DOCX or HTML are the easiest choices for
most users.

Open the **Code** panel to copy or download the complete
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
call, including the display choices you selected. This is the route from
a point-and-click table to a reproducible manuscript table.

## Compare groups tab

Use **Compare groups** for one focused inferential question—not to
replace a descriptive Table 1.

1.  Choose the **Variable to compare** (the outcome).
2.  Choose the categorical **Compare across groups** variable.
3.  Leave **Test** as Auto or explicitly select a planned test.
4.  Optionally request an effect size.
5.  Click **Compare groups**.

Variable and group must be different. The app starts with a sensible
pair in the birth-weight data (`age` by `low`).

### Test control

**Auto** is the recommended starting point when there is no prespecified
test. Its policy is visible in the package documentation and result
notes:

| Data structure | Automatic method |
|----|----|
| Continuous, two independent groups | Welch t-test by default; Student’s t-test when equal variances are explicitly justified; Wilcoxon if marked skew is flagged |
| Continuous, 3+ independent groups | Welch ANOVA by default; classical ANOVA when equal variances are explicitly justified; Kruskal-Wallis if marked skew is flagged |
| Continuous, paired | Paired t-test/Wilcoxon signed-rank for two occasions; repeated-measures ANOVA/Friedman for 3+ occasions |
| Ordinal | Wilcoxon rank-sum or Kruskal-Wallis when independent; Friedman for 3+ paired occasions |
| Binary/nominal categorical | Chi-square when no expected count is below 1 and no more than 20% are below 5; Fisher exact when sparse |
| Binary, paired | McNemar for two occasions; Cochran’s Q for 3+ occasions |

The app also exposes the paired methods: McNemar (two binary occasions),
Cochran’s Q (three or more binary occasions), repeated-measures ANOVA,
and Friedman. Turn on **Repeated measurements from the same
participant** and select the participant ID before running any paired
comparison. Use an explicit choice only when it is justified by the
study design or an analysis plan.

For **Auto**, the app also offers **equal variances are justified**.
This sets `var_equal = TRUE`: it switches only a non-skewed independent
continuous auto comparison to Student’s t-test or classical ANOVA. It
does not perform a variance test and does not alter paired, categorical,
ordinal, or rank-based comparisons.

### Result and Audit panels

The **Result** panel gives the publication-ready comparison table and
explains what auto selected. The **Audit** panels are important:

| Audit tab | What it shows | What you should do |
|----|----|----|
| Diagnostics | Calculated details such as expected counts or distribution context | Check for sparse data and unexpected patterns |
| Assumptions | Automatic checks and design checks | Confirm user-check items from the study design |
| Denominators | Observations used by the calculation | Confirm the analytical population is appropriate |

Use the **Code** panel to retain the exact comparison in your analysis
script.

## Crosstabs tab

Use **Crosstabs** for two categorical variables.

1.  Choose **Rows (exposure)**.
2.  Choose **Columns (outcome)**.
3.  Choose column, row, and/or total percentages.
4.  Choose Auto, chi-square, Fisher exact, or no association test.
5.  Click **Create crosstab**.

For a 2×2 table, the result includes RR, OR, and RD by default, in
addition to the association test and Cramer’s V. For larger R×C tables,
it gives the cross-tab and association statistics, but not 2×2 risk
measures.

If both row and column percentages are selected, cells are labelled so
their denominator is clear. The generated code contains
`percent = c("row", "column")`, which can be reused directly.

## History tab

The **History** tab records actions run during the current app session:

- Describe data
- Assess distribution
- Create Table 1
- Compare groups
- Create crosstab

It is a simple session log, not a permanent audit database. It clears
when the app closes, or when you click **Clear history**. Use it to
orient yourself while exploring; use copied/downloaded code for the
permanent analysis record.

## Help tab

The **Help** tab repeats the safe beginner order:

1.  Inspect the data.
2.  Check selected continuous variables before interpreting comparisons.
3.  Build Table 1 using one consistent presentation per variable.
4.  Use Compare groups for a focused inferential question.
5.  Review the output and generated code before reporting.

## Saving outputs

Every result tab offers table downloads. Use them as follows:

| Format | Good for | Notes |
|----|----|----|
| DOCX | A Word manuscript | Best general choice for reporting |
| HTML | Viewing or sharing in a browser | Preserves the table appearance |
| RTF | Basic word-processing interchange | Useful when DOCX is not required |
| PDF | A fixed-layout copy | Requires a local browser/webshot setup |
| `.R` code | Reproducible analysis | Recommended for every final analysis |

The copy buttons use your browser clipboard. If a browser blocks
clipboard access, use **Download .R** instead.

## Troubleshooting

### The app does not open

``` r

install.packages("shiny")
gtstats_app()
```

If it opens in an external browser and you prefer RStudio, run it from
an interactive RStudio session. You can also choose explicitly:

``` r

gtstats_app(launch.browser = rstudioapi::viewer)
```

### Excel upload gives an error

Install `rio`, restart the app, and try again:

``` r

install.packages("rio")
```

### A table or comparison is blank

Select the variables required by that tab and click its blue action
button. The app intentionally does not calculate Table 1, comparisons,
or crosstabs on startup.

### A variable seems to have the wrong type

Return to **Data** and check the preview and Data dictionary. In your
permanent script, explicitly convert categories to factors and ordered
scales to [`ordered()`](https://rdrr.io/r/base/factor.html) factors.
Numeric clinical codes should not be interpreted as continuous without
checking their meaning.

### I see `(blank)` in a result

The uploaded data contain an observed empty string. This is not an app
error: gtstats displays it safely as `(blank)`. Decide whether it means
“unknown”, “not recorded”, or a true category, then recode it in your
analysis script before final reporting.

### Chrome or a browser crashes

Run the app in the RStudio Viewer where possible. A browser is only
needed for the local interface and, on some systems, PDF export. HTML
and DOCX downloads do not require a browser screenshot engine.

## Best practice

Use the app to learn, explore, and produce a first publication-ready
output. Use the generated R code as the durable record of the analysis.
Before final reporting, ensure that the data preparation, category
meanings, missing-data policy, statistical choices, and exports are
reproducible outside the app.
