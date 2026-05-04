-- 投资产品增强：标签类型 + 封面图/组图 + 富文本介绍
-- 执行前请确认当前库为业务库（master）

-- 1) sys_invest_tag 新增 tag_type（PRODUCT=产品标签，RISK=风险标签）
SET @tag_type_col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_tag'
    AND COLUMN_NAME = 'tag_type'
);
SET @sql_stmt := IF(
  @tag_type_col_exists = 0,
  'ALTER TABLE sys_invest_tag ADD COLUMN tag_type varchar(20) NOT NULL DEFAULT ''PRODUCT'' COMMENT ''标签类型: PRODUCT/RISK'' AFTER tag_color',
  'SELECT ''skip add sys_invest_tag.tag_type'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE sys_invest_tag
SET tag_type = 'PRODUCT'
WHERE tag_type IS NULL OR tag_type = '';

SET @tag_type_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_tag'
    AND INDEX_NAME = 'idx_sys_invest_tag_type'
);
SET @sql_stmt := IF(
  @tag_type_idx_exists = 0,
  'ALTER TABLE sys_invest_tag ADD INDEX idx_sys_invest_tag_type(tag_type)',
  'SELECT ''skip add idx_sys_invest_tag_type'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2) sys_invest_product 新增展示字段
SET @cover_col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'cover_image'
);
SET @sql_stmt := IF(
  @cover_col_exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN cover_image varchar(512) NULL DEFAULT NULL COMMENT ''封面图'' AFTER risk_tag',
  'SELECT ''skip add sys_invest_product.cover_image'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @gallery_col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'gallery_images'
);
SET @sql_stmt := IF(
  @gallery_col_exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN gallery_images varchar(4000) NULL DEFAULT NULL COMMENT ''产品组图(逗号分隔)'' AFTER cover_image',
  'SELECT ''skip add sys_invest_product.gallery_images'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @content_col_exists := (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'sys_invest_product'
    AND COLUMN_NAME = 'product_content'
);
SET @sql_stmt := IF(
  @content_col_exists = 0,
  'ALTER TABLE sys_invest_product ADD COLUMN product_content longtext NULL COMMENT ''产品介绍(富文本)'' AFTER gallery_images',
  'SELECT ''skip add sys_invest_product.product_content'' as msg'
);
PREPARE stmt FROM @sql_stmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
