#' Get or Set sqltargets Options
#'
#' @param option_name Character. Option name. See Details.
#'
#' @details
#'
#' ## Available Options
#'
#'  - `"sqltargets.target_file_suffix"` - character. Length 1. Suffix appended to target name for SQL file dependency
#' @rdname sqltargets-options
#' @export
sqltargets_option_get <- function(option_name) {
  option_value <- sqltargets_env()[[option_name]]
  getOption(option_name, default = option_value)
}

#' @param option_value Value to assign to option `x`.
#' @rdname sqltargets-options
#' @export
sqltargets_option_set <- function(option_name, option_value) {
  sqltargets.env[[option_name]] <- option_value
}
