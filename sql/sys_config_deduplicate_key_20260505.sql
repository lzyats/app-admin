-- sys_config 重复 key 清理与唯一索引修复
-- 问题：当存在重复 config_key 时，selectOne 会报 "Expected one result ... found: 2"
-- 策略：按 config_id 保留最新一条，删除其余重复记录，再补唯一索引避免复发

-- 1) 删除重复 key（保留 config_id 最大的一条）
DELETE c1
FROM sys_config c1
INNER JOIN sys_config c2
    ON c1.config_key = c2.config_key
   AND c1.config_id < c2.config_id;

-- 2) 如不存在唯一索引则创建（已存在则跳过）
SET @uk_exists = (
    SELECT COUNT(1)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'sys_config'
      AND index_name = 'uk_sys_config_key'
);

SET @ddl = IF(
    @uk_exists = 0,
    'ALTER TABLE sys_config ADD UNIQUE KEY uk_sys_config_key (config_key)',
    'SELECT ''uk_sys_config_key already exists'' AS message'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
