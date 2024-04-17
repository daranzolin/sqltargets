targets::tar_test("tar_sql_deps() works", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(data1)",
    "-- tar_load(data2)",
    "select 1 as my_col",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    list(
      targets::tar_target(data1, mtcars),
      targets::tar_target(data2, iris),
      tar_sql(report, path = "query.sql")
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- tar_sql_deps("query.sql")
  expect_equal(out, c("data1", "data2"))
})
