library(lintr)

lintr::lint_package(
  linters = with_defaults(
    object_usage_linter = NULL,
    trailing_whitespace_linter = NULL,
    cyclocomp_linter = NULL
  ),
  exclusions = c(
    list.files("tests", recursive = TRUE, full.names = TRUE),
    list.files("man", recursive = TRUE, full.names = TRUE),
    list.files("vignettes", recursive = TRUE, full.names = TRUE)
  )
)
