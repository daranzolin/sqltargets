# sqltargets 0.2.1

* Uses glue::glue_data_sql instead of glue::glue_sql to avoid passing a list as .envir via @jennybc.

# sqltargets 0.2.0

* Included 'jinjar' as a dependency, allowing jinja-like SQL queries.
* New option `sqltargets.template_engine` (either 'glue' or 'jinjar').
* Breaking change: `query_params` argument in `tar_sql()` is now `params`.
* Additional tests
* `params` object name now recognized as an upstream dependency.

# sqltargets 0.1.0

* Added two additional options for the opening and closing delimiters.
* Upstream target name is now the file basename.
* Bug fix: readr::read_file correctly parses query file

# sqltargets 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* Added an initial batch of tests.
