source_sql_to_dataframe <- function(path, query_params = NULL) {

  connection_string <- stringr::str_extract(readr::read_lines(path, n_max = 1), "(?<=\\=).*")
  connection_call <- paste0("con <- ", connection_string)
  eval(parse(text = connection_call))
  on.exit(DBI::dbDisconnect(con))
  open <- sqltargets_option_get("sqltargets.glue_sql_opening_delimiter")
  close <- sqltargets_option_get("sqltargets.glue_sql_closing_delimiter")
  query <- readr::read_file(path)
  query <- glue::glue_sql(query, .con = con, .open = open, .close = close, .envir = query_params)
  out <- DBI::dbGetQuery(con, query)
  msg <- glue::glue("{basename(path)} executed:\n Rows: {nrow(out)}\n Columns: {ncol(out)}")
  cli::cli_alert_success(msg)
  return(out)

}
