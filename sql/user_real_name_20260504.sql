-- 用户表新增真实姓名字段（实名认证审核通过后回写）
SET @db_name := DATABASE();

SET @exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'sys_user'
    AND COLUMN_NAME = 'real_name'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE sys_user ADD COLUMN real_name varchar(50) NULL DEFAULT NULL COMMENT ''真实姓名'' AFTER nick_name',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
