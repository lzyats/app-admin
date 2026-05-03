-- 产品管理-标签管理菜单
-- 说明：
-- 1) 依赖“产品管理”一级目录（menu_type='M'）
-- 2) 若不存在则自动在“运营管理”下创建
-- 3) 新增“标签管理”菜单并补按钮权限
-- 4) 自动授权管理员角色（role_id=1）

SET @operation_parent_id := (
    SELECT menu_id
    FROM sys_menu
    WHERE path = 'operation' OR menu_name = '运营管理'
    ORDER BY menu_id
    LIMIT 1
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '产品管理', @operation_parent_id, 11, 'product', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'guide', 'admin', NOW(), '投资产品线分组菜单'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @operation_parent_id AND menu_name = '产品管理' AND menu_type = 'M'
);

SET @product_parent_id := (
    SELECT menu_id
    FROM sys_menu
    WHERE parent_id = @operation_parent_id AND menu_name = '产品管理' AND menu_type = 'M'
    ORDER BY menu_id
    LIMIT 1
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '标签管理', @product_parent_id, 5, 'investTag', 'operation/investTag/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:invest:list', 'tag', 'admin', NOW(), '投资产品标签管理'
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu
    WHERE parent_id = @product_parent_id AND component = 'operation/investTag/index' AND menu_type = 'C'
);

SET @tag_menu_id := (
    SELECT menu_id
    FROM sys_menu
    WHERE parent_id = @product_parent_id AND component = 'operation/investTag/index' AND menu_type = 'C'
    ORDER BY menu_id DESC
    LIMIT 1
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '标签查询', @tag_menu_id, 1, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:list', '#', 'admin', NOW(), ''
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @tag_menu_id AND perms = 'system:invest:list' AND menu_type = 'F'
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '标签新增', @tag_menu_id, 2, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:add', '#', 'admin', NOW(), ''
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @tag_menu_id AND perms = 'system:invest:add' AND menu_type = 'F'
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '标签修改', @tag_menu_id, 3, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:edit', '#', 'admin', NOW(), ''
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @tag_menu_id AND perms = 'system:invest:edit' AND menu_type = 'F'
);

INSERT INTO sys_menu
(menu_name, parent_id, order_num, path, component, query, route_name, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
SELECT '标签删除', @tag_menu_id, 4, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:remove', '#', 'admin', NOW(), ''
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE parent_id = @tag_menu_id AND perms = 'system:invest:remove' AND menu_type = 'F'
);

INSERT INTO sys_role_menu(role_id, menu_id)
SELECT 1, m.menu_id
FROM sys_menu m
WHERE m.menu_id = @tag_menu_id
   OR (m.parent_id = @tag_menu_id AND m.menu_type = 'F')
AND NOT EXISTS (
    SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 1 AND rm.menu_id = m.menu_id
);
