randomization_test_tables <- c(
  "redcap_randomization",
  "redcap_randomization_allocation",
  "redcap_events_arms",
  "redcap_events_metadata"
)

create_a_table_from_test_data <- function(table_name, conn, directory_under_test_path) {
  readr::read_csv(testthat::test_path(directory_under_test_path, paste0(table_name, ".csv"))) %>%
    DBI::dbWriteTable(conn = conn, name = table_name, value = .)
}

fix_randomization_tables <- function(conn) {
  # fix target_field in redcap_randomization_allocation
  DBI::dbExecute(conn, "ALTER TABLE redcap_randomization_allocation RENAME COLUMN target_field TO tf")
  DBI::dbExecute(conn, "ALTER TABLE redcap_randomization_allocation ADD COLUMN target_field TEXT")
  DBI::dbExecute(conn, "UPDATE redcap_randomization_allocation SET target_field = CAST(tf as INTEGER)")
  DBI::dbExecute(conn, "ALTER TABLE redcap_randomization_allocation DROP COLUMN tf")
}

# read an RDS file from tests/testthat/<directory_under_test_path>/<table_name>.rds
#   and make a same-named table in conn
create_a_table_from_rds_test_data <- function(table_name, conn, directory_under_test_path) {
  readRDS(testthat::test_path(directory_under_test_path, paste0(table_name, ".rds"))) %>%
    DBI::dbWriteTable(conn = conn, name = table_name, value = .)
}

# create session-persistent salt value for hashing with
#   digest::digest(paste0(datum, salt), algo = "sha1")
salt <- get_package_scope_var("salt")
if (is.null(salt)) {
  set_package_scope_var("salt", paste0(runif(1), runif(1), runif(1)))
  salt <- get_package_scope_var("salt")
}

# write a dataframe, referenced by 'table_name' to tests/testthat/directory_under_test_path
write_rds_to_test_dir <- function(table_name, directory_under_test_path) {
  get(table_name) |> saveRDS(testthat::test_path(directory_under_test_path, paste0(table_name, ".rds")))
}
