-- 投资产品升级：按金额/按份额双模式 + 总金额/已售金额
SET @db_name := DATABASE();

SET @exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'invest_mode'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN invest_mode varchar(16) NOT NULL DEFAULT ''SHARE'' COMMENT ''投资方式 SHARE按份额 AMOUNT按金额'' AFTER stage_config_json',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'total_amount'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN total_amount decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT ''总金额'' AFTER sold_shares',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'sold_amount'
);
SET @sql := IF(@exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN sold_amount decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT ''已售金额'' AFTER total_amount',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE sys_invest_product
SET invest_mode = IFNULL(NULLIF(invest_mode, ''), 'SHARE');

-- 历史数据回填：按份额模式将金额字段补齐
UPDATE sys_invest_product
SET total_amount = CASE
      WHEN IFNULL(total_amount, 0) > 0 THEN total_amount
      ELSE ROUND(IFNULL(total_shares, 0) * IFNULL(min_invest_amount, 0), 2)
    END,
    sold_amount = CASE
      WHEN IFNULL(sold_amount, 0) > 0 THEN sold_amount
      ELSE ROUND(IFNULL(sold_shares, 0) * IFNULL(min_invest_amount, 0), 2)
    END
WHERE invest_mode = 'SHARE';

-- 进度统一按金额优先计算（没有金额时兼容按份额）
UPDATE sys_invest_product
SET progress_percent = LEAST(100, GREATEST(0,
  CASE
    WHEN IFNULL(total_amount, 0) > 0 THEN ROUND(IFNULL(sold_amount, 0) * 100 / IFNULL(total_amount, 0), 4)
    WHEN IFNULL(total_shares, 0) > 0 THEN ROUND(IFNULL(sold_shares, 0) * 100 / IFNULL(total_shares, 0), 4)
    ELSE 0
  END
));
