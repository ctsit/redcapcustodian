export_allocation_tables_from_project <- function(conn,
                                                  project_id_to_export) {
  # Get column names from randomization_source
  # target_field and target_event describe the randomization group
  # source_fieldN and source_eventN describe the randomization variables
  # Pivot the data longer to prep it for renaming the strata fields in Allocations
  column_names_in_source <- dplyr::tbl(conn, "redcap_randomization") |>
    dplyr::filter(project_id == project_id_to_export) |>
    dplyr::collect() |>
    dplyr::select(target_field, starts_with("source_field")) |>
    tidyr::pivot_longer(
      cols = contains("field"),
      names_to = "strata",
      values_to = "redcap_field_name"
    ) |>
    dplyr::filter(!is.na(redcap_field_name))

  rid_to_export <- dplyr::tbl(conn, "redcap_randomization") |>
    dplyr::filter(project_id == !!project_id_to_export) |>
    dplyr::collect() |>
    dplyr::pull(rid)

  # Allocation data is in allocation_source
  allocations <-
    dplyr::tbl(conn, "redcap_randomization_allocation") |>
    dplyr::filter(rid == rid_to_export) |>
    dplyr::collect() |>
    dplyr::select(aid, project_status, target_field, starts_with("source_field")) |>
    # Pivot longer to facilitate renaming the abstract field names to redcap field names
    tidyr::pivot_longer(
      cols = contains("field"),
      names_to = "strata",
      values_to = "value"
    ) |>
    dplyr::filter(!is.na(value)) |>
    # dplyr::rename the *field* columns
    dplyr::inner_join(column_names_in_source, by = "strata") |>
    dplyr::select(-strata) |>
    tidyr::pivot_wider(
      id_cols = c("aid", "project_status"),
      names_from = "redcap_field_name",
      values_from = "value"
    )

  return(allocations)
}


# Write the allocation tables
write_allocations <- function(project_status_to_write, allocations, target_directory = ".") {
  base_name <- "RandomizationAllocation"
  date_time_stamp <- format(get_script_run_time(), "%Y%m%d%H%M%S")
  project_statuses <- setNames(c(0, 1), c("development", "production"))

  if (!fs::dir_exists(here::here(target_directory))) {
    fs::dir_create(here::here(target_directory))
  }

  allocations |>
    dplyr::filter(project_status == project_status_to_write) |>
    dplyr::select(-aid, -project_status) |>
    readr::write_csv(here::here(target_directory, paste(base_name, names(project_statuses)[project_status_to_write + 1], date_time_stamp, sep = "_")))
}


