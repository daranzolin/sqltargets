# sqltargets (dev)

* Included 'jinjar' as a dependency, allowing jinja-like SQL queries
* Breaking change: `query_params` argument in `tar_sql()` is now `params`.
* Additional tests

# sqltargets 0.1.0

* Added two additional options for the opening and closing delimiters.
* Upstream target name is now the file basename.
* Bug fix: readr::read_file correctly parses query file

# sqltargets 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* Added an initial batch of tests.
