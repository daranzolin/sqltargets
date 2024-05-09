source_sql_to_dataframe <- function(path, query_params = NULL) {

  lines <- readLines(path)
  connection_string <- stringr::str_extract(lines[1], "(?<=\\=).*")
  connection_call <- paste0("con <- ", connection_string)
  eval(parse(text = connection_call))
  on.exit(DBI::dbDisconnect(con))
  delimiters <- strsplit(sqltargets_option_get("sqltargets.glue_sql_delimiters"), "")[[1]]
  open <- delimiters[1]
  close <- delimiters[2]
  query <- lines[2:length(lines)]
  query <- query[!grepl("tar_load", query)]
  query <- paste(query, collapse = " ")
  query <- glue::glue_sql(query, .con = con, .open = open, .close = close, .envir = query_params)
  out <- DBI::dbGetQuery(con, query)
  return(out)

}
