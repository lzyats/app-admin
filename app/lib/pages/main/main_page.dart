import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/pages/mine/miner_page.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/widgets/app_network_image.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.onLocaleChanged,
    this.selectedLocale,
  });

  final Function(Locale)? onLocaleChanged;
  final Locale? selectedLocale;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildPlaceholder(i18n.t('tabHome'), Icons.home_rounded);
      case 1:
        return _buildPlaceholder(
            i18n.t('tabProduct'), Icons.calendar_view_month_rounded);
      case 2:
        return const MinerPage();
      case 3:
      default:
        return _MineTab(
          onLocaleChanged: widget.onLocaleChanged,
          selectedLocale: widget.selectedLocale,
        );
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 64, color: const Color(0xFF39E6FF)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFE9F3FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
              _buildNavItem(0, Icons.home_rounded, i18n.t('tabHome')),
              _buildNavItem(
                  1, Icons.calendar_view_month_rounded, i18n.t('tabProduct')),
              _buildNavItem(2, Icons.memory_rounded, i18n.t('tabMiner')),
              _buildNavItem(3, Icons.person_rounded, i18n.t('tabMine')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = const Color(0xFF39E6FF);
    final Color inactiveColor = const Color(0xFF9DB1C9);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
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

class _MineTab extends StatefulWidget {
  const _MineTab({
    this.onLocaleChanged,
    this.selectedLocale,
  });

  final Function(Locale)? onLocaleChanged;
  final Locale? selectedLocale;

  @override
  State<_MineTab> createState() => _MineTabState();
}

class _MineTabState extends State<_MineTab> {
  bool _hasCheckedSecurityQuestion = false;
  AuthUserProfile? _userInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final AuthUserProfile? cachedUser = await AuthTool.getUserProfile();
      if (cachedUser != null && cachedUser.userId > 0) {
        if (mounted) {
          setState(() {
            _userInfo = cachedUser;
            _loading = false;
          });
        }
        _checkSecurityQuestionSet();
      }

      final userInfo = await AuthApi.getInfo();
      await AuthTool.saveUserProfile(userInfo);
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _loading = false;
        });
      }
      _checkSecurityQuestionSet();
    } catch (e) {
      debugPrint('Failed to load mine user info: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkSecurityQuestionSet() async {
    if (_hasCheckedSecurityQuestion) {
      return;
    }
    _hasCheckedSecurityQuestion = true;

    try {
      final userInfo = _userInfo;
      if (userInfo == null || userInfo.userId <= 0) {
        _hasCheckedSecurityQuestion = false;
        return;
      }
      final int? securityQuestionSet = userInfo.securityQuestionSet;
      if (securityQuestionSet == 1) {
        return;
      }
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRouter.securityQuestionSet,
            ).then((_) {
              _hasCheckedSecurityQuestion = false;
              if (mounted) {
                _loadUserInfo();
              }
            });
          }
        });
      }
    } catch (_) {
      _hasCheckedSecurityQuestion = false;
    }
  }

  String get _displayName {
    if (_userInfo?.nickName != null && _userInfo!.nickName.isNotEmpty) {
      return _userInfo!.nickName;
    }
    if (_userInfo?.username != null && _userInfo!.username.isNotEmpty) {
      return _userInfo!.username;
    }
    return i18n.t('mineUserNameDefault');
  }

  String? get _avatarUrl => _userInfo?.resolvedAvatarUrl;

  Widget _buildPlainInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFFE9F3FF),
          fontSize: 12,
          fontFamily: 'monospace',
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override

  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0A1220),
            Color(0xFF0D1B2A),
            Color(0xFF14233A),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: _blurBall(
              size: 260,
              color: const Color(0x6639E6FF),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: _blurBall(
              size: 300,
              color: const Color(0x6638FFB3),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xCC101C30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x334CE3FF)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF39E6FF),
                                ),
                              ),
                            )
                          : Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _buildAvatar(),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: Text(
                                                  _displayName,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE9F3FF),
                                                    fontFamily: 'monospace',
                                                    letterSpacing: 0.3,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              _buildRealNameBadge(
                                                  _userInfo?.realNameStatus ??
                                                      -1),
                                              if (_userInfo?.level != null &&
                                                  _userInfo!.level! >
                                                      0) ...<Widget>[
                                                const SizedBox(width: 6),
                                                _buildLevelBadge(
                                                    _userInfo!.level!),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: _buildPlainInfoChip(
                                                    i18n.t('mineInviteCode'),
                                                    _userInfo!.inviteCode!),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white, size: 18),
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(
                                                      text: _userInfo!.inviteCode!));
                                                  if (!mounted) {
                                                    return;
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          i18n.t('copySuccess')),
                                                      backgroundColor:
                                                          const Color(0xFF38FFB3),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                },
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xCC101C30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x334CE3FF)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          _buildShortcutSection(
                            title: i18n.t('mineRelatedSection'),
                            items: <_MineShortcutItem>[
                              _MineShortcutItem(
                                icon: Icons.savings_outlined,
                                iconColor: const Color(0xFF39E6FF),
                                label: i18n.t('mineRecharge'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.recharge);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.account_balance_wallet_outlined,
                                iconColor: const Color(0xFF38FFB3),
                                label: i18n.t('mineWithdraw'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.withdraw);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.event_available_outlined,
                                iconColor: const Color(0xFFE2FF59),
                                label: i18n.t('signTitle'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.signIn);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.account_balance_wallet_rounded,
                                iconColor: const Color(0xFFFFA500),
                                label: i18n.t('mineAssetsNav'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.assets);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildShortcutSection(
                            title: '',
                            rowSpacing: 15,
                            items: <_MineShortcutItem>[
                              _MineShortcutItem(
                                icon: Icons.groups_outlined,
                                iconColor: const Color(0xFF39E6FF),
                                label: i18n.t('mineMyTeam'),
                                onTap: () {
                                  Navigator.pushNamed(context, AppRouter.myTeam);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.credit_card_outlined,
                                iconColor: const Color(0xFF38FFB3),
                                label: i18n.t('mineBankCard'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.bankCard);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.verified_user_outlined,
                                iconColor: const Color(0xFFE2FF59),
                                label: i18n.t('mineRealNameAuth'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.realNameAuth);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.savings_rounded,
                                iconColor: const Color(0xFFFFA500),
                                label: i18n.t('mineBalanceTreasure'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.balanceTreasure);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.trending_up_outlined,
                                iconColor: const Color(0xFF9DB1C9),
                                label: i18n.t('mineMyInvest'),
                                onTap: () => _showComingSoonSnackBar(
                                    context, i18n.t('mineFeatureComingSoon')),
                              ),
                              _MineShortcutItem(
                                icon: Icons.confirmation_num_outlined,
                                iconColor: const Color(0xFF39E6FF),
                                label: i18n.t('mineCoupon'),
                                onTap: () => _showComingSoonSnackBar(
                                    context, i18n.t('mineFeatureComingSoon')),
                              ),
                              _MineShortcutItem(
                                icon: Icons.person_add_alt_1_outlined,
                                iconColor: const Color(0xFF38FFB3),
                                label: i18n.t('mineInviteFriend'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.inviteFriend);
                                },
                              ),
                              _MineShortcutItem(
                                icon: Icons.workspace_premium_outlined,
                                iconColor: const Color(0xFFE2FF59),
                                label: i18n.t('mineLevelExperienceCoupon'),
                                onTap: () => _showComingSoonSnackBar(
                                    context, i18n.t('mineFeatureComingSoon')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: <Widget>[
                              _buildMineAction(
                                icon: Icons.person_outline,
                                iconColor: const Color(0xFF39E6FF),
                                label: i18n.t('mineProfileNav'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.mineProfile,
                                    arguments: _userInfo,
                                  ).then((_) {
                                    if (mounted) {
                                      _loadUserInfo();
                                    }
                                  });
                                },
                              ),
                              _buildMineAction(
                                icon: Icons.receipt_long_outlined,
                                iconColor: const Color(0xFF38FFB3),
                                label: i18n.locale.languageCode == 'zh'
                                    ? '账变记录'
                                    : 'Account Records',
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.accountChangeRecords);
                                },
                              ),
                              _buildMineAction(
                                icon: Icons.workspace_premium_outlined,
                                iconColor: const Color(0xFFE2FF59),
                                label: i18n.locale.languageCode == 'zh'
                                    ? '会员中心'
                                    : 'Member Center',
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.memberCenter);
                                },
                              ),
                              _buildMineAction(
                                icon: Icons.security_outlined,
                                iconColor: const Color(0xFFFFA500),
                                label: i18n.t('mineSecurityCenter'),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRouter.securityCenter);
                                },
                              ),
                              _buildMineAction(
                                icon: Icons.article_outlined,
                                iconColor: const Color(0xFF38FFB3),
                                label: i18n.t('mineNewsCenter'),
                                onTap: () {
                                  Navigator.pushNamed(context, AppRouter.news);
                                },
                              ),

                              _buildMineAction(
                                icon: Icons.settings_outlined,
                                iconColor: const Color(0xFF39E6FF),
                                label: i18n.t('mineSoftwareSettingNav'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.softwareSettings,
                                    arguments: {
                                      'onLocaleChanged': widget.onLocaleChanged,
                                      'selectedLocale': widget.selectedLocale,
                                    },
                                  );
                                },
                              ),
                              _buildMineAction(
                                icon: Icons.logout_outlined,
                                iconColor: const Color(0xFFFF6B6B),
                                label: i18n.t('mineLogoutNav'),
                                onTap: () async {
                                  await AuthTool.logout();
                                },
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurBall({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color,
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x5539E6FF),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF39E6FF).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: AppNetworkImage(
              src: _avatarUrl!,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultAvatar();
              },
            ),
          ),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E3A5F),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x5539E6FF),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 36,
        color: Color(0xFF39E6FF),
      ),
    );
  }

  Widget _buildRealNameBadge(int status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 1:
        color = const Color(0xFFFFA500);
        text = i18n.t('realNameStatusPending');
        icon = Icons.access_time;
        break;
      case 3:
        color = const Color(0xFF38FFB3);
        text = i18n.t('realNameStatusApproved');
        icon = Icons.verified_user;
        break;
      case 2:
        color = const Color(0xFFFF6B6B);
        text = i18n.t('realNameStatusRejected');
        icon = Icons.cancel;
        break;
      default:
        color = const Color(0xFF888888);
        text = i18n.t('realNameStatusNotSubmitted');
        icon = Icons.help_outline;
    }

    return Tooltip(
      message: _getRealNameStatusTooltip(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRealNameStatusTooltip(int status) {
    switch (status) {
      case 1:
        return i18n.t('realNamePendingDesc');
      case 3:
        return i18n.t('realNameApprovedDesc');
      case 2:
        return i18n.t('realNameRejectReason');
      default:
        return i18n.t('mineRealNameAuth');
    }
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9DB1C9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE9F3FF),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMineAction({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.15),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFFE9F3FF),
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDestructive
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF9DB1C9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutSection({
    required String title,
    required List<_MineShortcutItem> items,
    double rowSpacing = 0,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title.isNotEmpty) ...<Widget>[
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFE9F3FF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: rowSpacing,
              crossAxisSpacing: 6,
              mainAxisExtent: 58,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildShortcutItem(items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(_MineShortcutItem item) {
    return InkWell(
      onTap: item.onTap ??
          () =>
              _showComingSoonSnackBar(context, i18n.t('mineFeatureComingSoon')),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  item.iconColor.withOpacity(0.35),
                  item.iconColor.withOpacity(0.10),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: item.iconColor.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: item.iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 11,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFFA500),
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    final List<Color> levelColors = [
      const Color(0xFF9DB1C9),
      const Color(0xFF39E6FF),
      const Color(0xFF38FFB3),
      const Color(0xFFE2FF59),
      const Color(0xFFFFA500),
      const Color(0xFFFF6B6B),
    ];
    final List<String> levelNames = [
      '',
      'V1',
      'V2',
      'V3',
      'V4',
      'V5',
    ];
    final int colorIndex = level.clamp(0, levelColors.length - 1);
    final int nameIndex = level.clamp(0, levelNames.length - 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: levelColors[colorIndex].withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: levelColors[colorIndex]),
      ),
      child: Text(
        levelNames[nameIndex],
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: levelColors[colorIndex],
        ),
      ),
    );
  }

  Widget _buildCopyInviteCode(String inviteCode) {
    return GestureDetector(
      onTap: () async {
        await copyToClipboard(inviteCode);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('\u9080\u8bf7\u7801 $inviteCode \u5df2\u590d\u5236'),
              backgroundColor: const Color(0xFF38FFB3),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\u9080\u8bf7\u7801: $inviteCode',
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.copy,
              size: 14,
              color: Color(0xFF39E6FF),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineShortcutItem {
  const _MineShortcutItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
}
