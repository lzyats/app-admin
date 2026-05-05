-- 投资真实拼团能力升级
-- 1) 订单表补充拼团字段，兼容历史订单（默认普通订单）
-- 2) 新增拼团主表（开团/参团/成团/失败）
-- 3) 新增拼团超时分钟配置

ALTER TABLE sys_invest_order
    ADD COLUMN invest_shares BIGINT NOT NULL DEFAULT 0 COMMENT '认购份数（用于拼团失败回滚）' AFTER cycle_days,
    ADD COLUMN group_id BIGINT NULL COMMENT '拼团ID' AFTER contract_no,
    ADD COLUMN group_no VARCHAR(40) NULL COMMENT '拼团团号' AFTER group_id,
    ADD COLUMN group_status CHAR(1) NOT NULL DEFAULT '9' COMMENT '拼团状态：0拼团中 1已成团 2失败退款 9非拼团' AFTER group_no,
    ADD COLUMN group_deadline_time DATETIME NULL COMMENT '拼团截止时间' AFTER group_status;

CREATE INDEX idx_invest_order_group_id ON sys_invest_order(group_id);
CREATE INDEX idx_invest_order_group_no ON sys_invest_order(group_no);
CREATE INDEX idx_invest_order_group_status ON sys_invest_order(group_status);

CREATE TABLE IF NOT EXISTS sys_invest_group
(
    group_id           BIGINT(20)      NOT NULL AUTO_INCREMENT COMMENT '拼团ID',
    group_no           VARCHAR(40)     NOT NULL COMMENT '拼团团号',
    product_id         BIGINT(20)      NOT NULL COMMENT '产品ID',
    product_name       VARCHAR(128)    NOT NULL DEFAULT '' COMMENT '产品名称',
    currency           VARCHAR(16)     NOT NULL DEFAULT 'CNY' COMMENT '币种',
    initiator_user_id  BIGINT(20)      NOT NULL COMMENT '开团用户ID',
    target_size        INT(11)         NOT NULL DEFAULT 2 COMMENT '成团目标人数',
    member_count       INT(11)         NOT NULL DEFAULT 0 COMMENT '当前人数',
    total_amount       DECIMAL(18,2)   NOT NULL DEFAULT 0.00 COMMENT '累计认购金额',
    status             CHAR(1)         NOT NULL DEFAULT '0' COMMENT '状态：0拼团中 1已成团 2失败 3已关闭',
    deadline_time      DATETIME        NULL COMMENT '截止时间',
    success_time       DATETIME        NULL COMMENT '成团时间',
    fail_time          DATETIME        NULL COMMENT '失败时间',
    close_time         DATETIME        NULL COMMENT '关闭时间',
    remark             VARCHAR(500)    NULL COMMENT '备注',
    create_by          VARCHAR(64)     NULL,
    create_time        DATETIME        NULL,
    update_by          VARCHAR(64)     NULL,
    update_time        DATETIME        NULL,
    PRIMARY KEY (group_id),
    UNIQUE KEY uk_invest_group_no (group_no),
    KEY idx_invest_group_product (product_id),
    KEY idx_invest_group_status_deadline (status, deadline_time)
) ENGINE=InnoDB COMMENT='投资拼团主表';

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
    'APP配置-拼团超时分钟',
    'app.invest.groupExpireMinutes',
    '1440',
    'TEXT',
    'N',
    '1',
    'admin',
    NOW(),
    '真实拼团开团后的超时时间（分钟），超时未成团自动失败并退款'
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
