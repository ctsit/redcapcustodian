#' Sync data dictionary of a source project to a target project, using REDCapR credentials
#'
#' @param source_credentials A dataframe returned from \code{\link{REDCapR::retrieve_credentials_local}} \cr
#' contains credentials for the project you wish to copy from
#' @param target_credentials A dataframe returned from \code{\link{REDCapR::retrieve_credentials_local}} \cr
#' contains credentials for the project you wish to overwrite
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
      mutate(field_note = if_else(
        !is.na(field_annotation),
        paste(field_note, "Removed action tags: ", field_annotation),
        field_note
      )
      ) %>%
      mutate(field_annotation = NA_character_)
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
