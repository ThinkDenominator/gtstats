# Archived weekly US hospital-admission surveillance data

A teaching extract from CDC's archived weekly United States COVID-19
hospital-admission surveillance dataset. It contains one record per
health service area for the report dated 12 January 2024. The CDC county
file repeats the same area-level metrics for each constituent county;
this copy retains one exact metric record per health service area to
prevent double counting. Names and labels were simplified, dates were
parsed, and the source spelling `Insuficient Data` was corrected in the
factor label.

## Usage

``` r
surveillance_data
```

## Format

A data frame with 808 rows and 9 variables:

- health_service_area_id:

  CDC health service area identifier.

- population:

  Health service area population used as denominator.

- report_date:

  CDC report date.

- week_end_date:

  End date of the surveillance week.

- mmwr_week:

  MMWR epidemiological week.

- mmwr_year:

  MMWR year.

- admissions:

  Weekly confirmed COVID-19 hospital admissions.

- admissions_per_100k:

  CDC-published weekly rate per 100,000.

- admission_level:

  CDC admission-level category.

Two areas have insufficient admission data and therefore missing counts
and rates. The archived values are provisional teaching data and should
not be used to describe current disease activity.

## Source

CDC, [Weekly United States COVID-19 Hospitalization Metrics by County -
ARCHIVED](https://data.cdc.gov/d/akn2-qxic), dataset `akn2-qxic`. The
metadata identifies this dataset as `USGOV_WORKS`; it is available
without charge. CDC does not endorse gtstats. See the CDC [agency
materials policy](https://www.cdc.gov/other/agencymaterials.html).

## Examples

``` r
# \donttest{
complete_surveillance <- subset(surveillance_data, !is.na(admissions))
epi_table(
  complete_surveillance,
  numerator = admissions,
  denominator = population,
  label = admission_level,
  measure = "incidence_rate",
  multiplier = 100000
)
# }
```
