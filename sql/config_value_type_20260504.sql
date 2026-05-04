-- 参数配置扩展：参数值类型（文本/图片/文件/日期/开关/下拉）
-- 执行前请确认当前库为业务库（master）

SET @col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_config'
    AND COLUMN_NAME = 'config_value_type'
);

SET @sql_stmt := IF(
  @col_exists = 0,
  'ALTER TABLE sys_config ADD COLUMN config_value_type varchar(16) NOT NULL DEFAULT ''TEXT'' COMMENT ''参数值类型：TEXT/IMAGE/FILE/DATE/SWITCH/SELECT'' AFTER config_value',
  'SELECT ''skip add sys_config.config_value_type'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE sys_config
SET config_value_type = 'TEXT'
WHERE config_value_type IS NULL OR config_value_type = '';
