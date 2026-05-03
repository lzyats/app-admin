import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/auth_tool.dart';

class SecurityCenterPage extends StatelessWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('mineSecurityCenter')),
        backgroundColor: const Color(0xFF0A1220),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0A1220),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    iconColor: const Color(0xFF39E6FF),
                    label: i18n.t('mineSecurityQuestion'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.securityQuestionSet,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFF38FFB3),
                    label: i18n.t('mineRealNameAuth'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.realNameAuth,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFFE2FF59),
                    label: i18n.t('mineLoginPassword'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.loginPasswordUpdate,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    iconColor: const Color(0xFFFFA500),
                    label: i18n.t('payPassword'),
                    onTap: () async {
                      AuthUserProfile? userInfo = await AuthTool.getUserProfile();
                      if (userInfo == null || userInfo.userId <= 0) {
                        userInfo = await AuthApi.getInfo();
                        await AuthTool.saveUserProfile(userInfo);
                      }
                      if (userInfo.userId > 0) {
                        if (context.mounted) {
                          final int? payPasswordSet = userInfo.payPasswordSet;
                          if (payPasswordSet == 1) {
                            Navigator.pushNamed(
                              context,
                              AppRouter.payPasswordUpdate,
                              arguments: {'userId': userInfo.userId},
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRouter.payPasswordSet,
                              arguments: {'userId': userInfo.userId},
                            );
                          }
                        }
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.more_horiz_outlined,
                    iconColor: const Color(0xFF9DB1C9),
                    label: i18n.t('mineOtherSettings'),
                    onTap: () {
                      _showComingSoon(context);
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE9F3FF),
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9DB1C9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 76),
      height: 1,
      color: const Color(0x334CE3FF),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中'),
        backgroundColor: Color(0xFFFFA500),
      ),
    );
  }
}
