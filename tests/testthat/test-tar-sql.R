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
  expect_equal(sort(progress$name), sort(c("data", "report", "query.sql")))
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
  expect_equal(sort(targets::tar_progress()$name), sort(c("data", "report", "query.sql")))
})

targets::tar_test("tar_sql() with glue engine", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(query_params)",
    "select {val} as {col_name}",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "glue")
    list(
      targets::tar_target(params, list(val = 3, col_name = "column1")),
      tar_sql(
        report,
        path = "query.sql",
        params = params
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(column1 = 3))
})

targets::tar_test("tar_sql() with jinjar engine", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(params)",
    "select {{ params.val }} as {{ params.col_name }}",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "jinjar")
    list(
      targets::tar_target(params, list(val = 3, col_name = "column1")),
      tar_sql(
        report,
        path = "query.sql",
        params = params
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(column1 = 3))
})

targets::tar_test("tar_sql() for Jinja for loop", {
  lines <- c(
    "-- !preview conn=DBI::dbConnect(RSQLite::SQLite())",
    "-- tar_load(params)",
    "select",
    "{% for payment_method in params.payment_methods %}",
    "0 as {{ payment_method }}_amount",
    "{% if not loop.is_last %},{% endif %}",
    "{% endfor %}",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "jinjar")
    list(
      targets::tar_target(params, list(payment_methods = c("bank_transfer", "credit_card", "gift_card"))),
      tar_sql(
        report,
        path = "query.sql",
        params = params
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(bank_transfer_amount = 0,
                               credit_card_amount = 0,
                               gift_card_amount = 0))
})
