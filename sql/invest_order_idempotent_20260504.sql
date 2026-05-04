-- 投资订单幂等增强：为已存在的 sys_invest_order 增加 client_req_no 唯一约束

SET @col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'client_req_no'
);

SET @sql_stmt := IF(
  @col_exists = 0,
  'ALTER TABLE sys_invest_order ADD COLUMN client_req_no varchar(64) NOT NULL DEFAULT '''' COMMENT ''客户端请求流水（幂等）'' AFTER order_no',
  'SELECT ''skip add client_req_no'' as msg'
);
PREPARE stmt FROM @sql_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_order'
    AND INDEX_NAME = 'uk_sys_invest_order_user_req'
);

SET @idx_sql := IF(
  @idx_exists = 0,
  'ALTER TABLE sys_invest_order ADD UNIQUE KEY uk_sys_invest_order_user_req (user_id, client_req_no)',
  'SELECT ''skip add uk_sys_invest_order_user_req'' as msg'
);
PREPARE stmt2 FROM @idx_sql;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
