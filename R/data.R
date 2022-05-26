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
#'   \item{\code{user_email}}{character primnary email address}
#'}
#' @details DETAILS
"sync_table_test_user_data_result"
