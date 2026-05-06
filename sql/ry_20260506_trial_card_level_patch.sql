/*
  Trial card and invest order schema patch
  Compatible with MySQL 8.4 and GUI SQL runners.
*/

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_level_trial_user` ADD COLUMN `original_level` int(11) NULL DEFAULT NULL COMMENT ''原级别'' AFTER `grant_type`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_level_trial_user'
    AND COLUMN_NAME = 'original_level'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_level_trial_user` ADD COLUMN `current_level` int(11) NULL DEFAULT NULL COMMENT ''现级别'' AFTER `original_level`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_level_trial_user'
    AND COLUMN_NAME = 'current_level'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `user_level_snapshot` int(11) NULL DEFAULT NULL COMMENT ''下单时用户等级快照'' AFTER `expected_income`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'user_level_snapshot'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
