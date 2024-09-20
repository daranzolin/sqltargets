source_sql_to_dataframe <- function(path, params = NULL) {

  connection_string <- stringr::str_extract(readr::read_lines(path, n_max = 1), "(?<=\\=).*")
  connection_call <- paste0("con <- ", connection_string)
  rlang::eval_bare(rlang::parse_expr(connection_call))
  on.exit(DBI::dbDisconnect(con))
  query <- readr::read_file(path)
  template_engine <- sqltargets_option_get("sqltargets.template_engine")
  if (template_engine == "jinjar") {
    query <- jinjar::render(
      query,
      params = params,
      .config = jinjar::jinjar_config(
        block_open = sqltargets_option_get("sqltargets.jinja_block_open"),
        block_close = sqltargets_option_get("sqltargets.jinja_block_close"),
        variable_open = sqltargets_option_get("sqltargets.jinja_variable_open"),
        variable_close = sqltargets_option_get("sqltargets.jinja_variable_close"),
        comment_open = sqltargets_option_get("sqltargets.jinja_comment_open"),
        comment_close = sqltargets_option_get("sqltargets.jinja_comment_close"),
      )
    )
  } else {
    query <- glue::glue_data_sql(
      params,
      query,
      .con = con,
      .open = sqltargets_option_get("sqltargets.glue_sql_opening_delimiter"),
      .close = sqltargets_option_get("sqltargets.glue_sql_closing_delimiter")
    )
  }
  out <- DBI::dbGetQuery(con, query)
  msg <- glue::glue("{basename(path)} executed:\n Rows: {nrow(out)}\n Columns: {ncol(out)}")
  cli::cli_alert_success(msg)
  return(out)

}
