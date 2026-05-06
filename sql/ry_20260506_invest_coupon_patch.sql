/*
  Investment coupon payment patch
  Run this after selecting the business database.
*/

SET @db := DATABASE();

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `coupon_id` bigint NULL DEFAULT NULL COMMENT ''优惠券模板ID'' AFTER `user_level_snapshot`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'coupon_id'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `user_coupon_id` bigint NULL DEFAULT NULL COMMENT ''用户优惠券ID'' AFTER `coupon_id`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'user_coupon_id'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `coupon_name` varchar(128) NULL DEFAULT NULL COMMENT ''优惠券名称'' AFTER `user_coupon_id`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'coupon_name'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `coupon_type` varchar(32) NULL DEFAULT NULL COMMENT ''优惠券类型'' AFTER `coupon_name`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'coupon_type'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `coupon_discount_amount` decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT ''优惠券抵扣金额'' AFTER `coupon_type`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'coupon_discount_amount'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql := (
  SELECT IF(COUNT(*) = 0,
    'ALTER TABLE `sys_invest_order` ADD COLUMN `pay_amount` decimal(18,2) NOT NULL DEFAULT 0.00 COMMENT ''实际支付金额'' AFTER `coupon_discount_amount`',
    'SELECT 1'
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db
    AND TABLE_NAME = 'sys_invest_order'
    AND COLUMN_NAME = 'pay_amount'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
