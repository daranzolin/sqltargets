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
#'  - `"sqltargets.jinja_block_open"` - character. Length 1. The opening delimiter passed to `jinjar::jinjar_config()`.
#'  - `"sqltargets.jinja_block_close"` - character. Length 1. The closing delimiter passed to `jinjar::jinjar_config()`.
#'  - `"sqltargets.jinja_variable_open"` - character. Length 1. The closing delimiter passed to `jinjar::jinjar_config()`.
#'  - `"sqltargets.jinja_variable_close"` - character. Length 1. The closing delimiter passed to `jinjar::jinjar_config()`.
#'  - `"sqltargets.jinja_comment_open"` - character. Length 1. The closing delimiter passed to `jinjar::jinjar_config()`.
#'  - `"sqltargets.jinja_comment_close"` - character. Length 1. The closing delimiter passed to `jinjar::jinjar_config()`.
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
