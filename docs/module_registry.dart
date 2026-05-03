class ModuleEntry {
  const ModuleEntry({
    required this.id,
    required this.name,
    required this.summary,
    this.docs = const [],
    this.apis = const [],
    this.backendFiles = const [],
    this.frontendFiles = const [],
    this.configKeys = const [],
    this.cacheKeys = const [],
    this.jobs = const [],
  });

  final String id;
  final String name;
  final String summary;
  final List<String> docs;
  final List<String> apis;
  final List<String> backendFiles;
  final List<String> frontendFiles;
  final List<String> configKeys;
  final List<String> cacheKeys;
  final List<String> jobs;
}

const List<ModuleEntry> moduleRegistry = [
  ModuleEntry(
    id: 'auth_login_register',
    name: 'APP 登录/注册',
    summary:
        'APP 使用 /app/auth/login 与 /app/auth/register，返回 token + user(轻量字段)，不涉及部门/菜单权限/路由；注册成功直接签发 token 实现自动登录；UI 后台仍使用 /login + /getInfo + /getRouters。',
    docs: [
      'docs/module_registry_login_register.md',
    ],
    apis: [
      'POST /app/auth/login',
      'POST /app/auth/register',
      'POST /login',
      'POST /register',
      'GET /getInfo',
      'GET /getRouters',
    ],
    backendFiles: [
      'ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppAuthController.java',
      'ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java',
      'ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java',
      'ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java',
      'ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/UserDetailsServiceImpl.java',
      'ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java',
    ],
    frontendFiles: [
      'app/lib/request/auth_api.dart',
      'app/lib/request/ruoyi_endpoints.dart',
      'app/lib/pages/auth/login/login_controller.dart',
      'app/lib/pages/auth/register/register_controller.dart',
      'app/lib/tools/auth_tool.dart',
    ],
    configKeys: [
      'sys.account.registerUser',
      'sys.account.captchaEnabled',
      'app.feature.inviteCodeEnabled',
    ],
    cacheKeys: [
      'captcha_codes:{uuid}',
      'pwd_err_cnt:{username}',
      'login_tokens:{clientType}:{uuid}',
    ],
  ),
  ModuleEntry(
    id: 'miner',
    name: '矿机(节点)',
    summary:
        '10分钟定时任务仅处理到期(24h)结算，不再每10分钟写 produced_wag；预估收益由前端根据 startTime/cycleEndTime/cycleWag 计算展示；/app/miner/overview 与 /app/miner/reward/logs 后端缓存5分钟，矿机启用列表缓存30分钟；领取接口幂等避免 uk_user_miner 冲突。',
    apis: [
      'GET /app/miner/overview',
      'GET /app/miner/available',
      'POST /app/miner/claim',
      'POST /app/miner/collect',
      'GET /app/miner/reward/logs',
      'POST /app/miner/exchange',
    ],
    backendFiles: [
      'ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppMinerController.java',
      'ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysMinerAppServiceImpl.java',
      'ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysMinerRunServiceImpl.java',
      'ruoyi-system/src/main/resources/mapper/system/SysUserMinerMapper.xml',
      'ruoyi-system/src/main/resources/mapper/system/SysUserMinerRunMapper.xml',
      'ruoyi-system/src/main/resources/mapper/system/SysMinerRewardLogMapper.xml',
    ],
    frontendFiles: [
      'app/lib/pages/mine/miner_page.dart',
      'app/lib/pages/mine/miner_claim_page.dart',
      'app/lib/pages/mine/miner_reward_logs_page.dart',
    ],
    configKeys: [
      'app.miner.rewardMode',
      'app.miner.wagToUsdRate',
      'app.currency.investMode',
    ],
    cacheKeys: [
      'miner:active:list',
      'miner:overview:{userId}',
      'miner:rewardLogs:{userId}',
    ],
    jobs: [
      'sys_job.invoke_target = minerTask.settle (cron: */10 * * * * ?)',
    ],
  ),
];
