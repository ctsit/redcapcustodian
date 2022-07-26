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

#' @title get_redcap_emails_output
#' @description user email addresses from the table redcap_user_information.
#' Addresses have been pivoted taller into a single `email` column.
#' @format A data frame with 10 rows and 4 variables:
#' \describe{
#'   \item{\code{ui_id}}{double primary key}
#'   \item{\code{username}}{character redcap username}
#'   \item{\code{email_field_name}}{character column name in redcap_user_information}
#'   \item{\code{email}}{character email value in the column named in `email_field_name`}
#'}
#' @details DETAILS
"get_redcap_emails_output"

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
