# Change Log
All notable changes to the redcapcustodian package and its contained scripts will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [1.6.0] - 2023-02-21
### Added
- Add randomization management functions and a sample ETL (Philip Chase)
- Add batch_size parm to dbx calls in sync_table_2 (Philip Chase)
- Add batch_size parm to dbx calls in sync_table Prevents possible error: Expression tree is too large (maximum depth 1000) (Kyle Chesney)

### Changed
- Update testing image used at github (Philip Chase)
- Eschew deprecated tidyselect features (Philip Chase)
- Modernize tests of sync_table_2 (Philip Chase)
- Address fatal bug in sync_table caused when delete = T but there are no records to delete (Kyle Chesney)


## [1.5.0] - 2023-01-25
### Added
- Create write_summary_metrics function, corresponding schema and test (Kyle Chesney)
- Add render_report to /report (Laurence James-Woodley)
- Port convert_schema_to_sqlite from rcc.billing, altering it to accept path to sql file as input (Kyle Chesney)
- Port mutate_columns_to_posixct from rcc.billing (Kyle Chesney)

### Changed
- Ignore local credentials DBs (Philip Chase)


## [1.4.1] - 2022-12-15
### Changed
- Install latex packages directly in Dockerfile (Laurence James-Woodley)


## [1.4.0] - 2022-12-13
### Added
- Switch Dockerfile from tidyverse to verse (Laurence James-Woodley)
- Add render_report.R to render Rmds (Laurence James-Woodley)


## [1.3.2] - 2022-09-14
### Changed
- Specify package for na.exclude() (Philip Chase)
- escape . to treat as literal character instead of wildcard in gsub statements (Kyle Chesney)


## [1.3.1] - 2022-08-30
### Added
- Remove remants of the site concept (Philip Chase)


## [1.3.0] - 2022-08-29
### Added
- Add get_bad_emails_from_individual_emails function (Kyle Chesney)


## [1.2.2] - 2022-08-26
### Changed
- Modernize container and add dependencies (Philip Chase)


## [1.2.1] - 2022-08-26
### Changed
- Move schema files into package space (Philip Chase)
- Correct send_email using email_to for email_cc (Kyle Chesney)


## [1.2.0] - 2022-08-25
### Added
- Add email_from and email_cc params to send_email function, default to env value (Kyle Chesney)


## [1.1.1] - 2022-08-24
### Changed
- Fix test for search results in get_bad_emails_from_listserv_digest (Philip Chase)


## [1.1.0] - 2022-08-08
### Added
- Add logging in Friday Call demo (Philip Chase)

### Changed
- Define username and tube count variables in friday call demo (Kyle Chesney)
- Move fake data section to setup file in Friday Call Demo (Philip Chase)
- Move credential creation and scraping from main friday call to auxiliary setup file (Kyle Chesney)


## [1.0.0] - 2022-08-02
### Added
- Add logging to suspend_users_with_no_primary_email (Philip Chase)
- Add sync_table2 a merge of dataset_diff and sync_table (Philip Chase)
- Add expire_user_project_rights (Philip Chase)

### Changed
- Use sync_table_2 in update_redcap_email_addresses (Philip Chase)
- Refactor tests and test data related to cleanup_bad_email_addresses.R (Philip Chase)
- Remove credentials for public image (mbentz-uf)
- Fix deployment of cron file (Philip Chase)
- Add common directories to template ignore files (Philip Chase)
- Fix ADD of my.study (Philip Chase)


## [0.7.0] - 2022-07-17
### Changed
- Add here package to Dockerfile (Philip Chase)
- Add send_email function adapted from stp (Kyle Chesney)
- Add DOI badge to README (Philip Chase)


## [0.6.1] - 2022-07-13
### Changed
- Fix typo in description (Philip Chase)


## [0.6.0] - 2022-07-13
### Added
- Add resources for publication (Philip Chase)
- Add friday-call-demo.Rmd (Kyle Chesney, Philip Chase)

### Changed
- Update ignore files to respect new features (Philip Chase)
- Replace reference to stp with rcc.billing (Kyle Chesney)
- Enlarge the job_summary_data field in rcc_job_log (Philip Chase)
- Add new content to custom_rscript (Philip Chase)
- Make docs study-centric (Philip Chase)
- Update DESCRIPTION and init_etl.Rd to satisfy R 4.2.1 (Philip Chase)
- Use *_PORT_DB in connect_to_db, defaulting to 3306 (Kyle Chesney)
- Move credentials DB (Philip Chase)
- Reduce earliest_date in cleanup_bad_email_addresses.R (Philip Chase)
- Use MariaDB as default driver in init_etl (Philip Chase)
- Update username to my_username to avoid tautological filter in credential gathering (Kyle Chesney)


## [0.5.1] - 2022-06-24
### Changed
- Export email-fixing functions (Philip Chase)


## [0.5.0] - 2022-06-23
### Added
- Add first version of a demonstration script (Philip Chase)
- Add sync_table (Kyle Chesney)
- Add dataset_diff (Philip Chase)
- Add multi_instance.R (Kyle Chesney)
- Add sync_metadata using credentials (Kyle Chesney)
- Add scrape_user_api_tokens (Kyle Chesney)
- Add set_super_api_token (Kyle Chesney)
- Add set_project_api_token (Kyle Chesney)
- Add ETL job logging(Michael Bentz)
- Add cleanup_bad_email_addresses (Laurence James-Woodley)

### Changed
- Ignore site_template in build (Philip Chase)
- Ignore ./output/ (Philip Chase)


## [0.4.1] - 2022-03-04
### Changed
- Fix build.sh deployment bugs (Philip Chase)


## [0.4.0] - 2022-03-03
### Added
- Remove host image concet and deploy from site project (Philip Chase)


## [0.3.0] - 2022-03-03
### Added
- Add mRpostman and writexl to the Dockerfile (Philip Chase)
- Add suspend_users_with_no_primary_email (Laurence James-Woodley)
- Add update_redcap_email_addresses (Laurence James-Woodley)

### Changed
- Fix get_redcap_email_revisions to match initial implementation allows it to create data that will result in user suspension (Kyle Chesney)


## [0.2.0] - 2022-02-16
### Added
- Add get_redcap_email_revisions (Michael Bentz)
- Add automated tests (Michael Bentz)
- Add create_test_tables (ChemiKyle)
- Add test tables (Kyle Chesney)
- Add get_bad_emails_from_listserv_digest (Philip Chase)
- Add get_institutional_person_data (Philip Chase)
- Add get_redcap_emails (Philip Chase)
- Add create_test_table (Philip Chase)
- Add site concept and docs (Philip Chase)
- Add add_get_redcap_db_connection (Philip Chase)
- Store rc_conn in env (Philip Chase)
- Add add_connect_to_redcap_db (Philip Chase)
- Add basic logging (Michael Bentz)


## [0.1.0] - 2021-06-22
### Summary
- Initial commit of redcapcustodian
- Scripted image building.
- Scripted deployment.
- redcapcustodian R package
- testthat for redcapcustodian tests
- Host-specific	customization of R scripts
- Host-specific customization of cron-files
- Host-specific customization of environment files
