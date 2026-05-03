class AppImages {
  AppImages._();

  static const String unionPay = 'assets/images/unionpay.webp';
  static const String usdt = 'assets/images/usdt.webp';
  static const String rmb = 'assets/images/rmb.webp';
  static const String usdtPurple = 'assets/images/usdt_purple.webp';
  static const String rmbPurple = 'assets/images/rmb_purple.webp';
  static const String signHero = 'assets/images/sign-hero.webp';
  static const String signButtonBg = 'assets/images/sign-button-bg.webp';
  static const String signSuccess = 'assets/images/sign-success.webp';
  static const String inviteTitle = 'assets/images/invite_friend_title.webp';
  static const String teamRewardBanner = 'assets/images/team_reward_banner.webp';

  static String currencyBrand(String currencyType, {bool usePurpleVariant = false}) {
    final String code = currencyType.toUpperCase();
    if (code == 'USD') {
      return usePurpleVariant ? usdtPurple : usdt;
    }
    return usePurpleVariant ? rmbPurple : unionPay;
  }
}
