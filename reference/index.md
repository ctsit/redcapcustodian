# Package index

## All functions

- [`build_etl_job_log_df()`](build_etl_job_log_df.md) : Builds formatted
  rcc_job_log data frame from source data

- [`build_formatted_df_from_result()`](build_formatted_df_from_result.md)
  : Builds formatted data frame from source data

- [`connect_to_db()`](connect_to_db.md) : Connect to db

- [`connect_to_log_db()`](connect_to_log_db.md) : Connect to the log db

- [`connect_to_redcap_db()`](connect_to_redcap_db.md) : Connect to the
  Primary REDCap MySQL Database Assigns package-scoped conn

- [`convert_schema_to_sqlite()`](convert_schema_to_sqlite.md) : Converts
  a MySQL schema file to a sqlite schema. Facilitates easier creation of
  in-memory (i.e. sqlite) tables.

- [`copy_entire_table_to_db()`](copy_entire_table_to_db.md) :
  copy_entire_table_to_db

- [`create_allocation_rows()`](create_allocation_rows.md) :
  create_allocation_rows

- [`create_randomization_row()`](create_randomization_row.md) :
  create_randomization_row

- [`create_test_table()`](create_test_table.md) : Create a test table
  from package schema and data files

- [`create_test_tables()`](create_test_tables.md) :

  A wrapper around `create_test_table` to create all tables, or a
  specified subset of them

- [`dataframe_to_redcap_dictionary()`](dataframe_to_redcap_dictionary.md)
  : Create a REDCap data dictionary from a dataframe

- [`dataset_diff()`](dataset_diff.md) : dataset_diff

- [`dataset_diff_test_bar_bang`](dataset_diff_test_bar_bang.md) :
  dataset_diff_test_bar_bang

- [`dataset_diff_test_user_data`](dataset_diff_test_user_data.md) :
  dataset_diff_test_user_data

- [`delete_project()`](delete_project.md) : Delete a Project from REDCap

- [`disable_non_interactive_quit()`](disable_non_interactive_quit.md) :

  Prevent `quit_non_interactive_run` from quitting. This is not meant to
  be used outside of tests. See test-write.R for an example.

- [`enable_randomization_on_a_preconfigured_project_in_production()`](enable_randomization_on_a_preconfigured_project_in_production.md)
  : enable_randomization_on_a_preconfigured_project_in_production

- [`evaluate_checksums()`](evaluate_checksums.md) : evaluate_checksums

- [`expire_user_project_rights()`](expire_user_project_rights.md) :
  Expire user rights to REDCap projects

- [`export_allocation_tables_from_project()`](export_allocation_tables_from_project.md)
  : export_allocation_tables_from_project

- [`get_bad_emails_from_individual_emails()`](get_bad_emails_from_individual_emails.md)
  : Scrape an inbox for bad email addresses in bounce messages

- [`get_bad_emails_from_listserv_digest()`](get_bad_emails_from_listserv_digest.md)
  : Enumerate bad email addresses described in LISTSERV email digests

- [`get_bad_emails_from_listserv_digest_test_output`](get_bad_emails_from_listserv_digest_test_output.md)
  : get_bad_emails_from_listserv_digest_test_output

- [`get_current_time()`](get_current_time.md) : Fetches the current time
  in system time zone

- [`get_hipaa_disclosure_log_from_ehr_fhir_logs()`](get_hipaa_disclosure_log_from_ehr_fhir_logs.md)
  : get_hipaa_disclosure_log_from_ehr_fhir_logs

- [`get_institutional_person_data()`](get_institutional_person_data.md)
  : A template function for fetching authoritative email address data
  and other institutional data

- [`get_job_duration()`](get_job_duration.md) : Provide the exact length
  of the time span between start time and end time

- [`get_package_scope_var()`](get_package_scope_var.md) : Get the value
  from the redcapcustodian.env environment

- [`get_project_instance()`](get_project_instance.md) : Fetches the
  package-scoped value of project_instance

- [`get_project_life_cycle()`](get_project_life_cycle.md) :
  get_project_life_cycle

- [`get_project_name()`](get_project_name.md) : Fetches the
  package-scoped value of project_name

- [`get_redcap_credentials()`](get_redcap_credentials.md) : Retrieve
  REDCap Credentials Based on Specified Parameters

- [`get_redcap_db_connection()`](get_redcap_db_connection.md) : Get
  connection to the primary REDCap database

- [`get_redcap_email_revisions()`](get_redcap_email_revisions.md) : Get
  redcap user email revisions

- [`get_redcap_email_revisions_test_data`](get_redcap_email_revisions_test_data.md)
  : get_redcap_email_revisions_test_data

- [`get_redcap_emails()`](get_redcap_emails.md) : Get all user emails in
  redcap_user_information as tall data

- [`get_redcap_emails_test_data`](get_redcap_emails_test_data.md) :
  get_redcap_emails_test_data

- [`get_script_name()`](get_script_name.md) : Fetches the package-scoped
  value of script_name

- [`get_script_run_time()`](get_script_run_time.md) : Fetches the
  package-scoped value of script_run_time

- [`get_table_checksum()`](get_table_checksum.md) : get_table_checksum

- [`get_test_table_names()`](get_test_table_names.md) : Provides a list
  of table names which have schema and data files as part of the package

