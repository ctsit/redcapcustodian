library(redcapcustodian)
library(RMariaDB)
library(DBI)
library(tidyverse)
library(dotenv)

if (Sys.getenv("REDCAP_DB_NAME") == "") dotenv::load_dot_env(here::here(".env"))

init_etl("compare_two_mysql_dbs")

rc_source <- connect_to_redcap_db()
rc_target <- connect_to_db(
  drv = RMariaDB::MariaDB(),
  prefix = "TARGETREDCAP"
)

# example tables to compare
my_example_tables <- c(
  "redcap_entity_project_ownership",
  "redcap_user_information",
  "redcap_projects",
  "redcap_auth",
  "redcap_ip_banned"
)

# Prepare to compute the script's elapsed run time
start <- now()

source_tables <- dbListTables(rc_source)
# Uncomment the next line to run a quick test against a REDCap host.
#   Testing a full redcap database can several minutes
# source_tables <- my_example_tables
source_checksums <- purrr::map_df(source_tables, get_table_checksum, rc_source)

target_tables <- dbListTables(rc_target)
# Uncomment the next line to run a quick test against a REDCap host.
#   Testing a full redcap database can several minutes
# target_tables <- my_example_tables
target_checksums <- purrr::map_df(target_tables, get_table_checksum, rc_target)

# compare the source and target data
checksums <- evaluate_checksums(source_checksums, target_checksums)

# save our work
checksums |> write_csv(here::here("output", "checksums.csv"))

# report on the checksum matching
checksums |> count(matches)
checksums |> filter(!matches)

# compute elapsed run time
finish <- now()
finish - start
