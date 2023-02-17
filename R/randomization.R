#' export_allocation_tables_from_project
#'
#' Export randomization allocation data for a project from the REDCap
#'   randomization tables but in a form that reflects the allocation tables
#'   REDCap requests for import
#'
#' @param conn - a DBI connection object pointing at a REDCap
#'   database that houses the project on interest
#' @param project_id_to_export - The project ID of a REDCap project that
#'   contains randomization to be exported.
#'
#' @return a dataframe in the shape of REDCap randomization table CSVs
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' allocations <- export_allocation_tables_from_project(
#'   conn = source_conn,
#'   project_id_to_export = source_project_id
#' )
#' }
export_allocation_tables_from_project <- function(conn,
                                                  project_id_to_export) {
  # Get column names from randomization_source
  # target_field and target_event describe the randomization group
  # source_fieldN and source_eventN describe the randomization variables
  # Pivot the data longer to prep it for renaming the strata fields in Allocations
  column_names_in_source <- dplyr::tbl(conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == project_id_to_export) |>
    dplyr::collect() |>
    dplyr::select("target_field", dplyr::starts_with("source_field")) |>
    tidyr::pivot_longer(
      cols = dplyr::contains("field"),
      names_to = "strata",
      values_to = "redcap_field_name"
    ) |>
    dplyr::filter(!is.na(.data$redcap_field_name))

  rid_to_export <- dplyr::tbl(conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == !!project_id_to_export) |>
    dplyr::collect() |>
    dplyr::pull(.data$rid)

  # Allocation data is in allocation_source
  allocations <-
    dplyr::tbl(conn, "redcap_randomization_allocation") |>
    dplyr::filter(.data$rid == rid_to_export) |>
    dplyr::collect() |>
    dplyr::select("aid", "project_status", "target_field", dplyr::starts_with("source_field")) |>
    # Pivot longer to facilitate renaming the abstract field names to redcap field names
    tidyr::pivot_longer(
      cols = dplyr::contains("field"),
      names_to = "strata",
      values_to = "value"
    ) |>
    dplyr::filter(!is.na(.data$value)) |>
    # dplyr::rename the *field* columns
    dplyr::inner_join(column_names_in_source, by = "strata") |>
    dplyr::select(-"strata") |>
    tidyr::pivot_wider(
      id_cols = c("aid", "project_status"),
      names_from = "redcap_field_name",
      values_from = "value"
    )

  return(allocations)
}

#' write_allocations
#'
#' Write the development or production randomization allocation table in
#'   the same form in which it was loaded.
#'
#' @param project_status_to_write - the value of project_status to export.
#'   Use 0 for development. Use 1 for Production
#' @param allocations - the dataframe of randomization allocation data as
#'   exported by `export_allocation_tables_from_project`
#' @param target_directory - the directory into which the function should write the files
#'
#' @return the full path to the allocations file
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' # get and print importable allocations if we need them for reference
#' allocations <- export_allocation_tables_from_project(
#'   conn = source_conn,
#'   project_id_to_export = source_project_id
#' )
#'
#' # write both files
#' walk(c(0,1), write_allocations, allocations, "output")
#' }
write_allocations <- function(project_status_to_write, allocations, target_directory = ".") {
  base_name <- "RandomizationAllocation"
  date_time_stamp <- format(get_script_run_time(), "%Y%m%d%H%M%S")
  project_statuses <- stats::setNames(c(0, 1), c("development", "production"))

  if (!fs::dir_exists(here::here(target_directory))) {
    fs::dir_create(here::here(target_directory))
  }

  filename <- here::here(
    target_directory,
    paste0(
      paste(base_name, names(project_statuses)[project_status_to_write + 1], date_time_stamp, sep = "_"),
      ".csv"
    )
  )

  allocations |>
    dplyr::filter(.data$project_status == project_status_to_write) |>
    dplyr::select(-"aid", -"project_status") |>
    readr::write_csv(filename)

  return(filename)
}


