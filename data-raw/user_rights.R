# # Run this code once to export tables needed to test the user_rights functions
# library(redcapcustodian)
# library(DBI)
# library(RMariaDB)
# library(tidyverse)
#
# dotenv::load_dot_env("local.env.txt")
# conn <- redcapcustodian::connect_to_redcap_db()
# redcap_user_rights <- dplyr::tbl(conn, "redcap_user_rights") %>%
#   dplyr::collect()
#
# redcap_user_roles <- dplyr::tbl(conn, "redcap_user_roles") %>%
#   dplyr::collect()
#
# redcap_user_information <- dplyr::tbl(conn, "redcap_user_information") %>%
#   dplyr::collect()
#
# user_rights_test_data <-
#   list(
#     redcap_user_rights = redcap_user_rights,
#     redcap_user_roles = redcap_user_roles,
#     redcap_user_information = redcap_user_information
#   )
#
# usethis::use_data(user_rights_test_data, overwrite = T)
