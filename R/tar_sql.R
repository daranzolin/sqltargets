#' @title Target with a SQL query.
#' @export
#' @description Shorthand to include a SQL query in a
#'   `targets` pipeline.
#' @details `tar_sql()` is an alternative to `tar_target()` for
#'   SQL queries
#'   that depend on upstream targets. The SQL
#'   source files (`*.sql` files)
#'   should mention dependency targets with `tar_load()`
#'   within SQL comments ('--').
#'   (Do not use `tar_load_raw()` or `tar_read_raw()` for this.)
#'   Then, `tar_sql()` defines a special kind of target. It
#'     1. Finds all the `tar_load()`/`tar_read()` dependencies in the
#'       query and inserts them into the target's command.
#'       This enforces the proper dependency relationships.
#'       (Do not use `tar_load_raw()` or `tar_read_raw()` for this.)
#'     2. Sets `format = "file"` (see `tar_target()`) so `targets`
#'       watches the files at the returned paths and reruns the query
#'       if those files change.
#'     3. Creates another upstream target to watch the query file for changes
#'        '<target name> `sqltargets_option_get("sqltargets.target_file_suffix")`'.
#' @return A data frame
#' @inheritParams targets::tar_target
#' @inheritParams tar_sql_raw
#' @param params Code, can be `NULL`.
#'   `params` evaluates to a named list of parameters
#'   that are passed to `jinjar::render()`. The list is quoted
#'   (not evaluated until the target runs)
#'   so that upstream targets can serve as parameter values.
#' @examples
#' targets::tar_dir({  # tar_dir() runs code from a temporary directory.
#'   # Unparameterized SQL query:
#'   lines <- c(
#'     "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
#'     "-- targets::tar_load(data1)",
#'     "-- targets::tar_load(data2)",
#'     "select 1 AS my_col",
#'     ""
#'   )
#'   # In tar_dir(), not part of the user's file space:
#'   writeLines(lines, "query.sql")
#'   # Include the query in a pipeline as follows.
#'   targets::tar_script({
#'     library(tarchetypes)
#'     library(sqltargets)
#'     list(
#'       tar_sql(query, path = "query.sql")
#'     )
#'   }, ask = FALSE)
#' })
tar_sql <- function(name,
                    path,
                    params = list(),
                    format = targets::tar_option_get("format"),
                    tidy_eval = targets::tar_option_get("tidy_eval"),
                    repository = targets::tar_option_get("repository"),
                    iteration = targets::tar_option_get("iteration"),
                    error = targets::tar_option_get("error"),
                    memory = targets::tar_option_get("memory"),
                    garbage_collection = targets::tar_option_get("garbage_collection"),
                    deployment = targets::tar_option_get("deployment"),
                    priority = targets::tar_option_get("priority"),
                    resources = targets::tar_option_get("resources"),
                    storage = targets::tar_option_get("storage"),
                    retrieval = targets::tar_option_get("retrieval"),
                    cue = targets::tar_option_get("cue")) {

  check_pkg_installed("DBI")
  check_pkg_installed("glue")

  name <- targets::tar_deparse_language(substitute(name))
  params <- targets::tar_tidy_eval(
    expr = substitute(params),
    envir = targets::tar_option_get("envir"),
    tidy_eval = tidy_eval
  )

  tar_sql_raw(
    name = name,
    path = path,
    params = params,
    format = format,
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    retrieval = retrieval,
    cue = cue
  )
}
