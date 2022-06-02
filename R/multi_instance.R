#' Sync data dictionary of a source project to a target project using credential objects
#'
#' @param source_credentials A dataframe containing the following columns:
#' \itemize{
#'   \item redcap_uri - The uri for the API endpoint of a REDCap host
#'   \item token - The REDCap API token for a specific project
#' }
#' This dataframe should contain credentials for the project you wish to copy from
#' @param target_credentials A dataframe containing the following columns:
#' \itemize{
#'   \item redcap_uri - The uri for the API endpoint of a REDCap host
#'   \item token - The REDCap API token for a specific project
#' }
#' This dataframe should contain credentials for the project you wish to overwrite
#' @param strip_action_tags Optional toggle to remove action tags, useful for porting to a development environment; defaults to FALSE
#'
#' @return nothing
#'
#' @export
#' @importFrom magrittr "%>%"
#' @examples
#' \dontrun{
#'   source_credentials <- REDCapR::retrieve_credential_local(
#'     path_credential = "source_credentials.csv",
#'     project_id = 31
#'   )
#'
#'   target_credentials <- REDCapR::retrieve_credential_local(
#'     path_credential = "target_credentials.csv",
#'     project_id = 25
#'   )
#'
#'   sync_metadata(source_credentials, target_credentials)
#' }
#' @seealso
#'  \code{\link[REDCapR]{retrieve_credential}}, \code{\link{scrape_user_api_tokens}}
#'  \code{vignette("credential-scraping", package = "redcapcustodian")}
sync_metadata <- function(source_credentials, target_credentials, strip_action_tags = FALSE) {
  # TODO: repeating instrument and event metadata may be insufficient, can be gathered with RCurl::postForm
  source_metadata <- REDCapR::redcap_metadata_read(
    redcap_uri = source_credentials$redcap_uri,
    token = source_credentials$token
  )
  target_metadata <- REDCapR::redcap_metadata_read(
    redcap_uri = target_credentials$redcap_uri,
    token = target_credentials$token
  )

  if (strip_action_tags) {
    # Remove annoyances like @HIDDEN and @READONLY
    source_metadata$data <- source_metadata$data %>%
      dplyr::mutate(field_note = dplyr::if_else(
        !is.na(.data$field_annotation),
        paste(.data$field_note, "Removed action tags: ", .data$field_annotation),
        .data$field_note
      )
      ) %>%
      dplyr::mutate(field_annotation = NA_character_)
  }

  ## identical is unreliable in this context
  if( setdiff(source_metadata$data, target_metadata$data) %>% nrow() > 0 ) {
    REDCapR::redcap_metadata_write(
      ds = source_metadata,
      redcap_uri = target_credentials$redcap_uri,
      token = target_credentials$token
    )
  } else {
    print("metadata already up to date")
  }
}
