library(redcapcustodian)
library(DBI)
library(tidyverse)
library(lubridate)
library(dotenv)

# unnest_job_summary_data_json_object/make_test_data.R
# This script is designed to extract a sample of records from a redcapcustodian log table
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
library(redcapcustodian)
library(RMariaDB)
library(DBI)
library(tidyverse)
library(dotenv)
load_dot_env("../rcc.billing/prod.env")

init_etl("pbc_scratch")

log_conn <- get_package_scope_var("log_con")

test_data_dir <- "unnest_job_summary_data_json_object"
sample_size <- 3

log_data <-
  tbl(log_conn, "rcc_job_log") %>%
  dplyr::filter(script_name == "update_project_billable_attribute") %>%
  dplyr::collect() %>%
  dplyr::sample_n(size = sample_size)

log_data %>% saveRDS(testthat::test_path(test_data_dir, "log_data.rds"))
