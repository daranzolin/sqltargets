#' @title List SQL query dependencies.
#' @export
#' @family SQL query utilities
#' @description List the target dependencies of one or more SQL queries.
#' @return Character vector of the names of targets
#'   that are dependencies of the SQL query.
#' @param path Character vector, path to one or more SQL queries.
#' @examples
#' lines <- c(
#'   "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
#'   "-- targets::tar_load(data1)",
#'   "-- targets::tar_read(data2)",
#'   "select 1 as my_col",
#'   ""
#' )
#' query <- tempfile()
#' writeLines(lines, query)
#' tar_sql_deps(query)
tar_sql_deps <- function(path) {
  targets::tar_assert_path(path)
  targets::tar_assert_not_dirs(path)
  sort(unique(unlist(purrr::map(path, sql_deps))))
}
