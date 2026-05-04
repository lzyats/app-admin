-- 投资合同样本配置（APP在线签约）
-- 后端读取键：app.invest.contract.template

INSERT INTO sys_config
(`config_name`,`config_key`,`config_value`,`config_type`,`create_by`,`create_time`,`remark`)
SELECT
  'APP投资合同样本',
  'app.invest.contract.template',
  '甲方（投资者）：${investorNo}\n乙方（平台方）：投资平台\n投资产品：${productName}\n投资金额：¥${amount}\n投资期限：${cycleDays}天\n预期收益率：${rate}%\n\n合同条款：\n1. 甲方同意按照本合同约定向乙方投资指定金额的资金。\n2. 乙方承诺按照约定的收益率和期限向甲方支付投资收益。\n3. 投资期间，甲方不得提前撤回投资资金。\n4. 如因不可抗力因素导致投资损失，双方共同承担风险。',
  'N',
  'admin',
  NOW(),
  'APP端在线签约投资合同模板'
WHERE NOT EXISTS (
  SELECT 1 FROM sys_config WHERE config_key = 'app.invest.contract.template'
);

UPDATE sys_config
SET config_name = 'APP投资合同样本',
    config_type = 'N',
    update_by = 'admin',
    update_time = NOW(),
    remark = 'APP端在线签约投资合同模板'
WHERE config_key = 'app.invest.contract.template';
