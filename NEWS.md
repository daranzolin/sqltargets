# sqltargets 0.3.0

* Include `tar_read()` support as well as `tar_load()` when parsing deps in sql files by @kiwiroy in https://github.com/daranzolin/sqltargets/pull/25
* Add support for `DBI::dbBind()` placeholder parameters by @kiwiroy in https://github.com/daranzolin/sqltargets/pull/24

## New Contributors
* @kiwiroy made their first contribution in https://github.com/daranzolin/sqltargets/pull/25

**Full Changelog**: https://github.com/daranzolin/sqltargets/compare/v0.2.1...v0.3.0

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
