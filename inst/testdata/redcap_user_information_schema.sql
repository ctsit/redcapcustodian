CREATE TABLE `redcap_user_information` (
  `ui_id` int(10) NOT NULL,
  `username` varchar(191) DEFAULT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `user_email2` varchar(255) DEFAULT NULL,
  `user_email3` varchar(255) DEFAULT NULL,
  `user_phone` varchar(50) DEFAULT NULL,
  `user_phone_sms` varchar(50) DEFAULT NULL,
  `user_firstname` varchar(255) DEFAULT NULL,
  `user_lastname` varchar(255) DEFAULT NULL,
  `user_inst_id` varchar(255) DEFAULT NULL,
  `super_user` tinyint(1) NOT NULL DEFAULT '0',
  `account_manager` tinyint(1) NOT NULL DEFAULT '0',
  `access_system_config` tinyint(1) NOT NULL DEFAULT '0',
  `access_system_upgrade` tinyint(1) NOT NULL DEFAULT '0',
  `access_external_module_install` tinyint(1) NOT NULL DEFAULT '0',
  `admin_rights` tinyint(1) NOT NULL DEFAULT '0',
  `access_admin_dashboards` tinyint(1) NOT NULL DEFAULT '0',
  `user_creation` datetime DEFAULT NULL,
  `user_firstvisit` datetime DEFAULT NULL,
  `user_firstactivity` datetime DEFAULT NULL,
  `user_lastactivity` datetime DEFAULT NULL,
  `user_lastlogin` datetime DEFAULT NULL,
  `user_suspended_time` datetime DEFAULT NULL,
  `user_expiration` datetime DEFAULT NULL,
  `user_access_dashboard_view` datetime DEFAULT NULL,
  `user_access_dashboard_email_queued` DEFAULT NULL,
  `user_sponsor` varchar(255) DEFAULT NULL,
  `user_comments` text,
  `allow_create_db` int(1) NOT NULL DEFAULT '1',
  `email_verify_code` varchar(20) DEFAULT NULL,
  `email2_verify_code` varchar(20) DEFAULT NULL,
  `email3_verify_code` varchar(20) DEFAULT NULL,
  `datetime_format` NOT NULL DEFAULT 'M/D/Y_12',
  `number_format_decimal` NOT NULL DEFAULT '.',
  `number_format_thousands_sep` NOT NULL DEFAULT ',',
  `csv_delimiter` NOT NULL DEFAULT ',',
  `two_factor_auth_secret` varchar(20) DEFAULT NULL,
  `display_on_email_users` int(1) NOT NULL DEFAULT '1',
  `two_factor_auth_twilio_prompt_phone` tinyint(1) NOT NULL DEFAULT '1',
  `two_factor_auth_code_expiration` int(3) NOT NULL DEFAULT '2',
  `api_token` varchar(64) DEFAULT NULL,
  `messaging_email_preference` NOT NULL DEFAULT '4_HOURS',
  `messaging_email_urgent_all` tinyint(1) NOT NULL DEFAULT '1',
  `messaging_email_ts` datetime DEFAULT NULL,
  `messaging_email_general_system` tinyint(1) NOT NULL DEFAULT '1',
  `messaging_email_queue_time` datetime DEFAULT NULL,
  `ui_state` mediumtext,
  `api_token_auto_request` tinyint(1) NOT NULL DEFAULT '0',
  `fhir_data_mart_create_project` tinyint(1) NOT NULL DEFAULT '0'
)
