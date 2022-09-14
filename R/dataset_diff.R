#' dataset_diff
#'
#' returns differences of a source and target data list dataframes with
#' records that should be updated, inserted, and deleted, to update target
#' with facts in source.
#'
#' The goal is to allow intelligent one-way synchronization between these
#' source and target datasets using database CRUD operations. There are
#' two assumptions about source and target:
#'
#'   1. Columns of source are a subset of the columns of target.
#'   2. target_pk does not have to appear in source.
#'
#' @param source - a dataframe with content that needs to be reflected in target
#' @param source_pk - the primary key of source
#' @param target - a data frame that needs to reflect source
#' @param target_pk - the primary key of target
#' @param insert - compute and return insert records
#' @param delete - compute and return delete records
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
#' @return A list of dataframes
#' \itemize{
#'   \item update_records - a column of redcap user_ids / institutional IDs
#'   \item insert_records - a column of with the authoritative email address for user_id or NA if insert is NA
#'   \item delete_records ... - Additional columns are allowed in the return data frame or NA if delete is NA
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' dataset_diff(source = dataset_diff_test_user_data$source,
#'   source_pk = "username",
#'   target = dataset_diff_test_user_data$target,
#'   target_pk = "ui_id"
#' )
#' }
dataset_diff <- function(source,
                         source_pk,
                         target,
                         target_pk,
                         insert = T,
                         delete = T) {

  update_records <- source %>%
    dplyr::anti_join(target) %>%
    dplyr::inner_join(target, by=source_pk) %>%
    dplyr::select(dplyr::any_of(target_pk), dplyr::any_of(names(source)), dplyr::ends_with(".x")) %>%
    dplyr::rename_with(., ~ gsub("\\.x", "", .x), dplyr::ends_with(".x"))

  ids_of_update_records <- update_records %>% dplyr::pull({{target_pk}})

  if (insert) {
    insert_records <- source %>%
      dplyr::anti_join(target) %>%
      dplyr::anti_join(update_records)
  } else {
    insert_records = NA
  }


  if (delete) {
    delete_records <-
      target %>%
      dplyr::anti_join(source) %>%
      dplyr::filter(! (!!as.symbol(target_pk)) %in% ids_of_update_records)
  } else {
    delete_records <- NA
  }

  return(list(
    update_records = update_records,
    insert_records = insert_records,
    delete_records = delete_records
  ))
}
