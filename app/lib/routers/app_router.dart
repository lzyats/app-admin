import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/auth/forgot/forgot_page.dart';
import 'package:myapp/pages/auth/register/register_page.dart';
import 'package:myapp/pages/gateway/gateway_page.dart';
import 'package:myapp/pages/line/line_page.dart';
import 'package:myapp/pages/main/main_page.dart';
import 'package:myapp/pages/mine/profile_page.dart';
import 'package:myapp/pages/mine/pay_password_set_page.dart';
import 'package:myapp/pages/mine/pay_password_update_page.dart';
import 'package:myapp/pages/mine/login_password_update_page.dart';
import 'package:myapp/pages/mine/security_center_page.dart';
import 'package:myapp/pages/mine/security_question_set_page.dart';
import 'package:myapp/pages/mine/software_settings_page.dart';
import 'package:myapp/pages/mine/real_name_auth_page.dart';
import 'package:myapp/pages/mine/bank_card_page.dart';
import 'package:myapp/pages/mine/assets_page.dart';
import 'package:myapp/pages/mine/invite_friend_page.dart';
import 'package:myapp/pages/mine/news_detail_page.dart';
import 'package:myapp/pages/mine/news_page.dart';
import 'package:myapp/pages/mine/miner_page.dart';
import 'package:myapp/pages/mine/miner_claim_page.dart';
import 'package:myapp/pages/mine/miner_reward_logs_page.dart';
import 'package:myapp/pages/mine/miner_exchange_logs_page.dart';
import 'package:myapp/pages/mine/recharge_page.dart';
import 'package:myapp/pages/mine/account_change_records_page.dart';
import 'package:myapp/pages/mine/account_all_records_page.dart';
import 'package:myapp/pages/mine/account_recharge_records_page.dart';
import 'package:myapp/pages/mine/account_withdraw_records_page.dart';
import 'package:myapp/pages/mine/account_point_records_page.dart';
import 'package:myapp/pages/mine/account_invest_records_page.dart';
import 'package:myapp/pages/mine/member_center_page.dart';
import 'package:myapp/pages/mine/my_group_page.dart';
import 'package:myapp/pages/mine/my_team_page.dart';
import 'package:myapp/pages/mine/team_reward_page.dart';
import 'package:myapp/pages/mine/vip_guide_page.dart';
import 'package:myapp/pages/mine/sign_page.dart';
import 'package:myapp/pages/mine/yebao_income_page.dart';
import 'package:myapp/pages/mine/yebao_orders_page.dart';
import 'package:myapp/pages/mine/yebao_page.dart';
import 'package:myapp/pages/mine/my_invest_orders_page.dart';
import 'package:myapp/pages/mine/my_invest_income_page.dart';
import 'package:myapp/pages/mine/withdraw_page.dart';
import 'package:myapp/pages/mine/currency_exchange_page.dart';
import 'package:myapp/pages/product/invest_product_detail_page.dart';
import 'package:myapp/pages/product/invest_purchase_page.dart';
import 'package:myapp/pages/upgrade/upgrade_page.dart';
import 'package:myapp/request/news_api.dart';

class AppRouter {
  const AppRouter._();

