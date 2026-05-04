-- 投资产品进度字段：按已售份数/总份数计算，支持排序（100%置底）
-- 执行前请确认当前库为业务库（master）

SET @progress_col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'progress_percent'
);
SET @sql_stmt := IF(
  @progress_col_exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN progress_percent decimal(10,4) NOT NULL DEFAULT 0.0000 COMMENT ''进度百分比'' AFTER sold_shares',
  'SELECT ''skip add sys_invest_product.progress_percent'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE sys_invest_product
SET progress_percent = LEAST(100, GREATEST(0,
  CASE
    WHEN IFNULL(total_shares, 0) <= 0 THEN 0
    ELSE ROUND(IFNULL(sold_shares, 0) * 100 / IFNULL(total_shares, 0), 4)
  END
));
