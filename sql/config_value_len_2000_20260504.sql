-- 参数配置扩容：config_value -> varchar(2000)
-- 执行前请确认当前库为业务库（master）

SET @col_len := (
  SELECT CHARACTER_MAXIMUM_LENGTH
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_config'
    AND COLUMN_NAME = 'config_value'
  LIMIT 1
);

SET @sql_stmt := IF(
  @col_len IS NULL,
  'SELECT ''skip: sys_config.config_value not found'' as msg',
  IF(
    @col_len < 2000,
    'ALTER TABLE sys_config MODIFY COLUMN config_value varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '''' COMMENT ''参数键值''',
    'SELECT ''skip: sys_config.config_value length already >= 2000'' as msg'
  )
);

PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
