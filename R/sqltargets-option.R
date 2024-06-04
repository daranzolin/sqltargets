#' Get or Set sqltargets Options
#'
#' @param option_name Character. Option name. See Details.
#' @param option_value Value to assign to option `x`.
#'
#' @return No return value, called for side effects
#'
#' @details
#'
#' ## Available Options
#'
#'  - `"sqltargets.target_file_suffix"` - character. Length 1. Suffix appended to target name for SQL file dependency.
#'  - `"sqltargets.glue_sql_opening_delimiter"` - character. Length 1. Two characters. The opening delimiter passed to `glue::glue_sql()`.
#'  - `"sqltargets.glue_sql_closing_delimiter"` - character. Length 1. Two characters. The closing delimiter passed to `glue::glue_sql()`.
#' @rdname sqltargets-options
#' @export
sqltargets_option_get <- function(option_name) {
  option_value <- sqltargets_env()[[option_name]]
  getOption(option_name, default = option_value)
}

#' @rdname sqltargets-options
#' @export
sqltargets_option_set <- function(option_name, option_value) {
  sqltargets.env[[option_name]] <- option_value
}
