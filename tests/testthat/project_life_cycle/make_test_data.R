library(redcapcustodian)
library(DBI)
library(tidyverse)
library(lubridate)
library(dotenv)

# project_life_cycle/make_test_data.R
# This script is designed to extract records relevant to the project life
# cycle from each of the 9 redcap_log_event tables.
#
# Create a .env file according to the specs of
# redcapcustodian::connect_to_redcap_db with credentials. Save it at the root
# of this R Project.
#
# The redcap system read should be reasonably complex so that the returned
# data is similarly complex.
#
# With that in mind, you can run
conn <- connect_to_redcap_db()

salt <- get_package_scope_var("salt")

get_project_life_cycle_records_by_log_table <- function(log_event_table_name, conn) {
  one_log_table <- dplyr::tbl(conn, log_event_table_name) %>%
    dplyr::filter(.data$description %in% !!redcapcustodian::project_life_cycle_descriptions) %>%
    dplyr::collect()

  pids <- one_log_table %>%
    distinct(project_id)

  sampled_pids <- pids %>%
    dplyr::sample_n(size = min(5, nrow(pids))) %>%
    dplyr::pull(project_id)

  result <- one_log_table %>%
    dplyr::filter(project_id %in% sampled_pids) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(user = stringr::str_sub(digest::digest(paste0(user, salt), algo = "sha1"), start = 1, end = 12))

  return(result)
}

system.time({
log_event_table_data <- purrr::map(
  redcapcustodian::log_event_tables,
  get_project_life_cycle_records_by_log_table,
  conn
)
})

write_to_testing_rds <- function(dataframe, basename) {
  dataframe %>% saveRDS(testthat::test_path("project_life_cycle/", paste0(basename, ".rds")))
}

purrr::walk2(log_event_table_data, redcapcustodian::log_event_tables, write_to_testing_rds)
