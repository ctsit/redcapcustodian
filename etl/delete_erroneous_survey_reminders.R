library(tidyverse)
library(lubridate)
library(dotenv)
library(redcapcustodian) # devtools::install_github("ctsit/redcapcustodian")
library(DBI)
library(RMariaDB)

init_etl("delete_erroneous_survey_reminders")

rc_conn <- connect_to_redcap_db()

# identify future scheduled reminders
sql_scheduled_reminders <- paste("
  select a.project_id, q.record, p.event_id, s.form_name, q.ssq_id
  from redcap_surveys_emails_recipients r, redcap_surveys_participants p,
    redcap_surveys s, redcap_projects a, redcap_surveys_scheduler_queue q
  where q.time_sent is null and
    q.email_recip_id = r.email_recip_id and
    p.survey_id = s.survey_id and
    r.participant_id = p.participant_id and
    s.project_id = a.project_id and
    a.date_deleted is null and
    a.completed_time is null and
    q.scheduled_time_to_send >= now() and
    q.status = 'QUEUED' and
    a.status <= 1 and
    a.online_offline = 1
  order by q.scheduled_time_to_send, q.ssq_id;
")

scheduled_reminders <- dbGetQuery(rc_conn, sql_scheduled_reminders) %>%
  mutate(field_name = paste0(form_name, "_complete"))

# check form completed status
df_params <- scheduled_reminders %>%
  select(
    project_id,
    event_id,
    record,
    field_name
  ) %>%
  distinct()

data_statement <- dbSendQuery(rc_conn, "
  SELECT * FROM redcap_data
  WHERE
  project_id = ? and
  event_id = ? and
  record = ? and
  field_name = ?
")

dbBind(data_statement, list(
  df_params$project_id,
  df_params$event_id,
  df_params$record,
  df_params$field_name
))

form_status <- dbFetch(data_statement)

reminders_to_deactivate <-
  scheduled_reminders %>%
  inner_join(form_status, by = c("project_id", "event_id", "record", "field_name")) %>%
  filter(value == 2)

if (nrow(reminders_to_deactivate) > 0) {
  # describe what needs to be deleted
  sql_reminders_to_delete <-
    paste(
      "delete from redcap_surveys_scheduler_queue where ssq_id in (",
      paste(reminders_to_deactivate$ssq_id, collapse = " "),
      ");"
    )
  rows_to_be_deleted <- tbl(rc_conn, "redcap_surveys_scheduler_queue") %>%
    filter(ssq_id %in% !!reminders_to_deactivate$ssq_id) %>%
    collect()

  # delete the erroneous rows
  rows_affected <- dbExecute(rc_conn, sql_reminders_to_delete)

  # Log what we did
  if (rows_affected == nrow(reminders_to_deactivate)) {
    deletions <- rows_to_be_deleted
    activity_log <- lst(
      deletions
    )
    log_job_success(jsonlite::toJSON(activity_log))
  } else {
    log_job_failure(jsonlite::toJSON(lst(rows_affected)))
  }
}

dbDisconnect(rc_conn)
