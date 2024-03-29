% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/randomization.R
\name{create_allocation_rows}
\alias{create_allocation_rows}
\title{create_allocation_rows}
\usage{
create_allocation_rows(
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
- A dataframe containing the current allocation rows for the
  target project.
}
\description{
Create rows in the redcap_randomization_allocation table that mirror
those in another project.
}
\examples{
\dontrun{
target_project_allocation_state <- create_allocation_rows(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
)
}
}
