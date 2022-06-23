# Change Log
All notable changes to the redcapcustodian package and its contained scripts will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


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
