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
#'        '<target name> `getOption("sqltargets.target_file_suffix")`'.
#' @return A data frame
#' @inheritParams targets::tar_target_raw
#' @param path Character of length 1 to the single `*.sql` source file to be executed.
#'   Defaults to the working directory of the `targets` pipeline.
#' @param query_params A named list of parameters for parameterized queries.
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
tar_sql_raw <- function(
    name,
    path = ".",
    query_params = query_params,
    format = format,
    error = targets::tar_option_get("error"),
    memory = targets::tar_option_get("memory"),
    garbage_collection = targets::tar_option_get("garbage_collection"),
    deployment = "main",
    priority = targets::tar_option_get("priority"),
    resources = targets::tar_option_get("resources"),
    retrieval = targets::tar_option_get("retrieval"),
    cue = targets::tar_option_get("cue"),
    deps = deps
) {
  targets::tar_assert_scalar(name)
  targets::tar_assert_chr(name)
  targets::tar_assert_nzchar(name)
  targets::tar_assert_file(path)
  targets::tar_assert_lang(query_params)
  targets::tar_assert_not_expr(query_params)

  file_command <- tar_sql_file_command(path = path)
  file_dep <- paste0(name, "_query_file")

  query_command <- tar_sql_command(
    path = path,
    query_params = query_params,
    file_dep = file_dep
  )

  # Upstream target to track file
  target_file <- targets::tar_target_raw(
    name = file_dep,
    command = file_command,
    format = "file",
    repository = "local",
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    retrieval = retrieval,
    cue = cue
  )

  # downstream target
  deps <- sort(unique(sql_deps(path)))
  target_output <- targets::tar_target_raw(
    name = name,
    command = query_command,
    format = format,
    repository = "local",
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    retrieval = retrieval,
    cue = cue,
    deps = c(deps, file_dep)
  )

  tar_sql_target_list(
    target_file = target_file,
    target_output = target_output
  )
}

tar_sql_file_command <- function(path) {
  args <- substitute(
    list(path = path),
    env = list(path = path)
  )
  fun <- call_ns("sqltargets", "tar_sql_file")
  expr <- list(
    fun,
    args
  )
  as.expression(as.call(expr))
}

tar_sql_command <- function(
    path,
    query_params,
    file_dep
) {
  args <- substitute(
    list(
      path = path,
      query_params = query_params
    ),
    env = list(
      path = path,
      query_params = query_params
    )
  )
  deps <- c(sort(unique(sql_deps(path))), file_dep)
  deps <- call_list(as_symbols(deps))
  fun <- call_ns("sqltargets", "tar_sql_exec")
  expr <- list(
    fun,
    args = args,
    deps = deps
  )
  as.expression(as.call(expr))
}

#' @title Execute a SQL query.
#' @description Internal function needed for `tar_sql()`.
#'   Users should not invoke it directly.
#' @export
#' @keywords internal
#' @return a data frame.
#' @param path Path to the SQL query.
#' @param args A named list of arguments to `glue::glue_sql()`.
#' @param deps An unnamed list of target dependencies of the R Markdown
#'   report, automatically created by `tar_sql_deps()`.
tar_sql_exec <- function(args, deps) {
  rm(deps)
  gc()
  args <- args[!purrr::map_lgl(args, is.null)]
  do.call(what = source_sql_to_dataframe, args = args)
}

#' @title Define upstream SQL file dep.
#' @description Internal function needed for `tar_sql()`.
#'   Users should not invoke it directly.
#' @export
#' @keywords internal
#' @return a relative file path.
#' @param path Path to the SQL query.
tar_sql_file <- function(args) {
  gc()
  do.call(what = fs::path_rel, args)
}
