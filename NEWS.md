# Version 1.10.0 (released 2023-04-24)
- Add project_life_cycle_descriptions (Philip Chase)
- Add get_project_life_cycle() (Philip Chase)

# Version 1.9.0 (released 2023-04-24)
- Add quarto and tlmgr packages it needs for pdf generation (Philip Chase)

# Version 1.8.1 (released 2023-03-20)
- Update NEWS.md and DESCRIPTION to comply with pkgdown (@pbchase, #103)

# Version 1.8.0 (released 2023-03-17)
### Added
- Add a log database system for dev work (@pbchase)

### Changed
- Fix ORCIDs in DESCRIPTION (@pbchase)


# Version 1.7.0 (released 2023-03-17)
### Added
- Add a pkgdown website (@pbchase)

### Changed
- Revise the package title away from REDCap and towards automation (@pbchase)
- Remove publication_date from .zenodo.json (@pbchase)


# Version 1.6.0 (released 2023-02-21)
### Added
- Add randomization management functions and a sample ETL (@pbchase)
- Add batch_size parm to dbx calls in sync_table_2 (@pbchase)
- Add batch_size parm to dbx calls in sync_table Prevents possible error: Expression tree is too large (maximum depth 1000) (@ChemiKyle)

### Changed
- Update testing image used at github (@pbchase)
- Eschew deprecated tidyselect features (@pbchase)
- Modernize tests of sync_table_2 (@pbchase)
- Address fatal bug in sync_table caused when delete = T but there are no records to delete (@ChemiKyle)


# Version 1.5.0 (released 2023-01-25)
### Added
- Create write_summary_metrics function, corresponding schema and test (@ChemiKyle)
- Add render_report to /report (@ljwoodley)
- Port convert_schema_to_sqlite from rcc.billing, altering it to accept path to sql file as input (@ChemiKyle)
- Port mutate_columns_to_posixct from rcc.billing (@ChemiKyle)

### Changed
- Ignore local credentials DBs (@pbchase)


# Version 1.4.1 (released 2022-12-15)
### Changed
- Install latex packages directly in Dockerfile (@ljwoodley)


# Version 1.4.0 (released 2022-12-13)
### Added
- Switch Dockerfile from tidyverse to verse (@ljwoodley)
- Add render_report.R to render Rmds (@ljwoodley)


# Version 1.3.2 (released 2022-09-14)
### Changed
- Specify package for na.exclude() (@pbchase)
- escape . to treat as literal character instead of wildcard in gsub statements (@ChemiKyle)


# Version 1.3.1 (released 2022-08-30)
### Added
- Remove remants of the site concept (@pbchase)


# Version 1.3.0 (released 2022-08-29)
### Added
- Add get_bad_emails_from_individual_emails function (@ChemiKyle)


# Version 1.2.2 (released 2022-08-26)
### Changed
- Modernize container and add dependencies (@pbchase)


# Version 1.2.1 (released 2022-08-26)
### Changed
- Move schema files into package space (@pbchase)
- Correct send_email using email_to for email_cc (@ChemiKyle)


# Version 1.2.0 (released 2022-08-25)
### Added
- Add email_from and email_cc params to send_email function, default to env value (@ChemiKyle)


# Version 1.1.1 (released 2022-08-24)
### Changed
- Fix test for search results in get_bad_emails_from_listserv_digest (@pbchase)


# Version 1.1.0 (released 2022-08-08)
### Added
- Add logging in Friday Call demo (@pbchase)

### Changed
- Define username and tube count variables in friday call demo (@ChemiKyle)
- Move fake data section to setup file in Friday Call Demo (@pbchase)
- Move credential creation and scraping from main friday call to auxiliary setup file (@ChemiKyle)


# Version 1.0.0 (released 2022-08-02)
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


# Version 0.7.0 (released 2022-07-17)
### Changed
- Add here package to Dockerfile (@pbchase)
- Add send_email function adapted from stp (@ChemiKyle)
- Add DOI badge to README (@pbchase)


# Version 0.6.1 (released 2022-07-13)
### Changed
- Fix typo in description (@pbchase)


# Version 0.6.0 (released 2022-07-13)
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


# Version 0.5.1 (released 2022-06-24)
### Changed
- Export email-fixing functions (@pbchase)


# Version 0.5.0 (released 2022-06-23)
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


# Version 0.4.1 (released 2022-03-04)
### Changed
- Fix build.sh deployment bugs (@pbchase)


# Version 0.4.0 (released 2022-03-03)
### Added
- Remove host image concet and deploy from site project (@pbchase)


# Version 0.3.0 (released 2022-03-03)
### Added
- Add mRpostman and writexl to the Dockerfile (@pbchase)
- Add suspend_users_with_no_primary_email (@ljwoodley)
- Add update_redcap_email_addresses (@ljwoodley)

### Changed
- Fix get_redcap_email_revisions to match initial implementation allows it to create data that will result in user suspension (@ChemiKyle)


# Version 0.2.0 (released 2022-02-16)
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


# Version 0.1.0 (released 2021-06-22)
### Summary
- Initial commit of redcapcustodian
- Scripted image building.
- Scripted deployment.
- redcapcustodian R package
- testthat for redcapcustodian tests
- Host-specific	customization of R scripts
- Host-specific customization of cron-files
- Host-specific customization of environment files
