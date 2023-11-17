library(redcapcustodian)
library(DBI)
library(tidyverse)
library(lubridate)
library(dotenv)

# unnest_job_summary_data_json_object/make_test_data.R
#
# Create a .env file according to the specs of redcapcustodian
# Assure it defines a log database.
# Save it at the root of this R Project.
#
library(redcapcustodian)
library(RMariaDB)
library(DBI)
library(tidyverse)
library(dotenv)
load_dot_env(".env")

init_etl("test_unnest")

# Write some log data for us to read back
log_list <- lst(mtcars, iris)
log_job_success(jsonlite::toJSON(log_list))

log_conn <- get_package_scope_var("log_con")

test_data_dir <- "unnest_job_summary_data_json_object"

log_data <-
  tbl(log_conn, "rcc_job_log") %>%
  dplyr::filter(script_name == "test_unnest") %>%
  dplyr::collect()

log_data %>% saveRDS(testthat::test_path(test_data_dir, "log_data.rds"))
