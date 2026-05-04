-- 投资产品新增交易规则内容字段
-- 执行前请确认当前库为业务库（master）

SET @col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'trade_rule_content'
);

SET @sql_stmt := IF(
  @col_exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN trade_rule_content varchar(2000) NULL DEFAULT NULL COMMENT ''交易规则内容(按行展示)'' AFTER product_content',
  'SELECT ''skip add sys_invest_product.trade_rule_content'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
