% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{disable_non_interactive_quit}
\alias{disable_non_interactive_quit}
\title{Prevent \code{\link{quit_non_interactive_run}} from quitting.
This is not meant to be used outside of tests. See test-write.R for an example.}
\usage{
disable_non_interactive_quit()
}
\description{
Prevent \code{\link{quit_non_interactive_run}} from quitting.
This is not meant to be used outside of tests. See test-write.R for an example.
}
\examples{
\dontrun{
 disable_non_interactive_quit()
}
}
