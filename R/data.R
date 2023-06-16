#' @title dataset_diff_test_bar_bang
#' @description A list of test inputs and outputs for dataset_diff
#' @format A list of 5 variables:
#' \describe{
#'   \item{\code{source}}{tibble of the source data}
#'   \item{\code{source_pk}}{character primary key of the source data}
#'   \item{\code{target}}{tibble of the target data}
#'   \item{\code{target_pk}}{character primary key of the target data}
#'   \item{\code{result}}{list of dataset_diff output}
#'}
#' @details DETAILS
"dataset_diff_test_bar_bang"

#' @title dataset_diff_test_user_data
#' @description A list of test inputs and outputs for dataset_diff
#' @format A list of 5 variables:
#' \describe{
#'   \item{\code{source}}{tibble of the source data}
#'   \item{\code{source_pk}}{character primary key of the source data}
#'   \item{\code{target}}{tibble of the target data}
#'   \item{\code{target_pk}}{character primary key of the target data}
#'   \item{\code{result}}{list of dataset_diff output}
#'}
#' @details DETAILS
"dataset_diff_test_user_data"

#' @title sync_table_test_user_data_result
#' @description output for sync_table when dataset_diff_test_user_data is used as the input
#' @format A data frame with 4 rows and 3 variables:
#' \describe{
#'   \item{\code{ui_id}}{double primary key}
#'   \item{\code{username}}{character redcap username}
#'   \item{\code{user_email}}{character primary email address}
#'}
#' @details DETAILS
"sync_table_test_user_data_result"

#' @title get_bad_emails_from_listserv_digest_test_output
#' @description example output from get_bad_emails_from_listserv_digest that aligns with the related tests
#' @format A data frame with 7 rows and 1 variables:
#' \describe{
#'   \item{\code{email}}{character bad email address found by querying listserv error digests}
#'}
#' @details DETAILS
"get_bad_emails_from_listserv_digest_test_output"

#' @title get_redcap_emails_test_data
#' @description test data to mock get_redcap_emails
#' @return a list of 2 dataframes:
#' \itemize{
#'   \item wide, relevant email columns from redcap_user_information
#'   \item tall, wide data pivoted to include email_field_name and email columns
#' }
#' @details DETAILS
"get_redcap_emails_test_data"

#' @title user_rights_test_data
#' @description A named list of dataframes used to test the functions written to manage user rights
#' @format A named list of 3 dataframes:
#' \describe{
#'   \item{\code{redcap_user_information}}{REDCap Core table}
#'   \item{\code{redcap_user_rights}}{REDCap Core table}
#'   \item{\code{redcap_user_roles}}{REDCap Core table}
#' }
#' @details DETAILS
"user_rights_test_data"

#' @title update_redcap_email_addresses_test_data
#' @description A list of test inputs and outputs for update_redcap_email_addresses
#' @format A list of 1 variables:
#' \describe{
#'   \item{\code{output}}{tibble of email data read backfrom redcap_user_information}
#'}
#' @details DETAILS
"update_redcap_email_addresses_test_data"

#' @title get_redcap_email_revisions_test_data
#' @description A list of test inputs and outputs for get_redcap_email_revisions
#' @format A list of 3 tibbles:
#' \describe{
#'   \item{\code{bad_redcap_user_emails}}{tibble of bad email address and redcap usernames}
#'   \item{\code{person}}{tibble of corrected email addresses and the corresponding usernames}
#'   \item{\code{output}}{tibble of output from get_redcap_email_revisions}
#'}
#' @details DETAILS
"get_redcap_email_revisions_test_data"

#' @title log_event_tables
#' @description A vector of the names of the 9 redcap log event tables
#' @format A vector with 9 elements
#' @details DETAILS
"log_event_tables"

#' @title project_life_cycle_descriptions
#' @description A character vector of the descriptions used in the redcap_log_event table
#'   to describe the different stages in the life cycle of a REDCap Project
#' @format A character vector with 24 elements
#' @details DETAILS
"project_life_cycle_descriptions"

#' @title project_status_labels
#' @description A tibble project status IDs and project statuses that reflect their
#'   meaning as used in the `status` column of the `redcap_projects` table
#' @format A data frame with 4 rows and 2 variables:
#' \describe{
#'   \item{\code{id}}{double primary key}
#'   \item{\code{project_status}}{character redcap project status}
#'}
#' @details DETAILS
"project_status_labels"

#' @title project_purpose_labels
#' @description A tibble project purpose IDs and project purposes that reflect their
#'   meaning as used in the `purpose` column of the `redcap_projects` table
#' @format A data frame with 5 rows and 2 variables:
#' \describe{
#'   \item{\code{id}}{double primary key}
#'   \item{\code{project_purpose}}{character redcap project purpose}
#'}
#' @details DETAILS
"project_purpose_labels"
