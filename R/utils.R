# From https://github.com/njtierney/geotargets/blob/8ad4e66b2e2f2373a6237e5b4d8092a7711e6da3/R/utils.R#L8-L15
check_pkg_installed <- function(pkg, call = rlang::caller_env()) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort(
      message = "package {.pkg {pkg}} is required",
      call = call
    )
  }
}

# From https://github.com/ropensci/tarchetypes/blob/9de10e666d114c14d48fc8af0311b7588d16585d/R/utils_language
call_list <- function(args) {
  call_function("list", args)
}

as_symbols <- function(x) {
  lapply(x, as.symbol)
}
call_ns <- function(pkg, fun) {
  call_function("::", as_symbols(c(pkg, fun)))
}

call_function <- function(name, args) {
  as.call(c(as.symbol(name), args))
}

sql_deps <- function(path) {
  expr <- sql_expr(path)
  tarchetypes::walk_ast(expr, walk_call_sql)
}

sql_expr <- function(path) {
  tryCatch( {
    text <- sql_lines(path)
    text <- text[grepl("tar_load", text)]
    parse(text = text)
  },
    error = function(e) {
      targets::tar_throw_validate(
        "Could not parse SQL query ",
        path,
        " to detect dependencies: ",
        conditionMessage(e)
      )
    }
  )
}

sql_expr_warn_raw <- function(expr) {
  vars <- all.vars(expr, functions = TRUE)
  if (any(c("tar_load_raw", "tar_read_raw") %in% vars)) {
    targets::tar_warn_validate(
      "targets loaded with tar_load_raw() or tar_read_raw() ",
      "will not be detectd as dependencies in literate programming reports. ",
      "To properly register target dependencies of reports, use tar_load() ",
      "or tar_read() instead."
    )
  }
}

sql_lines <- function(path) {
  handle <- basename(tempfile())
  connection <- textConnection(handle, open = "w", local = TRUE)
  on.exit(close(connection))

  withr::with_options(
    new = list(),
    code = writeLines(readLines(path), con = connection)
  )
  textConnectionValue(connection)
}

walk_call_sql <- function(expr, counter) {
  name <- targets::tar_deparse_safe(expr[[1]], backtick = FALSE)
  if (any(name %in% paste0(c("", "targets::", "targets:::"), "tar_load"))) {
    walk_load(expr, counter)
  }
  if (any(name %in% paste0(c("", "targets::", "targets:::"), "tar_read"))) {
    walk_read(expr, counter)
  }
}

walk_load <- function(expr, counter) {
  expr <- match.call(targets::tar_load, as.call(expr))
  if (is.null(expr$names)) {
    targets::tar_warn_validate(
      "Found empty tar_load() call in SQL query ",
      "comment. Dependencies cannot be detected statically, ",
      "so they will be ignored."
    )
  }
  walk_target_name(expr$names, counter)
}

walk_read <- function(expr, counter) {
  expr <- match.call(targets::tar_read, as.call(expr))
  if (is.null(expr$name)) {
    targets::tar_warn_validate(
      "Found empty tar_read() call in a SQL query ",
      "comment. Dependencies cannot be detected statically, ",
      "so they will be ignored."
    )
  }
  walk_target_name(expr$name, counter)
}

walk_target_name <- function(expr, counter) {
  if (!length(expr)) {
    return()
  } else if (is.name(expr)) {
    tarchetypes::counter_set_names(counter, as.character(expr))
  } else if (is.character(expr)) {
    tarchetypes::counter_set_names(counter, expr)
  } else if (is.pairlist(expr) || is.recursive(expr) || is.call(expr)) {
    walk_tidyselect(expr, counter)
  }
}

walk_tidyselect <- function(expr, counter) {
  if (is.call(expr)) {
    name <- targets::tar_deparse_safe(expr[[1]], backtick = FALSE)
    if (name %in% tidyselect_names()) {
      targets::tar_warn_validate(
        "found ", name, "() from tidyselect in a call to tar_load() or ",
        "tar_read() in a SQL query comment. These dependencies ",
        "cannot be detected statically, so they will be ignored."
      )
      return()
    }
    expr <- expr[-1]
  }
  lapply(expr, walk_target_name, counter = counter)
}

tidyselect_names <- function() {
  tidyselect <- c(
    "all_of",
    "any_of",
    "contains",
    "ends_with",
    "everything",
    "last_col",
    "matches",
    "num_range",
    "one_of",
    "starts_with"
  )
  out <- c(tidyselect, paste0("tidyselect::", tidyselect))
  c(out, paste0("tidyselect:::", tidyselect))
}
