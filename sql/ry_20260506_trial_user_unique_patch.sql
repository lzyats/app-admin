/*
  Enforce one trial card template per user.
  Run this on the business database after USE your_db_name;
*/

DELETE t1
FROM sys_level_trial_user t1
JOIN sys_level_trial_user t2
  ON t1.trial_id = t2.trial_id
 AND t1.user_id = t2.user_id
 AND t1.user_trial_id > t2.user_trial_id;

SET @index_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_level_trial_user'
    AND INDEX_NAME = 'uk_sys_level_trial_user_trial_user'
);

SET @sql := IF(@index_exists = 0,
  'ALTER TABLE `sys_level_trial_user` ADD UNIQUE KEY `uk_sys_level_trial_user_trial_user` (`trial_id`, `user_id`)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
