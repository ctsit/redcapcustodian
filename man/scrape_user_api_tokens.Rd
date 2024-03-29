% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/credential_management.R
\name{scrape_user_api_tokens}
\alias{scrape_user_api_tokens}
\title{Gather all API tokens on a specified REDCap server for a given user}
\usage{
scrape_user_api_tokens(conn, username_to_scrape = Sys.info()[["user"]])
}
\arguments{
\item{conn}{a DBI database connection to a REDCap instance, such as that from \code{\link{get_redcap_db_connection}}}

\item{username_to_scrape}{a REDCap username, defaults to your system's username}
}
\value{
A dataframe of all tokens assigned to the user containing the following:
\itemize{
  \item project_id - The project ID in REDCap (0 if super token)
  \item username - The username from REDCap
  \item token - The API token associated with the project ID
  \item project_display_name - The name of the project as it appears in the REDCap GUI
}
}
\description{
Gather all API tokens on a specified REDCap server for a given user
}
\examples{
\dontrun{
  conn <- get_redcap_db_connection()
  my_credentials <- scrape_user_api_tokens(conn, "admin")

}
}
