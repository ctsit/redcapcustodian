CREATE TABLE `redcap_summary_metrics` (
  `id` INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `script_run_time` datetime NOT NULL,
  `script_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reporting_period_start` datetime NOT NULL,
  `reporting_period_end` datetime NOT NULL,
  `key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_type` enum('flux', 'state') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY `script_name` (`script_name`),
  KEY `script_run_time` (`script_run_time`),
  KEY `metric_type` (`metric_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
