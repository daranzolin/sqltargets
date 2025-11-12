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

targets::tar_test("tar_sql() with positional dbBind DBI engine", {
  db_file <- normalizePath(tempfile(pattern = "sqlite", fileext = ".db"), winslash = "/", mustWork = FALSE)
  lines <- c(
    glue::glue("-- !preview conn=DBI::dbConnect(RSQLite::SQLite(), dbname = \"{db_file}\")"),
    "-- tar_load(create_iris_table)",
    "select distinct(species) as wide_petals from iris where [Petal.Width] > ?",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "dbi")
    list(
      tar_target(test_db_file, db_file),
      tar_target(create_iris_table, {
        conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = test_db_file)
        on.exit(DBI::dbDisconnect(conn), after = TRUE)
        DBI::dbWriteTable(conn, 'iris', iris)
        TRUE
      }),
      tar_sql(
        report,
        path = "query.sql",
        params = list(2.3)
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(wide_petals = "virginica"))
})

targets::tar_test("tar_sql() with named dbBind DBI engine", {
  db_file <- normalizePath(tempfile(pattern = "sqlite", fileext = ".db"), winslash = "/", mustWork = FALSE)
  lines <- c(
    glue::glue("-- !preview conn=DBI::dbConnect(RSQLite::SQLite(), dbname = \"{db_file}\")"),
    "-- tar_load(create_iris_table)",
    "select distinct(species) as short_petals from iris where [Petal.Length] < $petal_length",
    ""
  )
  writeLines(lines, "named_ph_dollar.sql")
  lines <- c(
    glue::glue("-- !preview conn=DBI::dbConnect(RSQLite::SQLite(), dbname = \"{db_file}\")"),
    "-- tar_load(create_iris_table)",
    "select distinct(species) as short_petals from iris where [Petal.Length] < :petal_length",
    ""
  )
  writeLines(lines, "named_ph_colon.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "dbi")
    list(
      tar_target(test_db_file, db_file),
      tar_target(create_iris_table, {
        conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = test_db_file)
        on.exit(DBI::dbDisconnect(conn), after = TRUE)
        DBI::dbWriteTable(conn, 'iris', iris)
        TRUE
      }),
      tar_sql(
        report,
        path = "named_ph_dollar.sql",
        params = list(petal_length=1.5)
      ),
      tar_sql(
        report2,
        path = "named_ph_colon.sql",
        params = data.frame(petal_length=1.5)
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(short_petals = "setosa"))
  out2 <- targets::tar_read(report2)
  expect_equal(out2, data.frame(short_petals = "setosa"))
})

targets::tar_test("tar_sql() with dbBind DBI engine empty params", {
  db_file <- normalizePath(tempfile(pattern = "sqlite", fileext = ".db"), winslash = "/", mustWork = FALSE)
  lines <- c(
    glue::glue("-- !preview conn=DBI::dbConnect(RSQLite::SQLite(), dbname = \"{db_file}\")"),
    "-- tar_load(create_iris_table)",
    "select count(*) as row_count from iris"
  )
  writeLines(lines, "count_query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "dbi")
    list(
      tar_target(test_db_file, db_file),
      tar_target(create_iris_table, {
        conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = test_db_file)
        on.exit(DBI::dbDisconnect(conn), after = TRUE)
        DBI::dbWriteTable(conn, 'iris', iris)
        TRUE
      }),
      tar_sql(
        report,
        path = "count_query.sql",
        params = list()
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(row_count = 150))
})

targets::tar_test("tar_sql() with indexed dbBind DBI engine", {
  db_file <- normalizePath(tempfile(pattern = "sqlite", fileext = ".db"), winslash = "/", mustWork = FALSE)
  lines <- c(
    glue::glue("-- !preview conn=DBI::dbConnect(RSQLite::SQLite(), dbname = \"{db_file}\")"),
    "-- tar_load(create_iris_table)",
    "select species from iris where [Sepal.Length] > $1 and [Petal.Width] < $2 and [Sepal.Width] < $1",
    ""
  )
  writeLines(lines, "query.sql")
  targets::tar_script({
    library(sqltargets)
    sqltargets_option_set("sqltargets.template_engine", "dbi")
    list(
      tar_target(test_db_file, db_file),
      tar_target(create_iris_table, {
        conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = test_db_file)
        on.exit(DBI::dbDisconnect(conn), after = TRUE)
        DBI::dbWriteTable(conn, 'iris', iris)
        TRUE
      }),
      tar_sql(
        report,
        path = "query.sql",
        params = list(5.0, 1.0)
      )
    )
  })
  suppressMessages(targets::tar_make(callr_function = NULL))
  out <- targets::tar_read(report)
  expect_equal(out, data.frame(Species = rep("setosa", 22)))
})
