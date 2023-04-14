log_event_tables <- c(
  "redcap_log_event",
  "redcap_log_event2",
  "redcap_log_event3",
  "redcap_log_event4",
  "redcap_log_event5",
  "redcap_log_event6",
  "redcap_log_event7",
  "redcap_log_event8",
  "redcap_log_event9"
)

# write the test data
usethis::use_data(log_event_tables, overwrite = T)
