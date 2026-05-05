-- 新闻分类新增类型字段：用于区分新闻分类与APP首页运营位分类

ALTER TABLE sys_news_category
    ADD COLUMN category_type VARCHAR(32) NOT NULL DEFAULT 'NEWS' COMMENT '分类类型：NEWS/APP_HOME_BANNER/APP_HOME_AD'
    AFTER category_name;

-- 兼容历史数据：默认新闻分类
UPDATE sys_news_category
SET category_type = 'NEWS'
WHERE category_type IS NULL OR category_type = '';

-- 将首页运营位分类标记为对应类型
UPDATE sys_news_category
SET category_type = 'APP_HOME_BANNER'
WHERE category_code = 'APP_HOME_BANNER';

UPDATE sys_news_category
SET category_type = 'APP_HOME_AD'
WHERE category_code = 'APP_HOME_AD';
