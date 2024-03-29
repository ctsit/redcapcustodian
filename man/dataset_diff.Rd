% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataset_diff.R
\name{dataset_diff}
\alias{dataset_diff}
\title{dataset_diff}
\usage{
dataset_diff(source, source_pk, target, target_pk, insert = T, delete = T)
}
\arguments{
\item{source}{- a dataframe with content that needs to be reflected in target}

\item{source_pk}{- the primary key of source}

\item{target}{- a data frame that needs to reflect source}

\item{target_pk}{- the primary key of target}

\item{insert}{- compute and return insert records}

\item{delete}{- compute and return delete records}
}
\value{
A list of dataframes
\itemize{
  \item update_records - a column of redcap user_ids / institutional IDs
  \item insert_records - a column of with the authoritative email address for user_id or NA if insert is NA
  \item delete_records ... - Additional columns are allowed in the return data frame or NA if delete is NA
}
}
\description{
returns differences of a source and target data list dataframes with
records that should be updated, inserted, and deleted, to update target
with facts in source.
}
\details{
The goal is to allow intelligent one-way synchronization between these
source and target datasets using database CRUD operations. There are
two assumptions about source and target:

  1. Columns of source are a subset of the columns of target.
  2. target_pk does not have to appear in source.
}
\examples{
\dontrun{
dataset_diff(source = dataset_diff_test_user_data$source,
  source_pk = "username",
  target = dataset_diff_test_user_data$target,
  target_pk = "ui_id"
)
}
}