#' create_randomization_row
#'
#' Create a single row in the redcap_randomization table that mirrors
#' that in another project.
#'
#' @param source_conn - a DBI connection object pointing at the REDCap
#'   database that houses the source project.
#' @param target_conn - a DBI connection object pointing at the REDCap
#'   database that houses the target project.
#' @param source_project_id - The project ID of the REDCap project that
#'   contains randomization to be cloned.
#' @param target_project_id - The project ID of the REDCap project that
#'   will receive the mirrored randomization data.
#'
#' @return - A dataframe containing the current randomization row for the
#'   target project.
#'
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' target_project_randomization_state <- create_randomization_row(
#'   source_conn = source_conn,
#'   target_conn = target_conn,
#'   source_project_id = source_project_id,
#'   target_project_id = target_project_id
#' )
#' }
create_randomization_row <- function(source_conn,
                                     target_conn,
                                     source_project_id,
                                     target_project_id) {
  # get the current state
  target_project_randomization_state <- dplyr::tbl(target_conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == target_project_id) |>
    dplyr::collect()

  # create row in redcap_randomization on target if there is no current state
  if (nrow(target_project_randomization_state) == 0) {
    # get replacement event_ids
    source_event_ids <- dplyr::tbl(source_conn, "redcap_events_arms") |>
      dplyr::filter(.data$project_id == source_project_id) |>
      dplyr::inner_join(dplyr::tbl(source_conn, "redcap_events_metadata"), by = "arm_id") |>
      dplyr::collect()

    target_event_ids <- dplyr::tbl(target_conn, "redcap_events_arms") |>
      dplyr::filter(.data$project_id == target_project_id) |>
      dplyr::inner_join(dplyr::tbl(target_conn, "redcap_events_metadata"), by = "arm_id") |>
      dplyr::collect()

    max_rid_target <- dplyr::tbl(target_conn, "redcap_randomization") |>
      dplyr::arrange(dplyr::desc(.data$rid)) |>
      utils::head(n = 1) |>
      dplyr::collect() |>
      dplyr::pull(.data$rid)

    new_randomization_target_data <- dplyr::tbl(source_conn, "redcap_randomization") |>
      dplyr::filter(.data$project_id == source_project_id) |>
      dplyr::collect() |>
      # Replace the easy stuff
      dplyr::mutate(
        rid = max_rid_target + 1,
        project_id = target_project_id
      ) |>
      # Pivot longer so that we can replace each event_id with the
      #   corresponding event ID for the target project.
      tidyr::pivot_longer(
        cols = dplyr::contains("field"),
        names_to = "field_label",
        values_to = "field_value",
        values_drop_na = T
      ) |>
      tidyr::pivot_longer(
        cols = dplyr::contains("event"),
        names_to = "event_label",
        values_to = "event_value",
        values_drop_na = T
      ) |>
      # Replace the event_id by aligning the Event Description
      dplyr::inner_join(source_event_ids |> dplyr::select("event_id", "descrip"), by = c("event_value" = "event_id")) |>
      dplyr::inner_join(target_event_ids |> dplyr::select("event_id", "descrip"), by = "descrip") |>
      dplyr::select(-"event_value", "descrip") |>
      dplyr::rename(event_value = .data$event_id) |>
      # pivot wider to restore the original shape of the data
      tidyr::pivot_wider(
        id_cols = c("rid", "project_id", "stratified", "group_by", "field_label", "field_value"),
        names_from = "event_label",
        values_from = "event_value"
      ) |>
      tidyr::pivot_wider(
        id_cols = c("rid", "project_id", "stratified", "group_by", "target_event", "source_event1", "source_event2"),
        names_from = "field_label",
        values_from = "field_value"
      )

    # Write the new randomization record
    DBI::dbAppendTable(
      conn = target_conn,
      name = "redcap_randomization",
      value = new_randomization_target_data
    )

    target_project_randomization_state <- new_randomization_target_data
  }
  return(target_project_randomization_state)
}


#' create_allocation_rows
#'
#' Create rows in the redcap_randomization_allocation table that mirror
#' those in another project.
#'
#' @param source_conn - a DBI connection object pointing at the REDCap
#'   database that houses the source project.
#' @param target_conn - a DBI connection object pointing at the REDCap
#'   database that houses the target project.
#' @param source_project_id - The project ID of the REDCap project that
#'   contains randomization to be cloned.
#' @param target_project_id - The project ID of the REDCap project that
#'   will receive the mirrored randomization data.
#'
#' @return - A dataframe containing the current allocation rows for the
#'   target project.
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' target_project_allocation_state <- create_allocation_rows(
#'   source_conn = source_conn,
#'   target_conn = target_conn,
#'   source_project_id = source_project_id,
#'   target_project_id = target_project_id
#' )
#' }
create_allocation_rows <- function(source_conn,
                                   target_conn,
                                   source_project_id,
                                   target_project_id) {
  # get the current state
  target_project_randomization_state <- dplyr::tbl(target_conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == target_project_id) |>
    dplyr::collect()

  # create row in redcap_randomization on target if needed
  target_project_allocation_state <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(.data$rid == !!target_project_randomization_state$rid) |>
    dplyr::collect()

  if (!nrow(target_project_allocation_state) == 0) {
    message(paste("Allocation records exist for target project with ID", target_project_id, "Not writing allocation records"))
    result <- 0
  } else {
    max_aid_target <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
      dplyr::arrange(dplyr::desc(.data$aid)) |>
      utils::head(n = 1) |>
      dplyr::collect() |>
      dplyr::pull(.data$aid)

    rid_source <- dplyr::tbl(source_conn, "redcap_randomization") |>
      dplyr::filter(.data$project_id == !!source_project_id) |>
      dplyr::collect() |>
      dplyr::pull(.data$rid)

    new_allocation_target_data <- dplyr::tbl(source_conn, "redcap_randomization_allocation") |>
      dplyr::filter(.data$rid == rid_source) |>
      dplyr::arrange(.data$aid) |>
      dplyr::collect() |>
      dplyr::mutate(
        rid = target_project_randomization_state$rid,
        aid = max_aid_target + dplyr::row_number()
      )

    # Write the new allocation data to the target
    result <- DBI::dbAppendTable(
      conn = target_conn,
      name = "redcap_randomization_allocation",
      value = new_allocation_target_data
    )

    target_project_allocation_state <- new_allocation_target_data
  }
  return(target_project_allocation_state)
}


