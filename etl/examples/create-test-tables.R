library(tidyverse)
library(redcapcustodian)

# create SQLite table in memory
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

tables <- c(
  "redcap_projects",
  "redcap_user_information"
)

pmap(
  .l  = list(
  "conn" = c(conn),
  "table_name" = c(tables)
  ),
  .f = create_test_table
)

# check contents of each table
tbl(conn, "redcap_projects")
tbl(conn, "redcap_user_information")
