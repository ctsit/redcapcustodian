CREATE TABLE `rcc_detail_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `log_date` datetime NOT NULL,
  `script_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL, -- e.g. https://redcap.ctsi.ufl.edu/redcap/api/, smtp://smtp.ufl.edu, mysql://user_name@example.com:3306/schema
  `table_written` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL, -- e.g. ...
  `project_id_written` int CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_key` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL, -- REDCap Project record_id or table PK
  `record_level_data` json DEFAULT NULL,
  `level` enum('INFO','DEBUG','ERROR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `log_date` (`log_date`),
  KEY `script_name` (`script_name`),
  KEY `target_uri` (`target_uri`),
  KEY `table_written` (`table_written`),
  KEY `project_id_written` (`project_id_written`),
  KEY `primary_key` (`primary_key`),
  KEY `level` (`level`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
