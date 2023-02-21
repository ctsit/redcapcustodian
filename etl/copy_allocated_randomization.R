library(redcapcustodian)
library(DBI)
library(tidyverse)
library(lubridate)
library(dotenv)

init_etl("copy_allocated_randomization")

source_conn <- connect_to_redcap_db()
# specify a second database connection if the target project is on another host
target_conn <- source_conn
source_project_id <- 18
target_project_id <- 25

# get and print importable allocations if we need them for reference
allocations <- export_allocation_tables_from_project(
  conn = source_conn,
  project_id_to_export = source_project_id
)

target_directory = "output"
if (!fs::dir_exists(here::here(target_directory))) {
  fs::dir_create(here::here(target_directory))
}

walk(c(0,1), write_allocations, allocations, target_directory)

# Configure randomization on the target project
target_project_randomization_state <- create_randomization_row(
    source_conn = source_conn,
    target_conn = target_conn,
    source_project_id = source_project_id,
    target_project_id = target_project_id
)

target_project_allocation_state <- create_allocation_rows(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
)

# Update randomization on the target project
target_project_allocation_update <- update_production_allocation_state(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_rid = target_project_randomization_state$rid
)

# Enable randomization on the target
enable_randomization_on_a_preconfigured_project_in_production(
  target_conn = target_conn,
  target_project_id = target_project_id
)