#' update_production_allocation_state
#'
#' Update producition rows in the redcap_randomization_allocation table to
#'   mirror those in another project.
#'
#' @param source_conn - a DBI connection object pointing at the REDCap
#'   database that houses the source project.
#' @param target_conn - a DBI connection object pointing at the REDCap
#'   database that houses the target project.
#' @param source_project_id - The project ID of the REDCap project that
#'   contains randomization to be cloned.
#' @param target_rid - The randomization id of the REDCap project that
#'   will receive the updated randomization data.
#'
#' @return - The list output of sync_table_2 from the update of the
#'   randomization allocation table.
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' target_project_allocation_update <- update_production_allocation_state(
#'   source_conn = source_conn,
#'   target_conn = target_conn,
#'   source_project_id = source_project_id,
#'   target_rid = target_project_randomization_state$rid
#' )
#' }
update_production_allocation_state <- function(source_conn,
                                               target_conn,
                                               source_project_id,
                                               target_rid) {
  rid_source <- dplyr::tbl(source_conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == !!source_project_id) |>
    dplyr::collect() |>
    dplyr::pull(.data$rid)

  # get the source's production allocation data, but control the order and add an alignment column
  source_allocation_data <- dplyr::tbl(source_conn, "redcap_randomization_allocation") |>
    dplyr::filter(.data$rid == rid_source) |>
    dplyr::filter(.data$project_status == 1) |>
    dplyr::arrange(dplyr::desc(.data$aid)) |>
    dplyr::collect() |>
    dplyr::mutate(
      aid.alignment = .data$aid - min(.data$aid)
    )

  # get the target's production allocation data, but control the order and add an alignment column
  target_allocation_data <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(.data$rid == target_rid) |>
    dplyr::filter(.data$project_status == 1) |>
    dplyr::arrange(dplyr::desc(.data$aid)) |>
    dplyr::collect() |>
    dplyr::mutate(
      aid.alignment = .data$aid - min(.data$aid)
    )

  # Make the update dataset by replacing the RID and AID columns in the source data
  target_allocation_update <- source_allocation_data |>
    dplyr::filter(!is.na(.data$is_used_by)) |>
    dplyr::select(-"aid", -"rid") |>
    dplyr::inner_join(target_allocation_data |> dplyr::select("aid", "rid", "aid.alignment"), by = "aid.alignment") |>
    dplyr::select(-"aid.alignment")

  # Write updates to target allocation data
  sync_result <- sync_table_2(
    conn = target_conn,
    table_name = "redcap_randomization_allocation",
    source = target_allocation_update,
    source_pk = "aid",
    target = target_allocation_data |> dplyr::select(-"aid.alignment"),
    target_pk = "aid",
    update = T,
    insert = F,
    delete = F
  )

  return(sync_result)
}


#' enable_randomization_on_a_preconfigured_project_in_production
#'
#'  Turn on randomization in the target project but only if it has already
#'    been moved to production and randomization has been configured.
#'
#' @param target_conn - a DBI connection object pointing at the REDCap
#'   database that houses the target project.
#' @param target_project_id - The project ID of the REDCap project that
#'   will receive the mirrored randomization data.
#'
#' @return A logical indicating success or failure of the operation
#' @export
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' enable_randomization_on_a_preconfigured_project_in_production(
#'   target_conn = target_conn,
#'   target_project_id = target_project_id
#' )
#' }
enable_randomization_on_a_preconfigured_project_in_production <- function(target_conn,
                                                                          target_project_id) {
  # Turn on randomization in the target project but only if
  #  1) it has already been moved to production
  #  2) randomization has been configured

  # get the state of the project
  target_project_state <- dplyr::tbl(target_conn, "redcap_projects") |>
    dplyr::filter(.data$project_id == target_project_id) |>
    dplyr::select("project_id", "randomization", "status", "production_time") |>
    dplyr::collect()

  target_project_randomization_state <- dplyr::tbl(target_conn, "redcap_randomization") |>
    dplyr::filter(.data$project_id == target_project_id) |>
    dplyr::collect()

  target_project_production_allocation_state <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(.data$rid == !!target_project_randomization_state$rid) |>
    dplyr::filter(.data$project_status == 1) |>
    dplyr::collect()

  if (target_project_state$randomization == 0 &
      target_project_state$status == 1 &
      nrow(target_project_randomization_state) == 1 &
      nrow(target_project_production_allocation_state) > 0
  ) {
    sync_table_2(
      conn = target_conn,
      table_name = "redcap_projects",
      source = target_project_state |> dplyr::mutate(randomization = 1),
      source_pk = "project_id",
      target = target_project_state,
      target_pk = "project_id"
    )
    message("Randomization enabled.")
    result <- TRUE
  } else {
    message("Doing nothing. The project must be in production, with randomization configured, but randomization turned off.")
    result <- FALSE
  }
  return(result)
}
