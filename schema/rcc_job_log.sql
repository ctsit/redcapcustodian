CREATE TABLE `rcc_job_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `log_date` datetime NOT NULL,
  `script_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `script_run_time` datetime NOT NULL,
  `job_summary_data` mediumtext DEFAULT NULL,
  `job_duration` double not null,
  `level` enum('SUCCESS','DEBUG','ERROR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `log_date` (`log_date`),
  KEY `script_name` (`script_name`),
  KEY `script_run_time` (`script_run_time`),
  KEY `level` (`level`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