  static const String upgrade = '/upgrade';
  static const String line = '/line';
  static const String gateway = '/gateway';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot';
  static const String mineProfile = '/mine/profile';
  static const String recharge = '/mine/recharge';
  static const String withdraw = '/mine/withdraw';
  static const String payPasswordSet = '/mine/payPassword/set';
  static const String payPasswordUpdate = '/mine/payPassword/update';
  static const String appConfigManage = '/mine/appConfigManage';
  static const String securityCenter = '/mine/securityCenter';
  static const String securityQuestionSet = '/mine/securityQuestion/set';
  static const String loginPasswordUpdate = '/mine/loginPassword/update';
  static const String softwareSettings = '/mine/softwareSettings';
  static const String realNameAuth = '/mine/realNameAuth';
  static const String bankCard = '/mine/bankCard';
  static const String assets = '/mine/assets';
  static const String inviteFriend = '/mine/inviteFriend';
  static const String news = '/mine/news';
  static const String newsDetail = '/mine/news/detail';
  static const String miner = '/mine/miner';
  static const String minerClaim = '/mine/miner/claim';
  static const String minerRewardLogs = '/mine/miner/rewardLogs';
  static const String minerExchangeLogs = '/mine/miner/exchangeLogs';
  static const String exchange = '/mine/exchange';
  static const String signIn = '/mine/signIn';
  static const String balanceTreasure = '/mine/balanceTreasure';
  static const String balanceTreasureOrders = '/mine/balanceTreasure/orders';
  static const String balanceTreasureIncomes = '/mine/balanceTreasure/incomes';
  static const String accountChangeRecords = '/mine/account/records';
  static const String accountAllRecords = '/mine/account/records/all';
  static const String accountRechargeRecords = '/mine/account/records/recharge';
  static const String accountWithdrawRecords = '/mine/account/records/withdraw';
  static const String accountPointRecords = '/mine/account/records/points';
  static const String accountInvestRecords = '/mine/account/records/invest';
  static const String memberCenter = '/mine/memberCenter';
  static const String myTeam = '/mine/memberCenter/myTeam';
  static const String myGroup = '/mine/memberCenter/myGroup';
  static const String vipGuide = '/mine/memberCenter/vipGuide';
  static const String teamReward = '/mine/memberCenter/teamReward';
  static const String investProductDetail = '/product/detail';
  static const String investPurchase = '/product/purchase';
  static const String investGroupPurchase = '/product/purchase/group';
  static const String myInvestOrders = '/mine/myInvest/orders';
  static const String myInvestIncomes = '/mine/myInvest/incomes';

  static bool _needBottomNav(RouteSettings settings) {
    final Object? args = settings.arguments;
    return args is Map && args['showBottomNav'] == true;
  }

