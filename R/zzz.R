sqltargets.env <- new.env()

sqltargets_env <- function() {
  sqltargets.env
}

.onAttach <- function(lib, pkg) {
  sqltargets.env$sqltargets.target_file_suffix <- "_query_file"
  sqltargets.env$sqltargets.glue_sql_opening_delimiter <- formals(glue::glue)$.open
  sqltargets.env$sqltargets.glue_sql_closing_delimiter <- formals(glue::glue)$.close
}