- [`init_etl()`](init_etl.md) : Initialize all etl dependencies

- [`init_log_con()`](init_log_con.md) : Initialize the connection to the
  log db and set redcapcustodian.env\$log_con

- [`is_db_con()`](is_db_con.md) : Check if the provided connection is a
  DBI connection object

- [`is_on_ci()`](is_on_ci.md) : Check if "CI" environment variable is
  set to TRUE

- [`log_event_tables`](log_event_tables.md) : log_event_tables

- [`log_job_debug()`](log_job_debug.md) : Log a job debug entry

- [`log_job_failure()`](log_job_failure.md) : Log a failed job run

- [`log_job_success()`](log_job_success.md) : Log a successful job run

- [`mutate_columns_to_posixct()`](mutate_columns_to_posixct.md) :
  mutate_columns_to_posixct

- [`project_life_cycle_descriptions`](project_life_cycle_descriptions.md)
  : project_life_cycle_descriptions

- [`project_purpose_labels`](project_purpose_labels.md) :
  project_purpose_labels

- [`project_purpose_other_research_labels`](project_purpose_other_research_labels.md)
  : project_purpose_other_research_labels

- [`project_status_labels`](project_status_labels.md) :
  project_status_labels

- [`quit_non_interactive_run()`](quit_non_interactive_run.md) : Quit a
  non interactive R session

- [`render_report()`](render_report.md) : Render a Markdown Report from
  Rmd or Qmd Files

- [`scrape_user_api_tokens()`](scrape_user_api_tokens.md) : Gather all
  API tokens on a specified REDCap server for a given user

- [`send_email()`](send_email.md) : A wrapper function that sends an
  email (via sendmailR) reporting the outcome of another function

- [`set_package_scope_var()`](set_package_scope_var.md) :

  Assign a value to the redcapcustodian.env environment, retrievable
  with `get_package_scope_var`

- [`set_project_api_token()`](set_project_api_token.md) : Generate an
  API token for a REDCap project and assign it to a specified user

- [`set_project_instance()`](set_project_instance.md) : Sets the
  package-scoped value of project_instance

- [`set_project_name()`](set_project_name.md) : Sets the package-scoped
  value of project_name

- [`set_script_name()`](set_script_name.md) :

  Assigns package-scoped script_name.  
  By default this is sourced from the focused RStudio window or the
  calling command (e.g. Rscript script_name.R)

- [`set_script_run_time()`](set_script_run_time.md) : Sets the
  package-scoped value of script_run_time

- [`set_super_api_token()`](set_super_api_token.md) : Generate and set a
  Super API token for a provided REDCap user

- [`suspend_users_with_no_primary_email()`](suspend_users_with_no_primary_email.md)
  : Suspends users with no primary email in redcap_user_information

- [`sync_metadata()`](sync_metadata.md) : Sync data dictionary of a
  source project to a target project using credential objects

- [`sync_table()`](sync_table.md) :

  Write to a MySQL Database using the result of `dataset_diff`

- [`sync_table_2()`](sync_table_2.md) : Write to a MySQL Database based
  on the diff of source and target datasets.

- [`sync_table_test_user_data_result`](sync_table_test_user_data_result.md)
  : sync_table_test_user_data_result

- [`unnest_job_summary_data_json_object()`](unnest_job_summary_data_json_object.md)
  : unnest_job_summary_data_json_object

- [`update_production_allocation_state()`](update_production_allocation_state.md)
  : update_production_allocation_state

- [`update_redcap_email_addresses()`](update_redcap_email_addresses.md)
  : Updates bad redcap email addresses in redcap_user_information

- [`update_redcap_email_addresses_test_data`](update_redcap_email_addresses_test_data.md)
  : update_redcap_email_addresses_test_data

- [`user_rights_test_data`](user_rights_test_data.md) :
  user_rights_test_data

- [`verify_log_connectivity()`](verify_log_connectivity.md) : Attempts
  to connect to the DB using all LOG_DB\_\* environment variables.
  Returns an empty list if a connection is established, returns an
  \`error_list\` entry otherwise.

- [`verify_log_dependencies()`](verify_log_dependencies.md) : Verifies
  all dependencies required to write log entries.

- [`verify_log_env_variables()`](verify_log_env_variables.md) : Verifies
  all required environment variables are set. Returns an empty list if
  all necessary environment variables are set, returns a list of errors
  otherwise.

- [`write_allocations()`](write_allocations.md) : write_allocations

- [`write_debug_job_log_entry()`](write_debug_job_log_entry.md) : Write
  a debug log entry for the job

- [`write_error_job_log_entry()`](write_error_job_log_entry.md) : Write
  an error log entry for the job

- [`write_error_log_entry()`](write_error_log_entry.md) : Write an error
  log entry

- [`write_info_log_entry()`](write_info_log_entry.md) : Write an info
  log entry

- [`write_success_job_log_entry()`](write_success_job_log_entry.md) :
  Write an success job log entry

- [`write_summary_metrics()`](write_summary_metrics.md) : Format and
  write summary metrics to the redcap_summary_metrics table in your
  LOG_DB

- [`write_to_sql_db()`](write_to_sql_db.md) : Write to a MySQL Database
  with error checking and email alerting on failure
