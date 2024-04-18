targets::tar_test("tar_sql() works", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(data)",
    "select 1 as my_col",
    ""
    )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    list(
      targets::tar_target(data, mtcars),
      tar_sql(report, path = "query.sql")
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  progress <- targets::tar_progress()
  progress <- progress[progress$progress != "skipped", ]
  expect_equal(sort(progress$name), sort(c("data", "report", "report_query_file")))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(my_col = 1))
  # Should not rerun the query.
  suppressMessages(targets::tar_make(callr_function = NULL))
  progress <- targets::tar_progress()
  progress <- progress[progress$progress != "skipped", ]
  expect_equal(nrow(progress), 0L)
  targets::tar_script({
    list(
      targets::tar_target(data, iris),
      tar_sql(report, path = "query.sql")
    )
  })
  # Should rerun the query
  suppressMessages(targets::tar_make(callr_function = NULL))
  expect_equal(sort(targets::tar_progress()$name), sort(c("data", "report", "report_query_file")))
})

targets::tar_test("tar_sql() for parameterized queries", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(query_params)",
    "select {val} as {col_name}",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    list(
      tar_target(query_params, list(val = 3, col_name = "column1")),
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
