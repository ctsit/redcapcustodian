# Changelog

## redcapcustodian 1.28.2 (released 2026-06-22)

- Update container and refactor CI
  ([@pbchase](https://github.com/pbchase),
  [\#180](https://github.com/ctsit/redcapcustodian/issues/180))

## redcapcustodian 1.28.1 (released 2025-02-20)

- Fix Dockerfile ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.28.0 (released 2025-02-20)

- Update get_hipaa_disclosure_log_from_ehr_fhir_logs()
  ([@pbchase](https://github.com/pbchase),
  [\#176](https://github.com/ctsit/redcapcustodian/issues/176))
- Add redcap_ehr_settings values to the disclosures
  ([@saipavan10-git](https://github.com/saipavan10-git),
  [\#172](https://github.com/ctsit/redcapcustodian/issues/172),
  [\#175](https://github.com/ctsit/redcapcustodian/issues/175))

## redcapcustodian 1.27.0 (released 2024-12-11)

- Allow multiple EHR IDs in
  get_hipaa_disclosure_log_from_ehr_fhir_logs()
  ([@pbchase](https://github.com/pbchase),
  [\#173](https://github.com/ctsit/redcapcustodian/issues/173),
  [\#174](https://github.com/ctsit/redcapcustodian/issues/174))
- Include dependency setup in gh-action for tests
  ([@saipavan10-git](https://github.com/saipavan10-git),
  [\#171](https://github.com/ctsit/redcapcustodian/issues/171))
- Improve logging for delete_project function
  ([@saipavan10-git](https://github.com/saipavan10-git),
  [\#171](https://github.com/ctsit/redcapcustodian/issues/171))
- Use parameters in get_hipaa_disclosure_log_from_ehr_fhir_logs.R
  ([@pbchase](https://github.com/pbchase),
  [@saipavan10-git](https://github.com/saipavan10-git)
  [\#162](https://github.com/ctsit/redcapcustodian/issues/162))

## redcapcustodian 1.26.2 (released 2024-11-20)

- Add new production status
  ([@saipavan10-git](https://github.com/saipavan10-git),
  [\#168](https://github.com/ctsit/redcapcustodian/issues/168),
  [\#170](https://github.com/ctsit/redcapcustodian/issues/170))
- Add log event tables 10,11,12
  ([@saipavan10-git](https://github.com/saipavan10-git),
  [\#168](https://github.com/ctsit/redcapcustodian/issues/168),
  [\#170](https://github.com/ctsit/redcapcustodian/issues/170))

## redcapcustodian 1.26.1 (released 2024-11-03)

- Use latest rstudio-ci in run-tests.yaml
  ([@pbchase](https://github.com/pbchase),
  [\#167](https://github.com/ctsit/redcapcustodian/issues/167))
- Address check errors ([@pbchase](https://github.com/pbchase),
  [\#167](https://github.com/ctsit/redcapcustodian/issues/167))
- remove log and output folder from study_template
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#167](https://github.com/ctsit/redcapcustodian/issues/167))
- write log file to tempdir ([@ljwoodley](https://github.com/ljwoodley),
  [\#167](https://github.com/ctsit/redcapcustodian/issues/167))

## redcapcustodian 1.26.0 (released 2024-10-30)

- Update Dockerfile to rocker/verse:4.4.1
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.25.0 (released 2024-10-24)

- Add report crash logging to render_report.R
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#166](https://github.com/ctsit/redcapcustodian/issues/166))
- Update render_report.R to use render_report() function
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#166](https://github.com/ctsit/redcapcustodian/issues/166))
- Add render_report() ([@ljwoodley](https://github.com/ljwoodley),
  [\#166](https://github.com/ctsit/redcapcustodian/issues/166))

## redcapcustodian 1.24.0 (released 2024-10-17)

- Add job failure alerts with run_etl.R and updates to send_mail()
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#100](https://github.com/ctsit/redcapcustodian/issues/100),
  [\#165](https://github.com/ctsit/redcapcustodian/issues/165))
- Add Sai as author in DESCRIPTION
  ([@pbchase](https://github.com/pbchase))
- Filter out deleted projects in scrape_user_api_tokens()
  ([@pbchase](https://github.com/pbchase),
  [\#163](https://github.com/ctsit/redcapcustodian/issues/163),
  [\#164](https://github.com/ctsit/redcapcustodian/issues/164))
- Move Roxygen2 to 7.3.2 ([@pbchase](https://github.com/pbchase))
- Add get_hipaa_disclosure_log_from_ehr_fhir_logs()
  ([@pbchase](https://github.com/pbchase),
  [\#158](https://github.com/ctsit/redcapcustodian/issues/158))
- Update run-tests.yaml to use rstudio-ci:4.3.3
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.23.0 (released 2024-06-13)

- Add project and instance to logging
  ([@ljwoodley](https://github.com/ljwoodley),
  [@pbchase](https://github.com/pbchase),
  [\#159](https://github.com/ctsit/redcapcustodian/issues/159),
  [\#160](https://github.com/ctsit/redcapcustodian/issues/160))

## redcapcustodian 1.22.2 (released 2024-04-26)

- Restore ‘writexl’ to Dockerfile
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.22.1 (released 2024-04-23)

- Update run-tests.yaml to use rstudio-ci:4.3.3
  ([@pbchase](https://github.com/pbchase),
  [\#157](https://github.com/ctsit/redcapcustodian/issues/157))
- Switch send_mail() to use openxlsx
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#152](https://github.com/ctsit/redcapcustodian/issues/152),
  [\#157](https://github.com/ctsit/redcapcustodian/issues/157))

## redcapcustodian 1.22.0 (released 2024-03-26)

- Implement hacky fix for tlmgr 2023 being unable to install packages
  ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#156](https://github.com/ctsit/redcapcustodian/issues/156))
- Fix bug that prevented email_body from being included in email
  ([@ljwoodley](https://github.com/ljwoodley),
  [@ChemiKyle](https://github.com/ChemiKyle),
  [\#155](https://github.com/ctsit/redcapcustodian/issues/155))
- Add ‘Scraping one user’s API tokens’ section to
  vignettes/credential-scraping.Rmd
  ([@pbchase](https://github.com/pbchase),
  [@ChemiKyle](https://github.com/ChemiKyle),
  [\#154](https://github.com/ctsit/redcapcustodian/issues/154))
- Update scrape_user_api_tokens() to tidyselect 1.2 standards
  ([@pbchase](https://github.com/pbchase),
  [\#154](https://github.com/ctsit/redcapcustodian/issues/154))

## redcapcustodian 1.21.0 (released 2024-03-15)

- Add attachment management to send_email() allowing lists of files or
  dataframes to be attached to an email
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#152](https://github.com/ctsit/redcapcustodian/issues/152),
  [\#153](https://github.com/ctsit/redcapcustodian/issues/153))

## redcapcustodian 1.20.0 (released 2024-02-28)

- Add get_redcap_credentials()
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#149](https://github.com/ctsit/redcapcustodian/issues/149),
  [\#151](https://github.com/ctsit/redcapcustodian/issues/151))
- Revert “add redcap wrapper functions”
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#149](https://github.com/ctsit/redcapcustodian/issues/149),
  [\#150](https://github.com/ctsit/redcapcustodian/issues/150))

## redcapcustodian 1.19.0 (released 2024-01-30)

- Add REDCapR wrapper functions
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#147](https://github.com/ctsit/redcapcustodian/issues/147),
  [\#148](https://github.com/ctsit/redcapcustodian/issues/148))

## redcapcustodian 1.18.0 (released 2024-01-10)

- Update Dockerfile to verse:4.3.2
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.17.4 (released 2023-11-22)

- Turn off code chunks in job_logging.Rmd to fix
  pkgdown::deploy_to_branch() errors
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.17.3 (released 2023-11-21)

- Fix 4 intermittent test failures caused by environment vars
  ([@pbchase](https://github.com/pbchase),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))
- Fix error in test ‘init_etl properly sets script name, script run
  time, and initializes log connection’
  ([@pbchase](https://github.com/pbchase),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))
- Fix 11 warnings about dplyr::all_equal() in tests
  ([@pbchase](https://github.com/pbchase),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))
- Address lots of pkgdown::build_site() complaints about
  garbage-collected connections ([@pbchase](https://github.com/pbchase),
  [@ChemiKyle](https://github.com/ChemiKyle),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))
- Address pkgdown::build_site() complaints about non-parsable code
  examples ([@pbchase](https://github.com/pbchase),
  [@ChemiKyle](https://github.com/ChemiKyle),
  [\#104](https://github.com/ctsit/redcapcustodian/issues/104),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))
- Update vignettes/job_logging.Rmd to fix build errors
  ([@pbchase](https://github.com/pbchase),
  [\#143](https://github.com/ctsit/redcapcustodian/issues/143))

## redcapcustodian 1.17.2 (released 2023-11-17)

- Update vignettes/job_logging.Rmd to fix build errors
  ([@pbchase](https://github.com/pbchase),
  [\#142](https://github.com/ctsit/redcapcustodian/issues/142))

## redcapcustodian 1.17.1 (released 2023-11-17)

- Fix build failures caused by vignettes/job_logging.Rmd
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.17.0 (released 2023-11-17)

- Add job_logging vignette ([@pbchase](https://github.com/pbchase),
  [\#113](https://github.com/ctsit/redcapcustodian/issues/113),
  [\#115](https://github.com/ctsit/redcapcustodian/issues/115))
- Add objects_to_include param to unnest_job_summary_data_json_object()
  ([@pbchase](https://github.com/pbchase),
  [\#112](https://github.com/ctsit/redcapcustodian/issues/112),
  [\#115](https://github.com/ctsit/redcapcustodian/issues/115))

## redcapcustodian 1.16.0 (released 2023-11-16)

- Add MySQL database comparison tools
  ([@pbchase](https://github.com/pbchase),
  [@ChemiKyle](https://github.com/ChemiKyle),
  [\#140](https://github.com/ctsit/redcapcustodian/issues/140))

## redcapcustodian 1.15.0 (released 2023-10-31)

- Fix test data for get_redcap_email_revisions()
  ([@pbchase](https://github.com/pbchase))
- Add delete_project() ([@ljwoodley](https://github.com/ljwoodley),
  [\#139](https://github.com/ctsit/redcapcustodian/issues/139))
- Add dataframe_to_redcap_dictionary()
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#136](https://github.com/ctsit/redcapcustodian/issues/136))

## redcapcustodian 1.14.1 (released 2023-08-24)

- Update etl/delete_erroneous_survey_reminders.R
  ([@pbchase](https://github.com/pbchase),
  [\#137](https://github.com/ctsit/redcapcustodian/issues/137))

## redcapcustodian 1.14.0 (released 2023-08-14)

- Fix build issues on Apple silicon
  ([@pbchase](https://github.com/pbchase),
  [\#133](https://github.com/ctsit/redcapcustodian/issues/133),
  [\#134](https://github.com/ctsit/redcapcustodian/issues/134))
- Add delete_erroneous_survey_reminders.R
  ([@pbchase](https://github.com/pbchase),
  [\#131](https://github.com/ctsit/redcapcustodian/issues/131),
  [\#132](https://github.com/ctsit/redcapcustodian/issues/132))

## redcapcustodian 1.13.1 (released 2023-08-04)

- update render_report to handle qmd files
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#117](https://github.com/ctsit/redcapcustodian/issues/117),
  [\#129](https://github.com/ctsit/redcapcustodian/issues/129))
- Add LICENSE ([@pbchase](https://github.com/pbchase),
  [\#119](https://github.com/ctsit/redcapcustodian/issues/119),
  [\#124](https://github.com/ctsit/redcapcustodian/issues/124))

## redcapcustodian 1.13.0 (released 2023-06-23)

- Add project_purpose_other_research_labels.rda
  ([@pbchase](https://github.com/pbchase),
  [\#123](https://github.com/ctsit/redcapcustodian/issues/123))
- Add project_status_labels and project_purpose_labels
  ([@pbchase](https://github.com/pbchase),
  [\#122](https://github.com/ctsit/redcapcustodian/issues/122))
- Add conn parameter to write_summary_metrics()
  ([@pbchase](https://github.com/pbchase),
  [\#122](https://github.com/ctsit/redcapcustodian/issues/122))
- Add copy_entire_table_to_db() ([@pbchase](https://github.com/pbchase),
  [\#122](https://github.com/ctsit/redcapcustodian/issues/122))
- Update render_report.R to support quarto files
  ([@pbchase](https://github.com/pbchase),
  [\#118](https://github.com/ctsit/redcapcustodian/issues/118))

## redcapcustodian 1.12.0 (released 2023-06-02)

- Add unnest_job_summary_data_json_object()
  ([@pbchase](https://github.com/pbchase),
  [\#111](https://github.com/ctsit/redcapcustodian/issues/111))
- Fix Version in DESCRIPTION ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.11.0 (released 2023-05-10)

- Add description_base_name to get_project_life_cycle() output.
  ([@pbchase](https://github.com/pbchase),
  [\#110](https://github.com/ctsit/redcapcustodian/issues/110))
- Expand list of descriptions in project_life_cycle_descriptions to
  include more modern
  descriptions.([@pbchase](https://github.com/pbchase),
  [\#110](https://github.com/ctsit/redcapcustodian/issues/110))

## redcapcustodian 1.10.0 (released 2023-04-24)

- Add project_life_cycle_descriptions
  ([@pbchase](https://github.com/pbchase),
  [\#106](https://github.com/ctsit/redcapcustodian/issues/106))
- Add get_project_life_cycle() ([@pbchase](https://github.com/pbchase),
  [\#106](https://github.com/ctsit/redcapcustodian/issues/106))

## redcapcustodian 1.9.0 (released 2023-04-24)

- Add quarto and tlmgr packages it needs for pdf generation
  ([@pbchase](https://github.com/pbchase),
  [\#107](https://github.com/ctsit/redcapcustodian/issues/107))

## redcapcustodian 1.8.1 (released 2023-03-20)

- Update NEWS.md and DESCRIPTION to comply with pkgdown
  ([@pbchase](https://github.com/pbchase),
  [\#103](https://github.com/ctsit/redcapcustodian/issues/103))

## redcapcustodian 1.8.0 (released 2023-03-17)

#### Added

- Add a log database system for dev work
  ([@pbchase](https://github.com/pbchase),
  [\#110](https://github.com/ctsit/redcapcustodian/issues/110))

#### Changed

- Fix ORCIDs in DESCRIPTION ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.7.0 (released 2023-03-17)

#### Added

- Add a pkgdown website ([@pbchase](https://github.com/pbchase),
  [\#102](https://github.com/ctsit/redcapcustodian/issues/102))

#### Changed

- Revise the package title away from REDCap and towards automation
  ([@pbchase](https://github.com/pbchase))
- Remove publication_date from .zenodo.json
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.6.0 (released 2023-02-21)

#### Added

- Add randomization management functions and a sample ETL
  ([@pbchase](https://github.com/pbchase),
  [\#99](https://github.com/ctsit/redcapcustodian/issues/99))
- Add batch_size parm to dbx calls in sync_table_2
  ([@pbchase](https://github.com/pbchase))
- Add batch_size parm to dbx calls in sync_table Prevents possible
  error: Expression tree is too large (maximum depth 1000)
  ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#96](https://github.com/ctsit/redcapcustodian/issues/96))

#### Changed

- Update testing image used at github
  ([@pbchase](https://github.com/pbchase))
- Eschew deprecated tidyselect features
  ([@pbchase](https://github.com/pbchase),
  [\#98](https://github.com/ctsit/redcapcustodian/issues/98))
- Modernize tests of sync_table_2
  ([@pbchase](https://github.com/pbchase))
- Address fatal bug in sync_table caused when delete = T but there are
  no records to delete ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#97](https://github.com/ctsit/redcapcustodian/issues/97))

## redcapcustodian 1.5.0 (released 2023-01-25)

#### Added

- Create write_summary_metrics function, corresponding schema and test
  ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#95](https://github.com/ctsit/redcapcustodian/issues/95))
- Add render_report to /report
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#93](https://github.com/ctsit/redcapcustodian/issues/93))
- Port convert_schema_to_sqlite from rcc.billing, altering it to accept
  path to sql file as input ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#94](https://github.com/ctsit/redcapcustodian/issues/94))
- Port mutate_columns_to_posixct from rcc.billing
  ([@ChemiKyle](https://github.com/ChemiKyle),
  [\#94](https://github.com/ctsit/redcapcustodian/issues/94))

#### Changed

- Ignore local credentials DBs ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.4.1 (released 2022-12-15)

#### Changed

- Install latex packages directly in Dockerfile
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#91](https://github.com/ctsit/redcapcustodian/issues/91))

## redcapcustodian 1.4.0 (released 2022-12-13)

#### Added

- Switch Dockerfile from tidyverse to verse
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#90](https://github.com/ctsit/redcapcustodian/issues/90))
- Add render_report.R to render Rmds
  ([@ljwoodley](https://github.com/ljwoodley),
  [\#90](https://github.com/ctsit/redcapcustodian/issues/90))

## redcapcustodian 1.3.2 (released 2022-09-14)

#### Changed

- Specify package for na.exclude()
  ([@pbchase](https://github.com/pbchase))
- escape . to treat as literal character instead of wildcard in gsub
  statements ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 1.3.1 (released 2022-08-30)

#### Added

- Remove remants of the site concept
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.3.0 (released 2022-08-29)

#### Added

- Add get_bad_emails_from_individual_emails function
  ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 1.2.2 (released 2022-08-26)

#### Changed

- Modernize container and add dependencies
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.2.1 (released 2022-08-26)

#### Changed

- Move schema files into package space
  ([@pbchase](https://github.com/pbchase))
- Correct send_email using email_to for email_cc
  ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 1.2.0 (released 2022-08-25)

#### Added

- Add email_from and email_cc params to send_email function, default to
  env value ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 1.1.1 (released 2022-08-24)

#### Changed

- Fix test for search results in get_bad_emails_from_listserv_digest
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 1.1.0 (released 2022-08-08)

#### Added

- Add logging in Friday Call demo
  ([@pbchase](https://github.com/pbchase))

#### Changed

- Define username and tube count variables in friday call demo
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Move fake data section to setup file in Friday Call Demo
  ([@pbchase](https://github.com/pbchase))
- Move credential creation and scraping from main friday call to
  auxiliary setup file ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 1.0.0 (released 2022-08-02)

#### Added

- Add logging to suspend_users_with_no_primary_email
  ([@pbchase](https://github.com/pbchase))
- Add sync_table2 a merge of dataset_diff and sync_table
  ([@pbchase](https://github.com/pbchase))
- Add expire_user_project_rights
  ([@pbchase](https://github.com/pbchase))

#### Changed

- Use sync_table_2 in update_redcap_email_addresses
  ([@pbchase](https://github.com/pbchase))
- Refactor tests and test data related to cleanup_bad_email_addresses.R
  ([@pbchase](https://github.com/pbchase))
- Remove credentials for public image
  ([@mbentz-uf](https://github.com/mbentz-uf))
- Fix deployment of cron file ([@pbchase](https://github.com/pbchase))
- Add common directories to template ignore files
  ([@pbchase](https://github.com/pbchase))
- Fix ADD of my.study ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.7.0 (released 2022-07-17)

#### Changed

- Add here package to Dockerfile
  ([@pbchase](https://github.com/pbchase))
- Add send_email function adapted from stp
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Add DOI badge to README ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.6.1 (released 2022-07-13)

#### Changed

- Fix typo in description ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.6.0 (released 2022-07-13)

#### Added

- Add resources for publication ([@pbchase](https://github.com/pbchase))
- Add friday-call-demo.Rmd ([@ChemiKyle](https://github.com/ChemiKyle),
  [@pbchase](https://github.com/pbchase))

#### Changed

- Update ignore files to respect new features
  ([@pbchase](https://github.com/pbchase))
- Replace reference to stp with rcc.billing
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Enlarge the job_summary_data field in rcc_job_log
  ([@pbchase](https://github.com/pbchase))
- Add new content to custom_rscript
  ([@pbchase](https://github.com/pbchase))
- Make docs study-centric ([@pbchase](https://github.com/pbchase))
- Update DESCRIPTION and init_etl.Rd to satisfy R 4.2.1
  ([@pbchase](https://github.com/pbchase))
- Use \*\_PORT_DB in connect_to_db, defaulting to 3306
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Move credentials DB ([@pbchase](https://github.com/pbchase))
- Reduce earliest_date in cleanup_bad_email_addresses.R
  ([@pbchase](https://github.com/pbchase))
- Use MariaDB as default driver in init_etl
  ([@pbchase](https://github.com/pbchase))
- Update username to my_username to avoid tautological filter in
  credential gathering ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 0.5.1 (released 2022-06-24)

#### Changed

- Export email-fixing functions ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.5.0 (released 2022-06-23)

#### Added

- Add first version of a demonstration script
  ([@pbchase](https://github.com/pbchase))
- Add sync_table ([@ChemiKyle](https://github.com/ChemiKyle))
- Add dataset_diff ([@pbchase](https://github.com/pbchase))
- Add multi_instance.R ([@ChemiKyle](https://github.com/ChemiKyle))
- Add sync_metadata using credentials
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Add scrape_user_api_tokens
  ([@ChemiKyle](https://github.com/ChemiKyle))
- Add set_super_api_token ([@ChemiKyle](https://github.com/ChemiKyle))
- Add set_project_api_token ([@ChemiKyle](https://github.com/ChemiKyle))
- Add ETL job logging([@mbentz-uf](https://github.com/mbentz-uf))
- Add cleanup_bad_email_addresses
  ([@ljwoodley](https://github.com/ljwoodley))

#### Changed

- Ignore site_template in build ([@pbchase](https://github.com/pbchase))
- Ignore ./output/ ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.4.1 (released 2022-03-04)

#### Changed

- Fix build.sh deployment bugs ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.4.0 (released 2022-03-03)

#### Added

- Remove host image concet and deploy from site project
  ([@pbchase](https://github.com/pbchase))

## redcapcustodian 0.3.0 (released 2022-03-03)

#### Added

- Add mRpostman and writexl to the Dockerfile
  ([@pbchase](https://github.com/pbchase))
- Add suspend_users_with_no_primary_email
  ([@ljwoodley](https://github.com/ljwoodley))
- Add update_redcap_email_addresses
  ([@ljwoodley](https://github.com/ljwoodley))

#### Changed

- Fix get_redcap_email_revisions to match initial implementation allows
  it to create data that will result in user suspension
  ([@ChemiKyle](https://github.com/ChemiKyle))

## redcapcustodian 0.2.0 (released 2022-02-16)

#### Added

- Add get_redcap_email_revisions
  ([@mbentz-uf](https://github.com/mbentz-uf))
- Add automated tests ([@mbentz-uf](https://github.com/mbentz-uf))
- Add create_test_tables ([@ChemiKyle](https://github.com/ChemiKyle))
- Add test tables ([@ChemiKyle](https://github.com/ChemiKyle))
- Add get_bad_emails_from_listserv_digest
  ([@pbchase](https://github.com/pbchase))
- Add get_institutional_person_data
  ([@pbchase](https://github.com/pbchase))
- Add get_redcap_emails ([@pbchase](https://github.com/pbchase))
- Add create_test_table ([@pbchase](https://github.com/pbchase))
- Add site concept and docs ([@pbchase](https://github.com/pbchase))
- Add add_get_redcap_db_connection
  ([@pbchase](https://github.com/pbchase))
- Store rc_conn in env ([@pbchase](https://github.com/pbchase))
- Add add_connect_to_redcap_db ([@pbchase](https://github.com/pbchase))
- Add basic logging ([@mbentz-uf](https://github.com/mbentz-uf))

## redcapcustodian 0.1.0 (released 2021-06-22)

#### Summary

- Initial commit of redcapcustodian
- Scripted image building.
- Scripted deployment.
- redcapcustodian R package
- testthat for redcapcustodian tests
- Host-specific customization of R scripts
- Host-specific customization of cron-files
- Host-specific customization of environment files
