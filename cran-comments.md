## Resubmission

This is a resubmission. In response to CRAN's review:

* The relative `LICENSE.md` link in `README.md` was replaced with a stable public
  MIT licence URL, so the README no longer refers to a file excluded from the
  source package.
* References for the principal statistical methods were added to the
  `Description` field in `Authors (year) <doi:...>` format.

## Test environments

* Local: R 4.6.0, aarch64-apple-darwin23, macOS Tahoe 26.5.2
* `R CMD check --as-cran`

## R CMD check results

0 errors | 0 warnings | 2 notes

The first note is expected for a first submission:

* New submission

The second note is local-environment specific:

* HTML validation was skipped because the installed HTML Tidy was not recent
  enough. The HTML manual was generated successfully; this does not indicate a
  package error.

## Submission notes

This is the first CRAN submission of gtstats and a resubmission following CRAN
review.

The package provides beginner-friendly descriptive and inferential statistical
workflows and publication-ready tables. Automatic test selection is documented
explicitly, retained in result metadata, and can be overridden by the user.

There are no downstream dependencies to check.
