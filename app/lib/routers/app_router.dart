import 'package:flutter/material.dart';

import 'package:myapp/pages/auth/forgot/forgot_page.dart';
import 'package:myapp/pages/auth/register/register_page.dart';
import 'package:myapp/pages/gateway/gateway_page.dart';
import 'package:myapp/pages/line/line_page.dart';
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
import 'package:myapp/pages/mine/account_recharge_records_page.dart';
import 'package:myapp/pages/mine/account_withdraw_records_page.dart';
import 'package:myapp/pages/mine/account_point_records_page.dart';
import 'package:myapp/pages/mine/member_center_page.dart';
import 'package:myapp/pages/mine/my_team_page.dart';
import 'package:myapp/pages/mine/team_reward_page.dart';
import 'package:myapp/pages/mine/vip_guide_page.dart';
import 'package:myapp/pages/mine/sign_page.dart';
import 'package:myapp/pages/mine/yebao_income_page.dart';
import 'package:myapp/pages/mine/yebao_orders_page.dart';
import 'package:myapp/pages/mine/yebao_page.dart';
import 'package:myapp/pages/mine/withdraw_page.dart';
import 'package:myapp/pages/mine/currency_exchange_page.dart';
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
  static const String accountRechargeRecords = '/mine/account/records/recharge';
  static const String accountWithdrawRecords = '/mine/account/records/withdraw';
  static const String accountPointRecords = '/mine/account/records/points';
  static const String memberCenter = '/mine/memberCenter';
  static const String myTeam = '/mine/memberCenter/myTeam';
  static const String vipGuide = '/mine/memberCenter/vipGuide';
  static const String teamReward = '/mine/memberCenter/teamReward';

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
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case recharge:
        return MaterialPageRoute(builder: (_) => const RechargePage());
      case withdraw:
        return MaterialPageRoute(builder: (_) => const WithdrawPage());
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
        return MaterialPageRoute(
          builder: (_) => SoftwareSettingsPage(
            onLocaleChanged: args?['onLocaleChanged'] as Function(Locale)?,
            selectedLocale: args?['selectedLocale'] as Locale?,
          ),
        );
      case realNameAuth:
        return MaterialPageRoute(builder: (_) => const RealNameAuthPage());
      case bankCard:
        return MaterialPageRoute(builder: (_) => const BankCardPage());
      case assets:
        return MaterialPageRoute(builder: (_) => const AssetsPage());
      case inviteFriend:
        return MaterialPageRoute(builder: (_) => const InviteFriendPage());
      case news:
        return MaterialPageRoute(builder: (_) => const NewsPage());
      case newsDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NewsDetailPage(
            article: args?['article'] as NewsArticle?,
          ),
        );
      case miner:
        return MaterialPageRoute(builder: (_) => const MinerPage());
      case minerClaim:
        return MaterialPageRoute(builder: (_) => const MinerClaimPage());
      case minerRewardLogs:
        return MaterialPageRoute(builder: (_) => const MinerRewardLogsPage());
      case minerExchangeLogs:
        return MaterialPageRoute(builder: (_) => const MinerExchangeLogsPage());
      case exchange:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CurrencyExchangePage(
            initialFromCurrency: args?['fromCurrency'] as String?,
          ),
        );
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignPage());
      case balanceTreasure:
        return MaterialPageRoute(builder: (_) => const YebaoPage());
      case balanceTreasureOrders:
        return MaterialPageRoute(builder: (_) => const YebaoOrdersPage());
      case balanceTreasureIncomes:
        return MaterialPageRoute(builder: (_) => const YebaoIncomePage());
      case accountChangeRecords:
        return MaterialPageRoute(builder: (_) => const AccountChangeRecordsPage());
      case accountRechargeRecords:
        return MaterialPageRoute(builder: (_) => const AccountRechargeRecordsPage());
      case accountWithdrawRecords:
        return MaterialPageRoute(builder: (_) => const AccountWithdrawRecordsPage());
      case accountPointRecords:
        return MaterialPageRoute(builder: (_) => const AccountPointRecordsPage());
      case memberCenter:
        return MaterialPageRoute(builder: (_) => const MemberCenterPage());
      case myTeam:
        return MaterialPageRoute(builder: (_) => const MyTeamPage());
      case vipGuide:
        return MaterialPageRoute(builder: (_) => const VipGuidePage());
      case teamReward:
        return MaterialPageRoute(builder: (_) => const TeamRewardPage());
      default:
        return null;
    }
  }
}