  static Route<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page, {
    int navIndex = 3,
  }) {
    int selectedIndex = navIndex;
    final Object? args = settings.arguments;
    if (args is Map && args['showBottomNavIndex'] is int) {
      selectedIndex = (args['showBottomNavIndex'] as int).clamp(0, 3);
    }
    if (_needBottomNav(settings)) {
      return MaterialPageRoute(
        builder: (_) => _RouteWithBottomNav(
          child: page,
          navIndex: selectedIndex,
        ),
      );
    }
    return MaterialPageRoute(builder: (_) => page);
  }

  /// 鏍规嵁璺敱鍚嶇О鏋勫缓瀵瑰簲椤甸潰銆?
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case upgrade:
        return MaterialPageRoute(builder: (_) => const UpgradePage());
      case line:
        return MaterialPageRoute(builder: (_) => const LinePage());
      case gateway:
        return MaterialPageRoute(builder: (_) => const GatewayPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPage());
      case mineProfile:
        return _buildRoute(settings, const ProfilePage(), navIndex: 3);
      case recharge:
        return _buildRoute(settings, const RechargePage(), navIndex: 3);
      case withdraw:
        return _buildRoute(settings, const WithdrawPage(), navIndex: 3);
      case payPasswordSet:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PayPasswordSetPage(userId: args?['userId'] as int? ?? 0),
        );
      case payPasswordUpdate:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PayPasswordUpdatePage(userId: args?['userId'] as int? ?? 0),
        );
      case appConfigManage:
        return MaterialPageRoute(builder: (_) => const GatewayPage());
      case securityCenter:
        return MaterialPageRoute(builder: (_) => const SecurityCenterPage());
      case securityQuestionSet:
        return MaterialPageRoute(builder: (_) => const SecurityQuestionSetPage());
      case loginPasswordUpdate:
        return MaterialPageRoute(builder: (_) => const LoginPasswordUpdatePage());
      case softwareSettings:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings,
          SoftwareSettingsPage(
            onLocaleChanged: args?['onLocaleChanged'] as Function(Locale)?,
            selectedLocale: args?['selectedLocale'] as Locale?,
          ),
          navIndex: 3,
        );
      case realNameAuth:
        return _buildRoute(settings, const RealNameAuthPage(), navIndex: 3);
      case bankCard:
        return _buildRoute(settings, const BankCardPage(), navIndex: 3);
      case assets:
        return _buildRoute(settings, const AssetsPage(), navIndex: 3);
      case inviteFriend:
        return _buildRoute(settings, const InviteFriendPage(), navIndex: 3);
      case news:
        return _buildRoute(settings, const NewsPage(), navIndex: 3);
      case newsDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings,
          NewsDetailPage(
            article: args?['article'] as NewsArticle?,
          ),
          navIndex: 0,
        );
      case miner:
        return _buildRoute(settings, const MinerPage(), navIndex: 2);
      case minerClaim:
        return _buildRoute(settings, const MinerClaimPage(), navIndex: 2);
      case minerRewardLogs:
        return _buildRoute(settings, const MinerRewardLogsPage(), navIndex: 2);
      case minerExchangeLogs:
        return _buildRoute(settings, const MinerExchangeLogsPage(), navIndex: 2);
      case exchange:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CurrencyExchangePage(
            initialFromCurrency: args?['fromCurrency'] as String?,
          ),
        );
      case signIn:
        return _buildRoute(settings, const SignPage(), navIndex: 3);
      case balanceTreasure:
        return _buildRoute(settings, const YebaoPage(), navIndex: 3);
      case balanceTreasureOrders:
        return MaterialPageRoute(builder: (_) => const YebaoOrdersPage());
      case balanceTreasureIncomes:
        return MaterialPageRoute(builder: (_) => const YebaoIncomePage());
      case accountChangeRecords:
        return _buildRoute(settings, const AccountChangeRecordsPage(), navIndex: 3);
      case accountAllRecords:
        return MaterialPageRoute(builder: (_) => const AccountAllRecordsPage());
      case accountRechargeRecords:
        return MaterialPageRoute(builder: (_) => const AccountRechargeRecordsPage());
      case accountWithdrawRecords:
        return MaterialPageRoute(builder: (_) => const AccountWithdrawRecordsPage());
      case accountPointRecords:
        return MaterialPageRoute(builder: (_) => const AccountPointRecordsPage());
      case accountInvestRecords:
        return MaterialPageRoute(builder: (_) => const AccountInvestRecordsPage());
      case memberCenter:
        return _buildRoute(settings, const MemberCenterPage(), navIndex: 3);
      case myTeam:
        return _buildRoute(settings, const MyTeamPage(), navIndex: 3);
      case myGroup:
        return _buildRoute(settings, const MyGroupPage(), navIndex: 3);
      case vipGuide:
        return _buildRoute(settings, const VipGuidePage(), navIndex: 3);
      case teamReward:
        return _buildRoute(settings, const TeamRewardPage(), navIndex: 3);
      case investProductDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvestProductDetailPage(
            productId: (args?['productId'] as int?) ?? 0,
          ),
        );
      case investPurchase:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvestPurchasePage(
            productId: (args?['productId'] as int?) ?? 0,
            groupMode: false,
          ),
        );
      case investGroupPurchase:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvestPurchasePage(
            productId: (args?['productId'] as int?) ?? 0,
            groupMode: true,
          ),
        );
      case myInvestOrders:
        return _buildRoute(settings, const MyInvestOrdersPage(), navIndex: 3);
      case myInvestIncomes:
        return _buildRoute(settings, const MyInvestIncomePage(), navIndex: 3);
      default:
        return null;
    }
  }
}

class _RouteWithBottomNav extends StatelessWidget {
  const _RouteWithBottomNav({
    required this.child,
    required this.navIndex,
  });

  final Widget child;
  final int navIndex;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A1220),
          border: Border(
            top: BorderSide(
              color: Color(0x33FFFFFF),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(context, 0, navIndex, Icons.home_rounded, i18n.t('tabHome')),
                _buildNavItem(context, 1, navIndex, Icons.calendar_view_month_rounded, i18n.t('tabProduct')),
                _buildNavItem(context, 2, navIndex, Icons.memory_rounded, i18n.t('tabMiner')),
                _buildNavItem(context, 3, navIndex, Icons.person_rounded, i18n.t('tabMine')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    int selectedIndex,
    IconData icon,
    String label,
  ) {
    final bool isSelected = index == selectedIndex;
    const Color activeColor = Color(0xFF39E6FF);
    const Color inactiveColor = Color(0xFF9DB1C9);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => MainPage(initialIndex: index),
          ),
          (Route<dynamic> route) => false,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
