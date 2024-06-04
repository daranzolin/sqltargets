test_that("sqltargets_option_set() works", {
  sqltargets_option_set("sqltargets.target_file_suffix", "_x_query")
  sqltargets_option_set("sqltargets.glue_sql_opening_delimiter", "<<")
  sqltargets_option_set("sqltargets.glue_sql_closing_delimiter", ">>")
  expect_equal(sqltargets_option_get("sqltargets.target_file_suffix"), "_x_query")
  expect_equal(sqltargets_option_get("sqltargets.glue_sql_opening_delimiter"), "<<")
  expect_equal(sqltargets_option_get("sqltargets.glue_sql_closing_delimiter"), ">>")
})

test_that("different delimiters work", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(query_params)",
    "select @val@ as @col_name@",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    sqltargets_option_set("sqltargets.glue_sql_opening_delimiter", "@")
    sqltargets_option_set("sqltargets.glue_sql_closing_delimiter", "@")
    list(
      targets::tar_target(query_params, list(val = 3, col_name = "column1")),
      tar_sql(
        report,
        path = "query.sql",
        query_params = query_params
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(column1 = 3))
})
