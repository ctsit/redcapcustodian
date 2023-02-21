library(redcapcustodian)
library(DBI)
library(tidyverse)
library(lubridate)
library(dotenv)

# randomization/make_test_data.R
# This script is designed to extract the REDCap tables for two test projects
# on the same redcap system to test the randomization management functions.
# Should you need to regenerate the test data, follow the procedure here.
#
# Note: these randomization management tools do not support DAG group_ids.
# They could, but they don't as they were not needed for the project that
# inspired these tools. Do not try to use these on a project that uses
# DAGs in the randomization configuration.
#
# Create a .env file according to the specs of
# redcapcustodian::connect_to_redcap_db with credentials. Save it at the root
# of this R Project.
#
# The first project--the source project--should be a small project with just
# a few categorical variables. Randomization should be enabled. Two or more
# strata should be configured.The allocation tables for development and
# production should be generated and uploaded. The project should be moved
# to production and randomized. Do a full XML export of this project and note
# its project ID. Replace the value of project_id_to_read below with this new
# project ID.
#
# Create the second project as an XML import of the source project. Make sure
# randomization is turned off. Note this new project ID. Replace the value of
# target_project below with this new project ID.
#
# With these changes in place, you can run
conn <- connect_to_redcap_db()

project_id_to_read <- 18
target_project <- 27

# Create a one-project redcap_randomization with no columns with NA field name or event id.
# We need this form so that the field types are correct when read back from csv and then
# when pushed into a DBI-managed table.
redcap_randomization <- dplyr::tbl(conn, "redcap_randomization") |>
  dplyr::filter(project_id == project_id_to_read) |>
  dplyr::collect() |>
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

rid_to_read <- redcap_randomization |>
  dplyr::pull(rid)

# Create a one-rid redcap_randomization_allocation with no columns with NA field name
# We need this form so that the field types are correct when read back from csv and then
# when pushed into a DBI-managed table.
redcap_randomization_allocation <- dplyr::tbl(conn, "redcap_randomization_allocation") |>
  dplyr::filter(rid == rid_to_read) |>
  collect() |>
  tidyr::pivot_longer(
    cols = dplyr::contains("field"),
    names_to = "field_label",
    values_to = "field_value",
    values_drop_na = T
  ) |>
  # pivot wider to restore the original shape of the data
  tidyr::pivot_wider(
    id_cols = c("aid", "rid", "project_status", "is_used_by", "group_id"),
    names_from = "field_label",
    values_from = "field_value"
  )

redcap_events_arms <- dplyr::tbl(conn, "redcap_events_arms") |>
  filter(project_id %in% c(project_id_to_read, target_project)) |>
  collect()

redcap_events_metadata <- dplyr::tbl(conn, "redcap_events_metadata") |>
  filter(arm_id %in% !!redcap_events_arms$arm_id) |>
  collect()

test_tables <- c(
  "redcap_randomization",
  "redcap_randomization_allocation",
  "redcap_events_arms",
  "redcap_events_metadata"
)

write_to_testing_csv <- function(dataframe, basename) {
  dataframe %>% write_csv(testthat::test_path("randomization", paste0(basename, ".csv")))
}

# write all of the test inputs
walk(test_tables, ~ write_to_testing_csv(get(.), .))

# write expected dataframe for export_allocation_tables_from_project
conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
fix_randomization_tables(conn)

project_id_to_export <- 18
export_allocation_tables_from_project(conn, project_id_to_export) |>
  write_csv(testthat::test_path("randomization", "export_allocation_tables_from_project.csv"))

# write expected dataframe for create_randomization_row
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
fix_randomization_tables(conn)

source_project_id <- 18
target_project_id <- 27

create_randomization_row(
  source_conn = conn,
  target_conn = conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
) |>
  write_csv(testthat::test_path("randomization", "create_randomization_row.csv"))


# write expected dataframe for create_allocation_rows
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
purrr::walk(randomization_test_tables, create_a_table_from_test_data, conn, "randomization")
fix_randomization_tables(conn)

source_project_id <- 18
target_project_id <- 27

create_randomization_row(
  source_conn = conn,
  target_conn = conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
)

create_allocation_rows(
  source_conn = conn,
  target_conn = conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
) |>
  write_csv(testthat::test_path("randomization", "create_allocation_rows.csv"))
