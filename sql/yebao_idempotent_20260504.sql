-- 余额宝幂等增强：
-- 1) 购买请求幂等键 client_req_no（同一用户同一请求流水只允许一单）
-- 2) 结算幂等约束（同一订单同一期 period_end_time 仅允许一条收益流水）

SET @col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_yebao_order'
    AND COLUMN_NAME = 'client_req_no'
);

SET @sql_stmt := IF(
  @col_exists = 0,
  'ALTER TABLE sys_yebao_order ADD COLUMN client_req_no varchar(64) NULL COMMENT ''客户端请求流水（幂等）'' AFTER order_no',
  'SELECT ''skip add sys_yebao_order.client_req_no'' as msg'
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_yebao_order'
    AND INDEX_NAME = 'uk_yebao_user_req'
);

SET @idx_sql := IF(
  @idx_exists = 0,
  'ALTER TABLE sys_yebao_order ADD UNIQUE KEY uk_yebao_user_req (user_id, client_req_no)',
  'SELECT ''skip add uk_yebao_user_req'' as msg'
);
PREPARE stmt2 FROM @idx_sql;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

SET @income_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_yebao_income_log'
    AND INDEX_NAME = 'uk_yebao_order_period'
);

SET @income_idx_sql := IF(
  @income_idx_exists = 0,
  'ALTER TABLE sys_yebao_income_log ADD UNIQUE KEY uk_yebao_order_period (order_id, period_end_time)',
  'SELECT ''skip add uk_yebao_order_period'' as msg'
);
PREPARE stmt3 FROM @income_idx_sql;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;
