sqltargets.env <- new.env()

sqltargets_env <- function() {
  sqltargets.env
}

.onAttach <- function(lib, pkg) {
  sqltargets.env$sqltargets.target_file_suffix <- "_query_file"
  sqltargets.env$sqltargets.glue_sql_delimiters <- "{}"
}
