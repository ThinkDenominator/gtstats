# gtstats 1.0.0

* `compare_groups()` now has a public `var_equal` argument. The default remains
  `FALSE`, retaining Welch t-tests and Welch ANOVA for suitable independent
  continuous automatic comparisons. Set `var_equal = TRUE` only for a
  prespecified equal-variance assumption; it selects Student's t-test or
  classical ANOVA and is never inferred using a variance hypothesis test.
* `add_p()` and `plot_compare(show_p = TRUE)` now forward `var_equal` to the
  same comparison engine, so their selected methods remain consistent.
