sqltargets.env <- new.env()

sqltargets_env <- function() {
  sqltargets.env
}

.onAttach <- function(lib, pkg) {
  jinjar_defaults <- jinjar::default_config()
  sqltargets.env$sqltargets.template_engine <- "glue"
  sqltargets.env$sqltargets.glue_sql_opening_delimiter <- "{"
  sqltargets.env$sqltargets.glue_sql_closing_delimiter <- "}"
  sqltargets.env$sqltargets.jinja_block_open <- jinjar_defaults$block_open
  sqltargets.env$sqltargets.jinja_block_close <- jinjar_defaults$block_close
  sqltargets.env$sqltargets.jinja_comment_open <- jinjar_defaults$comment_open
  sqltargets.env$sqltargets.jinja_comment_close <- jinjar_defaults$comment_close
  sqltargets.env$sqltargets.jinja_variable_open <- jinjar_defaults$variable_open
  sqltargets.env$sqltargets.jinja_variable_close <- jinjar_defaults$variable_close
}
