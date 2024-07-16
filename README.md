
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sqltargets

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/daranzolin/sqltargets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/daranzolin/sqltargets/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/sqltargets)](https://CRAN.R-project.org/package=sqltargets)
[![](https://cranlogs.r-pkg.org/badges/sqltargets)](https://cran.r-project.org/package=sqltargets)
[![R
Targetopia](https://img.shields.io/badge/R_Targetopia-member-blue?style=flat&labelColor=gray)](https://wlandau.github.io/targetopia/)

<!-- badges: end -->

sqltargets makes it easy to integrate SQL files within your [targets
workflows.](https://github.com/ropensci/targets) The shorthand
`tar_sql()` creates two targets: (1) the ‘upstream’ SQL file; and (2)
the ‘downstream’ result of the query. Dependencies can be specified by
calling `tar_load()` within SQL comments. Parameters and [‘Jinja’
SQL](https://docs.getdbt.com/guides/using-jinja?step=3) can be
customized within the query.

## Installation

You can install sqltargets from CRAN with:

``` r
install.packages("sqltargets")
```

You can install the development version of sqltargets with:

``` r
remotes::install_github("daranzolin/sqltargets)
```

## Example

``` r
library(targets)
#> Warning: package 'targets' was built under R version 4.2.2
library(sqltargets)

tar_dir({  # 
# Unparameterized SQL query:
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "select 1 AS my_col",
    ""
  )
  writeLines(lines, "query.sql")
# Include the query in a pipeline as follows.
  tar_script({
    library(sqltargets)
    list(
      tar_sql(query, path = "query.sql")
      )
    }, ask = FALSE)
  })
```

## Specifying dependencies

Use `tar_load` or `targets::tar_load` within a SQL comment to indicate
query dependencies. Check the dependencies of any query with
`tar_sql_deps`.

``` r
lines <- c(
   "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
   "-- targets::tar_load(data1)",
   "-- targets::tar_load(data2)",
   "select 1 AS my_col",
   ""
 )
 query <- tempfile()
 writeLines(lines, query)
 tar_sql_deps(query)
#> [1] "data1" "data2"
```

## Parameters and Jinja

Generate parameters elsewhere and then use ‘Jinja’ and SQL together by
passing a named list to the `params` argument in `tar_sql()`.

`query.sql`

``` sql
-- !preview conn=pkgx::connect_to_some_db()
select
order_id,
{% for payment_method in params.payment_methods %}
sum(case when payment_method = '{{payment_method}}' then amount end) as {{payment_method}}_amount
{% if not loop.last %},{% endif %}
{% endfor %}
from payments
group by 1
```

`_targets.R`

``` r
library(targets)
library(sqltargets)

list(
  tar_target(payment_methods, list(payment_methods = c("bank_transfer", "credit_card", "gift_card"))),
  tar_sql(report, "query.sql", params = payment_methods)
)
```

![](inst/tar_glimpse.png)

## Code of Conduct

Please note that the sqltargets project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Acknowledgement

Much of the code has been adapted from [the excellent tarchetypes
package.](https://github.com/ropensci/tarchetypes) Special thanks to the
authors and Will Landau in particular for revolutionizing data pipelines
in R.
