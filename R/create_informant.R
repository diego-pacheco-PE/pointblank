#
#                _         _    _      _                _    
#               (_)       | |  | |    | |              | |   
#  _ __    ___   _  _ __  | |_ | |__  | |  __ _  _ __  | | __
# | '_ \  / _ \ | || '_ \ | __|| '_ \ | | / _` || '_ \ | |/ /
# | |_) || (_) || || | | || |_ | |_) || || (_| || | | ||   < 
# | .__/  \___/ |_||_| |_| \__||_.__/ |_| \__,_||_| |_||_|\_\
# | |                                                        
# |_|                                                        
# 
# This file is part of the 'rich-iannone/pointblank' package.
# 
# (c) Richard Iannone <riannone@me.com>
# 
# For full copyright and license information, please look at
# https://rich-iannone.github.io/pointblank/LICENSE.html
#


#' Create a **pointblank** *informant* object
#'
#' The `create_informant()` function creates an *informant* object, which is
#' used in an *information management* workflow. The overall aim of this
#' workflow is to record, collect, and generate useful information on data
#' tables. We can supply as information that is useful for describing a
#' particular data table. The *informant* object created by the
#' `create_informant()` function takes information-focused functions (the
#' `info_*()` series of functions).
#'
#' @param tbl The input table. This can be a data frame, a tibble, a `tbl_dbi`
#'   object, or a `tbl_spark` object. Alternatively, a function can be used to
#'   read in the input data table with the `read_fn` argument (in which case,
#'   `tbl` can be `NULL`).
#' @param read_fn A function that's used for reading in the data. Even if a
#'   `tbl` is provided, this function will be invoked to obtain the data (i.e.,
#'   the `read_fn` takes priority). There are two ways to specify a `read_fn`:
#'   (1) using a function (e.g., `function() { <table reading code> }`) or, (2)
#'   with an R formula expression.
#' @param agent A pointblank *agent* object. This object can be used instead of
#'   supplying a table in `tbl` or a table-reading function in `read_fn`.
#' @param tbl_name A optional name to assign to the input table object. If no
#'   value is provided, a name will be generated based on whatever information
#'   is available.
#' @param label An optional label for the information report. If no value is
#'   provided, a label will be generated based on the current system time.
#'   Markdown can be used here to make the label more visually appealing (it
#'   will appear in the header area of the information report).
#' @param lang The language to use for the information report (a summary table
#'   that provides all of the available information for the table. By default,
#'   `NULL` will create English (`"en"`) text. Other options include French
#'   (`"fr"`), German (`"de"`), Italian (`"it"`), Spanish (`"es"`), Portuguese,
#'   (`"pt"`), Chinese (`"zh"`), and Russian (`"ru"`).
#' @param locale An optional locale ID to use for formatting values in the
#'   information report according the locale's rules. Examples include `"en_US"`
#'   for English (United States) and `"fr_FR"` for French (France); more simply,
#'   this can be a language identifier without a country designation, like "es"
#'   for Spanish (Spain, same as `"es_ES"`).
#'   
#' @return A `ptblank_informant` object.
#' 
#' @examples 
#' # Let's walk through how we can
#' # generate some useful information for a
#' # really small table; it's actually
#' # called `small_table` and we can find
#' # it as a dataset in this package
#' small_table
#' 
#' # Create a pointblank `informant`
#' # object with `create_informant()`
#' # and the `small_table` dataset
#' informant <- 
#'   create_informant(
#'     read_fn = ~small_table,
#'     tbl_name = "small_table",
#'     label = "An example."
#'   )
#' 
#' # This function creates some information
#' # without any extra help by profiling
#' # the supplied table object; it adds
#' # the sections: (1) 'table' and
#' # (2) 'columns' and we can print the
#' # object to see the information report
#' 
#' # Alternatively, we can get the same report
#' # by using `get_informant_report()`
#' report <- get_informant_report(informant)
#' class(report)
#' 
#' @section Figures:
#' \if{html}{\figure{man_create_informant_1.png}{options: width=100\%}}
#' 
#' @family Planning and Prep
#' @section Function ID:
#' 1-3
#' 
#' @export
create_informant <- function(tbl = NULL,
                             read_fn = NULL,
                             agent = NULL,
                             tbl_name = NULL,
                             label = NULL,
                             lang = NULL,
                             locale = NULL) {

  read_fn_given <- !is.null(read_fn)
  
  # Generate a label if none provided
  label <- generate_label(label = label)
  
  # Normalize the reporting language identifier and stop if necessary
  lang <- normalize_reporting_language(lang)
 
  # Set the `locale` to the `lang` value if `locale` isn't set
  if (is.null(locale)) locale <- lang
  
  # If nothing is provided for either `tbl`, `read_fn`, or `agent`,
  # this function needs to be stopped
  if (is.null(tbl) && is.null(read_fn) && is.null(agent)) {
    
    stop(
      "A table object, table-reading function, or agent must be supplied:\n",
      " * Use a table object in the `tbl` argument.\n",
      " * Or supply a table-reading function in `read_fn`.\n",
      " * Or even an agent with some connection to a table.",
      call. = FALSE
    )
  }
  
  # Stop function if both a table and an agent are provided 
  if (!is.null(tbl) && !is.null(agent)) {
    stop("A `tbl` and a `agent` cannot both be provided.", call. = FALSE)
  }
  
  # Try to infer the table name if one isn't
  # explicitly given in `tbl_name`
  if (!is.null(tbl) && is.null(tbl_name)) {
    tbl_name <- deparse(match.call()$tbl)
    if (tbl_name == ".") {
      tbl_name <- NA_character_
    }
  } 
  if (is.null(tbl_name)) {
    tbl_name <- NA_character_
  }
  
  # Prefer reading a table from a `read_fn` if it's available
  # TODO: Verify that the table is a table object
  # and provide an error if it isn't
  if (!is.null(read_fn)) {
    if (inherits(read_fn, "function")) {
      tbl <- rlang::exec(read_fn)
    } else if (rlang::is_formula(read_fn)) {
      tbl <- read_fn %>% rlang::f_rhs() %>% rlang::eval_tidy()
    } else {
      stop(
        "The `read_fn` object must be a function or an R formula.\n",
        "* A function can be made with `function()` {<table reading code>}.\n",
        "* An R formula can also be used, with the expression on the RHS.",
        call. = FALSE
      )
    }
  }
  
  if (!is.null(tbl) || !is.null(read_fn)) {
    
    x <- 
      create_agent(
        tbl = tbl,
        read_fn = read_fn,
        tbl_name = tbl_name
      )
    
  } else {
    x <- agent
    if (is.null(read_fn)) read_fn <- agent$read_fn
  }
  
  table.name <- x$tbl_name
  table.type <- x$tbl_src
  
  column_names <- x$col_names
  column_types_r <- x$col_types
  column_types_sql <- x$db_col_types

  .tbl <- x$tbl
  
  table.columns <- length(column_names)
  
  table.rows <- 
    dplyr::count(.tbl, name = "n") %>%
    dplyr::pull(n) %>%
    as.numeric()
  
  column_list <- list(columns = lapply(col_schema(.tbl = .tbl), as.list))
  
  for (i in seq_along(column_names)) {
    
    column_list[["columns"]][[column_names[i]]] <- 
      list(`_type` = paste(
        unlist(column_list[["columns"]][[column_names[i]]]),
        collapse = ", "
      ))
  }
  
  if (!all(is.na(column_types_sql))) {
    
    for (i in seq_along(column_names)) {

      column_list[["columns"]][[i]] <- 
        c(
          column_list[["columns"]][[i]],
          list(`_sql_type` = column_types_sql[i])
        )
    }
  }
  
  metadata_list <-
    c(
      list(
        info_label = label,
        table = list(
          name = table.name,
          `_columns` = table.columns,
          `_rows` = table.rows,
          `_type` = table.type
        )
      ),
      column_list
    )

  # Create the metadata list object
  metadata <-
    list(
      tbl = if (!read_fn_given) tbl,
      read_fn = read_fn,
      tbl_name = table.name,
      info_label = label,
      meta_snippets = list(),
      lang = lang,
      locale = locale,
      metadata = metadata_list
    )
  
  # Assign the class attribute value `ptblank_informant` to
  # the `metadata` object
  attr(metadata, "class") <- "ptblank_informant"
  
  metadata
}
