# Citing gtstats

## Citation

If `gtstats` contributes to an analysis, table, teaching resource,
report, or publication, please cite the package as:

> Polani R, Kaviprawin M, Sakthivel M, Eliyas SK, Krishnamoorthy Y
> (2026). *gtstats: Beginner-Friendly Statistics and Publication-Ready
> Tables*. R package version 1.0.0.
> <https://gtstats.thinkdenominator.com/>.

R returns the authoritative citation installed with the package:

``` r

citation("gtstats")
#> To cite package 'gtstats' in publications use:
#> 
#>   Polani R, Kaviprawin M, Sakthivel M, Eliyas S, Krishnamoorthy Y
#>   (2026). _gtstats: Beginner-Friendly Statistics and Publication-Ready
#>   Tables_. R package version 1.0.0,
#>   <https://gtstats.thinkdenominator.com/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {gtstats: Beginner-Friendly Statistics and Publication-Ready Tables},
#>     author = {Rubeshkumar Polani and Mogan Kaviprawin and Manikandanesan Sakthivel and Salin K Eliyas and Yuvaraj Krishnamoorthy},
#>     year = {2026},
#>     note = {R package version 1.0.0},
#>     url = {https://gtstats.thinkdenominator.com/},
#>   }
```

## BibTeX

Copy this record into a `.bib` file when using Zotero, EndNote, LaTeX,
Quarto, R Markdown, or another reference manager:

``` bibtex
@Manual{gtstats,
  title  = {gtstats: Beginner-Friendly Statistics and Publication-Ready Tables},
  author = {Rubeshkumar Polani and Mogan Kaviprawin and Manikandanesan Sakthivel and Salin K Eliyas and Yuvaraj Krishnamoorthy},
  year   = {2026},
  note   = {R package version 1.0.0},
  url    = {https://gtstats.thinkdenominator.com/}
}
```

A DOI has been reserved for the Zenodo software record. It will be added
to the recommended citation after the record is published and resolves
publicly.

The citation can also be exported directly from R:

``` r

toBibtex(citation("gtstats"))
```

## Reproducibility

Report the package version used in the analysis. It can be checked with:

``` r

packageVersion("gtstats")
#> [1] '1.0.0'
```

For a full reproducibility record, include the output of
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) or
[`sessioninfo::session_info()`](https://sessioninfo.r-lib.org/reference/session_info.html)
with the analysis materials.
