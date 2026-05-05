-- APP广告管理：菜单 + 广告分类初始化

-- 1) 初始化 APP 首页广告分类（复用 sys_news_category/sys_news_article）
INSERT INTO sys_news_category
    (category_code, category_name, sort_order, status, create_by, create_time, remark)
SELECT 'APP_HOME_BANNER', 'APP首页Banner', 10, '0', 'admin', NOW(), 'APP首页Banner管理'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_news_category WHERE category_code = 'APP_HOME_BANNER'
);

INSERT INTO sys_news_category
    (category_code, category_name, sort_order, status, create_by, create_time, remark)
SELECT 'APP_HOME_AD', 'APP首页广告', 11, '0', 'admin', NOW(), 'APP首页广告管理'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_news_category WHERE category_code = 'APP_HOME_AD'
);

-- 2) 新增后台菜单：内容管理 -> APP广告管理
INSERT INTO sys_menu
    (menu_name, parent_id, order_num, path, component, query, route_name, is_frame,
     is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT 'APP广告管理', 2016, 3, 'appAd', 'system/appAd/index', '', '',
       1, 0, 'C', '0', '0', 'system:news:article:list', 'picture', 'admin', NOW(), 'APP首页Banner与广告管理'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = 2016 AND path = 'appAd'
);
