source_sql_to_dataframe <- function(path, query_params = NULL) {

  connection_string <- stringr::str_extract(readr::read_lines(path, n_max = 1), "(?<=\\=).*")
  connection_call <- paste0("con <- ", connection_string)
  eval(parse(text = connection_call))
  on.exit(DBI::dbDisconnect(con))
  delimiters <- strsplit(sqltargets_option_get("sqltargets.glue_sql_delimiters"), "")[[1]]
  open <- delimiters[1]
  close <- delimiters[2]
  query <- readr::read_file(path)
  query <- glue::glue_sql(query, .con = con, .open = open, .close = close, .envir = query_params)
  out <- DBI::dbGetQuery(con, query)
  msg <- glue::glue("{basename(path)} executed:\n Rows: {nrow(out)}\n Columns: {ncol(out)}")
  cli::cli_alert_success(msg)
  return(out)

}
