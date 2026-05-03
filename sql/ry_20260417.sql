/*
 Navicat Premium Data Transfer

 Source Server         : 本机
 Source Server Type    : MySQL
 Source Server Version : 80012 (8.0.12)
 Source Host           : localhost:3306
 Source Schema         : myapp

 Target Server Type    : MySQL
 Target Server Version : 80012 (8.0.12)
 File Encoding         : 65001

 Date: 03/05/2026 23:50:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for currency_exchange_log
-- ----------------------------
DROP TABLE IF EXISTS `currency_exchange_log`;
CREATE TABLE `currency_exchange_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `from_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_amount` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `to_amount` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exchange_rate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '货币互换记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of currency_exchange_log
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int(1) NULL DEFAULT 1 COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '代码生成业务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint(20) NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for sys_app_real_name_auth
-- ----------------------------
DROP TABLE IF EXISTS `sys_app_real_name_auth`;
CREATE TABLE `sys_app_real_name_auth`  (
  `auth_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '认证ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户账号',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `id_card_number` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证号',
  `id_card_front` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证正面照',
  `id_card_back` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证反面照',
  `handheld_photo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手持身份证照',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '审核状态：0待审核，1通过，2拒绝',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `submit_time` datetime NOT NULL COMMENT '提交时间',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_user_id` bigint(20) NULL DEFAULT NULL COMMENT '审核人ID',
  `review_user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人账号',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`auth_id`) USING BTREE,
  INDEX `idx_sys_app_real_name_auth_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_sys_app_real_name_auth_status`(`status` ASC) USING BTREE,
  INDEX `idx_sys_app_real_name_auth_submit_time`(`submit_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'APP实名认证表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_app_real_name_auth
-- ----------------------------
INSERT INTO `sys_app_real_name_auth` VALUES (1, 1000100, 'lanz', '张三', '513266197601021113', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222906A001.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222907A002.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222908A003.png', 2, '请重新提交', '2026-04-28 22:29:10', '2026-04-29 13:25:47', 1, 'admin', '', '2026-04-28 22:29:09', '', '2026-04-29 13:25:46', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (2, 1000100, 'lanz', '李四', '533124197812101114', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222906A001.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222907A002.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222908A003.png', 2, '还是不对', '2026-04-29 13:29:52', '2026-04-29 13:33:51', 1, 'admin', '', '2026-04-29 13:29:52', '', '2026-04-29 13:33:50', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (3, 1000100, 'lanz', '张三', '523147197812142236', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222906A001.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222907A002.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222908A003.png', 2, '不行', '2026-04-29 13:59:04', '2026-04-29 14:01:21', 1, 'admin', '', '2026-04-29 13:59:03', '', '2026-04-29 14:01:21', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (4, 1000100, 'lanz', '李三', '523124194512141115', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222906A001.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222907A002.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222908A003.png', 2, '再来一次', '2026-04-29 14:12:43', '2026-04-29 14:13:57', 1, 'admin', '', '2026-04-29 14:12:43', '', '2026-04-29 14:13:57', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (5, 1000100, 'lanz', 'sb', '123265197512142236', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222906A001.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222907A002.png', 'http://192.168.140.1:8080/profile/upload/2026/04/28/scaled_西部女骑士头像生成_20260428222908A003.png', 1, NULL, '2026-04-29 14:14:54', '2026-04-29 14:15:12', 1, 'admin', '', '2026-04-29 14:14:53', '', '2026-04-29 14:15:11', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (6, 1000102, 'test1', '弘毅', '522142196212121114', 'https://img.1trx.in/avatar/190957f233624329ade7e4836e3da6e8.jpg', 'https://img.1trx.in/avatar/b6f26497ed2a46b19f90b0780f910ad5.jpg', NULL, 1, NULL, '2026-05-01 20:25:05', '2026-05-01 22:47:12', 1, 'admin', '', '2026-05-01 20:25:04', '', '2026-05-01 22:47:11', NULL);
INSERT INTO `sys_app_real_name_auth` VALUES (7, 1000107, 'nnd1', 'xtsd', '533123191612122244', 'https://img.1trx.in/avatar/982b70328a8642a4b98ac64c9c2c9bcc.png', 'https://img.1trx.in/avatar/a89e978da9764b2f88d8ee167e0d1675.png', NULL, 1, NULL, '2026-05-02 14:10:48', '2026-05-02 14:25:34', 1, 'admin', '', '2026-05-02 14:10:48', '', '2026-05-02 14:25:33', NULL);

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int(5) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `is_app_config` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '是否APP配置（1是 0否）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 124 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, 'APP配置-验证码开关', 'sys.account.captchaEnabled', 'true', 'N', '1', 'admin', '2026-04-24 11:27:59', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (5, 'APP配置-开放注册', 'sys.account.registerUser', 'true', 'N', '1', 'admin', '2026-04-24 11:27:59', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (9, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
INSERT INTO `sys_config` VALUES (100, 'APP配置-APP升级配置', 'app.upgrade.config', '{\n	\"appUrl\": \"https://img.1trx.in/app/0501004.apk\",\n  \"androidVersion\": \"1.0.3\",\n  \"androidApkUrl\": \"https://img.1trx.in/app/0501004.apk\",\n  \"iosVersion\": \"1.0.3\",\n  \"iosInstallUrl\": \"https://apps.apple.com/app/idxxxxxxxxx\",\n  \"forceUpgrade\": false,\n  \"releaseNote\": \"修复已知问题，优化线路稳定性\"\n}', 'N', '0', 'admin', '2026-04-24 13:22:11', 'admin', '2026-05-01 22:25:27', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (101, 'APP配置-多语言开关', 'app.feature.multiLanguage', 'true', 'N', '1', 'admin', '2026-04-24 21:18:08', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (102, 'APP配置-邀请码注册', 'app.feature.inviteCodeEnabled', 'true', 'N', '1', 'admin', '2026-04-24 21:18:08', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (103, 'APP启动拉取项', 'app.bootstrap.items', 'multiLanguageEnabled,inviteCodeEnabled,realNameHandheldRequired,supportRmbToUsd,signRewardAmount,signContinuousRewardRule,yebaoRedeemAfter24h,usdRate,appDownloadUrl,registerEnabled,captchaEnabled,appUpgradeConfig,inviteRewardRule,investCurrencyMode,signRewardType', 'N', '0', 'admin', '2026-04-25 14:18:44', 'admin', '2026-05-01 17:15:21', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (104, 'APP配置-实名认证需手持', 'app.feature.realNameHandheldRequired', 'false', 'N', '1', 'admin', '2026-04-26 13:59:38', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (105, 'APP配置-美元汇率', 'app.currency.usdRate', '7', 'N', '1', 'admin', '2026-04-28 22:01:40', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (106, 'APP配置-投资货币方式', 'app.currency.investMode', '2', 'N', '1', 'admin', '2026-04-28 22:01:48', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (107, 'APP配置-支持人民币兑换美元', 'app.currency.supportRmbToUsd', 'true', 'N', '1', 'admin', '2026-04-29 16:40:02', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (108, 'APP配置-签到奖励类型', 'app.sign.rewardType', 'POINT', 'N', '1', 'admin', '2026-04-30 13:21:41', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (109, 'APP配置-签到奖励数', 'app.sign.rewardAmount', '300', 'N', '1', 'admin', '2026-04-30 13:21:41', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (110, 'APP配置-连续签到奖励规则', 'app.sign.continuousRewardRule', '[\n  {\"day\":1,\"amount\":300},\n  {\"day\":2,\"amount\":320},\n  {\"day\":3,\"amount\":350},\n  {\"day\":4,\"amount\":380},\n  {\"day\":5,\"amount\":400},\n  {\"day\":6,\"amount\":430},\n  {\"day\":7,\"amount\":466}\n]', 'N', '0', 'admin', '2026-04-30 13:21:41', 'admin', '2026-05-01 22:41:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (111, 'APP配置-余额宝必须持有24小时后才能赎回', 'app.yebao.redeemAfter24h', 'true', 'N', '1', 'admin', '2026-05-01 01:10:00', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (112, 'APP配置-APP下载地址', 'app.download.url', 'https://img.1trx.in/app/0501004.apk', 'N', '0', 'admin', '2026-05-01 17:15:21', 'admin', '2026-05-01 22:28:25', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (113, 'APP配置-邀请返佣规则', 'app.invite.rewardRule', '[]', 'N', '1', 'admin', '2026-05-01 17:15:21', 'admin', '2026-05-02 12:35:45', 'APP 配置管理页面保存');
INSERT INTO `sys_config` VALUES (114, '矿机收益模式', 'app.miner.rewardMode', 'AUTO', 'N', '0', 'admin', '2026-05-02 16:01:23', '', NULL, '分为自动和手动AUTO / MANUAL');
INSERT INTO `sys_config` VALUES (115, '矿机兑换 USD 汇率', 'app.miner.wagToUsdRate', '0.01', 'N', '0', 'admin', '2026-05-02 16:02:17', '', NULL, 'WAG 兑换 USD 汇率（单币种模式下后续按规则换算 RMB）');
INSERT INTO `sys_config` VALUES (116, '矿机收益模式', 'app.miner.rewardMode', 'AUTO', 'Y', '0', 'admin', '2026-05-02 16:02:44', 'admin', '2026-05-02 16:02:44', 'AUTO=自动领取；MANUAL=手工领取');
INSERT INTO `sys_config` VALUES (117, 'WAG兑换USD汇率', 'app.miner.wagToUsdRate', '0.001', 'Y', '0', 'admin', '2026-05-02 16:02:44', 'admin', '2026-05-02 16:02:44', '1 WAG 可兑换 USD 数量，单币种模式下将换算为人民币');
INSERT INTO `sys_config` VALUES (118, 'APP配置-矿机收益模式', 'app.miner.rewardMode', 'AUTO', 'N', '1', 'admin', '2026-05-02 17:01:40', 'admin', '2026-05-02 17:01:40', 'AUTO=自动领取；MANUAL=手工领取');
INSERT INTO `sys_config` VALUES (119, 'APP配置-WAG兑换USD汇率', 'app.miner.wagToUsdRate', '0.001', 'N', '1', 'admin', '2026-05-02 17:01:40', 'admin', '2026-05-02 17:01:40', '1 WAG 可兑换 USD 数量，单币种模式下将换算为人民币');
INSERT INTO `sys_config` VALUES (120, 'APP配置-余额宝收益等级加成开关', 'app.yebao.levelBonusEnabled', 'false', 'N', '1', 'admin', '2026-05-03 19:22:49', '', NULL, '为 true 时：余额宝结算收益按用户等级 invest_bonus(%) 加成');
INSERT INTO `sys_config` VALUES (121, '团队统计-计算层级', 'team.stats.calc.depth', '3', 'N', '0', 'admin', '2026-05-03 22:50:03', '', NULL, '夜间统计向上聚合层级，默认3');
INSERT INTO `sys_config` VALUES (122, '团队统计-夜间任务Cron', 'team.stats.calc.cron', '0 30 2 * * ?', 'N', '0', 'admin', '2026-05-03 22:50:03', '', NULL, '团队统计夜间任务Cron表达式');
INSERT INTO `sys_config` VALUES (123, '团队统计-最近统计日期', 'team.stats.last.calc.date', '2026-05-02', 'N', '0', 'admin', '2026-05-03 22:50:03', 'system', '2026-05-03 23:18:22', '夜间统计任务自动更新');

-- ----------------------------
-- Table structure for sys_coupon_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_coupon_template`;
CREATE TABLE `sys_coupon_template`  (
  `coupon_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '优惠券模板ID',
  `coupon_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '名称',
  `coupon_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'EXPERIENCE/CASH/FULL_REDUCTION/RATE_BOOST',
  `scope_type` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'GLOBAL' COMMENT 'GLOBAL/PRODUCT',
  `product_ids_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '指定产品ID集合(JSON)',
  `min_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '门槛金额',
  `discount_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '减免金额',
  `bonus_principal` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '赠送本金',
  `bonus_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '加息值(%)',
  `experience_principal` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '体验本金',
  `min_experience_units` int(11) NOT NULL DEFAULT 0 COMMENT '最小体验份数',
  `max_experience_units` int(11) NOT NULL DEFAULT 0 COMMENT '最大体验份数',
  `valid_days` int(11) NOT NULL DEFAULT 7 COMMENT '有效天数',
  `total_count` int(11) NOT NULL DEFAULT 0 COMMENT '总发放量（0不限）',
  `received_count` int(11) NOT NULL DEFAULT 0 COMMENT '已发放量',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`coupon_id`) USING BTREE,
  INDEX `idx_sys_coupon_template_type`(`coupon_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '优惠券模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_coupon_template
-- ----------------------------

-- ----------------------------
-- Table structure for sys_coupon_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_coupon_user`;
CREATE TABLE `sys_coupon_user`  (
  `user_coupon_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户券ID',
  `coupon_id` bigint(20) NOT NULL COMMENT '模板ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户名',
  `grant_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'MANUAL' COMMENT '发放类型 MANUAL/LEVEL/ACTIVITY/SYSTEM',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '状态（0未使用 1已使用 2已过期 3已作废）',
  `start_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `used_time` datetime NULL DEFAULT NULL COMMENT '使用时间',
  `used_product_id` bigint(20) NULL DEFAULT NULL COMMENT '使用产品ID',
  `used_order_id` bigint(20) NULL DEFAULT NULL COMMENT '使用订单ID',
  `source_ref` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '来源引用',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_coupon_id`) USING BTREE,
  INDEX `idx_sys_coupon_user_uid`(`user_id` ASC) USING BTREE,
  INDEX `idx_sys_coupon_user_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户优惠券' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_coupon_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int(4) NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-24 11:27:58', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int(4) NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '字典数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (30, 3, '业务提醒', '3', 'sys_notice_type', '', 'warning', 'N', '0', 'admin', '2026-04-26 15:07:46', '', NULL, '业务提醒类型');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_invest_order_plan
-- ----------------------------
DROP TABLE IF EXISTS `sys_invest_order_plan`;
CREATE TABLE `sys_invest_order_plan`  (
  `plan_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `product_id` bigint(20) NOT NULL COMMENT '产品ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `plan_type` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'INTEREST/PRINCIPAL',
  `stage_no` int(11) NOT NULL DEFAULT 1 COMMENT '阶段号',
  `plan_time` datetime NOT NULL COMMENT '计划执行时间',
  `plan_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '计划利率(%)',
  `plan_amount` decimal(18, 6) NOT NULL DEFAULT 0.000000 COMMENT '计划金额',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '状态（0待执行 1已执行 2取消）',
  `exec_time` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`plan_id`) USING BTREE,
  INDEX `idx_sys_invest_order_plan_oid`(`order_id` ASC) USING BTREE,
  INDEX `idx_sys_invest_order_plan_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '投资订单收益计划' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_invest_order_plan
-- ----------------------------

-- ----------------------------
-- Table structure for sys_invest_product
-- ----------------------------
DROP TABLE IF EXISTS `sys_invest_product`;
CREATE TABLE `sys_invest_product`  (
  `product_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '产品ID',
  `product_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '产品编码',
  `product_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '产品名称',
  `currency` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'USDT' COMMENT '投资币种',
  `card_theme` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'blue' COMMENT '前端卡片主题',
  `risk_tag` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '风险标签',
  `single_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '单购利率(%)',
  `group_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '拼团利率(%)',
  `cycle_days` int(11) NOT NULL DEFAULT 1 COMMENT '总周期(天)',
  `interest_mode` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'DAILY' COMMENT '返息方式 DAILY/STAGED/MATURITY',
  `principal_mode` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'MATURITY' COMMENT '返本方式 STAGED/MATURITY',
  `interest_stage_count` int(11) NOT NULL DEFAULT 0 COMMENT '返息阶段数',
  `principal_stage_count` int(11) NOT NULL DEFAULT 0 COMMENT '返本阶段数',
  `stage_config_json` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '分段配置JSON',
  `min_invest_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '起投金额',
  `max_invest_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '最高可投',
  `total_shares` bigint(20) NOT NULL DEFAULT 0 COMMENT '总份数',
  `sold_shares` bigint(20) NOT NULL DEFAULT 0 COMMENT '已售份数',
  `point_per_unit` decimal(18, 4) NOT NULL DEFAULT 0.0000 COMMENT '每份积分',
  `growth_per_unit` decimal(18, 4) NOT NULL DEFAULT 0.0000 COMMENT '每份成长值',
  `red_packet_per_unit` decimal(18, 4) NOT NULL DEFAULT 0.0000 COMMENT '每份红包金额',
  `coupon_enabled` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '1' COMMENT '是否可用优惠券（0否1是）',
  `group_enabled` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '是否拼团（0否1是）',
  `group_size` int(11) NOT NULL DEFAULT 2 COMMENT '成团人数',
  `auto_group` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '1' COMMENT '是否自动拼团（0否1是）',
  `limit_level` int(11) NOT NULL DEFAULT 0 COMMENT '限购等级',
  `limit_times` int(11) NOT NULL DEFAULT 0 COMMENT '限投次数（0不限）',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `start_time` datetime NULL DEFAULT NULL COMMENT '上架时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '下架时间',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`product_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_invest_product_code`(`product_code` ASC) USING BTREE,
  INDEX `idx_sys_invest_product_currency`(`currency` ASC) USING BTREE,
  INDEX `idx_sys_invest_product_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '投资产品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_invest_product
-- ----------------------------

-- ----------------------------
-- Table structure for sys_invest_product_tag_rel
-- ----------------------------
DROP TABLE IF EXISTS `sys_invest_product_tag_rel`;
CREATE TABLE `sys_invest_product_tag_rel`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_id` bigint(20) NOT NULL COMMENT '产品ID',
  `tag_id` bigint(20) NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sys_invest_product_tag`(`product_id` ASC, `tag_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '投资产品标签关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_invest_product_tag_rel
-- ----------------------------

-- ----------------------------
-- Table structure for sys_invest_tag
-- ----------------------------
DROP TABLE IF EXISTS `sys_invest_tag`;
CREATE TABLE `sys_invest_tag`  (
  `tag_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '标签ID',
  `tag_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '标签编码',
  `tag_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '标签名称',
  `tag_color` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '#409EFF' COMMENT '标签颜色',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`tag_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_invest_tag_code`(`tag_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '投资产品标签' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_invest_tag
-- ----------------------------
INSERT INTO `sys_invest_tag` VALUES (1, 'NEWBIE', '新手专区', '#67C23A', 1, '0', 'admin', '2026-05-03 21:30:27', '', NULL, '默认标签');
INSERT INTO `sys_invest_tag` VALUES (2, 'HOT', '热门投资', '#F56C6C', 2, '0', 'admin', '2026-05-03 21:30:27', '', NULL, '默认标签');
INSERT INTO `sys_invest_tag` VALUES (3, 'GROUP', '团购专区', '#E6A23C', 3, '0', 'admin', '2026-05-03 21:30:27', '', NULL, '默认标签');

-- ----------------------------
-- Table structure for sys_level_trial_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_level_trial_template`;
CREATE TABLE `sys_level_trial_template`  (
  `trial_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '体验券模板ID',
  `trial_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '名称',
  `trial_level` int(11) NOT NULL COMMENT '体验等级',
  `bonus_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '体验加成(%)',
  `valid_days` int(11) NOT NULL DEFAULT 7 COMMENT '有效天数',
  `total_count` int(11) NOT NULL DEFAULT 0 COMMENT '总发放量（0不限）',
  `received_count` int(11) NOT NULL DEFAULT 0 COMMENT '已发放量',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`trial_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '等级体验券模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_level_trial_template
-- ----------------------------

-- ----------------------------
-- Table structure for sys_level_trial_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_level_trial_user`;
CREATE TABLE `sys_level_trial_user`  (
  `user_trial_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户体验券ID',
  `trial_id` bigint(20) NOT NULL COMMENT '模板ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户名',
  `grant_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'MANUAL' COMMENT '发放类型 MANUAL/LEVEL/ACTIVITY/SYSTEM',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '状态（0待生效 1生效中 2已失效 3已作废）',
  `start_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_trial_id`) USING BTREE,
  INDEX `idx_sys_level_trial_user_uid`(`user_id` ASC) USING BTREE,
  INDEX `idx_sys_level_trial_user_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户等级体验券' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_level_trial_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 263 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统访问记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-24 11:35:53');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-24 12:39:25');
INSERT INTO `sys_logininfor` VALUES (102, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '1', '验证码错误', '2026-04-24 20:23:53');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-24 20:23:55');
INSERT INTO `sys_logininfor` VALUES (104, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '注册成功', '2026-04-24 20:30:27');
INSERT INTO `sys_logininfor` VALUES (105, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码已失效', '2026-04-24 20:31:19');
INSERT INTO `sys_logininfor` VALUES (106, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-24 20:31:25');
INSERT INTO `sys_logininfor` VALUES (107, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-24 20:48:04');
INSERT INTO `sys_logininfor` VALUES (108, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-24 20:48:09');
INSERT INTO `sys_logininfor` VALUES (109, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '1', '验证码错误', '2026-04-24 21:21:51');
INSERT INTO `sys_logininfor` VALUES (110, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '1', '验证码已失效', '2026-04-24 21:24:48');
INSERT INTO `sys_logininfor` VALUES (111, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-24 21:24:52');
INSERT INTO `sys_logininfor` VALUES (112, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-24 21:27:58');
INSERT INTO `sys_logininfor` VALUES (113, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-25 13:58:48');
INSERT INTO `sys_logininfor` VALUES (114, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-25 14:02:03');
INSERT INTO `sys_logininfor` VALUES (115, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-25 14:02:08');
INSERT INTO `sys_logininfor` VALUES (116, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 14:02:16');
INSERT INTO `sys_logininfor` VALUES (117, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '退出成功', '2026-04-25 14:18:35');
INSERT INTO `sys_logininfor` VALUES (118, 'test1', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '注册成功', '2026-04-25 14:31:39');
INSERT INTO `sys_logininfor` VALUES (119, 'test1', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '注册成功', '2026-04-25 14:39:59');
INSERT INTO `sys_logininfor` VALUES (120, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-25 15:38:36');
INSERT INTO `sys_logininfor` VALUES (121, 'admin', '127.0.0.1', '内网IP', 'WindowsPowerShell 5.1.22621.4111', 'Windows 10.0', '1', '验证码已失效', '2026-04-25 15:51:20');
INSERT INTO `sys_logininfor` VALUES (122, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-25 15:58:40');
INSERT INTO `sys_logininfor` VALUES (123, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 16:22:01');
INSERT INTO `sys_logininfor` VALUES (124, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码已失效', '2026-04-25 16:46:07');
INSERT INTO `sys_logininfor` VALUES (125, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 16:46:10');
INSERT INTO `sys_logininfor` VALUES (126, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 16:49:28');
INSERT INTO `sys_logininfor` VALUES (127, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 17:12:28');
INSERT INTO `sys_logininfor` VALUES (128, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-25 17:45:19');
INSERT INTO `sys_logininfor` VALUES (129, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '退出成功', '2026-04-25 17:48:32');
INSERT INTO `sys_logininfor` VALUES (130, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 17:48:37');
INSERT INTO `sys_logininfor` VALUES (131, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 18:27:20');
INSERT INTO `sys_logininfor` VALUES (132, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 18:44:03');
INSERT INTO `sys_logininfor` VALUES (133, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 18:57:09');
INSERT INTO `sys_logininfor` VALUES (134, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '1', '验证码已失效', '2026-04-25 19:41:54');
INSERT INTO `sys_logininfor` VALUES (135, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-25 19:41:56');
INSERT INTO `sys_logininfor` VALUES (136, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码已失效', '2026-04-25 19:42:43');
INSERT INTO `sys_logininfor` VALUES (137, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 19:42:47');
INSERT INTO `sys_logininfor` VALUES (138, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 20:41:48');
INSERT INTO `sys_logininfor` VALUES (139, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 21:37:07');
INSERT INTO `sys_logininfor` VALUES (140, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 22:20:43');
INSERT INTO `sys_logininfor` VALUES (141, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 22:35:11');
INSERT INTO `sys_logininfor` VALUES (142, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 22:44:07');
INSERT INTO `sys_logininfor` VALUES (143, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 23:02:11');
INSERT INTO `sys_logininfor` VALUES (144, 'lanz', '192.168.0.2', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-25 23:45:08');
INSERT INTO `sys_logininfor` VALUES (145, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-26 11:22:10');
INSERT INTO `sys_logininfor` VALUES (146, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 11:22:13');
INSERT INTO `sys_logininfor` VALUES (147, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-04-26 11:36:07');
INSERT INTO `sys_logininfor` VALUES (148, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 11:52:29');
INSERT INTO `sys_logininfor` VALUES (149, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-26 11:55:11');
INSERT INTO `sys_logininfor` VALUES (150, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '退出成功', '2026-04-26 11:55:53');
INSERT INTO `sys_logininfor` VALUES (151, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-26 11:55:59');
INSERT INTO `sys_logininfor` VALUES (152, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-26 11:56:27');
INSERT INTO `sys_logininfor` VALUES (153, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 12:23:32');
INSERT INTO `sys_logininfor` VALUES (154, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 12:30:14');
INSERT INTO `sys_logininfor` VALUES (155, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 13:50:20');
INSERT INTO `sys_logininfor` VALUES (156, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-26 13:52:32');
INSERT INTO `sys_logininfor` VALUES (157, 'admin', '127.0.0.1', '内网IP', 'QQ Browser 21.0.8421.400', 'Windows10', '0', '登录成功', '2026-04-26 14:22:58');
INSERT INTO `sys_logininfor` VALUES (158, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-26 15:12:13');
INSERT INTO `sys_logininfor` VALUES (159, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-27 21:17:41');
INSERT INTO `sys_logininfor` VALUES (160, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-27 21:20:43');
INSERT INTO `sys_logininfor` VALUES (161, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-27 21:49:35');
INSERT INTO `sys_logininfor` VALUES (162, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '退出成功', '2026-04-27 21:49:38');
INSERT INTO `sys_logininfor` VALUES (163, NULL, '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码已失效', '2026-04-27 22:35:20');
INSERT INTO `sys_logininfor` VALUES (164, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-27 22:35:32');
INSERT INTO `sys_logininfor` VALUES (165, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 11:00:37');
INSERT INTO `sys_logininfor` VALUES (166, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 11:01:29');
INSERT INTO `sys_logininfor` VALUES (167, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 11:01:54');
INSERT INTO `sys_logininfor` VALUES (168, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 11:03:32');
INSERT INTO `sys_logininfor` VALUES (169, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-28 17:37:09');
INSERT INTO `sys_logininfor` VALUES (170, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 17:37:33');
INSERT INTO `sys_logininfor` VALUES (171, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:01:39');
INSERT INTO `sys_logininfor` VALUES (172, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:01:51');
INSERT INTO `sys_logininfor` VALUES (173, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:02:36');
INSERT INTO `sys_logininfor` VALUES (174, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码已失效', '2026-04-28 20:10:00');
INSERT INTO `sys_logininfor` VALUES (175, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:10:09');
INSERT INTO `sys_logininfor` VALUES (176, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 20:11:00');
INSERT INTO `sys_logininfor` VALUES (177, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:27:20');
INSERT INTO `sys_logininfor` VALUES (178, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-28 20:27:38');
INSERT INTO `sys_logininfor` VALUES (179, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 20:32:21');
INSERT INTO `sys_logininfor` VALUES (180, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 20:37:22');
INSERT INTO `sys_logininfor` VALUES (181, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '验证码错误', '2026-04-28 20:41:09');
INSERT INTO `sys_logininfor` VALUES (182, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 20:41:18');
INSERT INTO `sys_logininfor` VALUES (183, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 21:00:13');
INSERT INTO `sys_logininfor` VALUES (184, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 21:13:41');
INSERT INTO `sys_logininfor` VALUES (185, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 22:16:53');
INSERT INTO `sys_logininfor` VALUES (186, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-28 23:04:50');
INSERT INTO `sys_logininfor` VALUES (187, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:23:35');
INSERT INTO `sys_logininfor` VALUES (188, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:24:57');
INSERT INTO `sys_logininfor` VALUES (189, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:25:19');
INSERT INTO `sys_logininfor` VALUES (190, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:29:14');
INSERT INTO `sys_logininfor` VALUES (191, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:30:21');
INSERT INTO `sys_logininfor` VALUES (192, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 13:34:31');
INSERT INTO `sys_logininfor` VALUES (193, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 14:02:20');
INSERT INTO `sys_logininfor` VALUES (194, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '退出成功', '2026-04-29 16:19:23');
INSERT INTO `sys_logininfor` VALUES (195, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 16:19:29');
INSERT INTO `sys_logininfor` VALUES (196, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 16:24:21');
INSERT INTO `sys_logininfor` VALUES (197, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 17:31:41');
INSERT INTO `sys_logininfor` VALUES (198, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 18:25:28');
INSERT INTO `sys_logininfor` VALUES (199, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 19:09:59');
INSERT INTO `sys_logininfor` VALUES (200, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-29 19:25:13');
INSERT INTO `sys_logininfor` VALUES (201, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-29 19:25:25');
INSERT INTO `sys_logininfor` VALUES (202, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '1', '用户不存在/密码错误', '2026-04-29 19:26:13');
INSERT INTO `sys_logininfor` VALUES (203, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 19:26:27');
INSERT INTO `sys_logininfor` VALUES (204, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 19:40:18');
INSERT INTO `sys_logininfor` VALUES (205, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 20:45:24');
INSERT INTO `sys_logininfor` VALUES (206, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 20:47:27');
INSERT INTO `sys_logininfor` VALUES (207, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 21:02:33');
INSERT INTO `sys_logininfor` VALUES (208, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 21:36:55');
INSERT INTO `sys_logininfor` VALUES (209, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 22:10:31');
INSERT INTO `sys_logininfor` VALUES (210, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-29 22:26:51');
INSERT INTO `sys_logininfor` VALUES (211, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 12:33:29');
INSERT INTO `sys_logininfor` VALUES (212, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 13:55:04');
INSERT INTO `sys_logininfor` VALUES (213, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 14:06:49');
INSERT INTO `sys_logininfor` VALUES (214, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 14:19:02');
INSERT INTO `sys_logininfor` VALUES (215, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 14:32:00');
INSERT INTO `sys_logininfor` VALUES (216, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 15:38:40');
INSERT INTO `sys_logininfor` VALUES (217, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 15:52:28');
INSERT INTO `sys_logininfor` VALUES (218, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 16:45:12');
INSERT INTO `sys_logininfor` VALUES (219, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 16:47:11');
INSERT INTO `sys_logininfor` VALUES (220, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 16:59:05');
INSERT INTO `sys_logininfor` VALUES (221, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 18:02:38');
INSERT INTO `sys_logininfor` VALUES (222, 'lanz', '192.168.140.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-04-30 19:24:46');
INSERT INTO `sys_logininfor` VALUES (223, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:50:14');
INSERT INTO `sys_logininfor` VALUES (224, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:50:19');
INSERT INTO `sys_logininfor` VALUES (225, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:50:31');
INSERT INTO `sys_logininfor` VALUES (226, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:51:01');
INSERT INTO `sys_logininfor` VALUES (227, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:56:25');
INSERT INTO `sys_logininfor` VALUES (228, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 19:56:43');
INSERT INTO `sys_logininfor` VALUES (229, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:13:19');
INSERT INTO `sys_logininfor` VALUES (230, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:13:35');
INSERT INTO `sys_logininfor` VALUES (231, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:16:08');
INSERT INTO `sys_logininfor` VALUES (232, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:19:34');
INSERT INTO `sys_logininfor` VALUES (233, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:19:52');
INSERT INTO `sys_logininfor` VALUES (234, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:21:10');
INSERT INTO `sys_logininfor` VALUES (235, NULL, '192.168.140.1', '内网IP', 'Dart 3.4', '', '1', '验证码已失效', '2026-04-30 20:29:46');
INSERT INTO `sys_logininfor` VALUES (236, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-04-30 20:33:03');
INSERT INTO `sys_logininfor` VALUES (237, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-04-30 20:39:41');
INSERT INTO `sys_logininfor` VALUES (238, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-04-30 20:53:05');
INSERT INTO `sys_logininfor` VALUES (239, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-04-30 21:01:50');
INSERT INTO `sys_logininfor` VALUES (240, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-05-01 12:07:59');
INSERT INTO `sys_logininfor` VALUES (241, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-05-01 15:30:17');
INSERT INTO `sys_logininfor` VALUES (242, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-01 16:11:18');
INSERT INTO `sys_logininfor` VALUES (243, 'test1', '192.168.0.2', '内网IP', 'Dart 3.4', '', '1', '用户不存在/密码错误', '2026-05-01 16:16:41');
INSERT INTO `sys_logininfor` VALUES (244, 'test1', '192.168.0.2', '内网IP', 'Dart 3.4', '', '1', '用户不存在/密码错误', '2026-05-01 16:16:56');
INSERT INTO `sys_logininfor` VALUES (245, 'test1', '192.168.0.2', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-01 16:17:13');
INSERT INTO `sys_logininfor` VALUES (246, 'test1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-01 16:18:42');
INSERT INTO `sys_logininfor` VALUES (247, 'liyats', '192.168.0.2', '内网IP', 'Dart 3.4', '', '0', '注册成功', '2026-05-01 17:12:24');
INSERT INTO `sys_logininfor` VALUES (248, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-05-01 17:59:25');
INSERT INTO `sys_logininfor` VALUES (249, 'test1', '192.168.0.3', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-01 18:02:44');
INSERT INTO `sys_logininfor` VALUES (250, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-05-02 12:30:06');
INSERT INTO `sys_logininfor` VALUES (251, 'lanz', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-02 12:30:28');
INSERT INTO `sys_logininfor` VALUES (252, 'suyat', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '注册成功', '2026-05-02 12:39:41');
INSERT INTO `sys_logininfor` VALUES (253, 'lian', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '注册成功', '2026-05-02 12:47:56');
INSERT INTO `sys_logininfor` VALUES (254, 'nnd', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '注册成功', '2026-05-02 13:08:40');
INSERT INTO `sys_logininfor` VALUES (255, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '注册成功', '2026-05-02 13:12:20');
INSERT INTO `sys_logininfor` VALUES (256, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-02 13:38:05');
INSERT INTO `sys_logininfor` VALUES (257, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-02 13:44:53');
INSERT INTO `sys_logininfor` VALUES (258, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-02 13:45:34');
INSERT INTO `sys_logininfor` VALUES (259, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-02 13:50:09');
INSERT INTO `sys_logininfor` VALUES (260, 'admin', '127.0.0.1', '内网IP', 'Chrome 147', 'Windows10', '0', '登录成功', '2026-05-02 14:24:33');
INSERT INTO `sys_logininfor` VALUES (261, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-03 21:46:33');
INSERT INTO `sys_logininfor` VALUES (262, 'nnd1', '192.168.140.1', '内网IP', 'Dart 3.4', '', '0', '登录成功', '2026-05-03 21:49:09');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int(4) NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int(1) NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int(1) NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2055 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-04-24 11:27:59', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-04-24 11:27:59', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-04-24 11:27:59', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (4, '若依官网', 0, 4, 'http://ruoyi.vip', NULL, '', '', 0, 0, 'M', '1', '0', '', 'guide', 'admin', '2026-04-24 11:27:59', 'admin', '2026-04-26 14:38:51', '若依官网地址');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-04-24 11:27:59', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-04-24 11:27:59', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-04-24 11:27:59', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-04-24 11:27:59', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-04-24 11:27:59', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-04-24 11:27:59', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-04-24 11:27:59', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-04-24 11:27:59', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-04-24 11:27:59', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-04-24 11:27:59', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-04-24 11:27:59', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-04-24 11:27:59', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-04-24 11:27:59', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-04-24 11:27:59', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-04-24 11:27:59', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-04-24 11:27:59', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-04-24 11:27:59', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-04-24 11:27:59', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-04-24 11:27:59', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-04-24 11:27:59', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '运营管理', 0, 25, '/', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'dict', 'admin', '2026-04-24 12:40:57', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2001, 'API二维码', 2000, 50, '/tool/line/qr', 'tool/line/qr', NULL, '', 1, 1, 'C', '0', '0', '', 'code', 'admin', '2026-04-24 12:42:13', 'admin', '2026-04-24 12:45:41', '');
INSERT INTO `sys_menu` VALUES (2002, 'APP配置管理', 2000, 1, 'appConfig', 'system/appConfig/index', NULL, '', 1, 0, 'C', '0', '0', 'system:appConfig:list;system:config:edit', 'clipboard', 'admin', '2026-04-25 14:08:13', 'admin', '2026-04-25 14:09:51', '');
INSERT INTO `sys_menu` VALUES (2003, '实名认证审核', 2000, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'system:realNameAuth:edit', '#', 'admin', '2026-04-26 14:05:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '实名认证删除', 2000, 3, '', '', NULL, '', 1, 0, 'F', '0', '0', 'system:realNameAuth:remove', '#', 'admin', '2026-04-26 14:05:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '实名认证管理', 2000, 3, 'system/realNameAuth/index', 'system/realNameAuth/index', NULL, 'realNameAuth', 1, 0, 'C', '0', '0', 'system:realNameAuth:list', 'build', 'admin', '2026-04-26 14:51:16', 'admin', '2026-04-26 14:52:34', '');
INSERT INTO `sys_menu` VALUES (2006, '充值管理', 2048, 4, 'operation/recharge/index', 'operation/recharge/index', '', '', 1, 0, 'C', '0', '0', 'operation:recharge:list', 'money', 'admin', '2026-04-29 16:14:22', 'admin', '2026-05-03 23:36:15', '');
INSERT INTO `sys_menu` VALUES (2007, '充值审核', 2048, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'operation:recharge:edit', '#', 'admin', '2026-04-29 16:14:22', 'admin', '2026-05-03 23:36:45', '');
INSERT INTO `sys_menu` VALUES (2008, '银行卡管理', 2048, 5, 'bankCard', 'operation/bankCard/index', '', '', 1, 0, 'C', '0', '0', 'operation:bankCard:list', 'tab', 'admin', '2026-04-29 17:28:52', 'admin', '2026-05-03 23:36:28', '银行卡管理菜单');
INSERT INTO `sys_menu` VALUES (2009, '银行卡删除', 2008, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'operation:bankCard:remove', '#', 'admin', '2026-04-29 17:28:52', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '提现管理', 2048, 6, 'withdraw', 'operation/withdraw/index', '', '', 1, 0, 'C', '0', '0', 'operation:withdraw:list', 'money', 'admin', '2026-04-29 18:28:59', 'admin', '2026-05-03 23:36:55', '提现管理菜单');
INSERT INTO `sys_menu` VALUES (2011, '提现审核', 2010, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'operation:withdraw:edit', '#', 'admin', '2026-04-29 18:28:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '提现删除', 2010, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'operation:withdraw:remove', '#', 'admin', '2026-04-29 18:28:59', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '积分管理', 2048, 7, 'point', 'operation/point/account/index', '', '', 1, 0, 'C', '0', '0', 'system:point:list', 'job', 'admin', '2026-04-30 12:58:22', 'admin', '2026-05-03 23:37:07', '积分账户管理');
INSERT INTO `sys_menu` VALUES (2014, '积分账户', 2013, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:point:add', '#', 'admin', '2026-04-30 12:58:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '积分账变', 2013, 2, 'log', 'operation/point/log/index', '', '', 1, 0, 'C', '0', '0', 'system:point:log:list', 'list', 'admin', '2026-04-30 12:58:22', '', NULL, '积分账变管理');
INSERT INTO `sys_menu` VALUES (2016, '内容管理', 0, 20, 'content', NULL, '', '', 1, 0, 'M', '0', '0', '', 'chart', 'admin', '2026-04-30 16:35:07', 'admin', '2026-05-03 21:56:51', '内容管理根菜单');
INSERT INTO `sys_menu` VALUES (2017, '新闻分类', 2016, 1, 'newsCategory', 'system/news/category/index', '', '', 1, 0, 'C', '0', '0', 'system:news:category:list', 'dict', 'admin', '2026-04-30 16:35:07', '', NULL, '新闻分类管理');
INSERT INTO `sys_menu` VALUES (2018, '新闻文章', 2016, 2, 'newsArticle', 'system/news/article/index', '', '', 1, 0, 'C', '0', '0', 'system:news:article:list', 'article', 'admin', '2026-04-30 16:39:37', '', NULL, '新闻文章管理');
INSERT INTO `sys_menu` VALUES (2019, '余额宝管理', 2048, 30, 'yebao', NULL, '', '', 1, 0, 'M', '0', '0', '', 'example', 'admin', '2026-05-01 11:41:28', 'admin', '2026-05-03 23:37:21', '余额宝管理根菜单');
INSERT INTO `sys_menu` VALUES (2020, '余额宝配置', 2019, 1, 'config', 'system/yebao/config/index', '', '', 1, 0, 'C', '0', '0', 'system:yebao:config:list', 'edit', 'admin', '2026-05-01 11:41:28', '', NULL, '余额宝配置管理');
INSERT INTO `sys_menu` VALUES (2021, '余额宝订单', 2019, 2, 'order', 'system/yebao/order/index', '', '', 1, 0, 'C', '0', '0', 'system:yebao:order:list', 'list', 'admin', '2026-05-01 11:41:28', '', NULL, '余额宝订单管理');
INSERT INTO `sys_menu` VALUES (2022, '收益流水', 2019, 3, 'income', 'system/yebao/income/index', '', '', 1, 0, 'C', '0', '0', 'system:yebao:income:list', 'money', 'admin', '2026-05-01 11:41:28', '', NULL, '余额宝收益流水');
INSERT INTO `sys_menu` VALUES (2030, '用户等级', 2000, 9, 'userLevel', 'operation/userLevel/index', '', '', 1, 0, 'C', '0', '0', 'system:userLevel:list', 'user', 'admin', '2026-05-03 18:10:33', 'admin', '2026-05-03 18:13:38', '用户等级菜单');
INSERT INTO `sys_menu` VALUES (2031, '用户等级新增', 2030, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:userLevel:add', '#', 'admin', '2026-05-03 18:10:33', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2032, '用户等级修改', 2030, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:userLevel:edit', '#', 'admin', '2026-05-03 18:10:33', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2033, '用户等级删除', 2030, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:userLevel:remove', '#', 'admin', '2026-05-03 18:10:33', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2034, '矿机管理', 2000, 2011, 'miner', 'operation/miner/index', NULL, '', 1, 0, 'C', '0', '0', 'operation:miner:list', 'redis', 'admin', '2026-05-03 18:53:13', 'admin', '2026-05-03 18:53:44', '矿机管理菜单');
INSERT INTO `sys_menu` VALUES (2035, '团队管理', 2000, 10, 'teamLevel', 'operation/teamLevel/index', '', '', 1, 0, 'C', '0', '0', 'system:teamLevel:list', 'peoples', 'admin', '2026-05-03 22:02:24', '', NULL, '团队等级管理菜单');
INSERT INTO `sys_menu` VALUES (2036, '团队等级新增', 2035, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:teamLevel:add', '#', 'admin', '2026-05-03 22:02:24', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2037, '团队等级修改', 2035, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:teamLevel:edit', '#', 'admin', '2026-05-03 22:02:24', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2038, '团队等级删除', 2035, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:teamLevel:remove', '#', 'admin', '2026-05-03 22:02:24', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2039, '团队升级检测', 2035, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:teamLevel:edit', '#', 'admin', '2026-05-03 22:02:24', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2040, '我的团队统计', 2000, 96, 'teamStats', 'operation/teamStats/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:teamStats:list', 'peoples', 'admin', '2026-05-03 22:50:13', '', NULL, '夜间快照统计查询');
INSERT INTO `sys_menu` VALUES (2041, '团队统计查询', 2040, 1, '', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:teamStats:list', '#', 'admin', '2026-05-03 22:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2042, '团队统计重算', 2040, 2, '', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:teamStats:rebuild', '#', 'admin', '2026-05-03 22:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2043, '产品管理', 0, 11, 'product', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'dict', 'admin', '2026-05-03 23:27:38', 'admin', '2026-05-03 23:33:55', '投资产品线分组菜单');
INSERT INTO `sys_menu` VALUES (2044, '产品管理', 2043, 1, 'investProduct', 'operation/investProduct/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:invest:list', 'list', 'admin', '2026-05-03 23:27:38', 'admin', '2026-05-03 23:39:18', '投资产品管理');
INSERT INTO `sys_menu` VALUES (2045, '优惠券管理', 2043, 2, 'couponTemplate', 'operation/couponTemplate/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:invest:list', 'icon', 'admin', '2026-05-03 23:27:38', 'admin', '2026-05-03 23:39:54', '优惠券模板管理');
INSERT INTO `sys_menu` VALUES (2046, '等级体验卡', 2043, 3, 'levelTrial', 'operation/levelTrial/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:invest:list', 'documentation', 'admin', '2026-05-03 23:27:38', 'admin', '2026-05-03 23:40:18', '等级体验卡管理');
INSERT INTO `sys_menu` VALUES (2047, '订单管理', 2043, 4, 'investOrder', 'system/yebao/order/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:yebao:order:list', 'edit', 'admin', '2026-05-03 23:27:38', 'admin', '2026-05-03 23:40:29', '订单管理（复用订单页）');
INSERT INTO `sys_menu` VALUES (2048, '资金管理', 0, 5, 'fund', NULL, NULL, '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-05-03 23:35:48', 'admin', '2026-05-03 23:42:29', '');
INSERT INTO `sys_menu` VALUES (2049, '产品管理', 2000, 11, 'product', NULL, NULL, NULL, 1, 0, 'M', '0', '0', '', 'guide', 'admin', '2026-05-03 23:50:04', '', NULL, '投资产品线分组菜单');
INSERT INTO `sys_menu` VALUES (2050, '标签管理', 2049, 5, 'investTag', 'operation/investTag/index', NULL, NULL, 1, 0, 'C', '0', '0', 'system:invest:list', 'tag', 'admin', '2026-05-03 23:50:04', '', NULL, '投资产品标签管理');
INSERT INTO `sys_menu` VALUES (2051, '标签查询', 2050, 1, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:list', '#', 'admin', '2026-05-03 23:50:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2052, '标签新增', 2050, 2, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:add', '#', 'admin', '2026-05-03 23:50:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2053, '标签修改', 2050, 3, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:edit', '#', 'admin', '2026-05-03 23:50:04', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2054, '标签删除', 2050, 4, '#', '', NULL, NULL, 1, 0, 'F', '0', '0', 'system:invest:remove', '#', 'admin', '2026-05-03 23:50:04', '', NULL, '');

-- ----------------------------
-- Table structure for sys_miner
-- ----------------------------
DROP TABLE IF EXISTS `sys_miner`;
CREATE TABLE `sys_miner`  (
  `miner_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '矿机ID',
  `miner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '矿机名称',
  `miner_level` int(11) NOT NULL DEFAULT 0 COMMENT '矿机等级（展示用）',
  `power` int(11) NOT NULL DEFAULT 0 COMMENT '功率（展示/计算用）',
  `wag_per_day` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '日收益WAG（24小时一轮）',
  `min_user_level` int(11) NOT NULL DEFAULT 0 COMMENT '可领取最小用户等级（含）',
  `max_user_level` int(11) NOT NULL DEFAULT 999 COMMENT '可领取最大用户等级（含）',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`miner_id`) USING BTREE,
  INDEX `idx_miner_level`(`miner_level` ASC) USING BTREE,
  INDEX `idx_miner_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '矿机定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_miner
-- ----------------------------
INSERT INTO `sys_miner` VALUES (1, '基础算力单元', 0, 100, 100.00000000, 0, 9, 'https://img.1trx.in/avatar/7d7dd072466c44d38d9aa3605b92aa35.webp', 0, '0', 'admin', '2026-05-03 18:59:31', '', NULL, '矿机的入门算力单元，运行稳定，日产出 100 WAG，适合新手起步，体验节点算力。');
INSERT INTO `sys_miner` VALUES (2, '模块化分层矿机', 1, 200, 200.00000000, 1, 9, 'https://img.1trx.in/avatar/8591c009d2144dfea35dc5af94356daa.webp', 0, '0', 'admin', '2026-05-03 19:00:27', '', NULL, '三层式模块化设计，算力比入门级翻倍，日产出 200 WAG，兼顾稳定与扩展。');
INSERT INTO `sys_miner` VALUES (3, '协议算力引擎', 2, 500, 500.00000000, 2, 9, 'https://img.1trx.in/avatar/34b7262046a6495d9d36dfbdd5e735ec.webp', 0, '0', 'admin', '2026-05-03 19:01:12', '', NULL, '搭载专属算力协议，双层高效运算架构，日产出 500 WAG，效率更上一层。');
INSERT INTO `sys_miner` VALUES (4, '标准云矿机主机', 3, 800, 800.00000000, 3, 9, 'https://img.1trx.in/avatar/429d42dd0728402d83088854d5c206f2.webp', 0, '0', 'admin', '2026-05-03 19:01:57', '', NULL, '标准云矿机主机，带高效散热与云端调度，日产出 800 WAG，长期稳定运行。');
INSERT INTO `sys_miner` VALUES (5, '多节点堆叠矿机', 4, 1500, 1500.00000000, 4, 9, 'https://img.1trx.in/avatar/f202f7a1871d4195991c08d669d4d5f3.webp', 0, '0', 'admin', '2026-05-03 19:02:38', 'admin', '2026-05-03 19:02:48', '多层堆叠式集群架构，支持横向扩展，日产出 1500 WAG，算力规模稳步提升。');
INSERT INTO `sys_miner` VALUES (6, '综合管理矿机单元', 5, 4000, 4000.00000000, 5, 9, 'https://img.1trx.in/avatar/397a8a7e6f0248aea9a3a1e9caa2c906.webp', 0, '0', 'admin', '2026-05-03 19:03:55', 'admin', '2026-05-03 19:04:21', '集成运算、监控、散热三大模块，日产出 4000 WAG，全程云端可控。');
INSERT INTO `sys_miner` VALUES (7, '带控制台矿机服务器', 6, 8000, 8000.00000000, 6, 9, 'https://img.1trx.in/avatar/87b3444bba5a4a8090b4ef46471cbcf5.webp', 0, '0', 'admin', '2026-05-03 19:05:20', '', NULL, '带本地控制台的专业服务器，支持参数配置与故障排查，日产出 8000 WAG。');
INSERT INTO `sys_miner` VALUES (8, '双集群协同矿机系统', 7, 15000, 15000.00000000, 7, 9, 'https://img.1trx.in/avatar/58c905fee1c941ab865f49daeca6ebf6.webp', 0, '0', 'admin', '2026-05-03 19:06:02', '', NULL, '双集群协同架构，算力备份不中断，日产出 15000 WAG，适合中大型部署。');
INSERT INTO `sys_miner` VALUES (9, '分布式矿机核心节点', 8, 50000, 50000.00000000, 8, 9, 'https://img.1trx.in/avatar/fc8e0953f6a54d4aa7db7a074fbd3a1c.webp', 0, '0', 'admin', '2026-05-03 19:06:57', '', NULL, '分布式集群核心节点，多链路并行传输，日产出 50000 WAG，高强度运算也能长期稳定。');

-- ----------------------------
-- Table structure for sys_miner_exchange_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_miner_exchange_log`;
CREATE TABLE `sys_miner_exchange_log`  (
  `exchange_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '兑换日志ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `request_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '幂等请求号',
  `wag_amount` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '兑换WAG数量',
  `rate` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '兑换汇率（1 WAG = rate USD）',
  `target_currency` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标币种（USD/CNY）',
  `target_amount` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '目标币种数量',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0成功 1失败 2处理中）',
  `error_msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`exchange_id`) USING BTREE,
  UNIQUE INDEX `uk_miner_exchange_req`(`request_no` ASC) USING BTREE COMMENT '幂等约束',
  INDEX `idx_miner_exchange_user_time`(`user_id` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '矿机WAG兑换日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_miner_exchange_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_miner_reward_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_miner_reward_log`;
CREATE TABLE `sys_miner_reward_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `miner_id` bigint(20) NOT NULL COMMENT '矿机ID',
  `user_miner_id` bigint(20) NOT NULL COMMENT '用户矿机ID',
  `run_id` bigint(20) NULL DEFAULT NULL COMMENT '运行记录ID',
  `reward_mode` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收益模式（A自动 M手工）',
  `action` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '动作（AUTO_CREDIT/MANUAL_COLLECT/CYCLE_FINISH/START/STOP等）',
  `wag_amount` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT 'WAG数量',
  `period_start` datetime NULL DEFAULT NULL COMMENT '收益周期开始',
  `period_end` datetime NULL DEFAULT NULL COMMENT '收益周期结束',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_miner_reward_user_time`(`user_id` ASC, `create_time` ASC) USING BTREE,
  INDEX `idx_miner_reward_run`(`run_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '矿机收益日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_miner_reward_log
-- ----------------------------
INSERT INTO `sys_miner_reward_log` VALUES (1, 1000107, 3, 1, 1, 'A', 'START', 0.00000000, '2026-05-01 20:35:31', '2026-05-03 20:35:31', '2026-05-03 20:35:31', NULL);

-- ----------------------------
-- Table structure for sys_news_article
-- ----------------------------
DROP TABLE IF EXISTS `sys_news_article`;
CREATE TABLE `sys_news_article`  (
  `article_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `category_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类编码',
  `article_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文章标题',
  `summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '摘要',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图',
  `article_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `top_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否置顶（0否 1是）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`article_id`) USING BTREE,
  INDEX `idx_news_article_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_news_article_code`(`category_code` ASC) USING BTREE,
  INDEX `idx_news_article_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '新闻文章表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_news_article
-- ----------------------------
INSERT INTO `sys_news_article` VALUES (1, 1, 'NEWS_INFO', '3,100 美元本金滾出 2,300 萬！「ICO 巨鯨」沉寂 11 年後轉出 1 萬枚以太幣', '幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。', 'https://img.1trx.in/avatar/442f4ec6d0294a5f9cdcdcfb3e89c177.png', '幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。鏈上數據顯示，這位巨鯨是在 2015 年參與以太坊 ICO 時獲得這 1 萬枚以太幣，當時以太幣平均單價僅為 0.31 美元。其實，這並非早期大戶首次現蹤。去年 9 月，另一位同樣在 2015 年 ICO 期間狂掃 100 萬枚以太幣的超級巨鯨，也曾將價值高達 6.45 億美元的以太幣，從 3 個錢包轉出並投入質押。巨鯨甦醒等於倒貨砸盤？專家：別自己嚇自己面對突如其來的巨額資金移動，市場免不了擔憂是否將引發拋售潮。不過分析師指出，「巨鯨甦醒」不等於「準備倒貨」。加密貨幣交易所 CEX.IO 首席分析師 Illia Otychenko 表示：「對於一個買在 0.31 美元的人來說，如今無論在任何價位脫手，都將獲得足以翻轉人生的報酬，因此他們比較沒有誘因去精確抓出場時機。」他進一步解釋，這次大動作轉移很可能出於「非價格因素」：或許只是找回了早期遺失的私鑰或助記詞，又或者是為了整合與重新分配資產。一個休眠近 10 年的錢包在非高峰時期甦醒，這反而更像是資產託管升級或找回金鑰。加密貨幣交易平台 Bitunix 分析師 Dean Chen 也指出，從轉移的時機點來看，實在不像是為了拋售：自 2015 年以來，這位大戶經歷了好幾次牛熊交替，甚至見證了以太幣屢創歷史新高的瘋狂時期。這意味著，他們的眼光遠比一般散戶來得長遠。在多數情況下，這類鉅額轉帳通常不是為了立即套現，更多是為了投資組合重組、託管升級、遺產規劃、準備進行場外交易（OTC），或是閒置資產轉移到更積極的管理架構中。市場機制的現實 VS. 恐慌敘事的蔓延兩位分析師都認為，從市場流動性機制來看，這筆轉帳對以太幣價格仍構不成威脅。Illia Otychenko 補充說明，以太幣目前的每日交易量高達 150 億美元，這區區 2,300 萬美元的籌碼，大約只占主流交易所買賣報價深度的 2%，即使一口氣全數拋售，市場也能輕鬆消化，不會造成嚴重滑價。更何況，「沒有任何專業賣家會採取這種粗暴的倒賣方式」。Dean Chen 也直言，除非這筆資金被直接轉入交易所錢包，否則單憑這筆轉帳，很難對市場結構產生實質的賣壓。然而，現實的交易機制與市場的「恐慌敘事」往往是兩回事，這也是兩位分析師最有共識的盲點。 Illia Otychenko 表示：無論這位巨鯨的真實意圖為何，市場往往會先入為主解讀成「賣出訊號」，這本身就會帶來短期壓力。敘事和交易是兩回事，但在加密貨幣領域，敘事卻成了推動市場交易的唯一理由。', 0, '0', '0', 'admin', '2026-04-30 18:08:19', 'admin', '2026-04-30 18:16:26', '');
INSERT INTO `sys_news_article` VALUES (2, 1, 'NEWS_INFO', 'Etherealize 重磅報告：以太幣長期目標價 25 萬美元，全因這項「超能力」', '如果比特幣是數位黃金，那以太幣（ETH）究竟算什麼？以太坊生態商務拓展和行銷公司 Etherealize 近日拋出震撼市場的重磅報告，並將以太幣的長期目標價定在 25 萬美元。他們認為，以太幣在人類貨幣發展史上，正展現出獨一無二的資產特性。', 'https://img.1trx.in/avatar/d62f4cb844c54e05b2f279907d27e85a.png', '如果比特幣是數位黃金，那以太幣（ETH）究竟算什麼？以太坊生態商務拓展和行銷公司 Etherealize 近日拋出震撼市場的重磅報告，並將以太幣的長期目標價定在 25 萬美元。他們認為，以太幣在人類貨幣發展史上，正展現出獨一無二的資產特性。從 74 萬美元下修至 25 萬美元根據 CoinGecko 報價，以太幣目前仍在 2,390 美元附近徘徊，較去年 8 月創下的 4,946 美元歷史高點回檔超過 51% 。儘管 Etherealize 這次給出的 25 萬美元目標價，比起去年首度公開喊出的 74 萬美元「神蹟價」已大幅下修，但對於現階段的市場而言，這仍是一個極具野心的數字。Etherealize 共同創辦人 Vivek Raman 指出：這只是時間早晚與必然性的問題。我們深信，以太坊最終將成為全球金融系統的支柱，而未來只會有一到兩種數位資產，能真正成為價值儲存工具。他補充說，如果比特幣的霸主地位「已成定局」，那麼以太幣絕對是「另一個強勢角逐者」。不過，這份報告並未給出「以太幣何時能漲到 25 萬美元」的具體時間表。比黃金、比特幣更完美的價值儲存資產？Etherealize 的核心論述在於，以太幣不僅具備如同比特幣、黃金般的「價值儲存」功能，同時也是一種能產生實質收益的「生產性資產」。這歸功於以太坊的「權益證明（PoS）」共識機制，投資人只要將以太幣投入質押，就能獲得穩定的收益。報告提到，目前全球黃金與比特幣的「貨幣溢價（Monetary premium，指資產因具備貨幣功能而產生的附加價值）」合計約 31 兆美元，假如若以太幣能捕捉到同樣的溢價，以目前約 1.21 億枚的流通量來推算，以太幣的合理價位將超過 25 萬美元。更重要的是，與黃金、比特幣這類「純貨幣資產」不同，以太坊底層擁有蓬勃發展的 DeFi 與穩定幣生態，支撐著「真實的經濟活動」。這意味著，即使以太坊需要時間才能完全吸收龐大的貨幣溢價，這些經濟活動也能為幣價提供下行保護，長遠來看，這更讓以太幣的投資吸引力大幅提升。報告寫道：以太幣是史上第一個「沒有交易對手風險，卻能創造複利」的貨幣資產。綜觀人類歷史，投資人往往面臨兩難：要麼持有現金（穩定但無法產生收益），要麼投資生產性資產（能創造財富但伴隨高風險）。這兩者向來是魚與熊掌不可兼得，但以太幣徹底打破了這個界線。目前以太坊的質押年化報酬率約落在 2% 到 4% 之間。雖然數字稱不上暴利，但 Etherealize 研究院 Mike McGuiness 認為，這提供了一種相對安全且能發揮複利效應的投資管道。他表示：大家總是盯著黃金和比特幣的市值，認為比特幣還有 20 倍的成長空間。其實，市場也應該用同樣的眼光來看待以太幣，甚至可以說以太幣才是「更好的貨幣」，因為比特幣根本無法產生複利。Mike McGuiness 進一步點出，黃金與比特幣無法產生收益，本質上就是一灘「死資本（Dead capital）」。不僅如此，比特幣未來還面臨著攸關生死存亡的危機：當 2,100 萬枚比特幣全數開採完畢後，礦工將無法再獲得區塊獎勵。屆時，僅靠微薄的交易手續費，是否還能吸引足夠的礦工貢獻算力來維持網路安全？這將是比特幣無可迴避的致命傷。「結算層霸主」：無懼 Solana 等公鏈圍剿時至今日，以太坊早已是代幣化資產、穩定幣與 DeFi 領域的「結算層霸主」，這為以太幣創造了結構性且具備規模化的龐大需求。更重要的是，由於以太坊會銷毀部分交易手續費，不僅將每年的供應量成長率限制在 1.5% 以下，隨著網路使用量激增，甚至會出現通縮效應。儘管如此，過去一年來，市場上也浮現出不少強勁的對手，試圖挑戰以太坊在機構級區塊鏈中的地位。例如由數十家華爾街巨擘支持的 Canton 、支付巨頭 Stripe 打造的 Tempo，以及已在實體資產（RWA）代幣化領域大放異彩的 Solana 。面對日趨激烈的競爭，Vivek Raman 表示：「這些競爭對手（指其他公鏈）真正要對抗的，其實是以太坊 Layer 2 。」他說：它們本質上只是『執行層』，根本無法與以太坊相提並論。它們不是貨幣，論主權性遠不及以太幣，論去中心化、無需許可更比不上以太坊。', 0, '0', '0', 'admin', '2026-04-30 18:16:59', '', NULL, NULL);
INSERT INTO `sys_news_article` VALUES (3, 1, 'NEWS_INFO', '賺了獎勵恐賠掉本金？BIS 警告：幣圈「高收益理財」實為無擔保貸款', '國際結算銀行發佈報告，警告加密貨幣交易所正轉型為「多功能加密資產仲介機構」，在缺乏監管防火牆的情況下，將交易、託管與自營等衝突職能整合。', 'https://img.1trx.in/avatar/2944a3666cfe4dbfa5d29a1ed3f495a9.png', '從交易平台到「全能機構」，MCIs 正在模糊金融邊界國際結算銀行（BIS）近期發佈一份長達 38 頁的研究報告，揭露全球大型加密貨幣交易所正迅速轉型為「多功能加密資產仲介機構」（Multifunction Crypto-asset Intermediaries，簡稱 MCIs）。這些機構在單一企業架構下，高度整合了交易平台、託管服務、自營交易、經紀業務以及代幣發行等多重職能。BIS 由全球 63 家央行共同持有，報告強調這種運作模式與傳統金融市場的風險隔離原則背道而馳。在傳統金融體系中，為了防止利益衝突與風險擴散，上述角色通常必須拆分至不同的獨立實體並設下嚴格的防火牆。然而，加密交易所傾向於採取垂直整合模式，將客戶資金與平台自身的營運風險深度綁定。這種結構在營運上缺乏透明度，且缺乏準備金要求與資產分開保管的規範，使這些平台實質上成為了規管程度極其鬆散的「影子銀行」。高收益背後的真相：使用者資產淪為無擔保貸款各大加密交易所目前正積極向散戶推銷「Earn」或「理財計畫」等高收益產品，將其包裝為便利的被動收入工具。BIS 報告直言，這些理財產品的本質是向平台提供的無擔保貸款。當使用者存入加密資產以換取報酬率時，平台通常會將這些資產進行「再抵押」（Rehypothecation），循環投入高風險活動。這些活動包含保證金貸款、高度槓桿的自營交易以及市場流動性供應。在這種機制下，使用者往往在不自覺中放棄了資產的法律所有權或實際控制權。一旦平台遭遇償付危機，使用者將直接面臨平台主體的償債風險，並成為清償序列末端的普通債權人。與受規管的傳統銀行存款不同，這些資產完全缺乏存款保險保護，也沒有央行作為最後貸款人提供支持。這種將客戶資產循環投入高風險博弈的行為，為數位資產市場埋下了巨大的不穩定因素。從 FTX 崩潰到 190 億美元閃崩的教訓2025 年 10 月發生的加密貨幣閃崩事件，清晰展示了槓桿回饋循環帶來的破壞力。在短短 24 小時內，受總體經濟經濟衝擊影響，全網強制平倉金額高達 190 億。當時比特幣單日跌幅超過 14%，導致約 160 萬名交易者面臨清算，加密市場總市值在一天內蒸發了 3,500 億。BIS 在報告中特別點名 Celsius Network 與 FTX 的倒閉案例，稱其為建立在槓桿、不透明承諾與缺乏風險管理上的典型教訓。報告指出，加密體系高度依賴自動化清算引擎，且交易深度集中在少數幾家大型平台。當市場信心潰散時，這種結構會引發劇烈的連鎖反應。此外，隨著加密市場與銀行及穩定幣發行商的聯繫日益加深，這種影子銀行體系的失敗可能會對更廣泛的傳統金融產業產生嚴重的外溢效應。監管滯後與駭客入侵，去中心化金融的「傳染路徑」加密市場與去中心化金融（DeFi）的高度整合進一步加劇了風險傳染的可能性。近期發生的 KelpDAO 協議攻擊事件便是一個典型案例。攻擊者透過漏洞鑄造了約 116,500 枚 $rsETH，並以此為抵押品從 Aave 等大型借貸平台借出大量資產，最終造成約 2.92 億的資金缺口。相關新聞：DeFi 震撼彈：Kelp DAO 跨鏈橋遭駭，損失近 3 億美元並波及多個借貸協議這類事件顯示，單一協議的漏洞可能引發整個生態系的流動性危機。安全分析顯示，此次攻擊與北韓 Lazarus Group 有關，駭客在 1.5 天內將 75,700 枚以太幣洗為比特幣，並為 THORChain 平台貢獻了約 91 萬的交易費收入。為了應對日益複雜的挑戰，BIS 建議採取「實體規管」（Entity-based）與「活動規管」（Activity-based）雙軌並行的模式。監管機構目前仍面臨法律架構滯後、跨境協作困難以及監管資源有限等挑戰。若無法落實有效的審慎監管與跨國監督，加密市場的隱性風險將持續威脅全球金融穩定。', 0, '0', '0', 'admin', '2026-04-30 19:36:15', '', NULL, NULL);
INSERT INTO `sys_news_article` VALUES (4, 1, 'NEWS_INFO', '誰是中本聰？紀錄片《Finding Satoshi》：比特幣創辦人有兩位', '自 2009 年比特幣問世以來，其創辦人「中本聰」（Satoshi Nakamoto）的真實身份始終是 21 世紀最大的金融謎團。紀錄片《Finding Satoshi》製作團隊聲稱，透過長達 4 年的縝密調查，首度為這個橫跨十餘年的大問號提供了「決定性的答案」。', 'https://img.1trx.in/avatar/83940c9bac6f4a5faac418a4dd88282a.png', '揭開金融迷霧，紀錄片主張中本聰為雙人組合自 2009 年比特幣問世以來，其創辦人 「中本聰」（Satoshi Nakamoto）的真實身份始終是 21 世紀最大的金融謎團。儘管多年來有無數調查報導、學術分析與猜測，這名改變全球金融地景的神祕人物依然隱身於數位迷霧之後。 2026 年 4 月 22 日，全新紀錄片 《Finding Satoshi》（中本聰尋蹤）正式發佈。製作團隊聲稱透過長達 4 年的縝密調查，首度為這個橫跨十餘年的大問號提供了「決定性的答案」。這部由知名調查報導記者 William D. Cohan 與私家偵探 Tyler Maroney 聯手打造，並由 Tucker Tooley 與 Matthew Miele 執導的作品，跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神，讓作品能直接與大眾連結。圖源：FindingSatoshi.com ｜《Finding Satoshi》跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神紀錄片提出的核心論點挑戰了過往認為中本聰是「單一個體」的普遍認知。調查團隊主張，中本聰實際上是由兩位已故的資深密碼學家共同組成的技術團隊，分別為哈爾・芬尼（Hal Finney）與萊恩・薩薩曼（Len Sassaman）。這兩位傳奇人物在密碼學界享有崇高地位，且都曾深入參與 PGP（Pretty Good Privacy）加密軟體的開發，具備開發比特幣所需的頂尖技術基礎。紀錄片指出，比特幣的誕生結合了 Hal Finney 精湛的程式碼撰寫能力，以及 Len Sassaman 卓越的學術邏輯與寫作才華。這種分工模式解釋了為何比特幣的核心程式碼極其嚴謹，技術白皮書則展現出高度專業的學術論述特質，兩者的融合創造出了一個無懈可擊的數位金融原型。四年深度調查與法醫學分析，還原開發分工真相為了支撐這項震撼結論，製作團隊進行了極其廣泛的跨產業取證。他們不僅走訪了密碼學的起源，更對 20 多位加密貨幣產業的關鍵人物進行深度訪談。受訪名單包含了 Strategy 董事長 Michael Saylor 、以太坊（Ethereum）共同創辦人 Joseph Lubin 、前美國證交會（SEC）主席 Gary Gensler 以及比特幣安全專家 Jameson Lopp 等重量級人士。此外，團隊甚至訪問了 C++ 語言的開發者 Bjarne Stroustrup，試圖從程式語言的演進中尋找比特幣程式碼的創作痕跡。團隊特別聘請了前聯邦調查局（FBI）行為分析專家 Kathleen Puckett 。她曾參與「郵包炸彈客」（Unabomber）的抓捕行動，擅長分析匿名創作者的行為模式。Puckett 透過對中本聰白皮書與早期電子郵件的文體法醫學分析指出，中本聰在溝通中經常使用複數代名詞「我們」，這與團體寫作的行為特徵吻合。分析同時顯示，中本聰引用了 1950 年代的機率論書籍《機率論及其應用導論》，這顯示創作者具備深厚的數學背景與特定的學術傳承，符合 Len Sassaman 的學術生涯軌跡。在技術層面上，調查團隊針對中本聰早期的線上活動時間進行了精確比對。數據顯示，中本聰活躍的時段與美國東部時間高度吻合，這排除了許多位於歐洲或亞洲的熱門候選人。數據科學家 Alyssa Blackburn 提供的文體分析與伺服器日誌比對則進一步證實，Finney 與 Sassaman 的寫作習慣與程式碼風格，在統計學上與中本聰的紀錄高度關聯。這項理論解決了中本聰在程式碼撰寫與文字論述上呈現出的專業差異，將比特幣重新定義為一場跨學科的集體智慧結晶。破解關鍵不在場證明，遺孀證詞推升論點可信度在過往的社群討論中， Hal Finney 雖然一直被視為中本聰的最有力人選，但比特幣開發者 Jameson Lopp 曾提出一項關鍵的「不在場證明」。他指出在中本聰與其它開發者進行電子郵件往返的時間點，Hal Finney 正在參加一場位於聖塔芭芭拉的馬拉松賽事。對此，《Finding Satoshi》提供了解答，認為這恰好證明了中本聰團隊的分工合作。當 Finney 專注於馬拉松賽跑時，團隊中的另一名成員 Len Sassaman 正在處理文字資訊的維護與回覆，使得「中本聰」能維持全天候的運作表象。紀錄片採訪了兩位候選人的遺孀，Hal Finney 的妻子 Fran Finney 在受訪時坦言，她認為丈夫在比特幣的創立中確實扮演了核心角色。 Sassaman 的妻子 Meredith L. Patterson 則描述了丈夫生前對於匿名與隱私技術的狂熱執著，這些人性化的視角為枯燥的技術推演增添了情感厚度。值得注意的是，這項調查結果與近期其它媒體的發現形成了強烈對比。例如，《紐約時報》先前曾透過為期 18 個月的調查，宣稱英國密碼學家 Adam Back 才是中本聰。 Back 本人多次強烈否認，並指出自己雖然發明了 Hashcash，但並非比特幣的創作者。相關新聞：《紐約時報》再掀「中本聰身分謎團」，Adam Back 被鎖定後火速澄清《Finding Satoshi》的製作團隊認為，雖然 Adam Back 的技術是比特幣的重要基石，但其活動軌跡無法完全覆蓋中本聰的所有足跡。紀錄片中還提到，團隊曾於 2021 年採訪了當時權勢如日中天的 FTX 創辦人 SBF，雖然這段 90 分鐘的訪談最終因其後來的詐騙醜聞與紀錄片焦點不符而未剪入正片，但也反映出團隊在調查上的全面性。隨著 Finney 與 Sassaman 相繼於 2014 年與 2011 年離世，這種「逝者已矣」的結論讓許多業界領袖感到釋懷。中本聰持有的 110 萬枚比特幣資產可能永遠處於封印狀態，降低了市場對於大規模拋售的恐懼，也讓這位「神」的傳奇得以在技術層面上延續。業界領袖反應兩極，匿名傳奇與技術信仰的對話紀錄片上映後，加密貨幣社群的反響極其熱烈。 Coinbase 執行長 Brian Armstrong 在觀影後表示，他相信製作團隊已經找到了「正確的答案」。《比特幣原理》作者 Vijay Boyapati 則評價此片為關於中本聰及其背後技術精神的最佳紀錄片。然而，並非所有人都認為揭開真相是必要的。卡爾達諾（Cardano）創辦人 Charles Hoskinson 指出，比特幣最幸運的地方在於「創辦人的缺位」。他認為，如果比特幣綁定某個具體的個人形象，該項目就會受限於該個體的名譽風險。中本聰在比特幣剛開始普及時選擇離開，將主導權交還給社群，這展現出天才的政治與社會學安排，賦予了比特幣一種近乎神話的純粹感。對於許多純粹的技術主義者而言，中本聰的身份或許已經不再重要。紀錄片探討指出，比特幣最初是作為對抗監控資本主義的隱私工具而誕生，其靈魂根植於密碼龐克文化。即便《Finding Satoshi》指出了 Finney 與 Sassaman 的雙人結構，比特幣的去中心化本質依然讓這個協議具備了超越創作者的獨立生命力。隨著各國監管法案如美國的《CLARITY 法案》持續推進，以及各類主動型虛擬資產 ETF 相繼掛牌，比特幣從一個充滿神祕色彩的數位實驗，轉變為全球金融體系中不可或缺的資產類別。中本聰的身份傳奇為這段進程留下了永恆的文學魅力，也讓世人記住那群在數位荒原中，透過程式碼爭取自由的先驅者。', 0, '0', '0', 'admin', '2026-04-30 19:37:29', 'admin', '2026-04-30 19:37:55', '');

-- ----------------------------
-- Table structure for sys_news_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_news_category`;
CREATE TABLE `sys_news_category`  (
  `category_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `category_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类编码',
  `category_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`category_id`) USING BTREE,
  UNIQUE INDEX `uk_news_category_code`(`category_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '新闻分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_news_category
-- ----------------------------
INSERT INTO `sys_news_category` VALUES (1, 'NEWS_INFO', '新闻资讯', 1, '0', 'admin', '2026-04-30 16:35:07', '', NULL, '默认新闻资讯分类');
INSERT INTO `sys_news_category` VALUES (2, 'COMPANY_INFO', '公司信息', 2, '0', 'admin', '2026-04-30 16:35:07', '', NULL, '默认公司信息分类');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int(4) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 42 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 若依系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (3, '若依开源框架介绍', '1', 0x3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE9A1B9E79BAEE4BB8BE7BB8D3C2F7370616E3E3C2F703E3C703E3C666F6E7420636F6C6F723D2223333333333333223E52756F5969E5BC80E6BA90E9A1B9E79BAEE698AFE4B8BAE4BC81E4B89AE794A8E688B7E5AE9AE588B6E79A84E5908EE58FB0E8849AE6898BE69EB6E6A186E69EB6EFBC8CE4B8BAE4BC81E4B89AE68993E980A0E79A84E4B880E7AB99E5BC8FE8A7A3E586B3E696B9E6A188EFBC8CE9998DE4BD8EE4BC81E4B89AE5BC80E58F91E68890E69CACEFBC8CE68F90E58D87E5BC80E58F91E69588E78E87E38082E4B8BBE8A681E58C85E68BACE794A8E688B7E7AEA1E79086E38081E8A792E889B2E7AEA1E79086E38081E983A8E997A8E7AEA1E79086E38081E88F9CE58D95E7AEA1E79086E38081E58F82E695B0E7AEA1E79086E38081E5AD97E585B8E7AEA1E79086E380813C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B297E4BD8DE7AEA1E790863C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E5AE9AE697B6E4BBBBE58AA13C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE380813C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE69C8DE58AA1E79B91E68EA7E38081E799BBE5BD95E697A5E5BF97E38081E6938DE4BD9CE697A5E5BF97E38081E4BBA3E7A081E7949FE68890E7AD89E58A9FE883BDE38082E585B6E4B8ADEFBC8CE8BF98E694AFE68C81E5A49AE695B0E68DAEE6BA90E38081E695B0E68DAEE69D83E99990E38081E59BBDE99985E58C96E380815265646973E7BC93E5AD98E38081446F636B6572E983A8E7BDB2E38081E6BB91E58AA8E9AA8CE8AF81E7A081E38081E7ACACE4B889E696B9E8AEA4E8AF81E799BBE5BD95E38081E58886E5B883E5BC8FE4BA8BE58AA1E380813C2F7370616E3E3C666F6E7420636F6C6F723D2223333333333333223EE58886E5B883E5BC8FE69687E4BBB6E5AD98E582A83C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E58886E5BA93E58886E8A1A8E5A484E79086E7AD89E68A80E69CAFE789B9E782B9E380823C2F7370616E3E3C2F703E3C703E3C696D67207372633D2268747470733A2F2F666F727564612E67697465652E636F6D2F696D616765732F313737333933313834383334323433393033322F61346432323331335F313831353039352E706E6722207374796C653D2277696474683A20363470783B223E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE5AE98E7BD91E58F8AE6BC94E7A4BA3C2F7370616E3E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE5AE98E7BD91E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F72756F79692E7669703C2F613E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E3C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE69687E6A1A3E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F646F632E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F646F632E72756F79692E7669703C2F613E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E4B88DE58886E7A6BBE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F64656D6F2E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F64656D6F2E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E58886E7A6BBE78988E69CACE38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F7675652E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F7675652E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E5BEAEE69C8DE58AA1E78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F636C6F75642E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F636C6F75642E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E7A7BBE58AA8E7ABAFE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F68352E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F68352E72756F79692E7669703C2F613E3C2F703E3C703E3C6272207374796C653D22636F6C6F723A207267622834382C2034392C203531293B20666F6E742D66616D696C793A202671756F743B48656C766574696361204E6575652671756F743B2C2048656C7665746963612C20417269616C2C2073616E732D73657269663B20666F6E742D73697A653A20313270783B223E3C2F703E, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (26, '实名认证待审核', '3', 0xE794A8E688B720E5BC98E6AF85EFBC88E8B4A6E58FB7EFBC9A7465737431EFBC89E68F90E4BAA4E4BA86E5AE9EE5908DE8AEA4E8AF81E794B3E8AFB7E38082, '0', 'system', '2026-05-01 20:25:05', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (27, '充值申请待审核', '3', 0xE794A8E688B720746573743120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20313030302E3030E38082, '0', 'system', '2026-05-01 23:25:14', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (28, '充值申请待审核', '3', 0xE794A8E688B720746573743120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20313030302E3030E38082, '0', 'system', '2026-05-01 23:25:19', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (29, 'Recharge approved', '3', 0x55736572207465737431207265636861726765206F726465722052433230323630353031323332353139304236373345463920686173206265656E20617070726F7665642E20416D6F756E7420313030302E30302055534420686173206265656E2063726564697465642E, '0', 'system', '2026-05-01 23:25:32', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (30, 'Recharge approved', '3', 0x55736572207465737431207265636861726765206F726465722052433230323630353031323332353133373934433533434320686173206265656E20617070726F7665642E20416D6F756E7420313030302E303020434E5920686173206265656E2063726564697465642E, '0', 'system', '2026-05-01 23:25:35', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (31, '充值申请待审核', '3', 0xE794A8E688B720746573743120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20313030302E3030E38082, '0', 'system', '2026-05-01 23:26:26', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (32, 'Recharge approved', '3', 0x55736572207465737431207265636861726765206F726465722052433230323630353031323332363236304143374439464220686173206265656E20617070726F7665642E20416D6F756E7420313030302E30302055534420686173206265656E2063726564697465642E, '0', 'system', '2026-05-01 23:26:45', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (33, '实名认证待审核', '3', 0xE794A8E688B72078747364EFBC88E8B4A6E58FB7EFBC9A6E6E6431EFBC89E68F90E4BAA4E4BA86E5AE9EE5908DE8AEA4E8AF81E794B3E8AFB7E38082, '0', 'system', '2026-05-02 14:10:49', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (34, '充值申请待审核', '3', 0xE794A8E688B7206E6E643120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20313030302E3030E38082, '0', 'system', '2026-05-02 14:24:11', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (35, '充值申请待审核', '3', 0xE794A8E688B7206E6E643120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20313030302E3030E38082, '0', 'system', '2026-05-02 14:24:16', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (36, 'Recharge approved', '3', 0x55736572206E6E6431207265636861726765206F726465722052433230323630353032313432343136303143323946304520686173206265656E20617070726F7665642E20416D6F756E7420313030302E30302055534420686173206265656E2063726564697465642E, '0', 'system', '2026-05-02 14:25:22', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (37, 'Recharge approved', '3', 0x55736572206E6E6431207265636861726765206F726465722052433230323630353032313432343131413833353142313420686173206265656E20617070726F7665642E20416D6F756E7420313030302E303020434E5920686173206265656E2063726564697465642E, '0', 'system', '2026-05-02 14:25:25', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (38, '充值申请待审核', '3', 0xE794A8E688B7206E6E643120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20323030302E3030E38082, '0', 'system', '2026-05-03 19:20:57', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (39, '充值申请待审核', '3', 0xE794A8E688B7206E6E643120E68F90E4BAA4E4BA86E4B880E7AC94E58585E580BCE794B3E8AFB7EFBC8CE98791E9A29D20323030302E3030E38082, '0', 'system', '2026-05-03 19:21:05', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (40, 'Recharge approved', '3', 0x55736572206E6E6431207265636861726765206F726465722052433230323630353033313932313035413644333645384320686173206265656E20617070726F7665642E20416D6F756E7420323030302E303020434E5920686173206265656E2063726564697465642E, '0', 'system', '2026-05-03 19:23:39', '', NULL, NULL);
INSERT INTO `sys_notice` VALUES (41, 'Recharge approved', '3', 0x55736572206E6E6431207265636861726765206F726465722052433230323630353033313932303537303334343331453620686173206265656E20617070726F7665642E20416D6F756E7420323030302E30302055534420686173206265656E2063726564697465642E, '0', 'system', '2026-05-03 19:23:44', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice_read`;
CREATE TABLE `sys_notice_read`  (
  `read_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '已读主键',
  `notice_id` int(4) NOT NULL COMMENT '公告id',
  `user_id` bigint(20) NOT NULL COMMENT '用户id',
  `read_time` datetime NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`) USING BTREE,
  UNIQUE INDEX `uk_user_notice`(`user_id` ASC, `notice_id` ASC) USING BTREE COMMENT '同一用户同一公告只记录一次'
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '公告已读记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notice_read
-- ----------------------------
INSERT INTO `sys_notice_read` VALUES (1, 3, 1, '2026-04-26 14:47:00');
INSERT INTO `sys_notice_read` VALUES (2, 2, 1, '2026-04-26 14:47:00');
INSERT INTO `sys_notice_read` VALUES (28, 37, 1, '2026-05-02 16:39:20');
INSERT INTO `sys_notice_read` VALUES (29, 36, 1, '2026-05-02 16:39:20');
INSERT INTO `sys_notice_read` VALUES (30, 35, 1, '2026-05-02 16:39:20');
INSERT INTO `sys_notice_read` VALUES (31, 34, 1, '2026-05-02 16:39:20');
INSERT INTO `sys_notice_read` VALUES (32, 33, 1, '2026-05-02 16:39:20');
INSERT INTO `sys_notice_read` VALUES (33, 41, 1, '2026-05-03 19:24:02');
INSERT INTO `sys_notice_read` VALUES (34, 40, 1, '2026-05-03 19:53:46');
INSERT INTO `sys_notice_read` VALUES (35, 39, 1, '2026-05-03 19:53:46');
INSERT INTO `sys_notice_read` VALUES (36, 38, 1, '2026-05-03 19:53:46');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int(2) NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int(1) NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int(1) NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint(20) NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 416 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '操作日志记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"dict\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"辅助工具\",\"menuType\":\"M\",\"orderNum\":25,\"params\":{},\"parentId\":0,\"path\":\"/\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 12:40:57', 86);
INSERT INTO `sys_oper_log` VALUES (101, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"/tool/line/qr\",\"createBy\":\"admin\",\"icon\":\"code\",\"isCache\":\"1\",\"isFrame\":\"1\",\"menuName\":\"API二维码\",\"menuType\":\"C\",\"orderNum\":50,\"params\":{},\"parentId\":2000,\"path\":\"tool/line/qr\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 12:42:13', 113);
INSERT INTO `sys_oper_log` VALUES (102, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"tool/line/qr\",\"createTime\":\"2026-04-24 12:42:13\",\"icon\":\"code\",\"isCache\":\"1\",\"isFrame\":\"1\",\"menuId\":2001,\"menuName\":\"API二维码\",\"menuType\":\"C\",\"orderNum\":50,\"params\":{},\"parentId\":2000,\"path\":\"/tool/line/qr\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 12:45:41', 116);
INSERT INTO `sys_oper_log` VALUES (103, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"app.upgrade.config\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"{\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://your-cdn.com/myapp-1.0.3.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 13:22:11', 369);
INSERT INTO `sys_oper_log` VALUES (104, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://your-cdn.com/myapp-1.0.3.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 13:22:42', 86);
INSERT INTO `sys_oper_log` VALUES (105, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"账号自助-是否开启用户注册功能\",\"configType\":\"Y\",\"configValue\":\"true\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 11:27:59\",\"params\":{},\"remark\":\"是否开启注册用户功能（true开启，false关闭）\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 20:30:07', 20);
INSERT INTO `sys_oper_log` VALUES (106, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP多语言\",\"configType\":\"Y\",\"configValue\":\"true\",\"params\":{}} ', '{\"msg\":\"新增参数\'APP多语言\'失败，参数键名已存在\",\"code\":500}', 0, NULL, '2026-04-24 21:28:48', 9);
INSERT INTO `sys_oper_log` VALUES (107, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"N\",\"configValue\":\"{\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://your-cdn.com/myapp-1.0.3.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-24 13:22:42\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-24 21:29:31', 92);
INSERT INTO `sys_oper_log` VALUES (108, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/appConfig/index\",\"createBy\":\"admin\",\"icon\":\"clipboard\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"APP配置管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"appConfig\",\"perms\":\"system:appConfig:list\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:08:13', 127);
INSERT INTO `sys_oper_log` VALUES (109, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/appConfig/index\",\"createTime\":\"2026-04-25 14:08:13\",\"icon\":\"clipboard\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2002,\"menuName\":\"APP配置管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":1,\"path\":\"appConfig\",\"perms\":\"system:appConfig:list;system:config:edit\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:09:52', 60);
INSERT INTO `sys_oper_log` VALUES (110, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:18:43', 38);
INSERT INTO `sys_oper_log` VALUES (111, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:18:43', 16);
INSERT INTO `sys_oper_log` VALUES (112, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:18:43', 14);
INSERT INTO `sys_oper_log` VALUES (113, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.bootstrap.items\",\"configName\":\"APP启动配置项白名单\",\"configType\":\"N\",\"configValue\":\"multiLanguageEnabled,registerEnabled,inviteCodeEnabled\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"APP 初始化时统一拉取哪些配置项\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:18:44', 17);
INSERT INTO `sys_oper_log` VALUES (114, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:18:44', 20);
INSERT INTO `sys_oper_log` VALUES (115, '用户管理', 3, 'com.ruoyi.web.controller.system.SysUserController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/user/101', '127.0.0.1', '内网IP', '[101] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 14:39:04', 90);
INSERT INTO `sys_oper_log` VALUES (116, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"email\":\"a@q.com\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 17:23:24', 187);
INSERT INTO `sys_oper_log` VALUES (117, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"/profile/avatar/2026/04/25/c0ded4737bf84ba8a2049557e5f79710.png\",\"code\":200}', 0, NULL, '2026-04-25 18:57:19', 231);
INSERT INTO `sys_oper_log` VALUES (118, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"/profile/avatar/2026/04/25/8c9aca7bf7674878954121c3610e4370.png\",\"code\":200}', 0, NULL, '2026-04-25 19:42:56', 195);
INSERT INTO `sys_oper_log` VALUES (119, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"/profile/avatar/2026/04/25/1756818e5e974cc69999b2c4507459f6.png\",\"code\":200}', 0, NULL, '2026-04-25 19:44:53', 32);
INSERT INTO `sys_oper_log` VALUES (120, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"/profile/avatar/2026/04/25/15c25cd64dc34e15b5f81039f8bf666a.png\",\"code\":200}', 0, NULL, '2026-04-25 19:50:29', 147);
INSERT INTO `sys_oper_log` VALUES (121, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', NULL, 1, 'Unable to execute HTTP request: Certificate for <img.96vip.cc.s3.ap-southeast-1.amazonaws.com> doesn\'t match any of the subject alternative names: [s3-ap-southeast-1.amazonaws.com, *.s3-ap-southeast-1.amazonaws.com, s3.ap-southeast-1.amazonaws.com, *.s3.ap-southeast-1.amazonaws.com, s3.dualstack.ap-southeast-1.amazonaws.com, *.s3.dualstack.ap-southeast-1.amazonaws.com, *.s3.amazonaws.com, *.s3-control.ap-southeast-1.amazonaws.com, s3-control.ap-southeast-1.amazonaws.com, *.s3-control.dualstack.ap-southeast-1.amazonaws.com, s3-control.dualstack.ap-southeast-1.amazonaws.com, *.s3-accesspoint.ap-southeast-1.amazonaws.com, *.s3-accesspoint.dualstack.ap-southeast-1.amazonaws.com, *.s3-deprecated.ap-southeast-1.amazonaws.com, s3-deprecated.ap-southeast-1.amazonaws.com]', '2026-04-25 19:57:48', 2686);
INSERT INTO `sys_oper_log` VALUES (122, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"https://img.96vip.cc/avatar/950065e750b3450b8a8e1d8e8394053b.png\",\"code\":200}', 0, NULL, '2026-04-25 20:02:31', 2102);
INSERT INTO `sys_oper_log` VALUES (123, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', NULL, 1, 'Failed to upload avatar to OSS: Certificate for <dongim.dongim.oss-cn-guangzhou.aliyuncs.com> doesn\'t match any of the subject alternative names: [cn-heyuan.oss.aliyuncs.com, cn-guangzhou.oss.aliyuncs.com, *.aliyuncs.com, *.cn-guangzhou-cross.mgw.aliyuncs.com, *.cn-guangzhou.mgw.aliyuncs.com, *.cn-guangzhou.oss-console.aliyuncs.com, *.cn-guangzhou.oss.aliyuncs.com, *.cn-heyuan-acdr-1.oss.aliyuncs.com, *.cn-heyuan.mgw.aliyuncs.com, *.cn-heyuan.oss-console.aliyuncs.com, *.cn-heyuan.oss.aliyuncs.com, *.oss-accelerate-overseas.aliyuncs.com, *.oss-accelerate.aliyuncs.com, *.oss-accesspoint.aliyuncs.com, *.oss-cn-guangzhou-cross.aliyuncs.com, *.oss-cn-guangzhou-internal.aliyuncs.com, *.oss-cn-guangzhou-internal.oss-accesspoint.aliyuncs.com, *.oss-cn-guangzhou-internal.oss-object-process.aliyuncs.com, *.oss-cn-guangzhou.aliyuncs.com, *.oss-cn-guangzhou.oss-accesspoint.aliyuncs.com, *.oss-cn-guangzhou.oss-object-process.aliyuncs.com, *.oss-cn-heyuan-acdr-1-cross.aliyuncs.com, *.oss-cn-heyuan-acdr-1-internal.aliyuncs.com, *.oss-cn-heyuan-acdr-1.aliyuncs.com, *.oss-cn-heyuan-cross.aliyuncs.com, *.oss-cn-heyuan-internal.aliyuncs.com, *.oss-cn-heyuan-internal.oss-accesspoint.aliyuncs.com, *.oss-cn-heyuan-internal.oss-object-process.aliyuncs.com, *.oss-cn-heyuan.aliyuncs.com, *.oss-cn-heyuan.oss-accesspoint.aliyuncs.com, *.oss-cn-heyuan.oss-object-process.aliyuncs.com, *.oss-console.aliyuncs.com, *.oss-enet.aliyuncs.com, *.oss-internal.aliyun-inc.com, *.oss-internal.aliyuncs.com, *.oss.cn-guangzhou.privatelink.aliyuncs.com, *.oss.cn-heyuan.privatelink.aliyuncs.com, *.s3.oss-accelerate-overseas.aliyuncs.com, *.s3.oss-accelerate.aliyuncs.com, *.s3.oss-cn-guangzhou-internal.aliyuncs.com, *.s3.oss-cn-guangzhou.aliyuncs.com, *.s3.oss-cn-heyuan-internal.aliyuncs.com, *.s3.oss-cn-heyuan.aliyuncs.com, *.cn-heyuan.osscloud.cn, *.cn-guangzhou.osscloud.cn, *.osscloud.cn, *.enet.osscloud.cn, *.enet.oss-svc-cn.cn]\n[ErrorCode]: SslException\n[RequestId]: Unknown', '2026-04-25 20:42:01', 4985);
INSERT INTO `sys_oper_log` VALUES (124, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/946b12f8b0b5449bb24ae22c0b3d46c7.png\",\"code\":200}', 0, NULL, '2026-04-25 20:45:04', 711);
INSERT INTO `sys_oper_log` VALUES (125, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"https://s3.ap-southeast-1.amazonaws.com/avatar/f870197536324395b2824c864ab894ee.png\",\"code\":200}', 0, NULL, '2026-04-25 20:45:56', 2475);
INSERT INTO `sys_oper_log` VALUES (126, '用户头像', 2, 'com.ruoyi.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'lanz', NULL, '/system/user/profile/avatar', '192.168.0.2', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/61ec5787a7ab4e329a10526f222751f2.png\",\"code\":200}', 0, NULL, '2026-04-25 20:47:22', 1098);
INSERT INTO `sys_oper_log` VALUES (127, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{},\"remark\":\"JJ好小\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:02:37', 72);
INSERT INTO `sys_oper_log` VALUES (128, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"nickName\":\"小兰南\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:02:51', 49);
INSERT INTO `sys_oper_log` VALUES (129, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{},\"sex\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:02:55', 20);
INSERT INTO `sys_oper_log` VALUES (130, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"nickName\":\"小兰男\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:03:15', 21);
INSERT INTO `sys_oper_log` VALUES (131, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{},\"remark\":\"万事开头男\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:03:24', 23);
INSERT INTO `sys_oper_log` VALUES (132, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"nickName\":\"小兰男\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:07:23', 110);
INSERT INTO `sys_oper_log` VALUES (133, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{},\"phonenumber\":\"13988888888\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:07:31', 49);
INSERT INTO `sys_oper_log` VALUES (134, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"email\":\"a@a.com\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:07:54', 58);
INSERT INTO `sys_oper_log` VALUES (135, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"birthday\":\"2026-04-25\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-25 23:07:59', 26);
INSERT INTO `sys_oper_log` VALUES (136, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'lanz', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '[{\"answer\":\"111\",\"params\":{},\"questionId\":1,\"userId\":1000100},{\"answer\":\"111\",\"params\":{},\"questionId\":2,\"userId\":1000100}] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 12:33:00', 78);
INSERT INTO `sys_oper_log` VALUES (137, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'lanz', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '[{\"answer\":\"222\",\"params\":{},\"questionId\":3,\"userId\":1000100},{\"answer\":\"222\",\"params\":{},\"questionId\":4,\"userId\":1000100}] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 12:33:28', 30);
INSERT INTO `sys_oper_log` VALUES (138, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updatePwd()', 'PUT', 1, 'lanz', NULL, '/system/user/profile/updatePwd', '192.168.140.1', '内网IP', '{} ', '{\"msg\":\"新密码不能与旧密码相同\",\"code\":500}', 0, NULL, '2026-04-26 13:05:04', 205);
INSERT INTO `sys_oper_log` VALUES (139, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updatePwd()', 'PUT', 1, 'lanz', NULL, '/system/user/profile/updatePwd', '192.168.140.1', '内网IP', '{} ', '{\"msg\":\"新密码不能与旧密码相同\",\"code\":500}', 0, NULL, '2026-04-26 13:05:18', 199);
INSERT INTO `sys_oper_log` VALUES (140, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updatePwd()', 'PUT', 1, 'lanz', NULL, '/system/user/profile/updatePwd', '192.168.140.1', '内网IP', '{} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 13:05:38', 497);
INSERT INTO `sys_oper_log` VALUES (141, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:28:20', 2096);
INSERT INTO `sys_oper_log` VALUES (142, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:08', 223);
INSERT INTO `sys_oper_log` VALUES (143, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:08', 164);
INSERT INTO `sys_oper_log` VALUES (144, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:09', 159);
INSERT INTO `sys_oper_log` VALUES (145, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:09', 177);
INSERT INTO `sys_oper_log` VALUES (146, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":103,\"configKey\":\"app.bootstrap.items\",\"configName\":\"APP启动配置项白名单\",\"configType\":\"N\",\"configValue\":\"multiLanguageEnabled,registerEnabled,inviteCodeEnabled\",\"params\":{},\"remark\":\"APP 初始化时统一拉取哪些配置项\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:10', 165);
INSERT INTO `sys_oper_log` VALUES (147, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:12', 2179);
INSERT INTO `sys_oper_log` VALUES (148, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:17', 159);
INSERT INTO `sys_oper_log` VALUES (149, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:18', 167);
INSERT INTO `sys_oper_log` VALUES (150, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:18', 152);
INSERT INTO `sys_oper_log` VALUES (151, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:19', 154);
INSERT INTO `sys_oper_log` VALUES (152, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":103,\"configKey\":\"app.bootstrap.items\",\"configName\":\"APP启动配置项白名单\",\"configType\":\"N\",\"configValue\":\"multiLanguageEnabled,registerEnabled,inviteCodeEnabled,realNameHandheldRequired\",\"params\":{},\"remark\":\"APP 初始化时统一拉取哪些配置项\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:20', 154);
INSERT INTO `sys_oper_log` VALUES (153, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:22', 2150);
INSERT INTO `sys_oper_log` VALUES (154, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:35', 192);
INSERT INTO `sys_oper_log` VALUES (155, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:36', 163);
INSERT INTO `sys_oper_log` VALUES (156, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:36', 148);
INSERT INTO `sys_oper_log` VALUES (157, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:37', 153);
INSERT INTO `sys_oper_log` VALUES (158, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":103,\"configKey\":\"app.bootstrap.items\",\"configName\":\"APP启动配置项白名单\",\"configType\":\"N\",\"configValue\":\"multiLanguageEnabled,registerEnabled,inviteCodeEnabled,realNameHandheldRequired\",\"params\":{},\"remark\":\"APP 初始化时统一拉取哪些配置项\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:37', 156);
INSERT INTO `sys_oper_log` VALUES (159, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:37:40', 2167);
INSERT INTO `sys_oper_log` VALUES (160, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-04-24 11:27:59\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"若依官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"parentId\":0,\"path\":\"http://ruoyi.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:38:52', 84);
INSERT INTO `sys_oper_log` VALUES (161, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:10', 212);
INSERT INTO `sys_oper_log` VALUES (162, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:11', 173);
INSERT INTO `sys_oper_log` VALUES (163, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:11', 161);
INSERT INTO `sys_oper_log` VALUES (164, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:12', 180);
INSERT INTO `sys_oper_log` VALUES (165, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":103,\"configKey\":\"app.bootstrap.items\",\"configName\":\"APP启动配置项白名单\",\"configType\":\"N\",\"configValue\":\"multiLanguageEnabled,registerEnabled,inviteCodeEnabled,realNameHandheldRequired\",\"params\":{},\"remark\":\"APP 初始化时统一拉取哪些配置项\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:13', 173);
INSERT INTO `sys_oper_log` VALUES (166, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:41:15', 2306);
INSERT INTO `sys_oper_log` VALUES (167, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"realNameAuth\",\"createBy\":\"admin\",\"icon\":\"build\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"实名认证管理\",\"menuType\":\"C\",\"orderNum\":3,\"params\":{},\"parentId\":2000,\"path\":\"system/realNameAuth/index\",\"perms\":\"system:realNameAuth:list\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:51:16', 90);
INSERT INTO `sys_oper_log` VALUES (168, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/realNameAuth/index\",\"createTime\":\"2026-04-26 14:51:16\",\"icon\":\"build\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2005,\"menuName\":\"实名认证管理\",\"menuType\":\"C\",\"orderNum\":3,\"params\":{},\"parentId\":2000,\"path\":\"system/realNameAuth/index\",\"perms\":\"system:realNameAuth:list\",\"routeName\":\"realNameAuth\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-26 14:52:34', 103);
INSERT INTO `sys_oper_log` VALUES (169, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:14', 7612);
INSERT INTO `sys_oper_log` VALUES (170, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:22', 7318);
INSERT INTO `sys_oper_log` VALUES (171, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:31', 9018);
INSERT INTO `sys_oper_log` VALUES (172, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"false\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:40', 7944);
INSERT INTO `sys_oper_log` VALUES (173, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.currency.usdRate\",\"configName\":\"APP配置-美元汇率\",\"configType\":\"N\",\"configValue\":\"7\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"APP 配置管理页面维护\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:47', 6611);
INSERT INTO `sys_oper_log` VALUES (174, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.currency.investMode\",\"configName\":\"APP配置-投资货币方式\",\"configType\":\"N\",\"configValue\":\"1\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"APP 配置管理页面维护\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:01:58', 10384);
INSERT INTO `sys_oper_log` VALUES (175, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:03:41', 11475);
INSERT INTO `sys_oper_log` VALUES (176, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:04:08', 11259);
INSERT INTO `sys_oper_log` VALUES (177, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:04:45', 7421);
INSERT INTO `sys_oper_log` VALUES (178, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:04:54', 8484);
INSERT INTO `sys_oper_log` VALUES (179, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:05:03', 8579);
INSERT INTO `sys_oper_log` VALUES (180, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:05:11', 6946);
INSERT INTO `sys_oper_log` VALUES (181, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.currency.usdRate\",\"configName\":\"APP配置-美元汇率\",\"configType\":\"N\",\"configValue\":\"7\",\"params\":{},\"remark\":\"APP 配置管理页面维护\"} ', '{\"msg\":\"新增参数\'APP配置-美元汇率\'失败，参数键名已存在\",\"code\":500}', 0, NULL, '2026-04-28 22:05:12', 3);
INSERT INTO `sys_oper_log` VALUES (182, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-28 22:05:27', 9984);
INSERT INTO `sys_oper_log` VALUES (183, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":1,\"params\":{},\"rejectReason\":\"请重新提交\",\"reviewTime\":\"2026-04-29 13:25:46\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":2} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 13:25:46', 89);
INSERT INTO `sys_oper_log` VALUES (184, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":2,\"params\":{},\"rejectReason\":\"还是不对\",\"reviewTime\":\"2026-04-29 13:33:50\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":2} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 13:33:50', 52);
INSERT INTO `sys_oper_log` VALUES (185, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/61ec5787a7ab4e329a10526f222751f2.png\",\"birthday\":\"2026-04-25\",\"createTime\":\"2026-04-24 20:30:27\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"a@a.com\",\"inviteCode\":\"ABCDEA\",\"level\":1,\"levelDetail\":\"0\",\"loginDate\":\"2026-04-29 13:34:30\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小兰男\",\"params\":{\"@type\":\"java.util.HashMap\"},\"payPasswordSet\":0,\"phonenumber\":\"13988888888\",\"postIds\":[],\"pwdUpdateDate\":\"2026-04-28 11:03:19\",\"realNameStatus\":2,\"remark\":\"万事开头男\",\"roleIds\":[],\"roles\":[],\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-29 13:29:52\",\"userId\":1000100,\"userLevel\":0,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 13:49:58', 2256);
INSERT INTO `sys_oper_log` VALUES (186, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{},\"sex\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 13:59:51', 1701);
INSERT INTO `sys_oper_log` VALUES (187, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"email\":\"aa@a.com\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:00:03', 2441);
INSERT INTO `sys_oper_log` VALUES (188, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/61ec5787a7ab4e329a10526f222751f2.png\",\"birthday\":\"2026-04-25\",\"createTime\":\"2026-04-24 20:30:27\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"aa@a.com\",\"inviteCode\":\"ABCDEA\",\"level\":1,\"levelDetail\":\"0\",\"loginDate\":\"2026-04-29 13:29:14\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小兰男\",\"params\":{\"@type\":\"java.util.HashMap\"},\"payPasswordSet\":0,\"phonenumber\":\"13988888888\",\"postIds\":[],\"pwdUpdateDate\":\"2026-04-28 11:03:19\",\"realNameStatus\":1,\"remark\":\"万事开头男\",\"roleIds\":[],\"roles\":[],\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-29 14:00:00\",\"userId\":1000100,\"userLevel\":0,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:00:48', 3690);
INSERT INTO `sys_oper_log` VALUES (189, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/61ec5787a7ab4e329a10526f222751f2.png\",\"birthday\":\"2026-04-25\",\"createTime\":\"2026-04-24 20:30:27\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"aa@a.com\",\"inviteCode\":\"ABCDEA\",\"level\":1,\"levelDetail\":\"0\",\"loginDate\":\"2026-04-29 13:29:14\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小兰男\",\"params\":{\"@type\":\"java.util.HashMap\"},\"payPasswordSet\":0,\"phonenumber\":\"13988888888\",\"postIds\":[],\"pwdUpdateDate\":\"2026-04-28 11:03:19\",\"realNameStatus\":1,\"remark\":\"万事开头男\",\"roleIds\":[],\"roles\":[],\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-29 14:00:00\",\"userId\":1000100,\"userLevel\":0,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:00:52', 2686);
INSERT INTO `sys_oper_log` VALUES (190, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":3,\"params\":{},\"rejectReason\":\"不行\",\"reviewTime\":\"2026-04-29 14:01:21\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":2} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:01:21', 94);
INSERT INTO `sys_oper_log` VALUES (191, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://dongim.oss-cn-guangzhou.aliyuncs.com/avatar/61ec5787a7ab4e329a10526f222751f2.png\",\"birthday\":\"2026-04-25\",\"createTime\":\"2026-04-24 20:30:27\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"aa@a.com\",\"inviteCode\":\"ABCDEA\",\"level\":1,\"levelDetail\":\"0\",\"loginDate\":\"2026-04-29 14:02:17\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小兰男\",\"params\":{\"@type\":\"java.util.HashMap\"},\"payPasswordSet\":0,\"phonenumber\":\"13988888888\",\"postIds\":[],\"pwdUpdateDate\":\"2026-04-28 11:03:19\",\"realNameStatus\":2,\"remark\":\"万事开头男\",\"roleIds\":[],\"roles\":[],\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-29 14:00:49\",\"userId\":1000100,\"userLevel\":0,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:02:51', 1359);
INSERT INTO `sys_oper_log` VALUES (192, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"email\":\"aa@abc.com\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:13:28', 2450);
INSERT INTO `sys_oper_log` VALUES (193, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":4,\"params\":{},\"rejectReason\":\"再来一次\",\"reviewTime\":\"2026-04-29 14:13:57\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":2,\"userId\":1000100,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:13:58', 1587);
INSERT INTO `sys_oper_log` VALUES (194, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":5,\"params\":{},\"reviewTime\":\"2026-04-29 14:15:11\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userId\":1000100,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 14:15:13', 1461);
INSERT INTO `sys_oper_log` VALUES (195, '用户钱包', 2, 'com.ruoyi.web.controller.system.SysUserWalletController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/wallet', '127.0.0.1', '内网IP', '{\"availableBalance\":1000.0,\"currencyType\":\"USD\",\"totalRecharge\":1000.0,\"walletId\":7} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":1}', 0, NULL, '2026-04-29 14:22:17', 36);
INSERT INTO `sys_oper_log` VALUES (196, '钱包流水', 1, 'com.ruoyi.web.controller.system.SysUserWalletController.addLog()', 'POST', 1, 'admin', '研发部门', '/system/wallet/log', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"balanceAfter\":1000.0,\"balanceBefore\":0.0,\"currencyType\":\"USD\",\"remark\":\"\",\"status\":\"success\",\"type\":\"recharge\",\"userId\":1000100,\"walletId\":7} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":1}', 0, NULL, '2026-04-29 14:22:18', 18);
INSERT INTO `sys_oper_log` VALUES (197, '鐢ㄦ埛閽卞寘', 2, 'com.ruoyi.web.controller.system.SysUserWalletController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/wallet', '127.0.0.1', '内网IP', '{\"availableBalance\":4000.0,\"currencyType\":\"CNY\",\"totalWithdraw\":1000.0,\"walletId\":3} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":1}', 0, NULL, '2026-04-29 14:54:51', 37);
INSERT INTO `sys_oper_log` VALUES (198, '閽卞寘娴佹按', 1, 'com.ruoyi.web.controller.system.SysUserWalletController.addLog()', 'POST', 1, 'admin', '研发部门', '/system/wallet/log', '127.0.0.1', '内网IP', '{\"amount\":-1000.0,\"balanceAfter\":4000.0,\"balanceBefore\":5000.0,\"currencyType\":\"CNY\",\"remark\":\"\",\"status\":\"success\",\"type\":\"withdraw\",\"userId\":1000100,\"walletId\":3} ', '{\"msg\":\"金额不能为负数\",\"code\":500}', 0, NULL, '2026-04-29 14:54:51', 6);
INSERT INTO `sys_oper_log` VALUES (199, '鐢ㄦ埛閽卞寘', 2, 'com.ruoyi.web.controller.system.SysUserWalletController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/wallet', '127.0.0.1', '内网IP', '{\"availableBalance\":4000.0,\"currencyType\":\"CNY\",\"totalWithdraw\":1000.0,\"walletId\":3} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":1}', 0, NULL, '2026-04-29 14:56:47', 25);
INSERT INTO `sys_oper_log` VALUES (200, '閽卞寘娴佹按', 1, 'com.ruoyi.web.controller.system.SysUserWalletController.addLog()', 'POST', 1, 'admin', '研发部门', '/system/wallet/log', '127.0.0.1', '内网IP', '{\"amount\":-1000.0,\"balanceAfter\":4000.0,\"balanceBefore\":5000.0,\"currencyType\":\"CNY\",\"operatorName\":\"admin\",\"remark\":\"\",\"status\":\"success\",\"type\":\"withdraw\",\"userId\":1000100,\"walletId\":3} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":1}', 0, NULL, '2026-04-29 14:56:47', 17);
INSERT INTO `sys_oper_log` VALUES (201, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:22:46', 6587);
INSERT INTO `sys_oper_log` VALUES (202, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:22:55', 8639);
INSERT INTO `sys_oper_log` VALUES (203, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":102,\"configKey\":\"app.feature.inviteCodeEnabled\",\"configName\":\"APP配置-邀请码注册开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:23:04', 8039);
INSERT INTO `sys_oper_log` VALUES (204, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":104,\"configKey\":\"app.feature.realNameHandheldRequired\",\"configName\":\"APP配置-实名认证需手持身份证\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:23:13', 7890);
INSERT INTO `sys_oper_log` VALUES (205, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":105,\"configKey\":\"app.currency.usdRate\",\"configName\":\"APP配置-美元汇率\",\"configType\":\"N\",\"configValue\":\"7\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:23:23', 10053);
INSERT INTO `sys_oper_log` VALUES (206, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:25:38', 27802);
INSERT INTO `sys_oper_log` VALUES (207, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":101,\"configKey\":\"app.feature.multiLanguage\",\"configName\":\"APP配置-多语言开关\",\"configType\":\"N\",\"configValue\":\"true\",\"params\":{},\"remark\":\"APP 配置管理页面维护\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:26:11', 9869);
INSERT INTO `sys_oper_log` VALUES (208, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'lanz', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"amount\":1000.0,\"createTime\":\"2026-04-29 16:27:59\",\"currencyType\":\"CNY\",\"orderNo\":\"RC202604291627591571ED42\",\"params\":{},\"rechargeId\":1,\"rechargeMethod\":\"RMB\",\"status\":0,\"submitTime\":\"2026-04-29 16:27:59\",\"updateTime\":\"2026-04-29 16:27:59\",\"userId\":1000100,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:27:59', 482);
INSERT INTO `sys_oper_log` VALUES (209, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC202604291627591571ED42\",\"params\":{},\"rechargeId\":1,\"rejectReason\":\"\",\"reviewTime\":\"2026-04-29 16:38:07\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:38:07', 737);
INSERT INTO `sys_oper_log` VALUES (210, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'lanz', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"amount\":1000.0,\"createTime\":\"2026-04-29 16:41:15\",\"currencyType\":\"USD\",\"orderNo\":\"RC20260429164115F8BD9AE8\",\"params\":{},\"rechargeId\":2,\"rechargeMethod\":\"USDT\",\"status\":0,\"submitTime\":\"2026-04-29 16:41:15\",\"updateTime\":\"2026-04-29 16:41:15\",\"userId\":1000100,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:41:16', 358);
INSERT INTO `sys_oper_log` VALUES (211, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC20260429164115F8BD9AE8\",\"params\":{},\"rechargeId\":2,\"rejectReason\":\"\",\"reviewTime\":\"2026-04-29 16:41:47\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 16:41:48', 410);
INSERT INTO `sys_oper_log` VALUES (212, 'Bank card bind', 1, 'com.ruoyi.web.controller.app.AppBankCardController.add()', 'POST', 1, 'lanz', NULL, '/app/bankCard', '192.168.140.1', '内网IP', '{\"accountName\":\"张三\",\"accountNo\":\"62332332222222\",\"bankCardId\":1,\"bankName\":\"建设银行\",\"createBy\":\"lanz\",\"createTime\":\"2026-04-29 17:32:23\",\"currencyType\":\"CNY\",\"params\":{},\"updateBy\":\"lanz\",\"updateTime\":\"2026-04-29 17:32:23\",\"userId\":1000100,\"userName\":\"lanz\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 17:32:23', 769);
INSERT INTO `sys_oper_log` VALUES (213, 'Bank card bind', 1, 'com.ruoyi.web.controller.app.AppBankCardController.add()', 'POST', 1, 'lanz', NULL, '/app/bankCard', '192.168.140.1', '内网IP', '{\"bankCardId\":2,\"createBy\":\"lanz\",\"createTime\":\"2026-04-29 17:33:33\",\"currencyType\":\"USD\",\"params\":{},\"updateBy\":\"lanz\",\"updateTime\":\"2026-04-29 17:33:33\",\"userId\":1000100,\"userName\":\"lanz\",\"walletAddress\":\"werewrdfsfsdfsdfdsfdsfdsfsd\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 17:33:33', 738);
INSERT INTO `sys_oper_log` VALUES (214, 'User withdraw submit', 1, 'com.ruoyi.web.controller.app.AppWithdrawController.submit()', 'POST', 1, 'lanz', NULL, '/app/withdraw/submit', '192.168.140.1', '内网IP', '{\"accountName\":\"张三\",\"accountNo\":\"62332332222222\",\"amount\":1000.0,\"bankCardId\":1,\"bankName\":\"建设银行\",\"createTime\":\"2026-04-29 18:29:11\",\"currencyType\":\"CNY\",\"orderNo\":\"WD202604291829112269CB3F\",\"params\":{},\"status\":0,\"submitTime\":\"2026-04-29 18:29:11\",\"updateTime\":\"2026-04-29 18:29:11\",\"userId\":1000100,\"userName\":\"lanz\",\"walletId\":3,\"withdrawId\":1,\"withdrawMethod\":\"BANK\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 18:29:11', 812);
INSERT INTO `sys_oper_log` VALUES (215, 'User withdraw submit', 1, 'com.ruoyi.web.controller.app.AppWithdrawController.submit()', 'POST', 1, 'lanz', NULL, '/app/withdraw/submit', '192.168.140.1', '内网IP', '{\"amount\":500.0,\"bankCardId\":2,\"createTime\":\"2026-04-29 18:29:23\",\"currencyType\":\"USD\",\"orderNo\":\"WD2026042918292376E7E907\",\"params\":{},\"status\":0,\"submitTime\":\"2026-04-29 18:29:23\",\"updateTime\":\"2026-04-29 18:29:23\",\"userId\":1000100,\"userName\":\"lanz\",\"walletAddress\":\"werewrdfsfsdfsdfdsfdsfdsfsd\",\"walletId\":7,\"withdrawId\":2,\"withdrawMethod\":\"USDT\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 18:29:23', 709);
INSERT INTO `sys_oper_log` VALUES (216, '提现审核', 2, 'com.ruoyi.web.controller.system.SysUserWithdrawController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/withdraw', '127.0.0.1', '内网IP', '{\"amount\":500.0,\"orderNo\":\"WD2026042918292376E7E907\",\"params\":{},\"rejectReason\":\"\",\"reviewTime\":\"2026-04-29 19:07:04\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"lanz\",\"withdrawId\":2} ', NULL, 1, '冻结金额不足。', '2026-04-29 19:07:05', 132);
INSERT INTO `sys_oper_log` VALUES (217, '提现删除', 3, 'com.ruoyi.web.controller.system.SysUserWithdrawController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/withdraw/2', '127.0.0.1', '内网IP', '[2] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:07:13', 84);
INSERT INTO `sys_oper_log` VALUES (218, '提现删除', 3, 'com.ruoyi.web.controller.system.SysUserWithdrawController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/withdraw/1', '127.0.0.1', '内网IP', '[1] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:07:16', 14);
INSERT INTO `sys_oper_log` VALUES (219, '提现申请', 1, 'com.ruoyi.web.controller.app.AppWithdrawController.submit()', 'POST', 1, 'lanz', NULL, '/app/withdraw/submit', '192.168.140.1', '内网IP', '{\"accountName\":\"张三\",\"accountNo\":\"62332332222222\",\"amount\":500.0,\"bankCardId\":1,\"bankName\":\"建设银行\",\"createTime\":\"2026-04-29 19:10:17\",\"currencyType\":\"CNY\",\"orderNo\":\"WD202604291910170BEA93F2\",\"params\":{},\"status\":0,\"submitTime\":\"2026-04-29 19:10:17\",\"updateTime\":\"2026-04-29 19:10:17\",\"userId\":1000100,\"userName\":\"lanz\",\"walletId\":3,\"withdrawId\":3,\"withdrawMethod\":\"BANK\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:10:18', 768);
INSERT INTO `sys_oper_log` VALUES (220, '提现申请', 1, 'com.ruoyi.web.controller.app.AppWithdrawController.submit()', 'POST', 1, 'lanz', NULL, '/app/withdraw/submit', '192.168.140.1', '内网IP', '{\"amount\":500.0,\"bankCardId\":2,\"createTime\":\"2026-04-29 19:10:31\",\"currencyType\":\"USD\",\"orderNo\":\"WD20260429191031064EFDDB\",\"params\":{},\"status\":0,\"submitTime\":\"2026-04-29 19:10:31\",\"updateTime\":\"2026-04-29 19:10:31\",\"userId\":1000100,\"userName\":\"lanz\",\"walletAddress\":\"werewrdfsfsdfsdfdsfdsfdsfsd\",\"walletId\":7,\"withdrawId\":4,\"withdrawMethod\":\"USDT\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:10:31', 772);
INSERT INTO `sys_oper_log` VALUES (221, '提现审核', 2, 'com.ruoyi.web.controller.system.SysUserWithdrawController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/withdraw', '127.0.0.1', '内网IP', '{\"amount\":500.0,\"orderNo\":\"WD20260429191031064EFDDB\",\"params\":{},\"rejectReason\":\"退回\",\"reviewTime\":\"2026-04-29 19:11:30\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":2,\"userName\":\"lanz\",\"withdrawId\":4} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:11:30', 90);
INSERT INTO `sys_oper_log` VALUES (222, '提现审核', 2, 'com.ruoyi.web.controller.system.SysUserWithdrawController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/withdraw', '127.0.0.1', '内网IP', '{\"amount\":500.0,\"orderNo\":\"WD202604291910170BEA93F2\",\"params\":{},\"rejectReason\":\"\",\"reviewTime\":\"2026-04-29 19:11:35\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"lanz\",\"withdrawId\":3} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 19:11:35', 33);
INSERT INTO `sys_oper_log` VALUES (223, '提现申请', 1, 'com.ruoyi.web.controller.app.AppWithdrawController.submit()', 'POST', 1, 'lanz', NULL, '/app/withdraw/submit', '192.168.140.1', '内网IP', '{\"amount\":100.0,\"bankCardId\":2,\"createTime\":\"2026-04-29 21:03:52\",\"currencyType\":\"USD\",\"orderNo\":\"WD20260429210352EDC579DA\",\"params\":{},\"status\":0,\"submitTime\":\"2026-04-29 21:03:52\",\"updateTime\":\"2026-04-29 21:03:52\",\"userId\":1000100,\"userName\":\"lanz\",\"walletAddress\":\"werewrdfsfsdfsdfdsfdsfdsfsd\",\"walletId\":7,\"withdrawId\":5,\"withdrawMethod\":\"USDT\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-29 21:03:52', 442);
INSERT INTO `sys_oper_log` VALUES (224, '通知公告', 3, 'com.ruoyi.web.controller.system.SysNoticeController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/notice/19,25,24,23,22,21,20,18,17,16,15,14,13,12,11,10', '127.0.0.1', '内网IP', '[19,25,24,23,22,21,20,18,17,16,15,14,13,12,11,10] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 17:01:37', 79);
INSERT INTO `sys_oper_log` VALUES (225, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"avatar\":\"http://192.168.140.1:8080/profile/upload/2026/04/30/scaled_西部女骑士头像生成_20260430180326A001.png\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:03:28', 711);
INSERT INTO `sys_oper_log` VALUES (226, '新闻文章', 1, 'com.ruoyi.web.controller.system.SysNewsArticleController.add()', 'POST', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。鏈上數據顯示，這位巨鯨是在 2015 年參與以太坊 ICO 時獲得這 1 萬枚以太幣，當時以太幣平均單價僅為 0.31 美元。其實，這並非早期大戶首次現蹤。去年 9 月，另一位同樣在 2015 年 ICO 期間狂掃 100 萬枚以太幣的超級巨鯨，也曾將價值高達 6.45 億美元的以太幣，從 3 個錢包轉出並投入質押。巨鯨甦醒等於倒貨砸盤？專家：別自己嚇自己面對突如其來的巨額資金移動，市場免不了擔憂是否將引發拋售潮。不過分析師指出，「巨鯨甦醒」不等於「準備倒貨」。加密貨幣交易所 CEX.IO 首席分析師 Illia Otychenko 表示：「對於一個買在 0.31 美元的人來說，如今無論在任何價位脫手，都將獲得足以翻轉人生的報酬，因此他們比較沒有誘因去精確抓出場時機。」他進一步解釋，這次大動作轉移很可能出於「非價格因素」：或許只是找回了早期遺失的私鑰或助記詞，又或者是為了整合與重新分配資產。一個休眠近 10 年的錢包在非高峰時期甦醒，這反而更像是資產託管升級或找回金鑰。加密貨幣交易平台 Bitunix 分析師 Dean Chen 也指出，從轉移的時機點來看，實在不像是為了拋售：自 2015 年以來，這位大戶經歷了好幾次牛熊交替，甚至見證了以太幣屢創歷史新高的瘋狂時期。這意味著，他們的眼光遠比一般散戶來得長遠。在多數情況下，這類鉅額轉帳通常不是為了立即套現，更多是為了投資組合重組、託管升級、遺產規劃、準備進行場外交易（OTC），或是閒置資產轉移到更積極的管理架構中。市場機制的現實 VS. 恐慌敘事的蔓延兩位分析師都認為，從市場流動性機制來看，這筆轉帳對以太幣價格仍構不成威脅。Illia Otychenko 補充說明，以太幣目前的每日交易量高達 150 億美元，這區區 2,300 萬美元的籌碼，大約只占主流交易所買賣報價深度的 2%，即使一口氣全數拋售，市場也能輕鬆消化，不會造成嚴重滑價。更何況，「沒有任何專業賣家會採取這種粗暴的倒賣方式」。Dean Chen 也直言，除非這筆資金被直接轉入交易所錢包，否則單憑這筆轉帳，很難對市場結構產生實質的賣壓。然而，現實的交易機制與市場的「恐慌敘事」往往是兩回事，這也是兩位分析師最有共識的盲點。 Illia Otychenko 表示：無論這位巨鯨的真實意圖為何，市場往往會先入為主解讀成「賣出訊號」，這本身就會帶來短期壓力。敘事和交易是兩回事，但在加密貨幣領域，敘事卻成了推動市場交易的唯一理由。\",\"articleId\":1,\"articleTitle\":\"3,100 美元本金滾出 2,300 萬！「ICO 巨鯨」沉寂 11 年後轉出 1 萬枚以太幣\",\"categoryCode\":\"NEWS_INFO\",\"categoryId\":1,\"coverImage\":\"/profile/upload/2026/04/30/QQ20260430-175139_20260430175158A001.png\",\"createBy\":\"admin\",\"params\":{},\"sortOrder\":0,\"status\":\"0\",\"summary\":\"幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。\",\"topFlag\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:08:19', 108);
INSERT INTO `sys_oper_log` VALUES (227, '新闻文章', 2, 'com.ruoyi.web.controller.system.SysNewsArticleController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。鏈上數據顯示，這位巨鯨是在 2015 年參與以太坊 ICO 時獲得這 1 萬枚以太幣，當時以太幣平均單價僅為 0.31 美元。其實，這並非早期大戶首次現蹤。去年 9 月，另一位同樣在 2015 年 ICO 期間狂掃 100 萬枚以太幣的超級巨鯨，也曾將價值高達 6.45 億美元的以太幣，從 3 個錢包轉出並投入質押。巨鯨甦醒等於倒貨砸盤？專家：別自己嚇自己面對突如其來的巨額資金移動，市場免不了擔憂是否將引發拋售潮。不過分析師指出，「巨鯨甦醒」不等於「準備倒貨」。加密貨幣交易所 CEX.IO 首席分析師 Illia Otychenko 表示：「對於一個買在 0.31 美元的人來說，如今無論在任何價位脫手，都將獲得足以翻轉人生的報酬，因此他們比較沒有誘因去精確抓出場時機。」他進一步解釋，這次大動作轉移很可能出於「非價格因素」：或許只是找回了早期遺失的私鑰或助記詞，又或者是為了整合與重新分配資產。一個休眠近 10 年的錢包在非高峰時期甦醒，這反而更像是資產託管升級或找回金鑰。加密貨幣交易平台 Bitunix 分析師 Dean Chen 也指出，從轉移的時機點來看，實在不像是為了拋售：自 2015 年以來，這位大戶經歷了好幾次牛熊交替，甚至見證了以太幣屢創歷史新高的瘋狂時期。這意味著，他們的眼光遠比一般散戶來得長遠。在多數情況下，這類鉅額轉帳通常不是為了立即套現，更多是為了投資組合重組、託管升級、遺產規劃、準備進行場外交易（OTC），或是閒置資產轉移到更積極的管理架構中。市場機制的現實 VS. 恐慌敘事的蔓延兩位分析師都認為，從市場流動性機制來看，這筆轉帳對以太幣價格仍構不成威脅。Illia Otychenko 補充說明，以太幣目前的每日交易量高達 150 億美元，這區區 2,300 萬美元的籌碼，大約只占主流交易所買賣報價深度的 2%，即使一口氣全數拋售，市場也能輕鬆消化，不會造成嚴重滑價。更何況，「沒有任何專業賣家會採取這種粗暴的倒賣方式」。Dean Chen 也直言，除非這筆資金被直接轉入交易所錢包，否則單憑這筆轉帳，很難對市場結構產生實質的賣壓。然而，現實的交易機制與市場的「恐慌敘事」往往是兩回事，這也是兩位分析師最有共識的盲點。 Illia Otychenko 表示：無論這位巨鯨的真實意圖為何，市場往往會先入為主解讀成「賣出訊號」，這本身就會帶來短期壓力。敘事和交易是兩回事，但在加密貨幣領域，敘事卻成了推動市場交易的唯一理由。\",\"articleId\":1,\"articleTitle\":\"3,100 美元本金滾出 2,300 萬！「ICO 巨鯨」沉寂 11 年後轉出 1 萬枚以太幣\",\"categoryCode\":\"NEWS_INFO\",\"categoryId\":1,\"coverImage\":\"https://img.1trx.in/avatar/442f4ec6d0294a5f9cdcdcfb3e89c177.png\",\"params\":{},\"remark\":\"\",\"sortOrder\":0,\"status\":\"0\",\"summary\":\"幣圈再次見證造富神話，一位在 2015 年參與以太坊首次代幣發行（ICO）的早期投資人，當年僅投入 3,100 美元買進 1 萬枚以太幣。如今，這筆資產已狂飆至約 2,300 萬美元，而這位「遠古巨鯨」也在沉寂近 11 年後，於近日首度將手中持幣全數轉出，瞬間挑動市場神經。\",\"topFlag\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:16:27', 58);
INSERT INTO `sys_oper_log` VALUES (228, '新闻文章', 1, 'com.ruoyi.web.controller.system.SysNewsArticleController.add()', 'POST', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"如果比特幣是數位黃金，那以太幣（ETH）究竟算什麼？以太坊生態商務拓展和行銷公司 Etherealize 近日拋出震撼市場的重磅報告，並將以太幣的長期目標價定在 25 萬美元。他們認為，以太幣在人類貨幣發展史上，正展現出獨一無二的資產特性。從 74 萬美元下修至 25 萬美元根據 CoinGecko 報價，以太幣目前仍在 2,390 美元附近徘徊，較去年 8 月創下的 4,946 美元歷史高點回檔超過 51% 。儘管 Etherealize 這次給出的 25 萬美元目標價，比起去年首度公開喊出的 74 萬美元「神蹟價」已大幅下修，但對於現階段的市場而言，這仍是一個極具野心的數字。Etherealize 共同創辦人 Vivek Raman 指出：這只是時間早晚與必然性的問題。我們深信，以太坊最終將成為全球金融系統的支柱，而未來只會有一到兩種數位資產，能真正成為價值儲存工具。他補充說，如果比特幣的霸主地位「已成定局」，那麼以太幣絕對是「另一個強勢角逐者」。不過，這份報告並未給出「以太幣何時能漲到 25 萬美元」的具體時間表。比黃金、比特幣更完美的價值儲存資產？Etherealize 的核心論述在於，以太幣不僅具備如同比特幣、黃金般的「價值儲存」功能，同時也是一種能產生實質收益的「生產性資產」。這歸功於以太坊的「權益證明（PoS）」共識機制，投資人只要將以太幣投入質押，就能獲得穩定的收益。報告提到，目前全球黃金與比特幣的「貨幣溢價（Monetary premium，指資產因具備貨幣功能而產生的附加價值）」合計約 31 兆美元，假如若以太幣能捕捉到同樣的溢價，以目前約 1.21 億枚的流通量來推算，以太幣的合理價位將超過 25 萬美元。更重要的是，與黃金、比特幣這類「純貨幣資產」不同，以太坊底層擁有蓬勃發展的 DeFi 與穩定幣生態，支撐著「真實的經濟活動」。這意味著，即使以太坊需要時間才能完全吸收龐大的貨幣溢價，這些經濟活動也能為幣價提供下行保護，長遠來看，這更讓以太幣的投資吸引力大幅提升。報告寫道：以太幣是史上第一個「沒有交易對手風險，卻能創造複利」的貨幣資產。綜觀人類歷史，投資人往往面臨兩難：要麼持有現金（穩定但無法產生收益），要麼投資生產性資產（能創造財富但伴隨高風險）。這兩者向來是魚與熊掌不可兼得，但以太幣徹底打破了這個界線。目前以太坊的質押年化報酬率約落在 2% 到 4% 之間。雖然數字稱不上暴利，但 Etherealize 研究院 Mike McGuiness 認為，這提供了一種相對安全且能發揮複利效應的投資管道。他表示：大家總是盯著黃金和比特幣的市值，認為比特幣還有 20 倍的成長空間。其實，市場也應該用同樣的眼光來看待以太幣，甚至可以說以太幣才是「更好的貨幣」，因為比特幣根本無法產生複利。Mike McGuiness 進一步點出，黃金與比特幣無法產生收益，本質上就是一灘「死資本（Dead capital）」。不僅如此，比特幣未來還面臨著攸關生死存亡的危機：當 2,100 萬枚比特幣全數開採完畢後，礦工將無法再獲得區塊獎勵。屆時，僅靠微薄的交易手續費，是否還能吸引足夠的礦工貢獻算力來維持網路安全？這將是比特幣無可迴避的致命傷。「結算層霸主」：無懼 Solana 等公鏈圍剿時至今日，以太坊早已是代幣化資產、穩定幣與 DeFi 領域的「結算層霸主」，這為以太幣創造了結構性且具備規模化的龐大需求。更重要的是，由於以太坊會銷毀部分交易手續費，不僅將每年的供應量成長率限制在 1.5% 以下，隨著網路使用量激增，甚至會出現通縮效應。儘管如此，過去一年來，市場上也浮現出不少強勁的對手，試圖挑戰以太坊在機構級區塊鏈中的地位。例如由數十家華爾街巨擘支持的 Canton 、支付巨頭 Stripe 打造的 Tempo，以及已在實體資產（RWA）代幣化領域大放異彩的 Solana 。面對日趨激烈的競爭，Vivek Raman 表示：「這些競爭對手（指其他公鏈）真正要對抗的，其實是以太坊 Layer 2 。」他說：它們本質上只是『執行層』，根本無法與以太坊相提並論。它們不是貨幣，論主權性遠不及以太幣，論去中心化、無需許可更比不上以太坊。\",\"articleId\":2,\"articleTitle\":\"Etherealize 重磅報告：以太幣長期目標價 25 萬美元，全因這項「超能力」\",\"categoryCode\":\"NEWS_INFO\",\"categoryId\":1,\"coverImage\":\"https://img.1trx.in/avatar/d62f4cb844c54e05b2f279907d27e85a.png\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"\",', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:16:59', 61);
INSERT INTO `sys_oper_log` VALUES (229, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/1e92ac62cfe8489fb85042359dd9de58.png\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:46:50', 922);
INSERT INTO `sys_oper_log` VALUES (230, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/cb18e493c3604ef99146f3ff1e73c8be.png\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 18:47:55', 863);
INSERT INTO `sys_oper_log` VALUES (231, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/6261112486f440e0bbb1ad0c8dbde87c.png\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 19:25:22', 844);
INSERT INTO `sys_oper_log` VALUES (232, '新闻文章', 1, 'com.ruoyi.web.controller.system.SysNewsArticleController.add()', 'POST', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"從交易平台到「全能機構」，MCIs 正在模糊金融邊界國際結算銀行（BIS）近期發佈一份長達 38 頁的研究報告，揭露全球大型加密貨幣交易所正迅速轉型為「多功能加密資產仲介機構」（Multifunction Crypto-asset Intermediaries，簡稱 MCIs）。這些機構在單一企業架構下，高度整合了交易平台、託管服務、自營交易、經紀業務以及代幣發行等多重職能。BIS 由全球 63 家央行共同持有，報告強調這種運作模式與傳統金融市場的風險隔離原則背道而馳。在傳統金融體系中，為了防止利益衝突與風險擴散，上述角色通常必須拆分至不同的獨立實體並設下嚴格的防火牆。然而，加密交易所傾向於採取垂直整合模式，將客戶資金與平台自身的營運風險深度綁定。這種結構在營運上缺乏透明度，且缺乏準備金要求與資產分開保管的規範，使這些平台實質上成為了規管程度極其鬆散的「影子銀行」。高收益背後的真相：使用者資產淪為無擔保貸款各大加密交易所目前正積極向散戶推銷「Earn」或「理財計畫」等高收益產品，將其包裝為便利的被動收入工具。BIS 報告直言，這些理財產品的本質是向平台提供的無擔保貸款。當使用者存入加密資產以換取報酬率時，平台通常會將這些資產進行「再抵押」（Rehypothecation），循環投入高風險活動。這些活動包含保證金貸款、高度槓桿的自營交易以及市場流動性供應。在這種機制下，使用者往往在不自覺中放棄了資產的法律所有權或實際控制權。一旦平台遭遇償付危機，使用者將直接面臨平台主體的償債風險，並成為清償序列末端的普通債權人。與受規管的傳統銀行存款不同，這些資產完全缺乏存款保險保護，也沒有央行作為最後貸款人提供支持。這種將客戶資產循環投入高風險博弈的行為，為數位資產市場埋下了巨大的不穩定因素。從 FTX 崩潰到 190 億美元閃崩的教訓2025 年 10 月發生的加密貨幣閃崩事件，清晰展示了槓桿回饋循環帶來的破壞力。在短短 24 小時內，受總體經濟經濟衝擊影響，全網強制平倉金額高達 190 億。當時比特幣單日跌幅超過 14%，導致約 160 萬名交易者面臨清算，加密市場總市值在一天內蒸發了 3,500 億。BIS 在報告中特別點名 Celsius Network 與 FTX 的倒閉案例，稱其為建立在槓桿、不透明承諾與缺乏風險管理上的典型教訓。報告指出，加密體系高度依賴自動化清算引擎，且交易深度集中在少數幾家大型平台。當市場信心潰散時，這種結構會引發劇烈的連鎖反應。此外，隨著加密市場與銀行及穩定幣發行商的聯繫日益加深，這種影子銀行體系的失敗可能會對更廣泛的傳統金融產業產生嚴重的外溢效應。監管滯後與駭客入侵，去中心化金融的「傳染路徑」加密市場與去中心化金融（DeFi）的高度整合進一步加劇了風險傳染的可能性。近期發生的 KelpDAO 協議攻擊事件便是一個典型案例。攻擊者透過漏洞鑄造了約 116,500 枚 $rsETH，並以此為抵押品從 Aave 等大型借貸平台借出大量資產，最終造成約 2.92 億的資金缺口。相關新聞：DeFi 震撼彈：Kelp DAO 跨鏈橋遭駭，損失近 3 億美元並波及多個借貸協議這類事件顯示，單一協議的漏洞可能引發整個生態系的流動性危機。安全分析顯示，此次攻擊與北韓 Lazarus Group 有關，駭客在 1.5 天內將 75,700 枚以太幣洗為比特幣，並為 THORChain 平台貢獻了約 91 萬的交易費收入。為了應對日益複雜的挑戰，BIS 建議採取「實體規管」（Entity-based）與「活動規管」（Activity-based）雙軌並行的模式。監管機構目前仍面臨法律架構滯後、跨境協作困難以及監管資源有限等挑戰。若無法落實有效的審慎監管與跨國監督，加密市場的隱性風險將持續威脅全球金融穩定。\",\"articleId\":3,\"articleTitle\":\"賺了獎勵恐賠掉本金？BIS 警告：幣圈「高收益理財」實為無擔保貸款\",\"categoryCode\":\"NEWS_INFO\",\"categoryId\":1,\"coverImage\":\"https://img.1trx.in/avatar/2944a3666cfe4dbfa5d29a1ed3f495a9.png\",\"createBy\":\"admin\",\"params\":{},\"remark\":\"\",\"sortOrder\":0,\"status\":\"0\",\"summary\":\"國際結算銀行發佈報告，警告加密貨幣交易所正轉型為「多功能加密資產仲介機構」，在缺乏監管防火牆的情況下，將交易、託管與自營等衝突職能整合。\",\"topFlag\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 19:36:16', 349);
INSERT INTO `sys_oper_log` VALUES (233, '新闻文章', 1, 'com.ruoyi.web.controller.system.SysNewsArticleController.add()', 'POST', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"揭開金融迷霧，紀錄片主張中本聰為雙人組合自 2009 年比特幣問世以來，其創辦人 「中本聰」（Satoshi Nakamoto）的真實身份始終是 21 世紀最大的金融謎團。儘管多年來有無數調查報導、學術分析與猜測，這名改變全球金融地景的神祕人物依然隱身於數位迷霧之後。 2026 年 4 月 22 日，全新紀錄片 《Finding Satoshi》（中本聰尋蹤）正式發佈。製作團隊聲稱透過長達 4 年的縝密調查，首度為這個橫跨十餘年的大問號提供了「決定性的答案」。這部由知名調查報導記者 William D. Cohan 與私家偵探 Tyler Maroney 聯手打造，並由 Tucker Tooley 與 Matthew Miele 執導的作品，跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神，讓作品能直接與大眾連結。圖源：FindingSatoshi.com ｜《Finding Satoshi》跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神紀錄片提出的核心論點挑戰了過往認為中本聰是「單一個體」的普遍認知。調查團隊主張，中本聰實際上是由兩位已故的資深密碼學家共同組成的技術團隊，分別為哈爾・芬尼（Hal Finney）與萊恩・薩薩曼（Len Sassaman）。這兩位傳奇人物在密碼學界享有崇高地位，且都曾深入參與 PGP（Pretty Good Privacy）加密軟體的開發，具備開發比特幣所需的頂尖技術基礎。紀錄片指出，比特幣的誕生結合了 Hal Finney 精湛的程式碼撰寫能力，以及 Len Sassaman 卓越的學術邏輯與寫作才華。這種分工模式解釋了為何比特幣的核心程式碼極其嚴謹，技術白皮書則展現出高度專業的學術論述特質，兩者的融合創造出了一個無懈可擊的數位金融原型。四年深度調查與法醫學分析，還原開發分工真相為了支撐這項震撼結論，製作團隊進行了極其廣泛的跨產業取證。他們不僅走訪了密碼學的起源，更對 20 多位加密貨幣產業的關鍵人物進行深度訪談。受訪名單包含了 Strategy 董事長 Michael Saylor 、以太坊（Ethereum）共同創辦人 Joseph Lubin 、前美國證交會（SEC）主席 Gary Gensler 以及比特幣安全專家 Jameson Lopp 等重量級人士。此外，團隊甚至訪問了 C++ 語言的開發者 Bjarne Stroustrup，試圖從程式語言的演進中尋找比特幣程式碼的創作痕跡。團隊特別聘請了前聯邦調查局（FBI）行為分析專家 Kathleen Puckett 。她曾參與「郵包炸彈客」（Unabomber）的抓捕行動，擅長分析匿名創作者的行為模式。Puckett 透過對中本聰白皮書與早期電子郵件的文體法醫學分析指出，中本聰在溝通中經常使用複數代名詞「我們」，這與團體寫作的行為特徵吻合。分析同時顯示，中本聰引用了 1950 年代的機率論書籍《機率論及其應用導論》，這顯示創作者具備深厚的數學背景與特定的學術傳承，符合 Len Sassaman 的學術生涯軌跡。在技術層面上，調查團隊針對中本聰早期的線上活動時間進行了精確比對。數據顯示，中本聰活躍的時段與美國東部時間高度吻合，這排除了許多位於歐洲或亞洲的熱門候選人。數據科學家 Alyssa Blackburn 提供的文體分析與伺服器日誌比對則進一步證實，Finney 與 Sassaman 的寫作習慣與程式碼風格，在統計學上與中本聰的紀錄高度關聯。這項理論解決了中本聰在程式碼撰寫與文字論述上呈現出的專業差異，將比特幣重新定義為一場跨學科的集體智慧結晶。破解關鍵不在場證明，遺孀證詞推升論點可信度在過往的社群討論中， Hal Finney 雖然一直被視為中本聰的最有力人選，但比特幣開發者 Jameson Lopp 曾提出一項關鍵的「不在場證明」。他指出在中本聰與其它開發者進行電子郵件往返的時間點，Hal Finney 正在參加一場位於聖塔芭芭拉的馬拉松賽事。對此，《Finding Satoshi》提供了解答，認為這恰好證明了中本聰團隊的分工合作。當 Finney 專注於馬拉松賽跑時，團隊中的另一名成員 Len Sassaman 正在處理文字資訊的維護與回覆，使得「中本聰」能維持全天候的運作表象。紀錄片採訪了兩位候選人的遺孀，Hal Finney 的妻子 Fran Finney 在受訪時坦言，她認為丈夫在比特幣的創立中確實扮演了核心角色。 Sassaman 的妻子 Meredith L. Patterson 則描述了丈夫生前對於匿名與隱私技術的狂', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 19:37:29', 304);
INSERT INTO `sys_oper_log` VALUES (234, '新闻文章', 2, 'com.ruoyi.web.controller.system.SysNewsArticleController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/news/article', '127.0.0.1', '内网IP', '{\"articleContent\":\"揭開金融迷霧，紀錄片主張中本聰為雙人組合自 2009 年比特幣問世以來，其創辦人 「中本聰」（Satoshi Nakamoto）的真實身份始終是 21 世紀最大的金融謎團。儘管多年來有無數調查報導、學術分析與猜測，這名改變全球金融地景的神祕人物依然隱身於數位迷霧之後。 2026 年 4 月 22 日，全新紀錄片 《Finding Satoshi》（中本聰尋蹤）正式發佈。製作團隊聲稱透過長達 4 年的縝密調查，首度為這個橫跨十餘年的大問號提供了「決定性的答案」。這部由知名調查報導記者 William D. Cohan 與私家偵探 Tyler Maroney 聯手打造，並由 Tucker Tooley 與 Matthew Miele 執導的作品，跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神，讓作品能直接與大眾連結。圖源：FindingSatoshi.com ｜《Finding Satoshi》跳過傳統影視發行管道，選擇在 FindingSatoshi.com 網站獨家公開。這種發行模式旨在呼應比特幣核心的「去中心化」精神紀錄片提出的核心論點挑戰了過往認為中本聰是「單一個體」的普遍認知。調查團隊主張，中本聰實際上是由兩位已故的資深密碼學家共同組成的技術團隊，分別為哈爾・芬尼（Hal Finney）與萊恩・薩薩曼（Len Sassaman）。這兩位傳奇人物在密碼學界享有崇高地位，且都曾深入參與 PGP（Pretty Good Privacy）加密軟體的開發，具備開發比特幣所需的頂尖技術基礎。紀錄片指出，比特幣的誕生結合了 Hal Finney 精湛的程式碼撰寫能力，以及 Len Sassaman 卓越的學術邏輯與寫作才華。這種分工模式解釋了為何比特幣的核心程式碼極其嚴謹，技術白皮書則展現出高度專業的學術論述特質，兩者的融合創造出了一個無懈可擊的數位金融原型。四年深度調查與法醫學分析，還原開發分工真相為了支撐這項震撼結論，製作團隊進行了極其廣泛的跨產業取證。他們不僅走訪了密碼學的起源，更對 20 多位加密貨幣產業的關鍵人物進行深度訪談。受訪名單包含了 Strategy 董事長 Michael Saylor 、以太坊（Ethereum）共同創辦人 Joseph Lubin 、前美國證交會（SEC）主席 Gary Gensler 以及比特幣安全專家 Jameson Lopp 等重量級人士。此外，團隊甚至訪問了 C++ 語言的開發者 Bjarne Stroustrup，試圖從程式語言的演進中尋找比特幣程式碼的創作痕跡。團隊特別聘請了前聯邦調查局（FBI）行為分析專家 Kathleen Puckett 。她曾參與「郵包炸彈客」（Unabomber）的抓捕行動，擅長分析匿名創作者的行為模式。Puckett 透過對中本聰白皮書與早期電子郵件的文體法醫學分析指出，中本聰在溝通中經常使用複數代名詞「我們」，這與團體寫作的行為特徵吻合。分析同時顯示，中本聰引用了 1950 年代的機率論書籍《機率論及其應用導論》，這顯示創作者具備深厚的數學背景與特定的學術傳承，符合 Len Sassaman 的學術生涯軌跡。在技術層面上，調查團隊針對中本聰早期的線上活動時間進行了精確比對。數據顯示，中本聰活躍的時段與美國東部時間高度吻合，這排除了許多位於歐洲或亞洲的熱門候選人。數據科學家 Alyssa Blackburn 提供的文體分析與伺服器日誌比對則進一步證實，Finney 與 Sassaman 的寫作習慣與程式碼風格，在統計學上與中本聰的紀錄高度關聯。這項理論解決了中本聰在程式碼撰寫與文字論述上呈現出的專業差異，將比特幣重新定義為一場跨學科的集體智慧結晶。破解關鍵不在場證明，遺孀證詞推升論點可信度在過往的社群討論中， Hal Finney 雖然一直被視為中本聰的最有力人選，但比特幣開發者 Jameson Lopp 曾提出一項關鍵的「不在場證明」。他指出在中本聰與其它開發者進行電子郵件往返的時間點，Hal Finney 正在參加一場位於聖塔芭芭拉的馬拉松賽事。對此，《Finding Satoshi》提供了解答，認為這恰好證明了中本聰團隊的分工合作。當 Finney 專注於馬拉松賽跑時，團隊中的另一名成員 Len Sassaman 正在處理文字資訊的維護與回覆，使得「中本聰」能維持全天候的運作表象。紀錄片採訪了兩位候選人的遺孀，Hal Finney 的妻子 Fran Finney 在受訪時坦言，她認為丈夫在比特幣的創立中確實扮演了核心角色。 Sassaman 的妻子 Meredith L. Patterson 則描述了丈夫生前對於匿名與隱私技術的狂', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 19:37:55', 308);
INSERT INTO `sys_oper_log` VALUES (235, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-24 21:29:31\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 21:43:24', 3483);
INSERT INTO `sys_oper_log` VALUES (236, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"APP配置-开放注册\",\"configType\":\"Y\",\"configValue\":\"true\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 11:27:59\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-30 13:31:43\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 21:43:32', 3440);
INSERT INTO `sys_oper_log` VALUES (237, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":110,\"configKey\":\"app.sign.continuousRewardRule\",\"configName\":\"APP配置-连续签到奖励规则\",\"configType\":\"Y\",\"configValue\":\"[\\n  {\\\"day\\\":1,\\\"amount\\\":300},\\n  {\\\"day\\\":2,\\\"amount\\\":310},\\n  {\\\"day\\\":3,\\\"amount\\\":330},\\n  {\\\"day\\\":4,\\\"amount\\\":350},\\n  {\\\"day\\\":5,\\\"amount\\\":380},\\n  {\\\"day\\\":6,\\\"amount\\\":400},\\n  {\\\"day\\\":7,\\\"amount\\\":488}\\n]\",\"createBy\":\"admin\",\"createTime\":\"2026-04-30 13:21:41\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-30 13:31:44\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 21:43:49', 3573);
INSERT INTO `sys_oper_log` VALUES (238, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-30 21:43:20\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-04-30 21:52:28', 3368);
INSERT INTO `sys_oper_log` VALUES (239, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 12:09:49', 99);
INSERT INTO `sys_oper_log` VALUES (240, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'lanz', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 13:17:34', 846);
INSERT INTO `sys_oper_log` VALUES (241, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 13:25:38', 3456);
INSERT INTO `sys_oper_log` VALUES (242, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501001.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-04-30 21:52:25\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 15:32:03', 3749);
INSERT INTO `sys_oper_log` VALUES (243, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501002.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 15:32:00\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 15:33:07', 3611);
INSERT INTO `sys_oper_log` VALUES (244, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501003.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 15:33:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 15:50:39', 3838);
INSERT INTO `sys_oper_log` VALUES (245, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501003.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0430001.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 15:33:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 15:50:42', 3715);
INSERT INTO `sys_oper_log` VALUES (246, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP升级配置\",\"configType\":\"Y\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"升级配置\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 15:50:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:11:01', 3782);
INSERT INTO `sys_oper_log` VALUES (247, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:17:30', 784);
INSERT INTO `sys_oper_log` VALUES (248, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:17:37', 711);
INSERT INTO `sys_oper_log` VALUES (249, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:18:19', 719);
INSERT INTO `sys_oper_log` VALUES (250, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.2', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:20:34', 732);
INSERT INTO `sys_oper_log` VALUES (251, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:20:49', 726);
INSERT INTO `sys_oper_log` VALUES (252, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:21:15', 811);
INSERT INTO `sys_oper_log` VALUES (253, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:25:09', 827);
INSERT INTO `sys_oper_log` VALUES (254, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:25:58', 855);
INSERT INTO `sys_oper_log` VALUES (255, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:26:49', 765);
INSERT INTO `sys_oper_log` VALUES (256, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:37:21', 808);
INSERT INTO `sys_oper_log` VALUES (257, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:42:24', 885);
INSERT INTO `sys_oper_log` VALUES (258, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'test1', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '{\"data\":\"pxxsnevziualPu8tKmpdHt3ttNYNcjB1B89fh8rk9zuu7aiwg9wRaoh4QyZ7LxZBBT/ZC5ewGTKZORGpJEFW1A==\"} ', '{\"msg\":\"安全问题数据不能为空\",\"code\":500}', 0, NULL, '2026-05-01 16:42:49', 0);
INSERT INTO `sys_oper_log` VALUES (259, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'test1', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '{\"data\":\"pxxsnevziualPu8tKmpdHt3ttNYNcjB1B89fh8rk9zuu7aiwg9wRaoh4QyZ7LxZBBT/ZC5ewGTKZORGpJEFW1A==\"} ', '{\"msg\":\"安全问题数据不能为空\",\"code\":500}', 0, NULL, '2026-05-01 16:43:10', 0);
INSERT INTO `sys_oper_log` VALUES (260, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'test1', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '{\"data\":\"pxxsnevziualPu8tKmpdHt3ttNYNcjB1B89fh8rk9zuu7aiwg9wRaoh4QyZ7LxZBBT/ZC5ewGTKZORGpJEFW1A==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:44:45', 317);
INSERT INTO `sys_oper_log` VALUES (261, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 16:56:46', 3759);
INSERT INTO `sys_oper_log` VALUES (262, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 17:11:08', 3864);
INSERT INTO `sys_oper_log` VALUES (263, '参数管理', 9, 'com.ruoyi.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 17:16:23', 4095);
INSERT INTO `sys_oper_log` VALUES (264, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":110,\"configKey\":\"app.sign.continuousRewardRule\",\"configName\":\"APP配置-连续签到奖励规则\",\"configType\":\"N\",\"configValue\":\"[\\n  {\\\"day\\\":1,\\\"amount\\\":300},\\n  {\\\"day\\\":2,\\\"amount\\\":320},\\n  {\\\"day\\\":3,\\\"amount\\\":350},\\n  {\\\"day\\\":4,\\\"amount\\\":380},\\n  {\\\"day\\\":5,\\\"amount\\\":400},\\n  {\\\"day\\\":6,\\\"amount\\\":430},\\n  {\\\"day\\\":7,\\\"amount\\\":466}\\n]\",\"createBy\":\"admin\",\"createTime\":\"2026-04-30 13:21:41\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 17:15:21\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 17:24:02', 4335);
INSERT INTO `sys_oper_log` VALUES (265, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 18:12:48', 768);
INSERT INTO `sys_oper_log` VALUES (266, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 18:17:32', 784);
INSERT INTO `sys_oper_log` VALUES (267, '涓汉淇℃伅', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:25:20', 2018);
INSERT INTO `sys_oper_log` VALUES (268, '涓汉淇℃伅', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:25:36', 2044);
INSERT INTO `sys_oper_log` VALUES (269, '涓汉淇℃伅', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:26:36', 1361);
INSERT INTO `sys_oper_log` VALUES (270, '涓汉淇℃伅', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:28:42', 1448);
INSERT INTO `sys_oper_log` VALUES (271, '涓汉淇℃伅', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"admin\":false,\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:30:24', 1321);
INSERT INTO `sys_oper_log` VALUES (272, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"KpPuSNXTrp65gLSfz7vbFayu9V5xRu25N45OY8ksdvararmBPZabYvAY8hXC/OxON3CRNQC7gu0B8MggPAe84Wzv72cCBGC9BG0UNEE/4JI=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:34:08', 2128);
INSERT INTO `sys_oper_log` VALUES (273, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"cWKChyvdtR/15SJmyDwsf9QdJDMqm826bG8Knb/bFJg=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 20:43:58', 1977);
INSERT INTO `sys_oper_log` VALUES (274, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"KpPuSNXTrp65gLSfz7vbFayu9V5xRu25N45OY8ksdvZi3NUmkzyxeC2JWTXytJQUemZ/inSRjlVeYZEGSECdulsVz1u7YpmSiwxo+bfzGkA=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 21:24:52', 4681);
INSERT INTO `sys_oper_log` VALUES (275, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"cWKChyvdtR/15SJmyDwsf9QdJDMqm826bG8Knb/bFJg=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 21:25:16', 5603);
INSERT INTO `sys_oper_log` VALUES (276, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"s6Wl7N4ow8S9qMZhSM0BAwEkUPR58htN9fHEZNrxh0M=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 21:28:42', 4690);
INSERT INTO `sys_oper_log` VALUES (277, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"KpPuSNXTrp65gLSfz7vbFayu9V5xRu25N45OY8ksdvZYYsWFTsZQrrXKlm2d2Ctsd8jggil9FEBlVsDnrAuTrA0OXtY/um7X0u9RoDac5JY=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 21:51:53', 5343);
INSERT INTO `sys_oper_log` VALUES (278, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP配置-APP升级配置\",\"configType\":\"N\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 17:15:21\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:25:00', 14114);
INSERT INTO `sys_oper_log` VALUES (279, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP配置-APP升级配置\",\"configType\":\"N\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 17:15:21\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:25:00', 11974);
INSERT INTO `sys_oper_log` VALUES (280, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP配置-APP升级配置\",\"configType\":\"N\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 22:24:48\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:25:13', 9393);
INSERT INTO `sys_oper_log` VALUES (281, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":100,\"configKey\":\"app.upgrade.config\",\"configName\":\"APP配置-APP升级配置\",\"configType\":\"N\",\"configValue\":\"{\\n\\t\\\"appUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"androidVersion\\\": \\\"1.0.3\\\",\\n  \\\"androidApkUrl\\\": \\\"https://img.1trx.in/app/0501004.apk\\\",\\n  \\\"iosVersion\\\": \\\"1.0.3\\\",\\n  \\\"iosInstallUrl\\\": \\\"https://apps.apple.com/app/idxxxxxxxxx\\\",\\n  \\\"forceUpgrade\\\": false,\\n  \\\"releaseNote\\\": \\\"修复已知问题，优化线路稳定性\\\"\\n}\",\"createBy\":\"admin\",\"createTime\":\"2026-04-24 13:22:11\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 22:24:48\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:26:19', 52331);
INSERT INTO `sys_oper_log` VALUES (282, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":110,\"configKey\":\"app.sign.continuousRewardRule\",\"configName\":\"APP配置-连续签到奖励规则\",\"configType\":\"N\",\"configValue\":\"[\\n  {\\\"day\\\":1,\\\"amount\\\":300},\\n  {\\\"day\\\":2,\\\"amount\\\":320},\\n  {\\\"day\\\":3,\\\"amount\\\":350},\\n  {\\\"day\\\":4,\\\"amount\\\":380},\\n  {\\\"day\\\":5,\\\"amount\\\":400},\\n  {\\\"day\\\":6,\\\"amount\\\":430},\\n  {\\\"day\\\":7,\\\"amount\\\":466}\\n]\",\"createBy\":\"admin\",\"createTime\":\"2026-04-30 13:21:41\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 17:23:58\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:27:47', 14156);
INSERT INTO `sys_oper_log` VALUES (283, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":112,\"configKey\":\"app.download.url\",\"configName\":\"APP配置-APP下载地址\",\"configType\":\"N\",\"configValue\":\"https://img.1trx.in/app/0501004.apk\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 17:15:21\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:28:41', 15060);
INSERT INTO `sys_oper_log` VALUES (284, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":110,\"configKey\":\"app.sign.continuousRewardRule\",\"configName\":\"APP配置-连续签到奖励规则\",\"configType\":\"N\",\"configValue\":\"[\\n  {\\\"day\\\":1,\\\"amount\\\":300},\\n  {\\\"day\\\":2,\\\"amount\\\":320},\\n  {\\\"day\\\":3,\\\"amount\\\":350},\\n  {\\\"day\\\":4,\\\"amount\\\":380},\\n  {\\\"day\\\":5,\\\"amount\\\":400},\\n  {\\\"day\\\":6,\\\"amount\\\":430},\\n  {\\\"day\\\":7,\\\"amount\\\":466}\\n]\",\"createBy\":\"admin\",\"createTime\":\"2026-04-30 13:21:41\",\"isAppConfig\":\"1\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 22:27:32\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:41:52', 11560);
INSERT INTO `sys_oper_log` VALUES (285, '参数管理', 2, 'com.ruoyi.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configId\":110,\"configKey\":\"app.sign.continuousRewardRule\",\"configName\":\"APP配置-连续签到奖励规则\",\"configType\":\"N\",\"configValue\":\"[\\n  {\\\"day\\\":1,\\\"amount\\\":300},\\n  {\\\"day\\\":2,\\\"amount\\\":320},\\n  {\\\"day\\\":3,\\\"amount\\\":350},\\n  {\\\"day\\\":4,\\\"amount\\\":380},\\n  {\\\"day\\\":5,\\\"amount\\\":400},\\n  {\\\"day\\\":6,\\\"amount\\\":430},\\n  {\\\"day\\\":7,\\\"amount\\\":466}\\n]\",\"createBy\":\"admin\",\"createTime\":\"2026-04-30 13:21:41\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"APP 配置管理页面保存\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 22:27:32\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:41:59', 13933);
INSERT INTO `sys_oper_log` VALUES (286, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":6,\"params\":{},\"reviewTime\":\"2026-05-01 22:47:11\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userId\":1000102,\"userName\":\"test1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:47:13', 1993);
INSERT INTO `sys_oper_log` VALUES (287, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"params\":{},\"userId\":1000102,\"userName\":\"test1\"} ', NULL, 1, 'Recharge amount must be greater than zero.', '2026-05-01 22:47:44', 17);
INSERT INTO `sys_oper_log` VALUES (288, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"params\":{},\"userId\":1000102,\"userName\":\"test1\"} ', NULL, 1, 'Recharge amount must be greater than zero.', '2026-05-01 22:47:51', 2);
INSERT INTO `sys_oper_log` VALUES (289, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"params\":{},\"userId\":1000102,\"userName\":\"test1\"} ', NULL, 1, 'Recharge amount must be greater than zero.', '2026-05-01 22:48:28', 3);
INSERT INTO `sys_oper_log` VALUES (290, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'test1', NULL, '/system/user/profile', '192.168.0.3', '内网IP', '{\"data\":\"DdT8c2nZYKCMEHIip2wmyKogWkEyDy4WbzDKUd7zF/8=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 22:55:55', 5144);
INSERT INTO `sys_oper_log` VALUES (291, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/74eb662070884ad8bf2872e7c53ec9d0.png\",\"birthday\":\"2013-05-01\",\"createTime\":\"2026-04-25 14:39:57\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"inviteCode\":\"LNWR6M\",\"level\":0,\"levelDetail\":\"0,1\",\"loginDate\":\"2026-05-01 16:17:13\",\"loginIp\":\"192.168.0.2\",\"nickName\":\"小王\",\"params\":{\"@type\":\"java.util.HashMap\"},\"parentUserName\":\"admin\",\"payPasswordSet\":0,\"phonenumber\":\"13977777777\",\"postIds\":[],\"pwdUpdateDate\":\"2026-04-25 14:39:57\",\"realNameStatus\":3,\"roleIds\":[],\"roles\":[],\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 22:55:52\",\"userId\":1000102,\"userLevel\":1,\"userName\":\"test1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:05:30', 1956);
INSERT INTO `sys_oper_log` VALUES (292, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"params\":{},\"userId\":1000102,\"userName\":\"test1\"} ', NULL, 1, 'Recharge amount must be greater than zero.', '2026-05-01 23:19:59', 49);
INSERT INTO `sys_oper_log` VALUES (293, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"data\":\"BISY2Osd/4zJ+S+qEdq6f5Y3iF2bgJ67T8U8LCK5FFGnJl3Tu8LfJ6XfA3jF3Du3q9e1FHtANQ1NfcVp3mQS/Q==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:25:14', 829);
INSERT INTO `sys_oper_log` VALUES (294, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"data\":\"BISY2Osd/4zJ+S+qEdq6f5Y3iF2bgJ67T8U8LCK5FFFQB1anxFXxf478VslrZvgbZ2KFzc9fgTLN2x6aXBOAjw==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:25:19', 323);
INSERT INTO `sys_oper_log` VALUES (295, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC202605012325190B673EF9\",\"params\":{},\"rechargeId\":4,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-01 23:25:31\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"test1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:25:32', 996);
INSERT INTO `sys_oper_log` VALUES (296, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC20260501232513794C53CC\",\"params\":{},\"rechargeId\":3,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-01 23:25:34\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"test1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:25:35', 955);
INSERT INTO `sys_oper_log` VALUES (297, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'test1', NULL, '/app/recharge/submit', '192.168.0.3', '内网IP', '{\"data\":\"BISY2Osd/4zJ+S+qEdq6f5Y3iF2bgJ67T8U8LCK5FFFQB1anxFXxf478VslrZvgbZ2KFzc9fgTLN2x6aXBOAjw==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:26:26', 392);
INSERT INTO `sys_oper_log` VALUES (298, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC202605012326260AC7D9FB\",\"params\":{},\"rechargeId\":5,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-01 23:26:45\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"test1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:26:45', 411);
INSERT INTO `sys_oper_log` VALUES (299, 'Bank card bind', 1, 'com.ruoyi.web.controller.app.AppBankCardController.add()', 'POST', 1, 'test1', NULL, '/app/bankCard', '192.168.0.3', '内网IP', '{\"accountName\":\"\",\"accountNo\":\"\",\"bankName\":\"\",\"createBy\":\"test1\",\"currencyType\":\"CNY\",\"params\":{},\"updateBy\":\"test1\",\"userId\":1000102,\"userName\":\"test1\"} ', NULL, 1, 'Bank name, account number and account name are required for RMB cards.', '2026-05-01 23:28:34', 1176);
INSERT INTO `sys_oper_log` VALUES (300, 'Bank card bind', 1, 'com.ruoyi.web.controller.app.AppBankCardController.add()', 'POST', 1, 'test1', NULL, '/app/bankCard', '192.168.0.3', '内网IP', '{\"data\":\"oAgJsURqlTlWh4E4HSqfAdgMJOUBZmNn3c7lxtsw7qgzCPB7Y4aCjczEPqpFkqF0jZ1KbM1j1+5JEo9VnPG3TN7xsRrgLQZ++zSpyI2LSpO5Kghvj2T/u1NfzoWIazQPo/lzhiSlLKvQ73HP2mCZ+Q==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-01 23:37:15', 1748);
INSERT INTO `sys_oper_log` VALUES (301, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"KpPuSNXTrp65gLSfz7vbFayu9V5xRu25N45OY8ksdvblSSlQ1sZ3y9TSV2+mA0bziAdMl4hQ2uiHkcsn3SNIMK9MX9Gs1zUAfbAZ6VVrIM8=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:25:22', 2690);
INSERT INTO `sys_oper_log` VALUES (302, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"g5pGxzzcjoGCOZ1GImMyEvhSOe0sz26dOMC7CUmQksE=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:25:48', 1452);
INSERT INTO `sys_oper_log` VALUES (303, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"BO/IkbeA1CQDKx/qr0Y+l0pqMAbvKA14xvkhJdb0jqI=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:32:27', 2140);
INSERT INTO `sys_oper_log` VALUES (304, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"MlLD2REC+n8jDTzwjfPCuM4yL/SC2+B0eWVuQXSOz38=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:33:01', 1411);
INSERT INTO `sys_oper_log` VALUES (305, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"BO/IkbeA1CQDKx/qr0Y+l/Yn9w0gcuAa9iAoRWKG/bc=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:37:04', 1440);
INSERT INTO `sys_oper_log` VALUES (306, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"DdT8c2nZYKCMEHIip2wmyNTXpnAdZt+l2aWOH3XvtWo=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:37:33', 1315);
INSERT INTO `sys_oper_log` VALUES (307, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"SEQapuHjwvvXsbI5/mDx3iBTpAbOE94KgNAVv0tlrok=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:50:35', 3162);
INSERT INTO `sys_oper_log` VALUES (308, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:58:11', 1755);
INSERT INTO `sys_oper_log` VALUES (309, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"cWKChyvdtR/15SJmyDwsfwFmZ0WUb80GUCVOtqziFbg=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 13:58:46', 1757);
INSERT INTO `sys_oper_log` VALUES (310, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:08:46', 1676);
INSERT INTO `sys_oper_log` VALUES (311, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"BO/IkbeA1CQDKx/qr0Y+l9ea5UI2KQfilcvE/J7asKA=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:08:56', 1738);
INSERT INTO `sys_oper_log` VALUES (312, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:11:15', 1727);
INSERT INTO `sys_oper_log` VALUES (313, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"Ua3KQ+f2qs8Si8sA7ET7H2ubrRzj6GDqxBlYgjVjPRZJWIYz4Ig4Su1/mfy1eY8v4kB2zHLEjfc9rkHd8FjoDz9v3cX6qL7veX7gxsVq0UE=\"} ', NULL, 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\r\n### The error may exist in file [E:\\Go\\go-api\\ruoyi-system\\target\\classes\\mapper\\system\\SysUserMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.SysUserMapper.selectUserById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: select u.user_id, u.dept_id, u.user_name, u.nick_name, u.email, u.avatar, u.phonenumber, u.password, u.pay_password, case when u.pay_password is null or u.pay_password = \'\' then 0 else 1 end as pay_password_set, u.security_question_set, u.default_currency, u.real_name_status, u.invite_code, u.level_detail, u.user_level, u.level, u.sex, u.birthday, u.status, u.del_flag, u.login_ip, u.login_date, u.pwd_update_date, u.create_by, u.create_time, u.update_by, u.update_time, u.remark,          d.dept_id, d.parent_id, d.ancestors, d.dept_name, d.order_num, d.leader, d.status as dept_status,         r.role_id, r.role_name, r.role_key, r.role_sort, r.data_scope, r.status as role_status,         (select p.user_name from sys_user p where p.user_id = substring_index(u.level_detail, \',\', -1) and p.user_id != 0) as parent_user_name         from sys_user u       left join sys_dept d on u.dept_id = d.dept_id       left join sys_user_role ur on u.user_id = ur.user_id       left join sys_role r on r.role_id = ur.role_id         where u.user_id = ?\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\n; bad SQL grammar []', '2026-05-02 14:16:28', 720);
INSERT INTO `sys_oper_log` VALUES (314, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', NULL, 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\r\n### The error may exist in file [E:\\Go\\go-api\\ruoyi-system\\target\\classes\\mapper\\system\\SysUserMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.SysUserMapper.selectUserById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: select u.user_id, u.dept_id, u.user_name, u.nick_name, u.email, u.avatar, u.phonenumber, u.password, u.pay_password, case when u.pay_password is null or u.pay_password = \'\' then 0 else 1 end as pay_password_set, u.security_question_set, u.default_currency, u.real_name_status, u.invite_code, u.level_detail, u.user_level, u.level, u.sex, u.birthday, u.status, u.del_flag, u.login_ip, u.login_date, u.pwd_update_date, u.create_by, u.create_time, u.update_by, u.update_time, u.remark,          d.dept_id, d.parent_id, d.ancestors, d.dept_name, d.order_num, d.leader, d.status as dept_status,         r.role_id, r.role_name, r.role_key, r.role_sort, r.data_scope, r.status as role_status,         (select p.user_name from sys_user p where p.user_id = substring_index(u.level_detail, \',\', -1) and p.user_id != 0) as parent_user_name         from sys_user u       left join sys_dept d on u.dept_id = d.dept_id       left join sys_user_role ur on u.user_id = ur.user_id       left join sys_role r on r.role_id = ur.role_id         where u.user_id = ?\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\n; bad SQL grammar []', '2026-05-02 14:16:33', 369);
INSERT INTO `sys_oper_log` VALUES (315, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', NULL, 1, '\r\n### Error querying database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\r\n### The error may exist in file [E:\\Go\\go-api\\ruoyi-system\\target\\classes\\mapper\\system\\SysUserMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.SysUserMapper.selectUserById-Inline\r\n### The error occurred while setting parameters\r\n### SQL: select u.user_id, u.dept_id, u.user_name, u.nick_name, u.email, u.avatar, u.phonenumber, u.password, u.pay_password, case when u.pay_password is null or u.pay_password = \'\' then 0 else 1 end as pay_password_set, u.security_question_set, u.default_currency, u.real_name_status, u.invite_code, u.level_detail, u.user_level, u.level, u.sex, u.birthday, u.status, u.del_flag, u.login_ip, u.login_date, u.pwd_update_date, u.create_by, u.create_time, u.update_by, u.update_time, u.remark,          d.dept_id, d.parent_id, d.ancestors, d.dept_name, d.order_num, d.leader, d.status as dept_status,         r.role_id, r.role_name, r.role_key, r.role_sort, r.data_scope, r.status as role_status,         (select p.user_name from sys_user p where p.user_id = substring_index(u.level_detail, \',\', -1) and p.user_id != 0) as parent_user_name         from sys_user u       left join sys_dept d on u.dept_id = d.dept_id       left join sys_user_role ur on u.user_id = ur.user_id       left join sys_role r on r.role_id = ur.role_id         where u.user_id = ?\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'u.security_question_set\' in \'field list\'\n; bad SQL grammar []', '2026-05-02 14:16:37', 362);
INSERT INTO `sys_oper_log` VALUES (316, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:22:02', 1806);
INSERT INTO `sys_oper_log` VALUES (317, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'nnd1', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"data\":\"BISY2Osd/4zJ+S+qEdq6f5Y3iF2bgJ67T8U8LCK5FFGnJl3Tu8LfJ6XfA3jF3Du3q9e1FHtANQ1NfcVp3mQS/Q==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:24:11', 406);
INSERT INTO `sys_oper_log` VALUES (318, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'nnd1', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"data\":\"BISY2Osd/4zJ+S+qEdq6f5Y3iF2bgJ67T8U8LCK5FFFQB1anxFXxf478VslrZvgbZ2KFzc9fgTLN2x6aXBOAjw==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:24:16', 364);
INSERT INTO `sys_oper_log` VALUES (319, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC2026050214241601C29F0E\",\"params\":{},\"rechargeId\":7,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-02 14:25:22\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:25:22', 440);
INSERT INTO `sys_oper_log` VALUES (320, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', '研发部门', '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":1000.0,\"orderNo\":\"RC20260502142411A8351B14\",\"params\":{},\"rechargeId\":6,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-02 14:25:25\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:25:26', 371);
INSERT INTO `sys_oper_log` VALUES (321, '实名认证审核', 2, 'com.ruoyi.web.controller.system.SysAppRealNameAuthController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/realNameAuth', '127.0.0.1', '内网IP', '{\"authId\":7,\"params\":{},\"reviewTime\":\"2026-05-02 14:25:33\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userId\":1000107,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:25:35', 1873);
INSERT INTO `sys_oper_log` VALUES (322, '安全问题设置', 1, 'com.ruoyi.web.controller.system.SysUserSecurityAnswerController.setAnswers()', 'POST', 1, 'nnd1', NULL, '/app/user/security/answers', '192.168.140.1', '内网IP', '{\"data\":\"pxxsnevziualPu8tKmpdHjlZq0OVo5G0oRbtJveRdpP6JK1hezM5APB8dNLCKQPUOy33zml0W0gBbJnbwLdpm6fowt03b5fGy3Gm5nzWgHw=\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 14:36:50', 2090);
INSERT INTO `sys_oper_log` VALUES (323, 'Bank card bind', 1, 'com.ruoyi.web.controller.app.AppBankCardController.add()', 'POST', 1, 'nnd1', NULL, '/app/bankCard', '192.168.140.1', '内网IP', '{\"data\":\"oAgJsURqlTlWh4E4HSqfAdgMJOUBZmNn3c7lxtsw7qjlnEHK/566HybODbtzIu6TIyFczTdTRc2xge4mPR4SbEKTAcc/X7N+Wd+IQTrSIAdKLajT0Gzq2oQ5FiPv7AcO\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:05:33', 1746);
INSERT INTO `sys_oper_log` VALUES (324, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:09:02', 1672);
INSERT INTO `sys_oper_log` VALUES (325, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:09:06', 1600);
INSERT INTO `sys_oper_log` VALUES (326, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/b06c80c1b0f349d1a94fc617bdd630e8.png\",\"birthday\":\"1995-05-01\",\"createTime\":\"2026-05-02 13:12:15\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"c@qq.com\",\"inviteCode\":\"YKZQ4N\",\"level\":0,\"levelDetail\":\"0,1000100\",\"loginDate\":\"2026-05-02 13:50:07\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小天\",\"params\":{\"@type\":\"java.util.HashMap\"},\"parentUserName\":\"lanz\",\"payPasswordSet\":0,\"phonenumber\":\"13988888887\",\"postIds\":[],\"pwdUpdateDate\":\"2026-05-02 13:12:15\",\"realNameStatus\":1,\"roleIds\":[],\"roles\":[],\"securityQuestionSet\":1,\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-02 15:09:05\",\"userId\":1000107,\"userLevel\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:20:43', 1322);
INSERT INTO `sys_oper_log` VALUES (327, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:21:04', 2855);
INSERT INTO `sys_oper_log` VALUES (328, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:21:11', 2201);
INSERT INTO `sys_oper_log` VALUES (329, '鐢ㄦ埛绠＄悊', 2, 'com.ruoyi.web.controller.system.SysUserController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/user', '127.0.0.1', '内网IP', '{\"admin\":false,\"avatar\":\"https://img.1trx.in/avatar/b06c80c1b0f349d1a94fc617bdd630e8.png\",\"birthday\":\"1995-05-01\",\"createTime\":\"2026-05-02 13:12:15\",\"defaultCurrency\":\"CNY\",\"delFlag\":\"0\",\"email\":\"c@qq.com\",\"inviteCode\":\"YKZQ4N\",\"level\":0,\"levelDetail\":\"0,1000100\",\"loginDate\":\"2026-05-02 13:50:07\",\"loginIp\":\"192.168.140.1\",\"nickName\":\"小天\",\"params\":{\"@type\":\"java.util.HashMap\"},\"parentUserName\":\"lanz\",\"payPasswordSet\":0,\"phonenumber\":\"13988888887\",\"postIds\":[],\"pwdUpdateDate\":\"2026-05-02 13:12:15\",\"realNameStatus\":3,\"roleIds\":[],\"roles\":[],\"securityQuestionSet\":1,\"sex\":\"0\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-02 15:21:09\",\"userId\":1000107,\"userLevel\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 15:21:44', 1332);
INSERT INTO `sys_oper_log` VALUES (330, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.miner.rewardMode\",\"configName\":\"矿机收益模式\",\"configType\":\"N\",\"configValue\":\"AUTO\",\"createBy\":\"admin\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"分为自动和手动AUTO / MANUAL\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 16:01:33', 9978);
INSERT INTO `sys_oper_log` VALUES (331, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.miner.rewardMode\",\"configName\":\"矿机收益模式\",\"configType\":\"N\",\"configValue\":\"AUTO\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"分为自动和手动AUTO / MANUAL\"} ', '{\"msg\":\"新增参数\'矿机收益模式\'失败，参数键名已存在\",\"code\":500}', 0, NULL, '2026-05-02 16:01:43', 8);
INSERT INTO `sys_oper_log` VALUES (332, '参数管理', 1, 'com.ruoyi.web.controller.system.SysConfigController.add()', 'POST', 1, 'admin', '研发部门', '/system/config', '127.0.0.1', '内网IP', '{\"configKey\":\"app.miner.wagToUsdRate\",\"configName\":\"矿机兑换 USD 汇率\",\"configType\":\"N\",\"configValue\":\"0.01\",\"createBy\":\"admin\",\"isAppConfig\":\"0\",\"params\":{},\"remark\":\"WAG 兑换 USD 汇率（单币种模式下后续按规则换算 RMB）\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-02 16:02:27', 10355);
INSERT INTO `sys_oper_log` VALUES (333, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/userLevel/index\",\"createTime\":\"2026-05-03 18:10:33\",\"icon\":\"user\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2030,\"menuName\":\"用户等级\",\"menuType\":\"C\",\"orderNum\":9,\"params\":{},\"parentId\":2000,\"path\":\"userLevel\",\"perms\":\"system:userLevel:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:13:38', 62);
INSERT INTO `sys_oper_log` VALUES (334, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0,\"level\":0,\"levelName\":\"VIP.0\",\"params\":{},\"sortOrder\":0,\"status\":\"0\"} ', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'sort_order\' in \'field list\'\r\n### The error may exist in file [E:\\Go\\go-api\\ruoyi-system\\target\\classes\\mapper\\system\\SysUserLevelMapper.xml]\r\n### The error may involve com.ruoyi.system.mapper.SysUserLevelMapper.insertUserLevel-Inline\r\n### The error occurred while setting parameters\r\n### SQL: insert into sys_user_level          ( level,             level_name,                          invest_bonus,                          sort_order,             status,             create_by,             create_time )           values ( ?,             ?,                          ?,                          ?,             ?,             ?,             now() )\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'sort_order\' in \'field list\'\n; bad SQL grammar []', '2026-05-03 18:15:01', 7);
INSERT INTO `sys_oper_log` VALUES (335, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0,\"level\":0,\"levelId\":11,\"levelName\":\"VIP.0\",\"params\":{},\"sortOrder\":0,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:17:32', 389);
INSERT INTO `sys_oper_log` VALUES (336, '用户等级', 2, 'com.ruoyi.web.controller.system.SysUserLevelController.edit()', 'PUT', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-05-03 18:17:31\",\"investBonus\":0,\"level\":0,\"levelId\":11,\"levelName\":\"VIP.0\",\"params\":{},\"requiredGrowthValue\":0,\"sortOrder\":0,\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:17:41', 474);
INSERT INTO `sys_oper_log` VALUES (337, '用户等级', 2, 'com.ruoyi.web.controller.system.SysUserLevelController.edit()', 'PUT', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-05-03 18:17:31\",\"investBonus\":0,\"level\":0,\"levelId\":11,\"levelName\":\"VIP.0\",\"params\":{},\"requiredGrowthValue\":0,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-05-03 18:17:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:42:44', 398);
INSERT INTO `sys_oper_log` VALUES (338, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.08,\"level\":1,\"levelId\":12,\"levelName\":\"VIP.1\",\"params\":{},\"requiredGrowthValue\":2000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:43:14', 935);
INSERT INTO `sys_oper_log` VALUES (339, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.12,\"level\":2,\"levelId\":13,\"levelName\":\"VIP.2\",\"params\":{},\"requiredGrowthValue\":8000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:43:43', 395);
INSERT INTO `sys_oper_log` VALUES (340, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.18,\"level\":3,\"levelId\":14,\"levelName\":\"VIP.3\",\"params\":{},\"requiredGrowthValue\":20000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:44:15', 391);
INSERT INTO `sys_oper_log` VALUES (341, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.25,\"level\":4,\"levelId\":15,\"levelName\":\"VIP.4\",\"params\":{},\"requiredGrowthValue\":50000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:44:51', 372);
INSERT INTO `sys_oper_log` VALUES (342, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.3,\"level\":5,\"levelId\":16,\"levelName\":\"VIP.5\",\"params\":{},\"requiredGrowthValue\":120000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:45:21', 425);
INSERT INTO `sys_oper_log` VALUES (343, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.5,\"level\":6,\"levelId\":17,\"levelName\":\"VIP.6\",\"params\":{},\"requiredGrowthValue\":300000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:45:45', 518);
INSERT INTO `sys_oper_log` VALUES (344, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":0.8,\"level\":7,\"levelId\":18,\"levelName\":\"VIP.7\",\"params\":{},\"requiredGrowthValue\":800000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:46:10', 356);
INSERT INTO `sys_oper_log` VALUES (345, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":1,\"level\":8,\"levelId\":19,\"levelName\":\"VIP.8\",\"params\":{},\"requiredGrowthValue\":2000000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:46:35', 393);
INSERT INTO `sys_oper_log` VALUES (346, '用户等级', 1, 'com.ruoyi.web.controller.system.SysUserLevelController.add()', 'POST', 1, 'admin', NULL, '/system/userLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"investBonus\":2,\"level\":9,\"levelId\":20,\"levelName\":\"VIP.9\",\"params\":{},\"requiredGrowthValue\":5000000,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:46:51', 384);
INSERT INTO `sys_oper_log` VALUES (347, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.run()', 'PUT', 1, 'admin', NULL, '/monitor/job/run', '127.0.0.1', '内网IP', '{\"jobGroup\":\"DEFAULT\",\"jobId\":100,\"misfirePolicy\":\"0\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:47:42', 58);
INSERT INTO `sys_oper_log` VALUES (348, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"Failed to update profile.\",\"code\":500}', 0, NULL, '2026-05-03 18:48:00', 25);
INSERT INTO `sys_oper_log` VALUES (349, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"iiBb+2vDAIh+T1n5kgVzww==\"} ', '{\"msg\":\"Failed to update profile.\",\"code\":500}', 0, NULL, '2026-05-03 18:48:04', 5);
INSERT INTO `sys_oper_log` VALUES (350, '个人信息', 2, 'com.ruoyi.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'nnd1', NULL, '/system/user/profile', '192.168.140.1', '内网IP', '{\"data\":\"ppODyRxmBJKnri+31bSByA==\"} ', '{\"msg\":\"Failed to update profile.\",\"code\":500}', 0, NULL, '2026-05-03 18:48:06', 3);
INSERT INTO `sys_oper_log` VALUES (351, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/miner/index\",\"createTime\":\"2026-05-03 18:53:13\",\"icon\":\"redis\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2034,\"menuName\":\"矿机管理\",\"menuType\":\"C\",\"orderNum\":2011,\"params\":{},\"parentId\":2000,\"path\":\"miner\",\"perms\":\"operation:miner:list\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:53:44', 35);
INSERT INTO `sys_oper_log` VALUES (352, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/7d7dd072466c44d38d9aa3605b92aa35.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":0,\"minerId\":1,\"minerLevel\":0,\"minerName\":\"基础算力单元\",\"params\":{},\"power\":100,\"remark\":\"矿机的入门算力单元，运行稳定，日产出 100 WAG，适合新手起步，体验节点算力。\",\"status\":\"0\",\"wagPerDay\":100.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 18:59:32', 420);
INSERT INTO `sys_oper_log` VALUES (353, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/8591c009d2144dfea35dc5af94356daa.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":1,\"minerId\":2,\"minerLevel\":1,\"minerName\":\"模块化分层矿机\",\"params\":{},\"power\":200,\"remark\":\"三层式模块化设计，算力比入门级翻倍，日产出 200 WAG，兼顾稳定与扩展。\",\"status\":\"0\",\"wagPerDay\":200.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:00:28', 359);
INSERT INTO `sys_oper_log` VALUES (354, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/34b7262046a6495d9d36dfbdd5e735ec.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":2,\"minerId\":3,\"minerLevel\":2,\"minerName\":\"协议算力引擎\",\"params\":{},\"power\":500,\"remark\":\"搭载专属算力协议，双层高效运算架构，日产出 500 WAG，效率更上一层。\",\"status\":\"0\",\"wagPerDay\":500.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:01:12', 473);
INSERT INTO `sys_oper_log` VALUES (355, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/429d42dd0728402d83088854d5c206f2.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":3,\"minerId\":4,\"minerLevel\":3,\"minerName\":\"标准云矿机主机\",\"params\":{},\"power\":800,\"remark\":\"标准云矿机主机，带高效散热与云端调度，日产出 800 WAG，长期稳定运行。\",\"status\":\"0\",\"wagPerDay\":800.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:01:58', 370);
INSERT INTO `sys_oper_log` VALUES (356, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/f202f7a1871d4195991c08d669d4d5f3.webp\",\"createBy\":\"admin\",\"maxUserLevel\":999,\"minUserLevel\":4,\"minerId\":5,\"minerLevel\":4,\"minerName\":\"多节点堆叠矿机\",\"params\":{},\"power\":1500,\"remark\":\"多层堆叠式集群架构，支持横向扩展，日产出 1500 WAG，算力规模稳步提升。\",\"status\":\"0\",\"wagPerDay\":1500.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:02:39', 480);
INSERT INTO `sys_oper_log` VALUES (357, '矿机', 2, 'com.ruoyi.web.controller.system.SysMinerController.edit()', 'PUT', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/f202f7a1871d4195991c08d669d4d5f3.webp\",\"createBy\":\"admin\",\"createTime\":\"2026-05-03 19:02:38\",\"maxUserLevel\":9,\"minUserLevel\":4,\"minerId\":5,\"minerLevel\":4,\"minerName\":\"多节点堆叠矿机\",\"params\":{},\"power\":1500,\"remark\":\"多层堆叠式集群架构，支持横向扩展，日产出 1500 WAG，算力规模稳步提升。\",\"sortOrder\":0,\"status\":\"0\",\"updateBy\":\"admin\",\"wagPerDay\":1500.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:02:48', 414);
INSERT INTO `sys_oper_log` VALUES (358, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/397a8a7e6f0248aea9a3a1e9caa2c906.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":5,\"minerId\":6,\"minerLevel\":5,\"minerName\":\"综合管理矿机单元\",\"params\":{},\"power\":5000,\"remark\":\"集成运算、监控、散热三大模块，日产出 5000 WAG，全程云端可控。\",\"status\":\"0\",\"wagPerDay\":5000.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:03:56', 353);
INSERT INTO `sys_oper_log` VALUES (359, '矿机', 2, 'com.ruoyi.web.controller.system.SysMinerController.edit()', 'PUT', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/397a8a7e6f0248aea9a3a1e9caa2c906.webp\",\"createBy\":\"admin\",\"createTime\":\"2026-05-03 19:03:55\",\"maxUserLevel\":9,\"minUserLevel\":5,\"minerId\":6,\"minerLevel\":5,\"minerName\":\"综合管理矿机单元\",\"params\":{},\"power\":4000,\"remark\":\"集成运算、监控、散热三大模块，日产出 4000 WAG，全程云端可控。\",\"sortOrder\":0,\"status\":\"0\",\"updateBy\":\"admin\",\"wagPerDay\":4000.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:04:21', 357);
INSERT INTO `sys_oper_log` VALUES (360, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/87b3444bba5a4a8090b4ef46471cbcf5.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":6,\"minerId\":7,\"minerLevel\":6,\"minerName\":\"带控制台矿机服务器\",\"params\":{},\"power\":8000,\"remark\":\"带本地控制台的专业服务器，支持参数配置与故障排查，日产出 8000 WAG。\",\"status\":\"0\",\"wagPerDay\":8000.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:05:21', 363);
INSERT INTO `sys_oper_log` VALUES (361, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/58c905fee1c941ab865f49daeca6ebf6.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":7,\"minerId\":8,\"minerLevel\":7,\"minerName\":\"双集群协同矿机系统\",\"params\":{},\"power\":15000,\"remark\":\"双集群协同架构，算力备份不中断，日产出 15000 WAG，适合中大型部署。\",\"status\":\"0\",\"wagPerDay\":15000.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:06:03', 359);
INSERT INTO `sys_oper_log` VALUES (362, '矿机', 1, 'com.ruoyi.web.controller.system.SysMinerController.add()', 'POST', 1, 'admin', NULL, '/system/miner', '127.0.0.1', '内网IP', '{\"coverImage\":\"https://img.1trx.in/avatar/fc8e0953f6a54d4aa7db7a074fbd3a1c.webp\",\"createBy\":\"admin\",\"maxUserLevel\":9,\"minUserLevel\":8,\"minerId\":9,\"minerLevel\":8,\"minerName\":\"分布式矿机核心节点\",\"params\":{},\"power\":50000,\"remark\":\"分布式集群核心节点，多链路并行传输，日产出 50000 WAG，高强度运算也能长期稳定。\",\"status\":\"0\",\"wagPerDay\":50000.0} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:06:58', 366);
INSERT INTO `sys_oper_log` VALUES (363, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'nnd1', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"data\":\"9ZAgTRaxDrSJsnbgvWUUO4nGmyKgl4rxq8T/Y6wUpYayyqOPlEFp1ykOXAgDzcQdimG34cBa9zMRZIglmyFeVw==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:20:57', 429);
INSERT INTO `sys_oper_log` VALUES (364, 'User recharge submit', 1, 'com.ruoyi.web.controller.app.AppRechargeController.submit()', 'POST', 1, 'nnd1', NULL, '/app/recharge/submit', '192.168.140.1', '内网IP', '{\"data\":\"9ZAgTRaxDrSJsnbgvWUUO4nGmyKgl4rxq8T/Y6wUpYbZvNatpYRml/6zT5sEmb18TfOdI8y3PxoG0XAgFfKOOw==\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:21:05', 349);
INSERT INTO `sys_oper_log` VALUES (365, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', NULL, '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":2000.0,\"orderNo\":\"RC20260503192105A6D36E8C\",\"params\":{},\"rechargeId\":9,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-03 19:21:40\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"nnd1\"} ', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'total_invest_amount\' in \'field list\'\r\n### The error may exist in file [E:\\Go\\go-api\\ruoyi-system\\target\\classes\\mapper\\system\\SysUserMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: update sys_user   set total_invest_amount = greatest(0, ifnull(total_invest_amount, 0) + ifnull(?, 0)),       total_recharge_amount = greatest(0, ifnull(total_recharge_amount, 0) + ifnull(?, 0)),       update_time = sysdate()   where user_id = ?\r\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'total_invest_amount\' in \'field list\'\n; bad SQL grammar []', '2026-05-03 19:21:41', 520);
INSERT INTO `sys_oper_log` VALUES (366, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', NULL, '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":2000.0,\"orderNo\":\"RC20260503192105A6D36E8C\",\"params\":{},\"rechargeId\":9,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-03 19:23:39\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:23:39', 371);
INSERT INTO `sys_oper_log` VALUES (367, 'User recharge review', 2, 'com.ruoyi.web.controller.system.SysUserRechargeController.audit()', 'PUT', 1, 'admin', NULL, '/system/recharge', '127.0.0.1', '内网IP', '{\"amount\":2000.0,\"orderNo\":\"RC20260503192057034431E6\",\"params\":{},\"rechargeId\":8,\"rejectReason\":\"\",\"reviewTime\":\"2026-05-03 19:23:43\",\"reviewUserId\":1,\"reviewUserName\":\"admin\",\"status\":1,\"userName\":\"nnd1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:23:44', 684);
INSERT INTO `sys_oper_log` VALUES (368, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:29:06', 34);
INSERT INTO `sys_oper_log` VALUES (369, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:29:40', 3);
INSERT INTO `sys_oper_log` VALUES (370, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:44:57', 36);
INSERT INTO `sys_oper_log` VALUES (371, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:45:05', 5);
INSERT INTO `sys_oper_log` VALUES (372, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:46:58', 3);
INSERT INTO `sys_oper_log` VALUES (373, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:48:36', 40);
INSERT INTO `sys_oper_log` VALUES (374, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作失败\",\"code\":500}', 0, NULL, '2026-05-03 19:48:49', 5);
INSERT INTO `sys_oper_log` VALUES (375, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', NULL, 1, '余额宝配置不存在或已被删除，无法更新。', '2026-05-03 19:51:03', 13);
INSERT INTO `sys_oper_log` VALUES (376, '余额宝配置', 2, 'com.ruoyi.web.controller.system.SysYebaoConfigController.edit()', 'PUT', 1, 'admin', NULL, '/system/yebao/config', '127.0.0.1', '内网IP', '{\"annualRate\":44.03,\"configId\":1,\"configName\":\"余额宝默认配置\",\"createBy\":\"admin\",\"createTime\":\"2026-05-01 11:41:28\",\"growthValuePerUnit\":0.1,\"params\":{},\"remark\":\"默认余额宝配置\",\"status\":\"0\",\"unitAmount\":100.0,\"updateBy\":\"admin\",\"updateTime\":\"2026-05-01 12:09:49\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 19:53:07', 1871);
INSERT INTO `sys_oper_log` VALUES (377, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":1000,\"remark\":\"测试奖励\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:19:08', 754);
INSERT INTO `sys_oper_log` VALUES (378, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":500,\"remark\":\"\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:24:58', 1400);
INSERT INTO `sys_oper_log` VALUES (379, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":1500,\"remark\":\"\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:25:32', 365);
INSERT INTO `sys_oper_log` VALUES (380, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":1500,\"remark\":\"\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:26:21', 357);
INSERT INTO `sys_oper_log` VALUES (381, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":1500,\"remark\":\"\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:31:23', 378);
INSERT INTO `sys_oper_log` VALUES (382, '成长值增加', 2, 'com.ruoyi.web.controller.system.SysUserGrowthController.increase()', 'POST', 1, 'admin', NULL, '/system/growth/increase', '127.0.0.1', '内网IP', '{\"growthValue\":5000,\"remark\":\"\",\"sourceNo\":\"\",\"sourceType\":\"manual\",\"userId\":1000107} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:31:45', 351);
INSERT INTO `sys_oper_log` VALUES (383, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.run()', 'PUT', 1, 'admin', NULL, '/monitor/job/run', '127.0.0.1', '内网IP', '{\"jobGroup\":\"DEFAULT\",\"jobId\":3,\"misfirePolicy\":\"0\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:37:00', 46);
INSERT INTO `sys_oper_log` VALUES (384, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.run()', 'PUT', 1, 'admin', NULL, '/monitor/job/run', '127.0.0.1', '内网IP', '{\"jobGroup\":\"DEFAULT\",\"jobId\":101,\"misfirePolicy\":\"0\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:37:04', 11);
INSERT INTO `sys_oper_log` VALUES (385, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.run()', 'PUT', 1, 'admin', NULL, '/monitor/job/run', '127.0.0.1', '内网IP', '{\"jobGroup\":\"DEFAULT\",\"jobId\":101,\"misfirePolicy\":\"0\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 20:38:15', 64);
INSERT INTO `sys_oper_log` VALUES (386, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-04-30 16:35:07\",\"icon\":\"chart\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2016,\"menuName\":\"内容管理\",\"menuType\":\"M\",\"orderNum\":20,\"params\":{},\"parentId\":0,\"path\":\"content\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 21:56:51', 46);
INSERT INTO `sys_oper_log` VALUES (387, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-01 11:41:28\",\"icon\":\"example\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2019,\"menuName\":\"余额宝管理\",\"menuType\":\"M\",\"orderNum\":30,\"params\":{},\"parentId\":0,\"path\":\"yebao\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 21:57:16', 22);
INSERT INTO `sys_oper_log` VALUES (388, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/bankCard/index\",\"createTime\":\"2026-04-29 17:28:52\",\"icon\":\"tab\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2008,\"menuName\":\"银行卡管理\",\"menuType\":\"C\",\"orderNum\":5,\"params\":{},\"parentId\":2000,\"path\":\"bankCard\",\"perms\":\"operation:bankCard:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 21:57:57', 108);
INSERT INTO `sys_oper_log` VALUES (389, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/point/account/index\",\"createTime\":\"2026-04-30 12:58:22\",\"icon\":\"job\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2013,\"menuName\":\"积分管理\",\"menuType\":\"C\",\"orderNum\":7,\"params\":{},\"parentId\":2000,\"path\":\"point\",\"perms\":\"system:point:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 21:58:14', 8);
INSERT INTO `sys_oper_log` VALUES (390, '团队等级', 2, 'com.ruoyi.web.controller.system.SysTeamLevelController.edit()', 'PUT', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-05-03 21:44:35\",\"params\":{},\"remark\":\"默认规则\",\"requiredDirectUsers\":3,\"requiredTeamInvest\":100000,\"requiredTeamUsers\":3,\"requiredUserLevel\":0,\"rewardAmount\":1200,\"status\":\"0\",\"teamBonusRate\":0.5,\"teamLevel\":1,\"teamLevelId\":1,\"teamLevelName\":\"一星团长\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:14:42', 420);
INSERT INTO `sys_oper_log` VALUES (391, '团队等级', 2, 'com.ruoyi.web.controller.system.SysTeamLevelController.edit()', 'PUT', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-05-03 21:44:35\",\"params\":{},\"remark\":\"默认规则\",\"requiredDirectUsers\":5,\"requiredTeamInvest\":300000,\"requiredTeamUsers\":8,\"requiredUserLevel\":1,\"rewardAmount\":3600,\"status\":\"0\",\"teamBonusRate\":1.2,\"teamLevel\":2,\"teamLevelId\":2,\"teamLevelName\":\"二星团长\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:15:17', 366);
INSERT INTO `sys_oper_log` VALUES (392, '团队等级', 2, 'com.ruoyi.web.controller.system.SysTeamLevelController.edit()', 'PUT', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-05-03 21:44:35\",\"params\":{},\"remark\":\"默认规则\",\"requiredDirectUsers\":8,\"requiredTeamInvest\":600000,\"requiredTeamUsers\":12,\"requiredUserLevel\":2,\"rewardAmount\":8000,\"status\":\"0\",\"teamBonusRate\":3,\"teamLevel\":3,\"teamLevelId\":3,\"teamLevelName\":\"三星团长\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:15:37', 349);
INSERT INTO `sys_oper_log` VALUES (393, '团队等级', 1, 'com.ruoyi.web.controller.system.SysTeamLevelController.add()', 'POST', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"params\":{},\"requiredDirectUsers\":20,\"requiredTeamInvest\":1000000,\"requiredTeamUsers\":30,\"requiredUserLevel\":3,\"rewardAmount\":15000,\"status\":\"0\",\"teamBonusRate\":6,\"teamLevel\":4,\"teamLevelId\":4,\"teamLevelName\":\"四星团长\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:16:57', 988);
INSERT INTO `sys_oper_log` VALUES (394, '团队等级', 1, 'com.ruoyi.web.controller.system.SysTeamLevelController.add()', 'POST', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"params\":{},\"requiredDirectUsers\":50,\"requiredTeamInvest\":3000000,\"requiredTeamUsers\":60,\"requiredUserLevel\":4,\"rewardAmount\":30000,\"status\":\"0\",\"teamBonusRate\":8,\"teamLevel\":5,\"teamLevelId\":5,\"teamLevelName\":\"五星团长\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:18:25', 972);
INSERT INTO `sys_oper_log` VALUES (395, '团队等级', 1, 'com.ruoyi.web.controller.system.SysTeamLevelController.add()', 'POST', 1, 'admin', NULL, '/system/teamLevel', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"params\":{},\"requiredDirectUsers\":100,\"requiredTeamInvest\":10000000,\"requiredTeamUsers\":120,\"requiredUserLevel\":5,\"rewardAmount\":50000,\"status\":\"0\",\"teamBonusRate\":12,\"teamLevel\":6,\"teamLevelId\":6,\"teamLevelName\":\"六星团长\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 22:19:42', 398);
INSERT INTO `sys_oper_log` VALUES (396, '定时任务', 1, 'com.ruoyi.quartz.controller.SysJobController.add()', 'POST', 1, 'admin', NULL, '/monitor/job', '127.0.0.1', '内网IP', '{\"concurrent\":\"1\",\"createBy\":\"admin\",\"cronExpression\":\"0 30 1 * * ?\",\"invokeTarget\":\"teamStatTask.rebuildYesterday()\",\"jobGroup\":\"DEFAULT\",\"jobId\":102,\"jobName\":\"团队统计\",\"misfirePolicy\":\"1\",\"nextValidTime\":\"2026-05-04 01:30:00\",\"params\":{},\"status\":\"1\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:17:58', 123);
INSERT INTO `sys_oper_log` VALUES (397, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.changeStatus()', 'PUT', 1, 'admin', NULL, '/monitor/job/changeStatus', '127.0.0.1', '内网IP', '{\"jobId\":102,\"misfirePolicy\":\"0\",\"params\":{},\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:18:05', 82);
INSERT INTO `sys_oper_log` VALUES (398, '定时任务', 2, 'com.ruoyi.quartz.controller.SysJobController.run()', 'PUT', 1, 'admin', NULL, '/monitor/job/run', '127.0.0.1', '内网IP', '{\"jobGroup\":\"DEFAULT\",\"jobId\":102,\"misfirePolicy\":\"0\",\"params\":{}} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:18:21', 74);
INSERT INTO `sys_oper_log` VALUES (399, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2043,\"menuName\":\"产品管理\",\"menuType\":\"M\",\"orderNum\":11,\"params\":{},\"parentId\":0,\"path\":\"product\",\"perms\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:31:38', 39);
INSERT INTO `sys_oper_log` VALUES (400, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"dict\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2043,\"menuName\":\"产品管理\",\"menuType\":\"M\",\"orderNum\":11,\"params\":{},\"parentId\":0,\"path\":\"product\",\"perms\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:32:44', 18);
INSERT INTO `sys_oper_log` VALUES (401, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"dict\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2043,\"menuName\":\"产品管理\",\"menuType\":\"M\",\"orderNum\":11,\"params\":{},\"parentId\":0,\"path\":\"product\",\"perms\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:33:06', 80);
INSERT INTO `sys_oper_log` VALUES (402, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"dict\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2043,\"menuName\":\"产品管理\",\"menuType\":\"M\",\"orderNum\":11,\"params\":{},\"parentId\":0,\"path\":\"product\",\"perms\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:33:55', 50);
INSERT INTO `sys_oper_log` VALUES (403, '菜单管理', 1, 'com.ruoyi.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"monitor\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"资金管理\",\"menuType\":\"M\",\"orderNum\":5,\"params\":{},\"parentId\":0,\"path\":\"money\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:35:48', 90);
INSERT INTO `sys_oper_log` VALUES (404, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/recharge/index\",\"createTime\":\"2026-04-29 16:14:22\",\"icon\":\"money\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2006,\"menuName\":\"充值管理\",\"menuType\":\"C\",\"orderNum\":4,\"params\":{},\"parentId\":2048,\"path\":\"operation/recharge/index\",\"perms\":\"operation:recharge:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:36:15', 26);
INSERT INTO `sys_oper_log` VALUES (405, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/bankCard/index\",\"createTime\":\"2026-04-29 17:28:52\",\"icon\":\"tab\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2008,\"menuName\":\"银行卡管理\",\"menuType\":\"C\",\"orderNum\":5,\"params\":{},\"parentId\":2048,\"path\":\"bankCard\",\"perms\":\"operation:bankCard:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:36:28', 13);
INSERT INTO `sys_oper_log` VALUES (406, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"\",\"createTime\":\"2026-04-29 16:14:22\",\"icon\":\"#\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2007,\"menuName\":\"充值审核\",\"menuType\":\"F\",\"orderNum\":4,\"params\":{},\"parentId\":2048,\"path\":\"\",\"perms\":\"operation:recharge:edit\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:36:45', 31);
INSERT INTO `sys_oper_log` VALUES (407, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/withdraw/index\",\"createTime\":\"2026-04-29 18:28:59\",\"icon\":\"money\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2010,\"menuName\":\"提现管理\",\"menuType\":\"C\",\"orderNum\":6,\"params\":{},\"parentId\":2048,\"path\":\"withdraw\",\"perms\":\"operation:withdraw:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:36:55', 59);
INSERT INTO `sys_oper_log` VALUES (408, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/point/account/index\",\"createTime\":\"2026-04-30 12:58:22\",\"icon\":\"job\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2013,\"menuName\":\"积分管理\",\"menuType\":\"C\",\"orderNum\":7,\"params\":{},\"parentId\":2048,\"path\":\"point\",\"perms\":\"system:point:list\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:37:07', 53);
INSERT INTO `sys_oper_log` VALUES (409, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-01 11:41:28\",\"icon\":\"example\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2019,\"menuName\":\"余额宝管理\",\"menuType\":\"M\",\"orderNum\":30,\"params\":{},\"parentId\":2048,\"path\":\"yebao\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:37:21', 52);
INSERT INTO `sys_oper_log` VALUES (410, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:35:48\",\"icon\":\"monitor\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2048,\"menuName\":\"资金管理\",\"menuType\":\"M\",\"orderNum\":5,\"params\":{},\"parentId\":0,\"path\":\"/\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"修改菜单\'资金管理\'失败，路由名称或地址已存在\",\"code\":500}', 0, NULL, '2026-05-03 23:38:13', 5);
INSERT INTO `sys_oper_log` VALUES (411, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/investProduct/index\",\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"list\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2044,\"menuName\":\"产品管理\",\"menuType\":\"C\",\"orderNum\":1,\"params\":{},\"parentId\":2043,\"path\":\"investProduct\",\"perms\":\"system:invest:list\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:39:18', 20);
INSERT INTO `sys_oper_log` VALUES (412, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/couponTemplate/index\",\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"icon\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2045,\"menuName\":\"优惠券管理\",\"menuType\":\"C\",\"orderNum\":2,\"params\":{},\"parentId\":2043,\"path\":\"couponTemplate\",\"perms\":\"system:invest:list\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:39:54', 90);
INSERT INTO `sys_oper_log` VALUES (413, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"operation/levelTrial/index\",\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"documentation\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2046,\"menuName\":\"等级体验卡\",\"menuType\":\"C\",\"orderNum\":3,\"params\":{},\"parentId\":2043,\"path\":\"levelTrial\",\"perms\":\"system:invest:list\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:40:18', 10);
INSERT INTO `sys_oper_log` VALUES (414, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"component\":\"system/yebao/order/index\",\"createTime\":\"2026-05-03 23:27:38\",\"icon\":\"edit\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2047,\"menuName\":\"订单管理\",\"menuType\":\"C\",\"orderNum\":4,\"params\":{},\"parentId\":2043,\"path\":\"investOrder\",\"perms\":\"system:yebao:order:list\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:40:29', 23);
INSERT INTO `sys_oper_log` VALUES (415, '菜单管理', 2, 'com.ruoyi.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-05-03 23:35:48\",\"icon\":\"monitor\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuId\":2048,\"menuName\":\"资金管理\",\"menuType\":\"M\",\"orderNum\":5,\"params\":{},\"parentId\":0,\"path\":\"fund\",\"perms\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-05-03 23:42:30', 27);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int(4) NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '岗位信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-04-24 11:27:59', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int(4) NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-04-24 11:27:59', '', NULL, '普通角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色和部门关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 2003);
INSERT INTO `sys_role_menu` VALUES (1, 2004);
INSERT INTO `sys_role_menu` VALUES (1, 2006);
INSERT INTO `sys_role_menu` VALUES (1, 2007);
INSERT INTO `sys_role_menu` VALUES (1, 2008);
INSERT INTO `sys_role_menu` VALUES (1, 2009);
INSERT INTO `sys_role_menu` VALUES (1, 2010);
INSERT INTO `sys_role_menu` VALUES (1, 2011);
INSERT INTO `sys_role_menu` VALUES (1, 2012);
INSERT INTO `sys_role_menu` VALUES (1, 2013);
INSERT INTO `sys_role_menu` VALUES (1, 2014);
INSERT INTO `sys_role_menu` VALUES (1, 2015);
INSERT INTO `sys_role_menu` VALUES (1, 2030);
INSERT INTO `sys_role_menu` VALUES (1, 2031);
INSERT INTO `sys_role_menu` VALUES (1, 2032);
INSERT INTO `sys_role_menu` VALUES (1, 2033);
INSERT INTO `sys_role_menu` VALUES (1, 2035);
INSERT INTO `sys_role_menu` VALUES (1, 2036);
INSERT INTO `sys_role_menu` VALUES (1, 2037);
INSERT INTO `sys_role_menu` VALUES (1, 2038);
INSERT INTO `sys_role_menu` VALUES (1, 2039);
INSERT INTO `sys_role_menu` VALUES (1, 2040);
INSERT INTO `sys_role_menu` VALUES (1, 2041);
INSERT INTO `sys_role_menu` VALUES (1, 2042);
INSERT INTO `sys_role_menu` VALUES (1, 2043);
INSERT INTO `sys_role_menu` VALUES (1, 2044);
INSERT INTO `sys_role_menu` VALUES (1, 2045);
INSERT INTO `sys_role_menu` VALUES (1, 2046);
INSERT INTO `sys_role_menu` VALUES (1, 2047);
INSERT INTO `sys_role_menu` VALUES (1, 2050);
INSERT INTO `sys_role_menu` VALUES (1, 2051);
INSERT INTO `sys_role_menu` VALUES (1, 2052);
INSERT INTO `sys_role_menu` VALUES (1, 2053);
INSERT INTO `sys_role_menu` VALUES (1, 2054);
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 117);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);
INSERT INTO `sys_role_menu` VALUES (2, 2005);
INSERT INTO `sys_role_menu` VALUES (2, 2006);
INSERT INTO `sys_role_menu` VALUES (2, 2007);
INSERT INTO `sys_role_menu` VALUES (2, 2010);
INSERT INTO `sys_role_menu` VALUES (2, 2011);
INSERT INTO `sys_role_menu` VALUES (2, 2012);
INSERT INTO `sys_role_menu` VALUES (2, 2013);
INSERT INTO `sys_role_menu` VALUES (2, 2014);
INSERT INTO `sys_role_menu` VALUES (2, 2015);

-- ----------------------------
-- Table structure for sys_security_question
-- ----------------------------
DROP TABLE IF EXISTS `sys_security_question`;
CREATE TABLE `sys_security_question`  (
  `question_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '问题ID',
  `question_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '问题代码',
  `question_text` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '问题文本',
  `question_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`question_id`) USING BTREE,
  UNIQUE INDEX `uk_question_code`(`question_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '安全问题表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_security_question
-- ----------------------------
INSERT INTO `sys_security_question` VALUES (1, 'FATHER_BIRTHDAY', '你父亲的生日是哪天？', 1, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (2, 'MOTHER_BIRTHDAY', '你母亲的生日是哪天？', 2, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (3, 'FIRST_PET_NAME', '你第一只宠物的名字是什么？', 3, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (4, 'FIRST_TEACHER', '你小学班主任的名字是什么？', 4, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (5, 'BIRTH_CITY', '你出生的城市是哪里？', 5, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (6, 'FAVORITE_BOOK', '你最喜欢的一本书是什么？', 6, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (7, 'FAVORITE_MOVIE', '你最喜爱的一部电影是什么？', 7, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (8, 'BEST_FRIEND', '你最好的朋友叫什么？', 8, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (9, 'FIRST_JOB', '你的第一份工作是什么？', 9, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (10, 'DREAM_CITY', '你最想居住的城市是哪里？', 10, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (11, 'CHILDHOOD_NICKNAME', '你童年时期的外号是什么？', 11, '0', '2026-04-26 12:19:02', NULL, NULL);
INSERT INTO `sys_security_question` VALUES (12, 'FIRST_LOVE', '你的初恋是谁？', 12, '0', '2026-04-26 12:19:02', NULL, NULL);

-- ----------------------------
-- Table structure for sys_team_level
-- ----------------------------
DROP TABLE IF EXISTS `sys_team_level`;
CREATE TABLE `sys_team_level`  (
  `team_level_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '团队等级ID',
  `team_level` int(11) NOT NULL COMMENT '团队长等级',
  `team_level_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '等级名称',
  `required_user_level` int(11) NOT NULL DEFAULT 0 COMMENT '自身等级要求',
  `required_direct_users` int(11) NOT NULL DEFAULT 0 COMMENT '直推有效用户数',
  `required_team_users` int(11) NOT NULL DEFAULT 0 COMMENT '团队有效用户数',
  `required_team_invest` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '团队总投资(元)',
  `reward_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '奖励(元)',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `team_bonus_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '团队长加成(‰)',
  PRIMARY KEY (`team_level_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_team_level_level`(`team_level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '团队等级配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_team_level
-- ----------------------------
INSERT INTO `sys_team_level` VALUES (1, 1, '一星团长', 0, 3, 3, 100000.00, 1200.00, '0', 'admin', '2026-05-03 21:44:35', 'admin', '2026-05-03 22:14:42', '默认规则', 0.5000);
INSERT INTO `sys_team_level` VALUES (2, 2, '二星团长', 1, 5, 8, 300000.00, 3600.00, '0', 'admin', '2026-05-03 21:44:35', 'admin', '2026-05-03 22:15:16', '默认规则', 1.2000);
INSERT INTO `sys_team_level` VALUES (3, 3, '三星团长', 2, 8, 12, 600000.00, 8000.00, '0', 'admin', '2026-05-03 21:44:35', 'admin', '2026-05-03 22:15:37', '默认规则', 3.0000);
INSERT INTO `sys_team_level` VALUES (4, 4, '四星团长', 3, 20, 30, 1000000.00, 15000.00, '0', 'admin', '2026-05-03 22:16:56', '', NULL, NULL, 6.0000);
INSERT INTO `sys_team_level` VALUES (5, 5, '五星团长', 4, 50, 60, 3000000.00, 30000.00, '0', 'admin', '2026-05-03 22:18:24', '', NULL, NULL, 8.0000);
INSERT INTO `sys_team_level` VALUES (6, 6, '六星团长', 5, 100, 120, 10000000.00, 50000.00, '0', 'admin', '2026-05-03 22:19:42', '', NULL, NULL, 12.0000);

-- ----------------------------
-- Table structure for sys_team_relation
-- ----------------------------
DROP TABLE IF EXISTS `sys_team_relation`;
CREATE TABLE `sys_team_relation`  (
  `ancestor_user_id` bigint(20) NOT NULL COMMENT '祖先用户ID（上级）',
  `descendant_user_id` bigint(20) NOT NULL COMMENT '后代用户ID（下级）',
  `depth` int(11) NOT NULL COMMENT '层级深度：1=直推，2=间推...',
  `is_direct` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否直推（1是 0否）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`ancestor_user_id`, `descendant_user_id`) USING BTREE,
  INDEX `idx_team_relation_desc_depth`(`descendant_user_id` ASC, `depth` ASC) USING BTREE,
  INDEX `idx_team_relation_ancestor_depth`(`ancestor_user_id` ASC, `depth` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队关系闭包表（夜间重建）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_team_relation
-- ----------------------------
INSERT INTO `sys_team_relation` VALUES (1, 1000102, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_relation` VALUES (1, 1000103, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_relation` VALUES (1000100, 1000104, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_relation` VALUES (1000100, 1000105, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_relation` VALUES (1000100, 1000106, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_relation` VALUES (1000100, 1000107, 1, 1, '2026-05-03 23:18:22', '2026-05-03 23:18:22');

-- ----------------------------
-- Table structure for sys_team_stat_daily
-- ----------------------------
DROP TABLE IF EXISTS `sys_team_stat_daily`;
CREATE TABLE `sys_team_stat_daily`  (
  `stat_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `team_level` int(11) NOT NULL DEFAULT 0 COMMENT '团队长等级',
  `calc_depth` int(11) NOT NULL DEFAULT 3 COMMENT '统计层级',
  `direct_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '直推人数',
  `direct_valid_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '直推有效人数',
  `team_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '团队总人数',
  `team_valid_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '团队有效人数',
  `team_total_asset` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '团队总资产（充值累计）',
  `team_total_invest` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '团队总投资（投资累计）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stat_id`) USING BTREE,
  UNIQUE INDEX `uk_team_stat_daily`(`stat_date` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_team_stat_daily_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队统计每日快照表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_team_stat_daily
-- ----------------------------
INSERT INTO `sys_team_stat_daily` VALUES (1, '2026-05-02', 1, 0, 3, 2, 0, 2, 0, 3000.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (2, '2026-05-02', 1000002, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (3, '2026-05-02', 1000100, 0, 3, 4, 1, 4, 1, 2000.00, 1500.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (4, '2026-05-02', 1000102, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (5, '2026-05-02', 1000103, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (6, '2026-05-02', 1000104, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (7, '2026-05-02', 1000105, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (8, '2026-05-02', 1000106, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_daily` VALUES (9, '2026-05-02', 1000107, 0, 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');

-- ----------------------------
-- Table structure for sys_team_stat_event
-- ----------------------------
DROP TABLE IF EXISTS `sys_team_stat_event`;
CREATE TABLE `sys_team_stat_event`  (
  `event_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '事件ID',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `owner_user_id` bigint(20) NOT NULL COMMENT '团队拥有者（上级）',
  `member_user_id` bigint(20) NOT NULL COMMENT '事件成员（下级）',
  `relation_depth` int(11) NOT NULL DEFAULT 0 COMMENT '关系深度',
  `event_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '事件类型：REGISTER/RECHARGE/INVEST',
  `event_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '事件金额',
  `is_valid_user` tinyint(1) NOT NULL DEFAULT 0 COMMENT '成员是否有效',
  `biz_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '业务唯一键',
  `event_time` datetime NULL DEFAULT NULL COMMENT '事件时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`event_id`) USING BTREE,
  UNIQUE INDEX `uk_team_event_dedupe`(`owner_user_id` ASC, `event_type` ASC, `biz_key` ASC) USING BTREE,
  INDEX `idx_team_event_date_owner`(`stat_date` ASC, `owner_user_id` ASC) USING BTREE,
  INDEX `idx_team_event_member`(`member_user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队统计事件流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_team_stat_event
-- ----------------------------
INSERT INTO `sys_team_stat_event` VALUES (1, '2026-05-02', 1000100, 1000104, 1, 'REGISTER', 0.00, 0, 'REG:1000104', '2026-05-02 12:39:39', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_event` VALUES (2, '2026-05-02', 1000100, 1000105, 1, 'REGISTER', 0.00, 0, 'REG:1000105', '2026-05-02 12:47:52', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_event` VALUES (3, '2026-05-02', 1000100, 1000106, 1, 'REGISTER', 0.00, 0, 'REG:1000106', '2026-05-02 13:08:38', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_event` VALUES (4, '2026-05-02', 1000100, 1000107, 1, 'REGISTER', 0.00, 1, 'REG:1000107', '2026-05-02 13:12:15', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_event` VALUES (8, '2026-05-02', 1000100, 1000107, 1, 'RECHARGE', 1000.00, 1, 'RC:6', '2026-05-02 14:25:26', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_event` VALUES (9, '2026-05-02', 1000100, 1000107, 1, 'RECHARGE', 1000.00, 1, 'RC:7', '2026-05-02 14:25:23', '2026-05-03 23:18:22');

-- ----------------------------
-- Table structure for sys_team_stat_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_team_stat_user`;
CREATE TABLE `sys_team_stat_user`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `team_level` int(11) NOT NULL DEFAULT 0 COMMENT '团队长等级',
  `calc_date` date NOT NULL COMMENT '统计日期',
  `calc_depth` int(11) NOT NULL DEFAULT 3 COMMENT '统计层级',
  `direct_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '直推人数',
  `direct_valid_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '直推有效人数',
  `team_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '团队总人数',
  `team_valid_user_count` int(11) NOT NULL DEFAULT 0 COMMENT '团队有效人数',
  `team_total_asset` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '团队总资产（充值累计）',
  `team_total_invest` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '团队总投资（投资累计）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`user_id`) USING BTREE,
  INDEX `idx_team_stat_user_calc_date`(`calc_date` ASC) USING BTREE,
  INDEX `idx_team_stat_user_team_level`(`team_level` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '团队统计用户汇总（最新快照）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_team_stat_user
-- ----------------------------
INSERT INTO `sys_team_stat_user` VALUES (1, 0, '2026-05-02', 3, 2, 0, 2, 0, 3000.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000002, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000100, 0, '2026-05-02', 3, 4, 1, 4, 1, 2000.00, 1500.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000102, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000103, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000104, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000105, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000106, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');
INSERT INTO `sys_team_stat_user` VALUES (1000107, 0, '2026-05-02', 3, 0, 0, 0, 0, 0.00, 0.00, '2026-05-03 23:18:22', '2026-05-03 23:18:22');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint(20) NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `avatar` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `invite_code` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户邀请码',
  `level_detail` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '层级详情，例如0,100,200',
  `user_level` int(11) NOT NULL DEFAULT 0 COMMENT '用户层级，根用户为0',
  `level` int(11) NULL DEFAULT 0 COMMENT '用户等级',
  `pay_password` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '支付密码',
  `real_name_status` tinyint(4) NOT NULL DEFAULT -1 COMMENT '实名认证状态：-1未提交，0待审核，1通过，2拒绝',
  `default_currency` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'CNY' COMMENT '默认币种：CNY(人民币), USD(美元)',
  `security_question_set` tinyint(1) NULL DEFAULT 0 COMMENT '是否设置安全问题',
  `total_invest_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '累计投资金额(人民币)',
  `total_recharge_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '累计充值金额(人民币)',
  `growth_value` bigint(20) NOT NULL DEFAULT 0 COMMENT '成长值',
  `team_leader_level` int(11) NOT NULL DEFAULT 0 COMMENT '团队长级别',
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_invite_code`(`invite_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1000108 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', NULL, '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-05-02 14:24:30', '2026-04-24 11:27:59', 'admin', '2026-04-24 11:27:59', '', NULL, '管理员', 'ABCDEF', '0', 0, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000002, 105, 'ry', '若依', '00', 'ry@qq.com', '15666666666', '1', NULL, '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-04-24 11:27:59', '2026-04-24 11:27:59', 'admin', '2026-04-24 11:27:59', '', NULL, '测试员', 'ABCDEG', '0', 0, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000100, NULL, 'lanz', '小兰男', '00', 'aa@abc.com', '13988888888', '0', '2026-04-25', 'https://img.1trx.in/avatar/6261112486f440e0bbb1ad0c8dbde87c.png', '$2a$10$JBPe895RePwgGN5hniLBguPWASmTXgvCtAu5ilkzlY35tNWGt7FOm', '0', '0', '192.168.140.1', '2026-05-02 12:30:28', '2026-04-30 20:54:01', '', '2026-04-24 20:30:27', 'admin', '2026-05-01 13:17:33', '万事开头男', 'ABCDEA', '0', 0, 1, '$2a$10$bLhiSDpHkYR7wLQBUAaKRuf.zrHU4s/NqOGLhI9iL7Gupz7hlb8z2', 3, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000102, NULL, 'test1', '小王', '00', '', '13977777777', '0', '2013-05-01', 'https://img.1trx.in/avatar/74eb662070884ad8bf2872e7c53ec9d0.png', '$2a$10$RhuENwv4Kr91c6QhcrY9DO0SSLJVworA2beGoIibf4PcXiO.Q5RVm', '0', '0', '192.168.0.2', '2026-05-01 16:17:13', '2026-04-25 14:39:57', '', '2026-04-25 14:39:57', 'admin', '2026-05-01 23:05:28', NULL, 'LNWR6M', '0,1', 1, 0, '$2a$10$VYHgMfZU9cEP5jWNN29K9ucmeS/mh76K622B52T8uUKVqhv3WD28S', 3, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000103, NULL, 'liyats', 'liyats', '00', '', '', '0', NULL, '', '$2a$10$39lvbALbw5Y26HvHAJjkZ.40H9QZSHpTtCRr/WuGhKLIxttn3wvNu', '0', '0', '', NULL, '2026-05-01 17:12:18', '', '2026-05-01 17:12:18', '', NULL, NULL, 'KLQQU2', '0,1', 1, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000104, NULL, 'suyat', 'suyat', '00', '', '', '0', NULL, '', '$2a$10$vAn3CcctPLeHdmmf6qR9OOyVqjsn4qik2tf3bdqtl0nmHh720uNBW', '0', '0', '', NULL, '2026-05-02 12:39:40', '', '2026-05-02 12:39:39', '', NULL, NULL, 'AW5A8K', '0,1000100', 1, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000105, NULL, 'lian', 'lian', '00', '', '', '0', NULL, '', '$2a$10$h9GWo3g.qhsb.AtVAI9TAuwhuDi6ngQbLoMfNR7c7y0ieUb.6cyEi', '0', '0', '192.168.140.1', '2026-05-02 12:47:57', '2026-05-02 12:47:52', '', '2026-05-02 12:47:52', '', NULL, NULL, '8HPBM2', '0,1000100', 1, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000106, NULL, 'nnd', 'nnd', '00', '', '', '0', NULL, '', '$2a$10$X/ErL7disJDeJhAVL/LxIezsA2kTy6y07Ifn/ozean3H72KGGRht.', '0', '0', '192.168.140.1', '2026-05-02 13:08:43', '2026-05-02 13:08:39', '', '2026-05-02 13:08:38', '', NULL, NULL, 'ERQJWA', '0,1000100', 1, 0, NULL, -1, 'CNY', 0, 0.00, 0.00, 0, 0);
INSERT INTO `sys_user` VALUES (1000107, NULL, 'nnd1', '小天', '00', 'c@qq.com', '13988888887', '0', '1995-05-01', 'https://img.1trx.in/avatar/b06c80c1b0f349d1a94fc617bdd630e8.png', '$2a$10$/CCCtZY0SFw.qCK5aKGrf.GtezC94R565l9f/MzxR1TiwSA7v.iPC', '0', '0', '192.168.140.1', '2026-05-03 21:49:08', '2026-05-02 13:12:15', '', '2026-05-02 13:12:15', 'admin', '2026-05-03 21:49:07', NULL, 'YKZQ4N', '0,1000100', 1, 2, NULL, 3, 'CNY', 1, 0.00, 16000.00, 8000, 0);

-- ----------------------------
-- Table structure for sys_user_bank_card
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_bank_card`;
CREATE TABLE `sys_user_bank_card`  (
  `bank_card_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '银行卡ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `currency_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'CNY' COMMENT '币种（CNY/USD）',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开户行',
  `account_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账号',
  `account_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `wallet_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '钱包地址',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`bank_card_id`) USING BTREE,
  INDEX `idx_user_currency`(`user_id` ASC, `currency_type` ASC) USING BTREE,
  INDEX `idx_user_name`(`user_name` ASC) USING BTREE,
  INDEX `idx_currency_type`(`currency_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户银行卡表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_bank_card
-- ----------------------------
INSERT INTO `sys_user_bank_card` VALUES (1, 1000100, 'lanz', 'CNY', '建设银行', '62332332222222', '张三', NULL, NULL, 'lanz', '2026-04-29 17:32:24', 'lanz', '2026-04-29 17:32:24');
INSERT INTO `sys_user_bank_card` VALUES (2, 1000100, 'lanz', 'USD', NULL, NULL, NULL, 'werewrdfsfsdfsdfdsfdsfdsfsd', NULL, 'lanz', '2026-04-29 17:33:33', 'lanz', '2026-04-29 17:33:33');
INSERT INTO `sys_user_bank_card` VALUES (3, 1000102, 'test1', 'CNY', '建行', '65288775588966558', '张五', NULL, NULL, 'test1', '2026-05-01 23:37:14', 'test1', '2026-05-01 23:37:14');
INSERT INTO `sys_user_bank_card` VALUES (4, 1000107, 'nnd1', 'CNY', '工行', '24234234324', '李四', NULL, NULL, 'nnd1', '2026-05-02 15:05:33', 'nnd1', '2026-05-02 15:05:33');

-- ----------------------------
-- Table structure for sys_user_growth_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_growth_log`;
CREATE TABLE `sys_user_growth_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户名',
  `change_value` bigint(20) NOT NULL COMMENT '变动成长值（可正可负）',
  `growth_value_before` bigint(20) NOT NULL DEFAULT 0 COMMENT '变动前成长值',
  `growth_value_after` bigint(20) NOT NULL DEFAULT 0 COMMENT '变动后成长值',
  `change_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'increase' COMMENT '变动类型：increase/decrease',
  `source_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'manual' COMMENT '来源类型',
  `source_id` bigint(20) NULL DEFAULT NULL COMMENT '来源ID',
  `source_no` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '来源单号',
  `status` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'success' COMMENT '状态',
  `operator_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '操作人',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_growth_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_growth_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户成长值变动日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_growth_log
-- ----------------------------
INSERT INTO `sys_user_growth_log` VALUES (1, 1000107, 'nnd1', 1000, 0, 1000, 'increase', 'manual', NULL, NULL, 'success', 'admin', '测试奖励', '2026-05-03 20:19:08', '2026-05-03 20:19:08');
INSERT INTO `sys_user_growth_log` VALUES (2, 1000107, 'nnd1', 500, 0, 500, 'increase', 'manual', NULL, NULL, 'success', 'admin', NULL, '2026-05-03 20:24:59', '2026-05-03 20:24:59');
INSERT INTO `sys_user_growth_log` VALUES (3, 1000107, 'nnd1', 1500, 0, 1500, 'increase', 'manual', NULL, NULL, 'success', 'admin', NULL, '2026-05-03 20:25:32', '2026-05-03 20:25:32');
INSERT INTO `sys_user_growth_log` VALUES (4, 1000107, 'nnd1', 1500, 0, 1500, 'increase', 'manual', NULL, NULL, 'success', 'admin', NULL, '2026-05-03 20:26:21', '2026-05-03 20:26:21');
INSERT INTO `sys_user_growth_log` VALUES (5, 1000107, 'nnd1', 1500, 1500, 3000, 'increase', 'manual', NULL, NULL, 'success', 'admin', NULL, '2026-05-03 20:31:23', '2026-05-03 20:31:23');
INSERT INTO `sys_user_growth_log` VALUES (6, 1000107, 'nnd1', 5000, 3000, 8000, 'increase', 'manual', NULL, NULL, 'success', 'admin', NULL, '2026-05-03 20:31:46', '2026-05-03 20:31:46');

-- ----------------------------
-- Table structure for sys_user_level
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_level`;
CREATE TABLE `sys_user_level`  (
  `level_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '等级ID',
  `level` int(11) NOT NULL COMMENT '等级',
  `level_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '等级名称',
  `required_growth_value` bigint(20) NOT NULL DEFAULT 0 COMMENT '所需成长值',
  `invest_bonus` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '投资分红比例',
  `icon` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '等级图标',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`level_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_level_level`(`level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户等级表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_level
-- ----------------------------
INSERT INTO `sys_user_level` VALUES (11, 0, 'VIP.0', 0, 0.00, NULL, '0', 'admin', '2026-05-03 18:17:31', 'admin', '2026-05-03 18:42:43', NULL);
INSERT INTO `sys_user_level` VALUES (12, 1, 'VIP.1', 2000, 0.08, NULL, '0', 'admin', '2026-05-03 18:43:13', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (13, 2, 'VIP.2', 8000, 0.12, NULL, '0', 'admin', '2026-05-03 18:43:43', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (14, 3, 'VIP.3', 20000, 0.18, NULL, '0', 'admin', '2026-05-03 18:44:15', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (15, 4, 'VIP.4', 50000, 0.25, NULL, '0', 'admin', '2026-05-03 18:44:51', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (16, 5, 'VIP.5', 120000, 0.30, NULL, '0', 'admin', '2026-05-03 18:45:21', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (17, 6, 'VIP.6', 300000, 0.50, NULL, '0', 'admin', '2026-05-03 18:45:45', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (18, 7, 'VIP.7', 800000, 0.80, NULL, '0', 'admin', '2026-05-03 18:46:10', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (19, 8, 'VIP.8', 2000000, 1.00, NULL, '0', 'admin', '2026-05-03 18:46:35', '', NULL, NULL);
INSERT INTO `sys_user_level` VALUES (20, 9, 'VIP.9', 5000000, 2.00, NULL, '0', 'admin', '2026-05-03 18:46:50', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_user_miner
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_miner`;
CREATE TABLE `sys_user_miner`  (
  `user_miner_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户矿机ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `miner_id` bigint(20) NOT NULL COMMENT '矿机ID',
  `is_current` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否当前使用（0否 1是）',
  `claim_time` datetime NOT NULL COMMENT '领取时间',
  `active_time` datetime NULL DEFAULT NULL COMMENT '启用时间（开始使用时间）',
  `inactive_time` datetime NULL DEFAULT NULL COMMENT '停用时间（更换/停止时间）',
  `total_output_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '累计产出WAG（仅统计）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`user_miner_id`) USING BTREE,
  UNIQUE INDEX `uk_user_miner`(`user_id` ASC, `miner_id` ASC) USING BTREE COMMENT '同一用户同一矿机只领取一次',
  INDEX `idx_user_miner_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_miner_current`(`user_id` ASC, `is_current` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户矿机持有表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_miner
-- ----------------------------
INSERT INTO `sys_user_miner` VALUES (1, 1000107, 3, '1', '2026-05-03 20:35:31', '2026-05-03 20:35:31', NULL, 0.00000000, '0', '2026-05-03 20:35:31', '2026-05-03 20:35:31');

-- ----------------------------
-- Table structure for sys_user_miner_run
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_miner_run`;
CREATE TABLE `sys_user_miner_run`  (
  `run_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '运行记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_miner_id` bigint(20) NOT NULL COMMENT '用户矿机ID',
  `miner_id` bigint(20) NOT NULL COMMENT '矿机ID',
  `reward_mode` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收益模式快照（A自动 M手工）',
  `run_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '运行状态（0运行中 1待领取 2已结束）',
  `start_time` datetime NOT NULL COMMENT '本轮开始时间',
  `cycle_end_time` datetime NOT NULL COMMENT '本轮结束时间（start_time+24h）',
  `last_calc_time` datetime NULL DEFAULT NULL COMMENT '上次计算时间（定时任务更新）',
  `cycle_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '本轮应产出WAG（通常=矿机wag_per_day）',
  `produced_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '本轮已产出WAG',
  `credited_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '是否已入账（0否 1是）',
  `collect_time` datetime NULL DEFAULT NULL COMMENT '手工领取时间（手工模式）',
  `version` int(11) NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`run_id`) USING BTREE,
  INDEX `idx_miner_run_status_end`(`run_status` ASC, `cycle_end_time` ASC) USING BTREE,
  INDEX `idx_miner_run_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户矿机运行表（24小时一轮）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_miner_run
-- ----------------------------
INSERT INTO `sys_user_miner_run` VALUES (1, 1000107, 1, 3, 'A', '0', '2026-05-03 20:35:31', '2026-05-04 20:35:31', '2026-05-03 20:35:31', 500.00000000, 0.00000000, '0', NULL, 0, '2026-05-03 20:35:31', '2026-05-03 20:35:31');

-- ----------------------------
-- Table structure for sys_user_point_account
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_point_account`;
CREATE TABLE `sys_user_point_account`  (
  `point_account_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '积分账户ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `available_points` bigint(20) NOT NULL DEFAULT 0 COMMENT '可用积分',
  `frozen_points` bigint(20) NOT NULL DEFAULT 0 COMMENT '冻结积分',
  `total_earned` bigint(20) NOT NULL DEFAULT 0 COMMENT '累计获得积分',
  `total_spent` bigint(20) NOT NULL DEFAULT 0 COMMENT '累计消耗积分',
  `total_adjusted` bigint(20) NOT NULL DEFAULT 0 COMMENT '累计人工调整积分',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`point_account_id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_name`(`user_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户积分账户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_point_account
-- ----------------------------
INSERT INTO `sys_user_point_account` VALUES (1, 1, 'admin', 0, 0, 0, 0, 0, '2026-04-30 12:58:22', '2026-04-30 12:58:22');
INSERT INTO `sys_user_point_account` VALUES (2, 1000002, 'ry', 0, 0, 0, 0, 0, '2026-04-30 12:58:22', '2026-04-30 12:58:22');
INSERT INTO `sys_user_point_account` VALUES (3, 1000100, 'lanz', 610, 0, 610, 0, 0, '2026-04-30 12:58:22', '2026-05-01 12:06:13');
INSERT INTO `sys_user_point_account` VALUES (4, 1000102, 'test1', 300, 0, 300, 0, 0, '2026-04-30 12:58:22', '2026-05-01 16:22:21');
INSERT INTO `sys_user_point_account` VALUES (5, 1000107, 'nnd1', 300, 0, 300, 0, 0, '2026-05-02 13:55:12', '2026-05-02 13:55:12');

-- ----------------------------
-- Table structure for sys_user_point_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_point_log`;
CREATE TABLE `sys_user_point_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '账变ID',
  `point_account_id` bigint(20) NOT NULL COMMENT '积分账户ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `points` bigint(20) NOT NULL DEFAULT 0 COMMENT '变动积分',
  `points_before` bigint(20) NOT NULL DEFAULT 0 COMMENT '变动前积分',
  `points_after` bigint(20) NOT NULL DEFAULT 0 COMMENT '变动后积分',
  `change_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '变动类型：earn/spend/adjust/freeze/unfreeze',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务来源：invest/activity/redeem/lottery/manual',
  `source_id` bigint(20) NULL DEFAULT NULL COMMENT '业务来源ID',
  `source_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '业务单号',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'success' COMMENT '状态',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作人',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_point_account_id`(`point_account_id` ASC) USING BTREE,
  INDEX `idx_change_type`(`change_type` ASC) USING BTREE,
  INDEX `idx_source_type`(`source_type` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户积分账变表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_point_log
-- ----------------------------
INSERT INTO `sys_user_point_log` VALUES (1, 3, 1000100, 'lanz', 300, 0, 300, 'earn', 'sign', NULL, 'SG20260430142032A22C6B2E', 'success', 'lanz', 'Daily sign-in reward', '2026-04-30 14:20:32', '2026-04-30 14:20:32');
INSERT INTO `sys_user_point_log` VALUES (2, 3, 1000100, 'lanz', 310, 300, 610, 'earn', 'sign', NULL, 'SG20260501120613169CF60E', 'success', 'lanz', 'Daily sign-in reward', '2026-05-01 12:06:13', '2026-05-01 12:06:13');
INSERT INTO `sys_user_point_log` VALUES (3, 4, 1000102, 'test1', 300, 0, 300, 'earn', 'sign', NULL, 'SG2026050116222004EE57A1', 'success', 'test1', 'Daily sign-in reward', '2026-05-01 16:22:21', '2026-05-01 16:22:21');
INSERT INTO `sys_user_point_log` VALUES (4, 5, 1000107, 'nnd1', 300, 0, 300, 'earn', 'sign', NULL, 'SG20260502135512E0056358', 'success', 'nnd1', 'Daily sign-in reward', '2026-05-02 13:55:12', '2026-05-02 13:55:12');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1000001, 1);
INSERT INTO `sys_user_post` VALUES (1000002, 2);

-- ----------------------------
-- Table structure for sys_user_recharge
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_recharge`;
CREATE TABLE `sys_user_recharge`  (
  `recharge_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '充值ID',
  `order_no` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名',
  `currency_type` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'CNY' COMMENT '币种（CNY/USD）',
  `recharge_method` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'RMB' COMMENT '充值方式（RMB/USDT）',
  `amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '充值金额',
  `wallet_id` bigint(20) NULL DEFAULT NULL COMMENT '入账钱包ID',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态（0待审核 1已通过 2已拒绝）',
  `reject_reason` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_user_id` bigint(20) NULL DEFAULT NULL COMMENT '审核人ID',
  `review_user_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '审核人姓名',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`recharge_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_status_submit_time`(`status` ASC, `submit_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户充值表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_recharge
-- ----------------------------
INSERT INTO `sys_user_recharge` VALUES (1, 'RC202604291627591571ED42', 1000100, 'lanz', 'CNY', 'RMB', 1000.00, 3, 1, NULL, '2026-04-29 16:27:59', '2026-04-29 16:38:07', 1, 'admin', NULL, '2026-04-29 16:27:59', '2026-04-29 16:38:08');
INSERT INTO `sys_user_recharge` VALUES (2, 'RC20260429164115F8BD9AE8', 1000100, 'lanz', 'USD', 'USDT', 1000.00, 7, 1, NULL, '2026-04-29 16:41:16', '2026-04-29 16:41:48', 1, 'admin', NULL, '2026-04-29 16:41:16', '2026-04-29 16:41:48');
INSERT INTO `sys_user_recharge` VALUES (3, 'RC20260501232513794C53CC', 1000102, 'test1', 'CNY', 'RMB', 1000.00, 4, 1, NULL, '2026-05-01 23:25:14', '2026-05-01 23:25:35', 1, 'admin', NULL, '2026-05-01 23:25:14', '2026-05-01 23:25:36');
INSERT INTO `sys_user_recharge` VALUES (4, 'RC202605012325190B673EF9', 1000102, 'test1', 'USD', 'USDT', 1000.00, 8, 1, NULL, '2026-05-01 23:25:19', '2026-05-01 23:25:31', 1, 'admin', NULL, '2026-05-01 23:25:19', '2026-05-01 23:25:32');
INSERT INTO `sys_user_recharge` VALUES (5, 'RC202605012326260AC7D9FB', 1000102, 'test1', 'USD', 'USDT', 1000.00, 8, 1, NULL, '2026-05-01 23:26:26', '2026-05-01 23:26:45', 1, 'admin', NULL, '2026-05-01 23:26:26', '2026-05-01 23:26:45');
INSERT INTO `sys_user_recharge` VALUES (6, 'RC20260502142411A8351B14', 1000107, 'nnd1', 'CNY', 'RMB', 1000.00, 20, 1, NULL, '2026-05-02 14:24:11', '2026-05-02 14:25:26', 1, 'admin', NULL, '2026-05-02 14:24:11', '2026-05-02 14:25:26');
INSERT INTO `sys_user_recharge` VALUES (7, 'RC2026050214241601C29F0E', 1000107, 'nnd1', 'USD', 'USDT', 1000.00, 21, 1, NULL, '2026-05-02 14:24:16', '2026-05-02 14:25:23', 1, 'admin', NULL, '2026-05-02 14:24:16', '2026-05-02 14:25:23');
INSERT INTO `sys_user_recharge` VALUES (8, 'RC20260503192057034431E6', 1000107, 'nnd1', 'USD', 'USDT', 2000.00, 21, 1, NULL, '2026-05-03 19:20:58', '2026-05-03 19:23:43', 1, 'admin', NULL, '2026-05-03 19:20:58', '2026-05-03 19:23:44');
INSERT INTO `sys_user_recharge` VALUES (9, 'RC20260503192105A6D36E8C', 1000107, 'nnd1', 'CNY', 'RMB', 2000.00, 20, 1, NULL, '2026-05-03 19:21:06', '2026-05-03 19:23:39', 1, 'admin', NULL, '2026-05-03 19:21:06', '2026-05-03 19:23:39');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (1000002, 2);

-- ----------------------------
-- Table structure for sys_user_security_answer
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_security_answer`;
CREATE TABLE `sys_user_security_answer`  (
  `answer_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '答案ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `question_id` bigint(20) NOT NULL COMMENT '问题ID',
  `answer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '答案（加密存储）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`answer_id`) USING BTREE,
  UNIQUE INDEX `uk_user_question`(`user_id` ASC, `question_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户安全问题答案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_security_answer
-- ----------------------------
INSERT INTO `sys_user_security_answer` VALUES (3, 1000100, 3, '222', '2026-04-26 12:33:28', NULL);
INSERT INTO `sys_user_security_answer` VALUES (4, 1000100, 4, '222', '2026-04-26 12:33:28', NULL);
INSERT INTO `sys_user_security_answer` VALUES (5, 1000102, 1, '1', '2026-05-01 16:44:44', NULL);
INSERT INTO `sys_user_security_answer` VALUES (6, 1000102, 2, '1', '2026-05-01 16:44:44', NULL);
INSERT INTO `sys_user_security_answer` VALUES (7, 1000107, 1, '$2a$10$Tj.hNo/V6UX3dgMaO7MDs.Wo3kqJsGYKB58Ew0fgUENgZJs68SbGi', '2026-05-02 14:36:49', NULL);
INSERT INTO `sys_user_security_answer` VALUES (8, 1000107, 2, '$2a$10$SvpO4ypZPveKVyyvFJRFke/J5WU/AKdu4pl4kzsoLaKrSIjPKV/QG', '2026-05-02 14:36:49', NULL);

-- ----------------------------
-- Table structure for sys_user_sign_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_sign_log`;
CREATE TABLE `sys_user_sign_log`  (
  `sign_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '签到ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `sign_date` date NOT NULL COMMENT '签到日期',
  `consecutive_days` int(11) NOT NULL DEFAULT 1 COMMENT '连续签到天数',
  `reward_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'POINT' COMMENT '奖励类型',
  `reward_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '奖励金额',
  `source_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'sign' COMMENT '来源类型',
  `source_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '来源单号',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'success' COMMENT '状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`sign_id`) USING BTREE,
  UNIQUE INDEX `uk_user_sign_date`(`user_id` ASC, `sign_date` ASC) USING BTREE,
  INDEX `idx_user_sign_date`(`user_id` ASC, `sign_date` ASC) USING BTREE,
  INDEX `idx_source_no`(`source_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户签到记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_sign_log
-- ----------------------------
INSERT INTO `sys_user_sign_log` VALUES (1, 1000100, 'lanz', '2026-04-30', 1, 'POINT', 300.00, 'sign', 'SG20260430142032A22C6B2E', 'success', 'Daily sign-in reward', '2026-04-30 14:20:32', '2026-04-30 14:20:32');
INSERT INTO `sys_user_sign_log` VALUES (2, 1000100, 'lanz', '2026-05-01', 2, 'POINT', 310.00, 'sign', 'SG20260501120613169CF60E', 'success', 'Daily sign-in reward', '2026-05-01 12:06:13', '2026-05-01 12:06:13');
INSERT INTO `sys_user_sign_log` VALUES (3, 1000102, 'test1', '2026-05-01', 1, 'POINT', 300.00, 'sign', 'SG2026050116222004EE57A1', 'success', 'Daily sign-in reward', '2026-05-01 16:22:21', '2026-05-01 16:22:21');
INSERT INTO `sys_user_sign_log` VALUES (4, 1000107, 'nnd1', '2026-05-02', 1, 'POINT', 300.00, 'sign', 'SG20260502135512E0056358', 'success', 'Daily sign-in reward', '2026-05-02 13:55:12', '2026-05-02 13:55:12');

-- ----------------------------
-- Table structure for sys_user_wag_wallet
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_wag_wallet`;
CREATE TABLE `sys_user_wag_wallet`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `available_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '可兑换WAG余额',
  `total_earned_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '累计获得WAG',
  `total_exchanged_wag` decimal(18, 8) NOT NULL DEFAULT 0.00000000 COMMENT '累计兑换WAG',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户WAG钱包' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_wag_wallet
-- ----------------------------
INSERT INTO `sys_user_wag_wallet` VALUES (1000107, 0.00000000, 0.00000000, 0.00000000, '2026-05-03 18:48:14', '2026-05-03 18:48:14');

-- ----------------------------
-- Table structure for sys_user_wallet
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_wallet`;
CREATE TABLE `sys_user_wallet`  (
  `wallet_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '钱包ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `currency_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CNY' COMMENT '钱包币种（CNY/USD）',
  `total_invest` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '总投资金额',
  `available_balance` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
  `usd_exchange_quota` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '人民币可兑换美元额度',
  `frozen_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '冻结金额',
  `profit_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '收益金额',
  `pending_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '待收金额',
  `total_recharge` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '累计充值',
  `total_withdraw` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '累计提现',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`wallet_id`) USING BTREE,
  UNIQUE INDEX `uk_user_wallet_currency`(`user_id` ASC, `currency_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户钱包表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_wallet
-- ----------------------------
INSERT INTO `sys_user_wallet` VALUES (1, 1000001, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-04-25 15:17:46', '2026-04-25 22:43:08');
INSERT INTO `sys_user_wallet` VALUES (2, 1000002, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-04-25 15:17:46', '2026-04-25 22:43:11');
INSERT INTO `sys_user_wallet` VALUES (3, 1000100, 'CNY', 300.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 6000.00, 1500.00, '2026-04-25 15:17:46', '2026-05-01 15:16:22');
INSERT INTO `sys_user_wallet` VALUES (4, 1000102, 'CNY', 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, '2026-04-25 15:17:46', '2026-05-01 23:25:36');
INSERT INTO `sys_user_wallet` VALUES (5, 1000001, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-04-27 20:59:04', '2026-04-27 20:59:04');
INSERT INTO `sys_user_wallet` VALUES (6, 1000002, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-04-27 20:59:04', '2026-04-27 20:59:04');
INSERT INTO `sys_user_wallet` VALUES (7, 1000100, 'USD', 0.00, 2000.00, 0.00, 100.00, 0.00, 0.00, 2000.00, 0.00, '2026-04-27 20:59:04', '2026-04-29 22:21:34');
INSERT INTO `sys_user_wallet` VALUES (8, 1000102, 'USD', 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, '2026-04-27 20:59:04', '2026-05-01 23:26:45');
INSERT INTO `sys_user_wallet` VALUES (12, 1000103, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-01 17:12:19', '2026-05-01 17:12:19');
INSERT INTO `sys_user_wallet` VALUES (13, 1000103, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-01 17:12:19', '2026-05-01 17:12:19');
INSERT INTO `sys_user_wallet` VALUES (14, 1000104, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 12:39:41', '2026-05-02 12:39:41');
INSERT INTO `sys_user_wallet` VALUES (15, 1000104, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 12:39:41', '2026-05-02 12:39:41');
INSERT INTO `sys_user_wallet` VALUES (16, 1000105, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 12:47:54', '2026-05-02 12:47:54');
INSERT INTO `sys_user_wallet` VALUES (17, 1000105, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 12:47:54', '2026-05-02 12:47:54');
INSERT INTO `sys_user_wallet` VALUES (18, 1000106, 'CNY', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 13:08:40', '2026-05-02 13:08:40');
INSERT INTO `sys_user_wallet` VALUES (19, 1000106, 'USD', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '2026-05-02 13:08:40', '2026-05-02 13:08:40');
INSERT INTO `sys_user_wallet` VALUES (20, 1000107, 'CNY', 1500.00, 1500.00, 0.00, 0.00, 0.00, 0.00, 3000.00, 0.00, '2026-05-02 13:12:17', '2026-05-03 19:24:42');
INSERT INTO `sys_user_wallet` VALUES (21, 1000107, 'USD', 0.00, 3000.00, 0.00, 0.00, 0.00, 0.00, 3000.00, 0.00, '2026-05-02 13:12:17', '2026-05-03 19:23:44');

-- ----------------------------
-- Table structure for sys_user_wallet_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_wallet_log`;
CREATE TABLE `sys_user_wallet_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '账变ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `wallet_id` bigint(20) NOT NULL COMMENT '钱包ID',
  `currency_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CNY' COMMENT '钱包币种（CNY/USD）',
  `amount` decimal(18, 2) NOT NULL COMMENT '变动金额（正数增加，负数减少）',
  `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '变动类型：recharge(充值), withdraw(提现), invest(投资), profit(收益), frozen(冻结), unfrozen(解冻), other(其他)',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '状态：success(成功), pending(处理中), failed(失败)',
  `balance_before` decimal(18, 2) NOT NULL COMMENT '变动前余额',
  `balance_after` decimal(18, 2) NOT NULL COMMENT '变动后余额',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联订单号',
  `operator_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_wallet_id`(`wallet_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户账变表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_wallet_log
-- ----------------------------
INSERT INTO `sys_user_wallet_log` VALUES (1, 1000100, 3, 'CNY', 5000.00, 'recharge', 'success', 0.00, 5000.00, NULL, NULL, '', '2026-04-25 16:12:35', '2026-04-25 22:43:43');
INSERT INTO `sys_user_wallet_log` VALUES (2, 1000100, 7, 'USD', 1000.00, 'recharge', 'success', 0.00, 1000.00, NULL, NULL, '', '2026-04-29 14:22:18', '2026-04-29 14:22:18');
INSERT INTO `sys_user_wallet_log` VALUES (3, 1000100, 3, 'CNY', -1000.00, 'withdraw', 'success', 5000.00, 4000.00, NULL, 'admin', '', '2026-04-29 14:56:47', '2026-04-29 14:56:47');
INSERT INTO `sys_user_wallet_log` VALUES (4, 1000100, 3, 'CNY', 1000.00, 'recharge', 'success', 4000.00, 5000.00, 'RC202604291627591571ED42', 'admin', 'Recharge approved', '2026-04-29 16:38:07', '2026-04-29 16:38:07');
INSERT INTO `sys_user_wallet_log` VALUES (5, 1000100, 7, 'USD', 1000.00, 'recharge', 'success', 1000.00, 2000.00, 'RC20260429164115F8BD9AE8', 'admin', 'Recharge approved', '2026-04-29 16:41:48', '2026-04-29 16:41:48');
INSERT INTO `sys_user_wallet_log` VALUES (6, 1000100, 3, 'CNY', -500.00, 'frozen', 'pending', 5000.00, 4500.00, 'WD202604291910170BEA93F2', 'lanz', '提现提交并冻结金额', '2026-04-29 19:10:18', '2026-04-29 19:10:18');
INSERT INTO `sys_user_wallet_log` VALUES (7, 1000100, 7, 'USD', -500.00, 'frozen', 'pending', 2000.00, 1500.00, 'WD20260429191031064EFDDB', 'lanz', '提现提交并冻结金额', '2026-04-29 19:10:31', '2026-04-29 19:10:31');
INSERT INTO `sys_user_wallet_log` VALUES (8, 1000100, 7, 'USD', 500.00, 'unfrozen', 'success', 1500.00, 2000.00, 'WD20260429191031064EFDDB', 'admin', '提现审核拒绝，冻结金额已解冻', '2026-04-29 19:11:30', '2026-04-29 19:11:30');
INSERT INTO `sys_user_wallet_log` VALUES (9, 1000100, 3, 'CNY', 0.00, 'withdraw', 'success', 4500.00, 4500.00, 'WD202604291910170BEA93F2', 'admin', '提现审核通过，冻结金额已扣除', '2026-04-29 19:11:35', '2026-04-29 19:11:35');
INSERT INTO `sys_user_wallet_log` VALUES (10, 1000100, 7, 'USD', -100.00, 'frozen', 'pending', 2000.00, 1900.00, 'WD20260429210352EDC579DA', 'lanz', '提现提交并冻结金额', '2026-04-29 21:03:52', '2026-04-29 21:03:52');
INSERT INTO `sys_user_wallet_log` VALUES (11, 1000100, 3, 'CNY', 700.00, 'exchange_out', 'success', 4500.00, 3800.00, 'EX20260429221219EC6BC4FA', 'lanz', 'Exchange out: CNY to USD', '2026-04-29 22:12:19', '2026-04-29 22:12:19');
INSERT INTO `sys_user_wallet_log` VALUES (12, 1000100, 7, 'USD', 100.00, 'exchange_in', 'success', 1900.00, 2000.00, 'EX20260429221219EC6BC4FA', 'lanz', 'Exchange in: CNY to USD', '2026-04-29 22:12:19', '2026-04-29 22:12:19');
INSERT INTO `sys_user_wallet_log` VALUES (13, 1000100, 7, 'USD', 500.00, 'exchange_out', 'success', 2000.00, 1500.00, 'EX20260429222113A6398E60', 'lanz', 'Exchange out: USD to CNY', '2026-04-29 22:21:14', '2026-04-29 22:21:14');
INSERT INTO `sys_user_wallet_log` VALUES (14, 1000100, 3, 'CNY', 3500.00, 'exchange_in', 'success', 3800.00, 7300.00, 'EX20260429222113A6398E60', 'lanz', 'Exchange in: USD to CNY', '2026-04-29 22:21:14', '2026-04-29 22:21:14');
INSERT INTO `sys_user_wallet_log` VALUES (15, 1000100, 3, 'CNY', 3500.00, 'exchange_out', 'success', 7300.00, 3800.00, 'EX202604292221343C39F357', 'lanz', 'Exchange out: CNY to USD', '2026-04-29 22:21:34', '2026-04-29 22:21:34');
INSERT INTO `sys_user_wallet_log` VALUES (16, 1000100, 7, 'USD', 500.00, 'exchange_in', 'success', 1500.00, 2000.00, 'EX202604292221343C39F357', 'lanz', 'Exchange in: CNY to USD', '2026-04-29 22:21:34', '2026-04-29 22:21:34');
INSERT INTO `sys_user_wallet_log` VALUES (17, 1000100, 3, 'CNY', 1400.00, 'invest', 'success', 3800.00, 2400.00, 'YB1777607987816731ccba6', 'lanz', 'Yebao purchase', '2026-05-01 11:59:48', '2026-05-01 11:59:48');
INSERT INTO `sys_user_wallet_log` VALUES (18, 1000100, 3, 'CNY', 300.00, 'invest', 'success', 2400.00, 2100.00, 'YB177760889708566eae707', 'lanz', 'Yebao purchase', '2026-05-01 12:14:57', '2026-05-01 12:14:57');
INSERT INTO `sys_user_wallet_log` VALUES (19, 1000100, 3, 'CNY', 300.00, 'redeem', 'success', 2100.00, 2400.00, 'YB177760889708566eae707', 'lanz', 'Yebao redeem', '2026-05-01 12:18:41', '2026-05-01 12:18:41');
INSERT INTO `sys_user_wallet_log` VALUES (20, 1000100, 3, 'CNY', 1400.00, 'redeem', 'success', 2400.00, 3800.00, 'YB1777607987816731ccba6', 'lanz', 'Yebao redeem', '2026-05-01 12:19:25', '2026-05-01 12:19:24');
INSERT INTO `sys_user_wallet_log` VALUES (21, 1000100, 3, 'CNY', 300.00, 'invest', 'success', 3800.00, 3500.00, 'YB1777619781831d8681461', 'lanz', 'Yebao purchase', '2026-05-01 15:16:22', '2026-05-01 15:16:22');
INSERT INTO `sys_user_wallet_log` VALUES (22, 1000102, 8, 'USD', 1000.00, 'recharge', 'success', 0.00, 1000.00, 'RC202605012325190B673EF9', 'admin', 'Recharge approved', '2026-05-01 23:25:32', '2026-05-01 23:25:32');
INSERT INTO `sys_user_wallet_log` VALUES (23, 1000102, 4, 'CNY', 1000.00, 'recharge', 'success', 0.00, 1000.00, 'RC20260501232513794C53CC', 'admin', 'Recharge approved', '2026-05-01 23:25:36', '2026-05-01 23:25:36');
INSERT INTO `sys_user_wallet_log` VALUES (24, 1000102, 8, 'USD', 1000.00, 'recharge', 'success', 1000.00, 2000.00, 'RC202605012326260AC7D9FB', 'admin', 'Recharge approved', '2026-05-01 23:26:45', '2026-05-01 23:26:45');
INSERT INTO `sys_user_wallet_log` VALUES (25, 1000107, 21, 'USD', 1000.00, 'recharge', 'success', 0.00, 1000.00, 'RC2026050214241601C29F0E', 'admin', 'Recharge approved', '2026-05-02 14:25:23', '2026-05-02 14:25:23');
INSERT INTO `sys_user_wallet_log` VALUES (26, 1000107, 20, 'CNY', 1000.00, 'recharge', 'success', 0.00, 1000.00, 'RC20260502142411A8351B14', 'admin', 'Recharge approved', '2026-05-02 14:25:26', '2026-05-02 14:25:26');
INSERT INTO `sys_user_wallet_log` VALUES (27, 1000107, 20, 'CNY', 500.00, 'invest', 'success', 1000.00, 500.00, 'YB17777032462914e9c57d8', 'nnd1', 'Yebao purchase', '2026-05-02 14:27:26', '2026-05-02 14:27:26');
INSERT INTO `sys_user_wallet_log` VALUES (29, 1000107, 20, 'CNY', 2000.00, 'recharge', 'success', 500.00, 2500.00, 'RC20260503192105A6D36E8C', 'admin', 'Recharge approved', '2026-05-03 19:23:39', '2026-05-03 19:23:39');
INSERT INTO `sys_user_wallet_log` VALUES (30, 1000107, 21, 'USD', 2000.00, 'recharge', 'success', 1000.00, 3000.00, 'RC20260503192057034431E6', 'admin', 'Recharge approved', '2026-05-03 19:23:44', '2026-05-03 19:23:44');
INSERT INTO `sys_user_wallet_log` VALUES (31, 1000107, 20, 'CNY', 1000.00, 'invest', 'success', 2500.00, 1500.00, 'YB1777807481691b561adf8', 'nnd1', 'Yebao purchase', '2026-05-03 19:24:42', '2026-05-03 19:24:41');

-- ----------------------------
-- Table structure for sys_user_withdraw
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_withdraw`;
CREATE TABLE `sys_user_withdraw`  (
  `withdraw_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '提现ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `request_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Idempotency request number',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `currency_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'CNY' COMMENT '币种（CNY/USD）',
  `withdraw_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'BANK' COMMENT '提现方式（BANK/USDT）',
  `bank_card_id` bigint(20) NULL DEFAULT NULL COMMENT '银行卡ID',
  `bank_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '开户行',
  `account_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `account_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `wallet_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '钱包地址',
  `amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '提现金额',
  `wallet_id` bigint(20) NULL DEFAULT NULL COMMENT '钱包ID',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态（0待审核 1已通过 2已拒绝）',
  `reject_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_user_id` bigint(20) NULL DEFAULT NULL COMMENT '审核人ID',
  `review_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '审核人',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`withdraw_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_request_no`(`request_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_currency`(`user_id` ASC, `currency_type` ASC) USING BTREE,
  INDEX `idx_status_submit_time`(`status` ASC, `submit_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户提现表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_withdraw
-- ----------------------------
INSERT INTO `sys_user_withdraw` VALUES (3, 'WD202604291910170BEA93F2', 'WD202604291910170BEA93F2', 1000100, 'lanz', 'CNY', 'BANK', 1, '建设银行', '62332332222222', '张三', NULL, 500.00, 3, 1, NULL, '2026-04-29 19:10:18', '2026-04-29 19:11:35', 1, 'admin', NULL, '', '2026-04-29 19:10:18', '', '2026-04-29 19:11:35');
INSERT INTO `sys_user_withdraw` VALUES (4, 'WD20260429191031064EFDDB', 'WD20260429191031064EFDDB', 1000100, 'lanz', 'USD', 'USDT', 2, NULL, NULL, NULL, 'werewrdfsfsdfsdfdsfdsfdsfsd', 500.00, 7, 2, '退回', '2026-04-29 19:10:31', '2026-04-29 19:11:30', 1, 'admin', NULL, '', '2026-04-29 19:10:31', '', '2026-04-29 19:11:30');
INSERT INTO `sys_user_withdraw` VALUES (5, 'WD20260429210352EDC579DA', 'WD20260429210352EDC579DA', 1000100, 'lanz', 'USD', 'USDT', 2, NULL, NULL, NULL, 'werewrdfsfsdfsdfdsfdsfdsfsd', 100.00, 7, 0, NULL, '2026-04-29 21:03:52', NULL, NULL, NULL, NULL, '', '2026-04-29 21:03:52', '', '2026-04-29 21:03:52');

-- ----------------------------
-- Table structure for sys_yebao_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_yebao_config`;
CREATE TABLE `sys_yebao_config`  (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '配置名称',
  `annual_rate` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '年化利率',
  `unit_amount` decimal(18, 2) NOT NULL DEFAULT 100.00 COMMENT '每份金额',
  `growth_value_per_unit` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '每份成长值',
  `status` char(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '余额宝配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_yebao_config
-- ----------------------------
INSERT INTO `sys_yebao_config` VALUES (1, '余额宝默认配置', 44.03, 100.00, 0.1000, '0', 'admin', '2026-05-01 11:41:28', 'admin', '2026-05-03 19:53:05', '默认余额宝配置');

-- ----------------------------
-- Table structure for sys_yebao_income_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_yebao_income_log`;
CREATE TABLE `sys_yebao_income_log`  (
  `income_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '收益ID',
  `income_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收益流水号',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户名',
  `shares` int(11) NOT NULL DEFAULT 0 COMMENT '结算份数',
  `principal_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '本金金额',
  `annual_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '年化收益率(%)',
  `settle_days` int(11) NOT NULL DEFAULT 0 COMMENT '结算天数',
  `income_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '收益金额',
  `period_start_time` datetime NOT NULL COMMENT '区间开始',
  `period_end_time` datetime NOT NULL COMMENT '区间结束',
  `settle_time` datetime NOT NULL COMMENT '结算时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0成功 1失败）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`income_id`) USING BTREE,
  UNIQUE INDEX `uk_yebao_income_no`(`income_no` ASC) USING BTREE,
  INDEX `idx_yebao_income_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_yebao_income_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_yebao_income_settle_time`(`settle_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '余额宝收益流水表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_yebao_income_log
-- ----------------------------
INSERT INTO `sys_yebao_income_log` VALUES (1, 'YI177780526279673d65b5c', 3, 'YB1777619781831d8681461', 1000100, '', 3, 300.00, 44.0300, 2, 0.72, '2026-05-01 15:16:22', '2026-05-03 15:16:22', '2026-05-03 18:47:42', '0', 'system', '2026-05-03 18:47:42', '', NULL, 'Yebao daily settlement');
INSERT INTO `sys_yebao_income_log` VALUES (2, 'YI17778052647296118c5ac', 4, 'YB17777032462914e9c57d8', 1000107, '', 5, 500.00, 44.0300, 1, 0.60, '2026-05-02 14:27:26', '2026-05-03 14:27:26', '2026-05-03 18:47:43', '0', 'system', '2026-05-03 18:47:43', '', NULL, 'Yebao daily settlement');

-- ----------------------------
-- Table structure for sys_yebao_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_yebao_order`;
CREATE TABLE `sys_yebao_order`  (
  `order_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户名',
  `shares` int(11) NOT NULL DEFAULT 0 COMMENT '购买份数',
  `unit_amount` decimal(18, 2) NOT NULL DEFAULT 100.00 COMMENT '每份金额',
  `principal_amount` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '本金金额',
  `annual_rate` decimal(10, 4) NOT NULL DEFAULT 0.0000 COMMENT '下单时年化收益率(%)',
  `settled_income` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '已结算收益',
  `invest_time` datetime NOT NULL COMMENT '购买时间',
  `last_settle_time` datetime NOT NULL COMMENT '上次结算时间',
  `next_settle_time` datetime NOT NULL COMMENT '下次结算时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0' COMMENT '状态（0持有 1已赎回）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_yebao_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_yebao_order_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_yebao_order_status`(`status` ASC) USING BTREE,
  INDEX `idx_yebao_order_next_settle`(`next_settle_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '余额宝订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_yebao_order
-- ----------------------------
INSERT INTO `sys_yebao_order` VALUES (1, 'YB1777607987816731ccba6', 1000100, 'lanz', 14, 100.00, 1400.00, 3.6500, 0.00, '2026-05-01 11:59:48', '2026-05-01 11:59:48', '2026-05-02 11:59:48', '1', 'lanz', '2026-05-01 11:59:48', 'lanz', '2026-05-01 12:19:24', 'Yebao purchase');
INSERT INTO `sys_yebao_order` VALUES (2, 'YB177760889708566eae707', 1000100, 'lanz', 3, 100.00, 300.00, 44.0300, 0.00, '2026-05-01 12:14:57', '2026-05-01 12:14:57', '2026-05-02 12:14:57', '1', 'lanz', '2026-05-01 12:14:57', 'lanz', '2026-05-01 12:18:40', 'Yebao purchase');
INSERT INTO `sys_yebao_order` VALUES (3, 'YB1777619781831d8681461', 1000100, 'lanz', 3, 100.00, 300.00, 44.0300, 0.72, '2026-05-01 15:16:22', '2026-05-01 15:16:22', '2026-05-04 15:16:22', '0', 'lanz', '2026-05-01 15:16:22', 'system', '2026-05-03 18:47:42', 'Yebao purchase');
INSERT INTO `sys_yebao_order` VALUES (4, 'YB17777032462914e9c57d8', 1000107, 'nnd1', 5, 100.00, 500.00, 44.0300, 0.60, '2026-05-01 14:27:26', '2026-05-01 14:27:26', '2026-05-04 14:27:26', '0', 'nnd1', '2026-05-02 14:27:26', 'system', '2026-05-03 18:47:44', 'Yebao purchase');
INSERT INTO `sys_yebao_order` VALUES (5, 'YB1777807481691b561adf8', 1000107, 'nnd1', 10, 100.00, 1000.00, 44.0300, 0.00, '2026-05-01 19:24:42', '2026-05-01 19:24:42', '2026-05-04 19:24:42', '0', 'nnd1', '2026-05-03 19:24:42', '', NULL, 'Yebao purchase');

SET FOREIGN_KEY_CHECKS = 1;
