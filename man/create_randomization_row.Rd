% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/randomization.R
\name{create_randomization_row}
\alias{create_randomization_row}
\title{create_randomization_row}
\usage{
create_randomization_row(
  source_conn,
  target_conn,
  source_project_id,
  target_project_id
)
}
\arguments{
\item{source_conn}{- a DBI connection object pointing at the REDCap
database that houses the source project.}

\item{target_conn}{- a DBI connection object pointing at the REDCap
database that houses the target project.}

\item{source_project_id}{- The project ID of the REDCap project that
contains randomization to be cloned.}

\item{target_project_id}{- The project ID of the REDCap project that
will receive the mirrored randomization data.}
}
\value{
- A dataframe containing the current randomization row for the
  target project.
}
\description{
Create a single row in the redcap_randomization table that mirrors
that in another project.
}
\examples{
\dontrun{
target_project_randomization_state <- create_randomization_row(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
)
}
}
