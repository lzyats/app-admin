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
  static const String investCardBg = 'assets/images/bg.webp';
  static const String investToken = 'assets/images/t.webp';
  static const String investContractStamp = 'assets/images/2.webp';
  static const String homeBanner1 = 'assets/images/home-banner.webp';
  static const String homeBanner2 = 'assets/images/home-banner2.webp';
  static const String homeLogo = 'assets/images/mlogo.webp';
  static const String homeLogo1 = 'assets/images/mylogo1.webp';

  static String currencyBrand(String currencyType, {bool usePurpleVariant = false}) {
    final String code = currencyType.toUpperCase();
    if (code == 'USD' || code == 'USDT') {
      return usePurpleVariant ? usdtPurple : usdt;
    }
    return usePurpleVariant ? rmbPurple : rmb;
  }
}
