#' A template function for fetching authoritative email address data
#' and other institutional data
#'
#' @param user_ids a optional vector of REDCap user IDs to be used in a query
#' against the institutional data
#'
#' @return A Dataframe
#' \itemize{
#'   \item user_id - a column of redcap user_ids / institutional IDs
#'   \item email - a column of with the authoritative email address for user_id
#'   \item ... - Additional columns are allowed in the return data frame
#' }
#' @export
#'
#' @examples
#' redcap_users <- c("jane_doe", "john_q_public")
#' get_institutional_person_data(user_ids = redcap_users)
get_institutional_person_data <- function(user_ids = c(NA_character_)) {
  email_data <- dplyr::tribble(
    ~user_id, ~email,
    "inappropriate_user_id", "inappropriate_user@example.org",
    "jane_doe", "jane_doe@example.org",
    "john_q_public", "john_q_public@example.org"
  )

  if (length(user_ids) == 1 && is.na(user_ids)) {
    result <- email_data
  } else {
    result <- email_data %>%
      dplyr::filter(.data$user_id %in% user_ids)
  }

  return(result)
}
