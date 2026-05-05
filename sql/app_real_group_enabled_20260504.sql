-- APP 配置：真实拼团开关
-- 说明：为 true 时，APP 产品详情进入真实拼团下单链路；为 false 时按普通下单链路
INSERT INTO sys_config
(
    config_name,
    config_key,
    config_value,
    config_value_type,
    config_type,
    is_app_config,
    create_by,
    create_time,
    remark
)
VALUES
(
    'APP配置-真实拼团开关',
    'app.invest.realGroupEnabled',
    'false',
    'SWITCH',
    'N',
    '1',
    'admin',
    NOW(),
    '为 true 时，APP 产品详情进入真实拼团下单链路；为 false 时按普通下单链路'
)
ON DUPLICATE KEY UPDATE
    config_name = VALUES(config_name),
    config_value = VALUES(config_value),
    config_value_type = VALUES(config_value_type),
    config_type = VALUES(config_type),
    is_app_config = VALUES(is_app_config),
    update_by = 'admin',
    update_time = NOW(),
    remark = VALUES(remark);
