test_that("sqltargets_option_set() works", {
  sqltargets_option_set("sqltargets.jinja_block_open", "<<")
  sqltargets_option_set("sqltargets.jinja_block_close", ">>")
  expect_equal(sqltargets_option_get("sqltargets.jinja_block_open"), "<<")
  expect_equal(sqltargets_option_get("sqltargets.jinja_block_close"), ">>")
})

targets::tar_test("different delimiters work", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(params)",
    "select [[params.val]] as [[params.col_name]]",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    sqltargets_option_set("sqltargets.template_engine", "jinjar")
    sqltargets_option_set("sqltargets.jinja_variable_open", "[[")
    sqltargets_option_set("sqltargets.jinja_variable_close", "]]")
    list(
      targets::tar_target(params, list(val = 3, col_name = "column1")),
      tar_sql(
        report,
        path = "query.sql",
        params = params
      )
    )
  }, ask = FALSE)
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(column1 = 3))
})
