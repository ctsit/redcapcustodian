# redcapcustodian 1.20.0 (released 2024-02-28)
- Add get_redcap_credentials() (@ljwoodley, #149, #151)
- Revert "add redcap wrapper functions" (@ljwoodley, #149, #150)

# redcapcustodian 1.19.0 (released 2024-01-30)
- Add REDCapR wrapper functions (@ljwoodley, #147, #148)

# redcapcustodian 1.18.0 (released 2024-01-10)
- Update Dockerfile to verse:4.3.2 (@pbchase)

# redcapcustodian 1.17.4 (released 2023-11-22)
- Turn off code chunks in job_logging.Rmd to fix pkgdown::deploy_to_branch() errors (@pbchase)

# redcapcustodian 1.17.3 (released 2023-11-21)
- Fix 4 intermittent test failures caused by environment vars (@pbchase, #143)
- Fix error in test 'init_etl properly sets script name, script run time, and initializes log connection' (@pbchase, #143)
- Fix 11 warnings about dplyr::all_equal() in tests (@pbchase, #143)
- Address lots of pkgdown::build_site() complaints about garbage-collected connections (@pbchase, @ChemiKyle, #143)
- Address pkgdown::build_site() complaints about non-parsable code examples (@pbchase, @ChemiKyle, #104, #143)
- Update vignettes/job_logging.Rmd to fix build errors (@pbchase, #143)

# redcapcustodian 1.17.2 (released 2023-11-17)
- Update vignettes/job_logging.Rmd to fix build errors (@pbchase, #142)

# redcapcustodian 1.17.1 (released 2023-11-17)
- Fix build failures caused by vignettes/job_logging.Rmd (@pbchase)

# redcapcustodian 1.17.0 (released 2023-11-17)
- Add job_logging vignette (@pbchase, #113, #115)
- Add objects_to_include param to unnest_job_summary_data_json_object() (@pbchase, #112, #115)

# redcapcustodian 1.16.0 (released 2023-11-16)
- Add MySQL database comparison tools (@pbchase, @ChemiKyle, #140)

# redcapcustodian 1.15.0 (released 2023-10-31)
- Fix test data for get_redcap_email_revisions() (@pbchase)
- Add delete_project() (@ljwoodley, #139)
- Add dataframe_to_redcap_dictionary() (@ljwoodley, #136)

# redcapcustodian 1.14.1 (released 2023-08-24)
- Update etl/delete_erroneous_survey_reminders.R (@pbchase, #137)

# redcapcustodian 1.14.0 (released 2023-08-14)
- Fix build issues on Apple silicon (@pbchase, #133, #134)
- Add delete_erroneous_survey_reminders.R (@pbchase, #131, #132)

# redcapcustodian 1.13.1 (released 2023-08-04)
- update render_report to handle qmd files (@ljwoodley, #117, #129)
- Add LICENSE (@pbchase, #119, #124)

# redcapcustodian 1.13.0 (released 2023-06-23)
- Add project_purpose_other_research_labels.rda (@pbchase, #123)
- Add project_status_labels and project_purpose_labels (@pbchase, #122)
- Add conn parameter to write_summary_metrics() (@pbchase, #122)
- Add copy_entire_table_to_db() (@pbchase, #122)
- Update render_report.R to support quarto files (@pbchase, #118)

# redcapcustodian 1.12.0 (released 2023-06-02)
- Add unnest_job_summary_data_json_object() (@pbchase, #111)
- Fix Version in DESCRIPTION (@pbchase)

# redcapcustodian 1.11.0 (released 2023-05-10)
- Add description_base_name to get_project_life_cycle() output. (@pbchase, #110)
- Expand list of descriptions in project_life_cycle_descriptions to include more modern descriptions.(@pbchase, #110)

# redcapcustodian 1.10.0 (released 2023-04-24)
- Add project_life_cycle_descriptions (@pbchase, #106)
- Add get_project_life_cycle() (@pbchase, #106)

# redcapcustodian 1.9.0 (released 2023-04-24)
- Add quarto and tlmgr packages it needs for pdf generation (@pbchase, #107)

# redcapcustodian 1.8.1 (released 2023-03-20)
- Update NEWS.md and DESCRIPTION to comply with pkgdown (@pbchase, #103)

# redcapcustodian 1.8.0 (released 2023-03-17)
### Added
- Add a log database system for dev work (@pbchase, #110)

### Changed
- Fix ORCIDs in DESCRIPTION (@pbchase)


# redcapcustodian 1.7.0 (released 2023-03-17)
### Added
- Add a pkgdown website (@pbchase, #102)

### Changed
- Revise the package title away from REDCap and towards automation (@pbchase)
- Remove publication_date from .zenodo.json (@pbchase)


# redcapcustodian 1.6.0 (released 2023-02-21)
### Added
- Add randomization management functions and a sample ETL (@pbchase, #99)
- Add batch_size parm to dbx calls in sync_table_2 (@pbchase)
- Add batch_size parm to dbx calls in sync_table Prevents possible error: Expression tree is too large (maximum depth 1000) (@ChemiKyle, #96)

### Changed
- Update testing image used at github (@pbchase)
- Eschew deprecated tidyselect features (@pbchase, #98)
- Modernize tests of sync_table_2 (@pbchase)
- Address fatal bug in sync_table caused when delete = T but there are no records to delete (@ChemiKyle, #97)


# redcapcustodian 1.5.0 (released 2023-01-25)
### Added
- Create write_summary_metrics function, corresponding schema and test (@ChemiKyle, #95)
- Add render_report to /report (@ljwoodley, #93)
- Port convert_schema_to_sqlite from rcc.billing, altering it to accept path to sql file as input (@ChemiKyle, #94)
- Port mutate_columns_to_posixct from rcc.billing (@ChemiKyle, #94)

### Changed
- Ignore local credentials DBs (@pbchase)


# redcapcustodian 1.4.1 (released 2022-12-15)
### Changed
- Install latex packages directly in Dockerfile (@ljwoodley, #91)


# redcapcustodian 1.4.0 (released 2022-12-13)
### Added
- Switch Dockerfile from tidyverse to verse (@ljwoodley, #90)
- Add render_report.R to render Rmds (@ljwoodley, #90)


# redcapcustodian 1.3.2 (released 2022-09-14)
### Changed
- Specify package for na.exclude() (@pbchase)
- escape . to treat as literal character instead of wildcard in gsub statements (@ChemiKyle)


# redcapcustodian 1.3.1 (released 2022-08-30)
### Added
- Remove remants of the site concept (@pbchase)


# redcapcustodian 1.3.0 (released 2022-08-29)
### Added
- Add get_bad_emails_from_individual_emails function (@ChemiKyle)


# redcapcustodian 1.2.2 (released 2022-08-26)
### Changed
- Modernize container and add dependencies (@pbchase)


# redcapcustodian 1.2.1 (released 2022-08-26)
### Changed
- Move schema files into package space (@pbchase)
- Correct send_email using email_to for email_cc (@ChemiKyle)


# redcapcustodian 1.2.0 (released 2022-08-25)
### Added
- Add email_from and email_cc params to send_email function, default to env value (@ChemiKyle)


# redcapcustodian 1.1.1 (released 2022-08-24)
### Changed
- Fix test for search results in get_bad_emails_from_listserv_digest (@pbchase)


# redcapcustodian 1.1.0 (released 2022-08-08)
### Added
- Add logging in Friday Call demo (@pbchase)

### Changed
- Define username and tube count variables in friday call demo (@ChemiKyle)
- Move fake data section to setup file in Friday Call Demo (@pbchase)
- Move credential creation and scraping from main friday call to auxiliary setup file (@ChemiKyle)


# redcapcustodian 1.0.0 (released 2022-08-02)
### Added
- Add logging to suspend_users_with_no_primary_email (@pbchase)
- Add sync_table2 a merge of dataset_diff and sync_table (@pbchase)
- Add expire_user_project_rights (@pbchase)

### Changed
- Use sync_table_2 in update_redcap_email_addresses (@pbchase)
- Refactor tests and test data related to cleanup_bad_email_addresses.R (@pbchase)
- Remove credentials for public image (@mbentz-uf)
- Fix deployment of cron file (@pbchase)
- Add common directories to template ignore files (@pbchase)
- Fix ADD of my.study (@pbchase)


# redcapcustodian 0.7.0 (released 2022-07-17)
### Changed
- Add here package to Dockerfile (@pbchase)
- Add send_email function adapted from stp (@ChemiKyle)
- Add DOI badge to README (@pbchase)


# redcapcustodian 0.6.1 (released 2022-07-13)
### Changed
- Fix typo in description (@pbchase)


# redcapcustodian 0.6.0 (released 2022-07-13)
### Added
- Add resources for publication (@pbchase)
- Add friday-call-demo.Rmd (@ChemiKyle, @pbchase)

### Changed
- Update ignore files to respect new features (@pbchase)
- Replace reference to stp with rcc.billing (@ChemiKyle)
- Enlarge the job_summary_data field in rcc_job_log (@pbchase)
- Add new content to custom_rscript (@pbchase)
- Make docs study-centric (@pbchase)
- Update DESCRIPTION and init_etl.Rd to satisfy R 4.2.1 (@pbchase)
- Use *_PORT_DB in connect_to_db, defaulting to 3306 (@ChemiKyle)
- Move credentials DB (@pbchase)
- Reduce earliest_date in cleanup_bad_email_addresses.R (@pbchase)
- Use MariaDB as default driver in init_etl (@pbchase)
- Update username to my_username to avoid tautological filter in credential gathering (@ChemiKyle)


# redcapcustodian 0.5.1 (released 2022-06-24)
### Changed
- Export email-fixing functions (@pbchase)


# redcapcustodian 0.5.0 (released 2022-06-23)
### Added
- Add first version of a demonstration script (@pbchase)
- Add sync_table (@ChemiKyle)
- Add dataset_diff (@pbchase)
- Add multi_instance.R (@ChemiKyle)
- Add sync_metadata using credentials (@ChemiKyle)
- Add scrape_user_api_tokens (@ChemiKyle)
- Add set_super_api_token (@ChemiKyle)
- Add set_project_api_token (@ChemiKyle)
- Add ETL job logging(@mbentz-uf)
- Add cleanup_bad_email_addresses (@ljwoodley)

### Changed
- Ignore site_template in build (@pbchase)
- Ignore ./output/ (@pbchase)


# redcapcustodian 0.4.1 (released 2022-03-04)
### Changed
- Fix build.sh deployment bugs (@pbchase)


# redcapcustodian 0.4.0 (released 2022-03-03)
### Added
- Remove host image concet and deploy from site project (@pbchase)


# redcapcustodian 0.3.0 (released 2022-03-03)
### Added
- Add mRpostman and writexl to the Dockerfile (@pbchase)
- Add suspend_users_with_no_primary_email (@ljwoodley)
- Add update_redcap_email_addresses (@ljwoodley)

### Changed
- Fix get_redcap_email_revisions to match initial implementation allows it to create data that will result in user suspension (@ChemiKyle)


# redcapcustodian 0.2.0 (released 2022-02-16)
### Added
- Add get_redcap_email_revisions (@mbentz-uf)
- Add automated tests (@mbentz-uf)
- Add create_test_tables (@ChemiKyle)
- Add test tables (@ChemiKyle)
- Add get_bad_emails_from_listserv_digest (@pbchase)
- Add get_institutional_person_data (@pbchase)
- Add get_redcap_emails (@pbchase)
- Add create_test_table (@pbchase)
- Add site concept and docs (@pbchase)
- Add add_get_redcap_db_connection (@pbchase)
- Store rc_conn in env (@pbchase)
- Add add_connect_to_redcap_db (@pbchase)
- Add basic logging (@mbentz-uf)


# redcapcustodian 0.1.0 (released 2021-06-22)
### Summary
- Initial commit of redcapcustodian
- Scripted image building.
- Scripted deployment.
- redcapcustodian R package
- testthat for redcapcustodian tests
- Host-specific	customization of R scripts
- Host-specific customization of cron-files
- Host-specific customization of environment files
