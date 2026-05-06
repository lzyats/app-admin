/*
  Add template activation window for level trial cards.
  Run this after selecting the business database with USE your_db_name;
*/

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_level_trial_template` ADD COLUMN `valid_start_time` datetime NULL DEFAULT NULL COMMENT ''可启用开始时间'' AFTER `valid_days`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_level_trial_template'
    AND COLUMN_NAME = 'valid_start_time'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_level_trial_template` ADD COLUMN `valid_end_time` datetime NULL DEFAULT NULL COMMENT ''可启用结束时间'' AFTER `valid_start_time`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_level_trial_template'
    AND COLUMN_NAME = 'valid_end_time'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
