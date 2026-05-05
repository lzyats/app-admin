/*
 Navicat Premium Data Transfer

 Source Server         : WS
 Source Server Type    : MySQL
 Source Server Version : 50744 (5.7.44-log)
 Source Host           : localhost:3306
 Source Schema         : fb

 Target Server Type    : MySQL
 Target Server Version : 50744 (5.7.44-log)
 File Encoding         : 65001

 Date: 05/05/2026 20:33:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin_users
-- ----------------------------
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '管理账号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号密码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1002 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '管理员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admin_users
-- ----------------------------
INSERT INTO `admin_users` VALUES (1001, 'admin', '$2y$10$vg7q8RDyF.4UWY/.c1G2Mun3e0pLTUpocytM5X7bXzOf0BZygzzC2');

-- ----------------------------
-- Table structure for biz_ok
-- ----------------------------
DROP TABLE IF EXISTS `biz_ok`;
CREATE TABLE `biz_ok`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `member_account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ok_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0,
  `buyer_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `extra` json NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_ok_key`(`ok_key`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_buyer`(`buyer_key`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_created`(`created_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5641 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订阅成功表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of biz_ok
-- ----------------------------

-- ----------------------------
-- Table structure for biz_query_result
-- ----------------------------
DROP TABLE IF EXISTS `biz_query_result`;
CREATE TABLE `biz_query_result`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '手机号',
  `biz_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '二维码key',
  `provider` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '渠道',
  `raw_status_1` int(11) NOT NULL DEFAULT 0 COMMENT '第一次查询原始qrCodeStatus',
  `raw_status_2` int(11) NOT NULL DEFAULT 0 COMMENT '第二次查询原始qrCodeStatus',
  `final_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '最终状态 0待定 1成功 2失败',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_provider_biz_key`(`provider`, `biz_key`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3307 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '二维码状态查询结果' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of biz_query_result
-- ----------------------------

-- ----------------------------
-- Table structure for blacklist_asn
-- ----------------------------
DROP TABLE IF EXISTS `blacklist_asn`;
CREATE TABLE `blacklist_asn`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID编号',
  `asn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ASN',
  `org` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组织',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'ASN / IDC 黑名单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blacklist_asn
-- ----------------------------

-- ----------------------------
-- Table structure for blacklist_ip
-- ----------------------------
DROP TABLE IF EXISTS `blacklist_ip`;
CREATE TABLE `blacklist_ip`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '黑名单IP-ID',
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IP',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '原因',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ip`(`ip`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'IP 黑名单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blacklist_ip
-- ----------------------------

-- ----------------------------
-- Table structure for blacklist_ua
-- ----------------------------
DROP TABLE IF EXISTS `blacklist_ua`;
CREATE TABLE `blacklist_ua`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID编号',
  `keyword` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关键词',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'User-Agent 黑名单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blacklist_ua
-- ----------------------------

-- ----------------------------
-- Table structure for buyers
-- ----------------------------
DROP TABLE IF EXISTS `buyers`;
CREATE TABLE `buyers`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '投手ID',
  `buyer_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手KEY',
  `source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手姓名',
  `pixel_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '像素ID',
  `access_token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'TOKEN',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `payout` decimal(10, 4) NULL DEFAULT 0.0000 COMMENT '金额',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `buyer_key`(`buyer_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10036 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '投手表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of buyers
-- ----------------------------
INSERT INTO `buyers` VALUES (10001, '1651948112878964', 'facebook', 'wina', '1651948112878964', 'EAA9Do1W0BSQBQZAa1vCtOPJi4FvEo57jzlKvOmOckfgqSv6a2IZAyyGnlx55LR5jS1WvZAtYKctdgZBydu7fXBITgK8bTAgjoFmWcSAPN6VWro44WxMzxDGCZAQix7MCYLcvBWa4wFrDyiV4VwEJUQRilzyaypZCmQUfj9WXgin9CeTHZAZAXL8HtwRtl6YstZCXpmwZDZD', 1, '2026-01-09 12:15:49', 0.0000);
INSERT INTO `buyers` VALUES (10002, '1953381462270882', 'facebook', 'winb', '1953381462270882', 'EAA9Do1W0BSQBQXzh4AyF0H1ZBwPbQ3g2neZC1eh3BBQtRWMEzf5ZAWmgS7audxHmYCmPmgsanePZA2ioT3aPbn8eNrSxPge5VuKXO8wsyQa0LurmEFwHnw9H1XnZAyQTrbIRxt21VswlPIkKN3VpHcyR7M17BIDk7flQYPKG6bJZAZBcfKttqLtlfSDLhmTALmVkwZDZD', 1, '2026-01-09 12:15:53', 0.0000);
INSERT INTO `buyers` VALUES (10003, '2092010268268868', 'facebook', '2092010268268868', '2092010268268868', 'EAA9Do1W0BSQBQdL3ZBsdsSTJZBaCDaKLrs4ZAPJdg6wAv3n7heND88UGAzNwV0teZBQADISBPxTSrvyzYAB5EKBgkO80JQemcIZBTZAMq738TfDrvfkK6jrEzQuh7F6ZBcxDYzfqy5ZArIPGBDhmy3uJTlLYVKy05U2NEnYZB3OdPJ0Cy0vxc0l4wUF6YsdotX7uOWAZDZD', 1, '2026-01-09 12:15:57', 0.0000);
INSERT INTO `buyers` VALUES (10004, '851202844322691', 'facebook', '851202844322691', '851202844322691', 'EAA9Do1W0BSQBQcofvOgxrN8NkatkeZACWYdp6O7XwULZBh7r0mhxdqVUNPZAG64qbbSAyspHAXzMbK4lbYCfV7d9lY72lW5CcNCJltZCLWxNNdx7t3sdf9Db94jyQHPiutZC9cobg6x6GQJPlbyNeh6ZC9IJZBHjZBZBQ2FmSqrnpYVkRU6ZAWHDBTreMZCc1ZBBvJRPZBwZDZD', 1, '2026-01-09 12:16:00', 0.0000);
INSERT INTO `buyers` VALUES (10007, '1568457124278938', 'facebook', 'jiangjun6', '1568457124278938', 'EAA9Do1W0BSQBQTPHgexGJsjvY4g3Ivo4zq56iQ5GP2qaZBZB4BeYdv0nnWmXnkt8CWzcO6hePBJXK1u7qxIefdG5MqbNKhd7Ke6MbZCUjEfSbce4rCZC28oARZB08ot6ZAREdgZBSpikyFM20s4F3OUMCVgAGMeQKiagAMpWCrnRLJgZBCyoNlmLIFSzTJfOZAgOQZAgZDZD', 1, '2026-01-09 12:16:02', 0.0000);
INSERT INTO `buyers` VALUES (10008, '4088953328022952', 'facebook', 'ffff11', '4088953328022952', 'EAA9Do1W0BSQBQSLwmsktrCIIpaxZB23FmIR4l8oKtUyoZCE0qMkBloyti0ZA6SZASYqpY0I1G2XsKDN4tjO0PgA2wwZAcEj9cRgCjEEbuQP9cTpzlRzhei3SXOtlur3otARmEkDJmI60jJsCtWRiTt0PlsWAtEUxKxvQSKTI9j2uuk6ae0rvelFA3Qn95g8MwtwZDZD', 1, '2026-01-09 12:16:05', 0.0000);
INSERT INTO `buyers` VALUES (10009, '2880789287658548', 'other', '色站APP', '2880789287658548', 'V74RUQU4FWO3T4VP8M7VCLBWNRYMGQBB764GGINS7JEENWT1W2PVER82TV5YF7N24LT4AF66HDA1IXC1MVGXIQEDOUIYT8TGA3WFPF69FFYYKNANVA3N4Y03GPSUMMIJDGP5AAW677BWHUF4MK1AJFNW2TVM0MO20G4EJ6IOAFJFK36B4KFCD3VVT9ILGR0OU4IEOLYAPP09', 1, '2026-01-09 12:16:24', 0.0000);
INSERT INTO `buyers` VALUES (10010, '1584532862878241', 'facebook', '1584532862878241', '1584532862878241', 'EAA9Do1W0BSQBQVWtyfeFSBYPbx1Q0NZAolTwU4ahKFOaFqWUY5ak0TEWhIUPBa9mumdls4vSBt3xGdPgZBrgRHdwdWaKZAvZAIIktsCQudulC8rCZChZBa1V6gLl0igFdA8E4lIvrOWaElXIZCBo0GW822b8HK1KwX8UR12ZBF94JbIAg6a5mpVDYqsRbtkvDKvZAOwZDZD', 1, '2026-01-10 14:56:49', 0.0000);
INSERT INTO `buyers` VALUES (10011, '870063152292423', 'facebook', '870063152292423', '870063152292423', 'EAAtmgvJp20cBQdYZAy9mlZAeRxGUL4MBjb87ZA1ryOZCkFj9FyZC9yfOzqXT1mVGx72TjfB181nwAAe0ZBaaIaOU3PhXxvVZC8lTvuVvnZAurm1RQeLZArdAoUvgJcXZC734r3lKrqLPTsZBYeQZCqYmymtRNvV0UhLynj4JtjwD3G7ZBZAQmo02ZAF423gm2UwGVTJgYb3YgZDZD', 1, '2026-01-10 15:22:31', 0.0000);
INSERT INTO `buyers` VALUES (10012, '1410225774114448', 'facebook', '1410225774114448', '1410225774114448', 'EAAdbghKlGh0BQUVM1CxsEeP7rVHEbhWrwsEBQKD1qKAm2XYITpItQVrBd4bomCGkHDuceRzZBqpPTZCTSImyDdv2vZAoIoTqAvt6OIuheRZCj6ZCCvzGxSoUZBnvjiVnQ2vAZBdRlVRA01Sd9eibT0Qk0kToPQgH7IaReZCUFPXukfHZCO6mE5obAZAhlspZC1vIIgGhgZDZD', 1, '2026-01-10 19:33:21', 0.0000);
INSERT INTO `buyers` VALUES (10013, '2289672608219922', 'facebook', '2289672608219922', '2289672608219922', 'EAAVobUIKL98BQYv6M5XgFJkcC3AaCV2db3GcbqUqLKDWsZCUBtvil0NxeUzyiT6QvustYqcVmPYkmdVUMDXCcbHOInjVbfzZAnIZCmW9VIPgYIzWZC9DgGyzORE81fyUO4zsFQ3w67iAl1VEcyvmhNZB4oID7lwqkVlszoL1ZBDNLFcmiSqZASQfNLTbNkp0AZDZD', 1, '2026-01-11 22:43:52', 0.0000);
INSERT INTO `buyers` VALUES (10014, '1268583055241244', 'facebook', '乌鸡', '1268583055241244', 'EAAR1WibYgfEBQyR4Iamf2uRjLbBzBOudUBKBIpxZCt765fmxeszlyXylfTVkdU6AQpuYOUxZASSZB6h97Mk7WI2wT4gfhc1Vpf1TyIs1Qte9ndC8SVGD63F57S8jUUDlZBNdmjry1oilOXPranr6ZB5zCAfhopNaLulcNIn3YmL0ScLrqjJjWwwfykR8sR0N9pwZDZD', 1, '2026-03-14 13:48:03', 0.0000);
INSERT INTO `buyers` VALUES (10015, '1573957213908761', 'facebook', '悟空', '1573957213908761', 'EAA3H5a4PISkBQ27M9zRegdOLrYCzYv32EF6Mv4iscM7vsurg4TzTK4TdANTQwJWJ5HxowQOX2zHMmJLcrB5ZAsUPUvZACkHyhJbWGqbUUTsvVPP1I3PiAnuB6ZCvfOmePA9QyDTCg1qGHwsxeTPm3kFosQUZAgucR9dZCFaUoozv8YwmdzOkxQ9gQGWvogwZDZD', 1, '2026-03-14 15:33:50', 0.0000);
INSERT INTO `buyers` VALUES (10016, '667672893037925', 'facebook', 'keke111', '667672893037925', 'LVZ53VHA0RI5TG1MHXXUN3VXJHZKFRFHHKXQHFXJVEICM8AA72HXED8J24IPO6VOK6QRYISATTHOUP1S0BCB8TOGZPEXBDSSAQ19Y7HF9XY68BORMO4PJUGS114VN4SNIRXRYAXA6SOP7ATULW9JYZECQ9CF67OC6XW7ZF749YXQS0KG9PNN3USDJNM5DKGM89LBU95O2KDF', 1, '2026-03-15 20:25:04', 0.0000);
INSERT INTO `buyers` VALUES (10017, '1317208440229265', 'facebook', 'QC', '1317208440229265', 'T72I9VEWAENA9KMHJZYNASU9VUOWXDKS7AUHAFB30XUZSJIXQMKQNLOPG24BYZ75WBF1Q73YU42291JXUO3121TGTZCP36VO0T9IKMEZ3LTNNCRJ8L4MS5KE330DENE6M9NPXJ3Y7MYS11YL24P5N8P79S39KD5D4EHHAMUI84OM8NGN16HRJ7Y3U7K8355T6YQBK8XUXGZW', 1, '2026-03-15 20:26:58', 0.0000);
INSERT INTO `buyers` VALUES (10018, '2002390447291622', 'facebook', '彬印度', '2002390447291622', 'T72I9VEWAENA9KMHJZYNASU9VUOWXDKS7AUHAFB30XUZSJIXQMKQNLOPG24BYZ75WBF1Q73YU42291JXUO3121TGTZCP36VO0T9IKMEZ3LTNNCRJ8L4MS5KE330DENE6M9NPXJ3Y7MYS11YL24P5N8P79S39KD5D4EHHAMUI84OM8NGN16HRJ7Y3U7K8355T6YQBK8XUXGZW', 1, '2026-04-05 21:33:22', 0.0000);
INSERT INTO `buyers` VALUES (10019, '1600720671143186', 'facebook', 'wujiqq', '1600720671143186', 'EAAW7jBWlMgABRHf6nKLSKBgEkyheZAux3WNClS9iIItcc1cmGhO0cRJ1gjO4ZAVTarLxqOpd6tjHrNWryyZCXK0CvwKZBOErLkP01YR0ZBmdR0D7VxtiUlyz4xuuOkLINVwzjiuSeof9jDMb3z2VUGbM44w0yPMTywhZCZBoMcGRBzvcYcFtjQ3Dygrj34RuAZDZD', 1, '2026-04-03 18:09:51', 0.0000);
INSERT INTO `buyers` VALUES (10020, '809480601715175', 'facebook', '彬别', '809480601715175', 'EAAXJwcPVg3UBRJBq1okcg0YHYWea41LYSZBH5R36VVdJmoLRjTO9HK2AchcKRLW9J4qzZBmGmOrXfkqAZA4arTQIdu8ItX84usuNKEW9rWDZCGdYdhXfkVOCgzDWtnfyTH0wScgpMAvKr2MmoNcZB0DRxuiSGPZC0XgZAN172aIOTlZBxIWlhkZBqAXfsqimAKr19lQZDZD', 1, '2026-04-04 01:12:58', 0.0000);
INSERT INTO `buyers` VALUES (10021, '1915633215756498', 'facebook', '大头', '1915633215756498', 'EAAd4bEGsProBRNfT0DUjKToMvdF9m8N30egyCit2TSYUw7s9jlHFeZC6ykD73FftLZC3BPlHfzr3f7qHJXiKfu8ZCKWYeMpyUzKrtpI5Jr7H271StjeuCw7AJVQ1LEvZCnRwKf9qeIs8xZAN8eTZCMN62xCixwni0YjD4Ffs7wG1yJvN2EDBVGcHbmc9q6vJbLlQZDZD', 1, '2026-04-05 21:31:21', 0.0000);
INSERT INTO `buyers` VALUES (10022, '1622588565458715', 'facebook', 'xiaoye1', '1622588565458715', 'EAAdbghKlGh0BRE1uZCPWTEDgOcanzt9TRAy071vnl7PiIeTTKo3tPPmDOcAtfBZAgGLuz4CDSNoAadEw8TGOOWZCldXTYkgZC3s6of0ZCLL8ZAcBHofC5ZA9s16AwZC1Kj6chfScbZBQ2IGD0xdPkUf4N6BHPp1TtherWqw5sbk9XXFFzI9R7OdZAjEZAdZB97rbBLhHKQZDZD', 1, '2026-04-06 00:06:29', 0.0000);
INSERT INTO `buyers` VALUES (10023, '1126744416252930', 'facebook', 'datou印度', '1126744416252930', 'EAAd4bEGsProBRJoO01Jnrp2uAPcZBqsdIi5KA8m8P39dLY45dtel2zQGSyDTnETfvkSZBK7SLTsm8dcZAt6ZCCRLI4TZAzmqrahSeOrcovx3QtukOypOzAo5y9ymNiTdSH7ZAZBaJxa4M9cDPiRnbmQAQhghZAZA7UEA6IJE0bFXR9eJzZCnfvsjm4q7LaR0hcEvvdNwZDZD', 1, '2026-04-06 02:25:57', 0.0000);
INSERT INTO `buyers` VALUES (10024, '3078574285660752', 'facebook', 'bin印度', '3078574285660752', 'EAANpJrMOX0wBRCNuYWECn7J7lL3wApPFyqeEikEN554DHqheJXbeNByo639BL6SAi1X57s33HPGdzytqbVFSur5ZCtNSBuKrSPhcmSiTBl6EpuxHvR0ptPggq5fRyXzkZABcRPOxUWsduJ61CGjvr9mZCnfGU5KdCmH1CHUE7NJTQyJNHD3BVry0ERZCbyRifgZDZD', 1, '2026-04-06 13:02:27', 0.0000);
INSERT INTO `buyers` VALUES (10025, '1534135294897820', 'facebook', '大头新全球', '1534135294897820', 'EAAWXFcCHbRwBRODaymxtcVFZAwTNUnZB4tzrZCcO0U14qV4bsUyHOocCBhZCCnaZCogHViqcQhcpa5ybP0f6HfpAi25Khe7vZAZBQOTOoWIXBmpYElLCp7n48l3BaZBoq1cieDtq19IT6rZBCwLxzdt3q86VZB7RVlZCeimuYKznF9LjGHI5GOtyNkkwHqQtmt5SvnnQAZDZD', 1, '2026-04-11 01:22:44', 0.0000);
INSERT INTO `buyers` VALUES (10026, '927026267058802', 'facebook', 'bin新全球', '927026267058802', 'EAAUsV2sz3skBRPaiylgTe88TjOKW5ptd5LK9WDfLY1j1OeZAvHbMhXBZCZBS5PF4C279apZCwRje1gNxFu5KWK5gpJpv99fDWImojVzuuOpQqr9TfrWHnHiPSyAzBvxTRHgaWvXgUQ6w8XqNmx8eCtoLqviGgj1ldkLhsN6gKzdCskA8LnxrQyzLPB8SZAUq1WQZDZD', 1, '2026-04-11 02:31:07', 0.0000);
INSERT INTO `buyers` VALUES (10027, '2015948183139390', 'facebook', '彬别qq', '2015948183139390', NULL, 1, '2026-04-13 17:23:58', 0.0000);
INSERT INTO `buyers` VALUES (10028, '1511623767295275', 'facebook', 'bin12', '1511623767295275', 'EAAfF9OgA6FgBRA1krj2KHtZBbEOneLLbhrKlo9mLnkpaC5GnN3ZCGmoA2uNN10ODGddyEDnatlt9fuhet3VLyPKVE5ZB7wstQvFH4aAskqmkUlnNPQZBIhCwgdvaXC6gqJfZBr7bRjElKcKsat8nzn0VFG86IDCcJAXWkRsCqWYW3XkE8CnX86U4JFpC6zDHA4QZDZD', 1, '2026-04-13 17:23:54', 0.0000);
INSERT INTO `buyers` VALUES (10029, '2122547545253503', 'facebook', '大头  新落地页', '2122547545253503', 'EAAiohyV9nfABRNsylLQF6sCOYZCngVJsYbI7hkPYyLzOVJH3KJ9aBZA4uvPoKx188azGtvWZA2cEU58LdOWa64ZCIq4QHgW0qXV37dGUFkY38zJk5dS1ME5an5OYhetYkkvZBSlTFBHDnb2ojWZAHV6tBlwm1S1QSp6eXU5InOkkrOqML8HrqXKbifdMQoz1UT8QZDZD', 1, '2026-04-13 21:14:13', 0.0000);
INSERT INTO `buyers` VALUES (10030, '1458410562593891', 'facebook', '文武Q', '1458410562593891', 'EAAiohyV9nfABRLG8x6og0ArY03maixb7ZB71Ql2TI0Kots1ML1VLVDaLJ4ZAZAObkl6BU5xFyHRZCEgctZBE4RDAmYFZBH4TPGI6bSnp35MYA6yT0JCmyEOJ9XVoOsmt1K3FQkZA8kOHsNSXNVl5uGGiyihkNAgAVYbV3lQAn4l7yWXeO9S4ZBijZCcZCyncqhygPBJAZDZD', 1, '2026-04-14 03:33:59', 0.0000);
INSERT INTO `buyers` VALUES (10031, '4215774762020749', 'facebook', '大头414', '4215774762020749', 'EAAfF9OgA6FgBRAiOZCNmxqXL6h26xDK5UQNamZAqCAeyy613B0HZBrYokwZCk2OZCz2DdGwHlZAuWsPfZAKb2L62nOLRjxwogPFS6kdpOuDNfQqic6IPAGoMqqGcilXBVsTTrPQoB0ySlFSrZBoAJZBq83m7qo36dpp0N0Fn50T8T9AmlCava9beYEddwZBN3ZASTqENAZDZD', 1, '2026-04-14 21:34:00', 0.0000);
INSERT INTO `buyers` VALUES (10032, '1307495914309509', 'facebook', '大头yy', '1307495914309509', 'EAAiohyV9nfABRKfffWiNZAEGHzzRMZAJiuLL806myOmaP4WWyITHbOW6eH7AAZCNoFsBJIvDOf3nZBIPdTttAUgl7jrW5yrnna9jJJRF8ZCPNEZBRDA3ZB4FgRfBzhLYuktc7KCX3GcxfrUFRo386RRtG9YPbD3qZBaMsZC8BEJO96hdEaMN1p9th1czWUHvnYWq42wZDZD', 1, '2026-04-15 18:36:20', 0.0000);
INSERT INTO `buyers` VALUES (10033, '1918230752229984', 'facebook', '测试', '1918230752229984', 'EAAUeY65vwZA8BRf2elTS6ZAnV2C6HzZA9LuaAOaCa7TkFgiBWx5kVUtHZCEVF6ZApHyFNdIFaG7FXHS5vQtEUuXSXkCgXWOxZCuDZAZAINMcfNBYwqP7JraetWvkdQMoSdav1LnBLhyarIqi4oJGcNVaOlekzIiVFqlgm9GCYPJvmqgLrbCVLT9xVv4gKimJ0AZDZD', 0, '2026-04-27 18:55:21', 0.0000);
INSERT INTO `buyers` VALUES (10034, '2268335804002974', 'facebook', 'WJ', '2268335804002974', 'EAAVKspZAKLtUBRRVKEykgRYIzCloZCQLogeM7koDGJC8Wb8fyXZAZAn5epjcMyDtZB1xWAo8nwXMO634MRdCHmPEZAvPAdZA6F1TbULzZCR7LimU3lZAQ6poKWu4fs3GZBNBY03xdZAIat8095ornccGZBlWZCHpJ3xZBInA3s3vbZCIvDdTsYap8BSB0iJSC97Typ4rAZDZD', 1, '2026-04-24 16:44:47', 0.0000);
INSERT INTO `buyers` VALUES (10035, '1304858848192633', 'facebook', '425US', '1304858848192633', 'EAAawpPg0wlkBRUqUmQTBqQy1eawaX8Aud0X9vqXZCi1kw3SYeqty4rMZBCPzv35OZC4HhCV4czYiUcZBeB3p4FZAze80ZBLz4F6FmwTWnbnH3FirM9AWgDZB1K6lyFZCLBwiI70yfQZBX8xt8VHqq2tK7sP7s4D2rNZAeUoricZApsYZCQV0ExAhgseYwoQhlmHnXrw6XwZDZD', 1, '2026-04-25 17:28:59', 0.0000);

-- ----------------------------
-- Table structure for country_rules
-- ----------------------------
DROP TABLE IF EXISTS `country_rules`;
CREATE TABLE `country_rules`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '编号ID',
  `buyer_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手KEY',
  `allowed_countries` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '允许国家',
  `blocked_countries` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '禁止国家',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '国家黑名单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of country_rules
-- ----------------------------

-- ----------------------------
-- Table structure for events
-- ----------------------------
DROP TABLE IF EXISTS `events`;
CREATE TABLE `events`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID编号',
  `event_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '事件ID',
  `a2c_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'A2C 验证码请求 key',
  `source` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'facebook' COMMENT '数据来源',
  `buyer_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手KEY',
  `event_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '事件名称',
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IP',
  `ua` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '浏览器',
  `country` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家',
  `value` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '值',
  `custom_data` json NULL COMMENT '数据',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `phone` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `hzf` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'as2' COMMENT '合作方',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_buyer_eventid`(`buyer_key`, `event_id`) USING BTREE,
  INDEX `buyer_key`(`buyer_key`) USING BTREE,
  INDEX `ip`(`ip`) USING BTREE,
  INDEX `event_name`(`event_name`) USING BTREE,
  INDEX `created_at`(`created_at`) USING BTREE,
  INDEX `idx_buyer_time`(`buyer_key`, `created_at`) USING BTREE,
  INDEX `idx_buyer_event_time`(`buyer_key`, `event_name`, `created_at`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_event_phone_time`(`phone`, `created_at`) USING BTREE,
  INDEX `idx_buyer_a2c_key`(`buyer_key`, `a2c_key`) USING BTREE,
  INDEX `idx_phone_a2c_key`(`phone`, `a2c_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 47374 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '事件表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of events
-- ----------------------------

-- ----------------------------
-- Table structure for mld_device_log
-- ----------------------------
DROP TABLE IF EXISTS `mld_device_log`;
CREATE TABLE `mld_device_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '手机号',
  `source_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手 buyer_key',
  `a2c_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'A2C key',
  `device_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '设备码',
  `qr_status` tinyint(4) NULL DEFAULT 0 COMMENT 'qrCodeStatus: 0=未查询,1=已生成,2=已扫码(登录成功),3=已过期,4=异常',
  `a2c_ok` tinyint(1) NULL DEFAULT 0 COMMENT '设备码是否成功',
  `logged_in` tinyint(1) NULL DEFAULT 0 COMMENT '是否已登录(qrCodeStatus=2)',
  `a2c_skipped` tinyint(1) NULL DEFAULT 0 COMMENT '是否跳过A2C(冷却期)',
  `ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IP',
  `country` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_source_id`(`source_id`) USING BTREE,
  INDEX `idx_created_at`(`created_at`) USING BTREE,
  INDEX `idx_logged_in`(`logged_in`) USING BTREE,
  INDEX `idx_a2c_key`(`a2c_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mld_device_log
-- ----------------------------

-- ----------------------------
-- Table structure for risk_logs
-- ----------------------------
DROP TABLE IF EXISTS `risk_logs`;
CREATE TABLE `risk_logs`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID编号',
  `buyer_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手KEY',
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `country` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '国家',
  `asn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ASN',
  `ua` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT 'User-Agent',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '原因',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `buyer_key`(`buyer_key`) USING BTREE,
  INDEX `ip`(`ip`) USING BTREE,
  INDEX `created_at`(`created_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 163 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '风控日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of risk_logs
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户密码',
  `role` enum('admin','buyer') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户规则',
  `buyer_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '投手KEY',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2y$10$zAJTLUMd6IDV/vtEN0FleORI4KgX6S9kiLp6r/upCOIBGD8eDkbzS', 'admin', NULL, 1, '2025-12-24 21:14:17');
INSERT INTO `users` VALUES (13, '1268583055241244', '$2y$10$oGvrpqBAVofn1Rz3F9dOHuxb5.J7ULqBrg5RXy2Ol7nV0G6LrII36', 'buyer', '1268583055241244', 1, '2026-03-14 13:48:03');
INSERT INTO `users` VALUES (14, '1573957213908761', '$2y$10$MSOYKpg6SKawFRuEGvG9ju1bOw2bSIYfzkdgAuLU5RVmxpgURJc2C', 'buyer', '1573957213908761', 1, '2026-03-14 15:33:50');
INSERT INTO `users` VALUES (15, '667672893037925', '$2y$10$ydUkaqqWkQcGxt7uwHq4iePy58l.NDdPutIyrTJGuWFvD2oXMlzwO', 'buyer', '667672893037925', 1, '2026-03-15 20:25:04');
INSERT INTO `users` VALUES (16, '1317208440229265', '$2y$10$krxWHAADyJOxz7LQlyzq1eGCFaN0hWivXklClxYGd7MRri31aoera', 'buyer', '1317208440229265', 1, '2026-03-15 20:26:59');
INSERT INTO `users` VALUES (17, '2002390447291622', '$2y$10$/7hXyeOo8L5Ga5OCxgmVIe9j0T8Yo4PH1/ZCLI/bReujM1DBdLAwi', 'buyer', '2002390447291622', 1, '2026-03-15 20:27:20');
INSERT INTO `users` VALUES (18, '1600720671143186', '$2y$10$zg8H.cYN8RhiVl4rrO6G8ewGRWz6Gtz3HYVQxGSuycq2DufmDEhlK', 'buyer', '1600720671143186', 1, '2026-04-03 18:09:51');
INSERT INTO `users` VALUES (19, '809480601715175', '$2y$10$UtKs8ll9KWcEm1OJ8TFNe.M1Tj2Nohfm8drSJFvo0QKEk1LIXwlr.', 'buyer', '809480601715175', 1, '2026-04-04 01:12:58');
INSERT INTO `users` VALUES (20, '1915633215756498', '$2y$10$aMcKn7bsr.pI5rSLvIh7uuUPZDvOCJCKM/B.hzw2ayaA/0M7EHOfy', 'buyer', '1915633215756498', 1, '2026-04-04 01:13:29');
INSERT INTO `users` VALUES (21, '1622588565458715', '$2y$10$LvQa6LyA0rwS7lQDlGNcMOW2G5aepvo.9aDBycJ9TEu6GTKAk5XRS', 'buyer', '1622588565458715', 1, '2026-04-06 00:06:29');
INSERT INTO `users` VALUES (22, '1126744416252930', '$2y$10$dkZ8AmUN6g6YQHO4XVT3ieR6VUniWhZxf83/6rieRQstMpbBI8hUa', 'buyer', '1126744416252930', 1, '2026-04-06 02:25:57');
INSERT INTO `users` VALUES (23, '3078574285660752', '$2y$10$V2B.8rVgPr16v0H9wgxajOMITnLNzUo66NtgCpTT99h63zoG4RtUG', 'buyer', '3078574285660752', 1, '2026-04-06 02:26:35');
INSERT INTO `users` VALUES (24, '1534135294897820', '$2y$10$p.tQwdf5GdeIfMep5Z1JmuFEgZF4P8zG/BRZH1/44QY5P/1lKVN0S', 'buyer', '1534135294897820', 1, '2026-04-11 01:22:44');
INSERT INTO `users` VALUES (25, '927026267058802', '$2y$10$UgxGG6FoC6ieMCre.hBopeu2OZWxR3fWgq0WkLJmHmIX5zWdIpm4i', 'buyer', '927026267058802', 1, '2026-04-11 02:31:07');
INSERT INTO `users` VALUES (26, '2015948183139390', '$2y$10$zEWJRBlN76KyWpQrrwlz8OFKWo8fqdap2p7Pb6uIapQ4QPqsFlWBa', 'buyer', '2015948183139390', 1, '2026-04-11 02:53:31');
INSERT INTO `users` VALUES (27, '1511623767295275', '$2y$10$URTBnO9fWRlFNhXO5h27fOM3toFuTqx65fOGOMIU3qXo5o836DZR6', 'buyer', '1511623767295275', 1, '2026-04-13 00:04:48');
INSERT INTO `users` VALUES (28, '2122547545253503', '$2y$10$xde0Tq8eVxe41S0glhNoo.oORqhGcuIqN4h2r62Q/iDvpy4WgjvDy', 'buyer', '2122547545253503', 1, '2026-04-13 17:24:49');
INSERT INTO `users` VALUES (29, '1458410562593891', '$2y$10$OErtGzL/FlUZ0MoBYKV2N./NxKKLnZ03ce/5jkE3drP.bNyp0t2M2', 'buyer', '1458410562593891', 1, '2026-04-14 03:33:59');
INSERT INTO `users` VALUES (30, '4215774762020749', '$2y$10$J44m.TrErsiY0hpDzZkX4.MOXGWP08Hbr2WbzM7831t0NmGUpNwPe', 'buyer', '4215774762020749', 1, '2026-04-14 21:34:00');
INSERT INTO `users` VALUES (31, '1307495914309509', '$2y$10$w4zZpOmFDpxLaWK9KKCKy.Xip3xHf2P5RzGQBXp5OdThVVL8reNIW', 'buyer', '1307495914309509', 1, '2026-04-15 18:36:20');
INSERT INTO `users` VALUES (32, '1918230752229984', '$2y$10$7xgBBSwLf4vIVeQk9il6AuyibzQoUbdJxvQZBDykAneX68jhJ7Plq', 'buyer', '1918230752229984', 1, '2026-04-24 15:03:58');
INSERT INTO `users` VALUES (33, '2268335804002974', '$2y$10$FqvxBImaRhsOhfIs8r9jK.m7wnOavkAoplgZL3Ly5UqOWPVQtB972', 'buyer', '2268335804002974', 1, '2026-04-24 16:44:47');
INSERT INTO `users` VALUES (34, '1304858848192633', '$2y$10$XH9.K.xeH4AJpt3ciN13ieZXpGdJ1.k60JuFoglS2a0PgHNGzwv2y', 'buyer', '1304858848192633', 1, '2026-04-25 17:28:59');

SET FOREIGN_KEY_CHECKS = 1;
