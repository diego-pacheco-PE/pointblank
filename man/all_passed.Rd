% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_passed.R
\name{all_passed}
\alias{all_passed}
\title{Did all of the validations fully \emph{pass}?}
\usage{
all_passed(agent)
}
\arguments{
\item{agent}{An agent object of class \code{ptblank_agent}.}
}
\value{
A logical value.
}
\description{
Given an agent's validation plan that had undergone interrogation via
\code{interrogate()}, did every single validation step result in zero \emph{fail}
levels? Using the \code{all_passed()} function will let us know whether that's
\code{TRUE} or not.
}
\section{Function ID}{

7-4
}

\examples{
# Create a simple table with
# a column of numerical values
tbl <- 
  dplyr::tibble(a = c(5, 7, 8, 5))

# Validate that values in column
# `a` are always greater than 4
agent <-
  create_agent(tbl = tbl) \%>\%
  col_vals_gt(vars(a), 4) \%>\%
  interrogate()

# Determine if these column
# validations have all passed
# by using `all_passed()`
all_passed(agent)

}
\seealso{
Other Post-interrogation: 
\code{\link{get_agent_x_list}()},
\code{\link{get_data_extracts}()},
\code{\link{get_sundered_data}()}
}
\concept{Post-interrogation}
