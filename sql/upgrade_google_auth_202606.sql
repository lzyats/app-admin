-- Google 二次验证（后台敏感操作）基础表
CREATE TABLE IF NOT EXISTS `sys_user_google_auth` (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `secret` varchar(64) NOT NULL COMMENT 'Google TOTP密钥(Base32)',
  `enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用(1启用 0停用)',
  `bind_time` datetime DEFAULT NULL COMMENT '绑定时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台用户Google验证绑定表';

-- 建议参数：Google 发行方（可按实际品牌修改）
INSERT INTO `sys_config` (`config_name`, `config_key`, `config_value`, `config_type`, `create_by`, `create_time`, `remark`)
SELECT 'Google验证发行方', 'sys.google.auth.issuer', 'RuoYiAdmin', 'Y', 'admin', NOW(), 'Google Authenticator 显示的服务名称'
WHERE NOT EXISTS (
  SELECT 1 FROM `sys_config` WHERE `config_key` = 'sys.google.auth.issuer'
);
