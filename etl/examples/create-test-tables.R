tables <- c(
  "redcap_projects",
  "redcap_user_information"
)

tables %>% map(redcap_custodian::create_test_table())