create_randomization_row <- function(source_conn,
                                     target_conn,
                                     source_project_id,
                                     target_project_id) {
  # get the current state
  target_project_randomization_state <- dplyr::tbl(target_conn, "redcap_randomization") |>
    dplyr::filter(project_id == target_project_id) |>
    dplyr::collect()

  # create row in redcap_randomization on target if there is no current state
  if (nrow(target_project_randomization_state) == 0) {
    # get replacement event_ids
    source_event_ids <- dplyr::tbl(source_conn, "redcap_events_arms") |>
      dplyr::filter(project_id == source_project_id) |>
      dplyr::inner_join(dplyr::tbl(source_conn, "redcap_events_metadata"), by = "arm_id") |>
      dplyr::collect()

    target_event_ids <- dplyr::tbl(target_conn, "redcap_events_arms") |>
      dplyr::filter(project_id == target_project_id) |>
      dplyr::inner_join(dplyr::tbl(target_conn, "redcap_events_metadata"), by = "arm_id") |>
      dplyr::collect()

    max_rid_target <- dplyr::tbl(target_conn, "redcap_randomization") |>
      dplyr::arrange(dplyr::desc(rid)) |>
      head(n = 1) |>
      dplyr::collect() |>
      dplyr::pull(rid)

    new_randomization_target_data <- randomization_source |>
      dplyr::filter(project_id == source_project_id) |>
      dplyr::collect() |>
      # Replace the easy stuff
      dplyr::mutate(
        rid = max_rid_target + 1,
        project_id = target_project_id
      ) |>
      # Pivot longer so that we can replace each event_id with the
      #   corresponding event ID for the target project.
      tidyr::pivot_longer(
        cols = contains("field"),
        names_to = "field_label",
        values_to = "field_value",
        values_drop_na = T
      ) |>
      tidyr::pivot_longer(
        cols = contains("event"),
        names_to = "event_label",
        values_to = "event_value",
        values_drop_na = T
      ) |>
      # Replace the event_id by aligning the Event Description
      dplyr::inner_join(source_event_ids |> dplyr::select(event_id, descrip), by = c("event_value" = "event_id")) |>
      dplyr::inner_join(target_event_ids |> dplyr::select(event_id, descrip), by = "descrip") |>
      dplyr::select(-event_value, descrip) |>
      dplyr::rename(event_value = event_id) |>
      # pivot wider to restore the original shape of the data
      tidyr::pivot_wider(
        id_cols = c(rid, project_id, stratified, group_by, field_label, field_value),
        names_from = "event_label",
        values_from = "event_value"
      ) |>
      tidyr::pivot_wider(
        id_cols = c(rid, project_id, stratified, group_by, target_event, source_event1, source_event2),
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


create_allocation_rows <- function(source_conn,
                                   target_conn,
                                   source_project_id) {
  # create row in redcap_randomization on target if needed
  target_project_allocation_state <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(rid == !!target_project_randomization_state$rid) |>
    dplyr::collect()

  if (!nrow(target_project_allocation_state) == 0) {
    message(paste("Allocation records exist for target project with ID", project_id_target, "Not writing allocation records"))
    result <- 0
  } else {
    max_aid_target <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
      dplyr::arrange(dplyr::desc(aid)) |>
      head(n = 1) |>
      dplyr::collect() |>
      dplyr::pull(aid)

    rid_source <- dplyr::tbl(source_conn, "redcap_randomization") |>
      dplyr::filter(project_id == !!source_project_id) |>
      dplyr::collect() |>
      dplyr::pull(rid)

    new_allocation_target_data <- dplyr::tbl(source_conn, "redcap_randomization_allocation") |>
      dplyr::filter(rid == rid_source) |>
      dplyr::arrange(aid) |>
      dplyr::collect() |>
      dplyr::mutate(
        rid = target_project_randomization_state$rid,
        aid = max_aid_target + row_number()
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

update_production_allocation_state <- function(source_conn,
                                               target_conn,
                                               source_project_id,
                                               target_rid) {
  rid_source <- dplyr::tbl(source_conn, "redcap_randomization") |>
    dplyr::filter(project_id == !!source_project_id) |>
    dplyr::collect() |>
    dplyr::pull(rid)

  # get the source's production allocation data, but control the order and add an alignment column
  source_allocation_data <- dplyr::tbl(source_conn, "redcap_randomization_allocation") |>
    dplyr::filter(rid == rid_source) |>
    dplyr::filter(project_status == 1) |>
    dplyr::arrange(dplyr::desc(aid)) |>
    dplyr::collect() |>
    dplyr::mutate(
      aid.alignment = aid - min(aid)
    )

  # get the target's production allocation data, but control the order and add an alignment column
  target_allocation_data <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(rid == target_rid) |>
    dplyr::filter(project_status == 1) |>
    dplyr::arrange(dplyr::desc(aid)) |>
    dplyr::collect() |>
    dplyr::mutate(
      aid.alignment = aid - min(aid)
    )

  # Make the update dataset by replacing the RID and AID columns in the source data
  target_allocation_update <- source_allocation_data |>
    dplyr::filter(!is.na(is_used_by)) |>
    dplyr::select(-aid, -rid) |>
    dplyr::inner_join(target_allocation_data |> dplyr::select(aid, rid, aid.alignment), by = "aid.alignment") |>
    dplyr::select(-aid.alignment)

  # Write updates to target allocation data
  sync_result <- sync_table_2(
    conn = target_conn,
    table_name = "redcap_randomization_allocation",
    source = target_allocation_update,
    source_pk = "aid",
    target = target_allocation_data |> dplyr::select(-aid.alignment),
    target_pk = "aid",
    update = T,
    insert = F,
    delete = F
  )

  return(sync_result)
}


enable_randomization_on_a_preconfigured_project_in_production <- function(target_conn,
                                                                          target_project_id) {
  # Turn on randomization in the target project but only if
  #  1) it has already been moved to production
  #  2) randomization has been configured

  # get the state of the project
  target_project_state <- dplyr::tbl(rc_conn_target, "redcap_projects") |>
    dplyr::filter(project_id == project_id_target) |>
    dplyr::select(project_id, randomization, status, production_time) |>
    dplyr::collect()

  target_project_randomization_state <- dplyr::tbl(target_conn, "redcap_randomization") |>
    dplyr::filter(project_id == target_project_id) |>
    dplyr::collect()

  target_project_production_allocation_state <- dplyr::tbl(target_conn, "redcap_randomization_allocation") |>
    dplyr::filter(rid == !!target_project_randomization_state$rid) |>
    dplyr::filter(project_status == 1) |>
    dplyr::collect()

  if (target_project_state$randomization == 0 &
      target_project_state$status == 1 &
      nrow(target_project_randomization_state) == 1 &
      nrow(target_project_production_allocation_state) > 0
  ) {
    sync_table_2(
      conn = rc_conn_target,
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
