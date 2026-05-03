class RuoYiEndpoints {
  const RuoYiEndpoints._();

  static const String login = '/login';
  static const String appLogin = '/app/auth/login';
  static const String register = '/register';
  static const String appRegister = '/app/auth/register';
  static const String captchaImage = '/captchaImage';
  static const String forgotPassword = '/app/auth/forgotPwd';
  static const String logout = '/logout';
  static const String appBootstrapConfig = '/app/config/bootstrap';
  static const String appConfigOptions = '/app/config/options';
  static const String getInfo = '/getInfo';
  static const String getRouters = '/getRouters';
  static const String user = '/system/user';
  static const String profile = '/system/user/profile';
  static const String dictType = '/system/dict/data/type/';

  static const String upload = '/common/upload';
  static const String uploadPresigned = '/common/upload/presigned';
  static const String uploadCallback = '/common/upload/callback';

  static const String upgradeConfig = '/app/upgrade/config';
  static const String inviteQr = '/app/invite/qr';

  static const String securityQuestions = '/app/auth/security/questions';
  static const String securityAnswers = '/app/user/security/answers';
  static const String securityAnswerCount = '/app/user/security/count';
  static const String securityVerify = '/app/user/security/verify';
  static const String securityHasSet = '/app/auth/security/hasSet';
  static const String forgotPwdBySecurity = '/app/auth/forgotPwdBySecurity';
  static const String forgotPasswordBySecurity = forgotPwdBySecurity;
  static const String getUserSecurityQuestions = '/app/auth/security/myQuestions';
  static const String getMySecurityAnswers = '/app/user/security/my';
  static const String saveSecurityQuestions = '/app/user/security/answers';

  static const String updatePassword = '/system/user/profile/updatePwd';
  static const String updatePasswordBySecurity = '/app/user/security/updatePwd';
  static const String updatePayPasswordBySecurity = '/app/user/security/updatePayPwd';
  static const String setPayPassword = '/system/user/setPayPwd';
  static const String updatePayPassword = '/system/user/updatePayPwd';
  static const String resetPayPassword = '/system/user/updatePayPwd';
  static const String verifyPayPassword = '/system/user/verifyPayPwd';

  static const String realNameStatus = '/app/auth/realName/status';
  static const String realNameSubmit = '/app/auth/realName/submit';

  static const String rechargeSubmit = '/app/recharge/submit';
  static const String rechargeList = '/app/recharge/list';

  static const String bankCardList = '/app/bankCard/list';
  static const String bankCardAdd = '/app/bankCard';
  static const String bankCardDelete = '/app/bankCard/delete';

  static const String appUserWallets = '/app/user/wallets';
  static const String appPointAccount = '/app/point/account';
  static const String appPointLogList = '/app/point/log/list';
  static const String appYebaoMy = '/app/yebao/my';
  static const String appYebaoOrders = '/app/yebao/orders';
  static const String appYebaoIncomes = '/app/yebao/incomes';
  static const String appYebaoPurchase = '/app/yebao/purchase';
  static const String appYebaoRedeem = '/app/yebao/redeem';

  static const String withdrawSubmit = '/app/withdraw/submit';
  static const String withdrawList = '/app/withdraw/list';

  static const String appUserExchangeCurrency = '/app/user/currency/exchange';
  static const String signStatus = '/app/sign/status';
  static const String signSubmit = '/app/sign/submit';
  static const String signConfig = '/app/sign/config';
  static const String newsCategories = '/app/news/categories';
  static const String newsList = '/app/news/list';
  static const String minerOverview = '/app/miner/overview';
  static const String minerAvailable = '/app/miner/available';
  static const String minerClaim = '/app/miner/claim';
  static const String minerCollect = '/app/miner/collect';
  static const String minerExchange = '/app/miner/exchange';
  static const String minerRewardLogs = '/app/miner/reward/logs';
  static const String minerExchangeLogs = '/app/miner/exchange/logs';
  static const String uploadAvatar = '/system/user/profile/avatar';
  static const String updateUserInfo = '/system/user/profile';
  static const String appUserLevelOptions = '/app/userLevel/options';
  static const String appTeamRewardInfo = '/app/team/reward/info';
  static const String appTeamStatsMe = '/app/team/stats/me';

  static String newsDetail(int articleId) => '/app/news/$articleId';
}
