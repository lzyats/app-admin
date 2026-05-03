import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/upgrade_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/auth_tool.dart';

class InviteFriendPage extends StatefulWidget {
  const InviteFriendPage({super.key});

  @override
  State<InviteFriendPage> createState() => _InviteFriendPageState();
}

class _InviteFriendPageState extends State<InviteFriendPage> {
  late Future<_InviteFriendData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_InviteFriendData> _loadData() async {
    AuthUserProfile? user = await AuthTool.getUserProfile();
    if (user == null || user.userId <= 0) {
      user = await AuthApi.getInfo();
      await AuthTool.saveUserProfile(user);
    }

    final UpgradeConfig upgradeConfig = await UpgradeApi.fetchUpgradeConfig();
    final String qrContent = upgradeConfig.appUrl.trim().isNotEmpty
        ? upgradeConfig.appUrl.trim()
        : upgradeConfig.androidApkUrl.trim().isNotEmpty
            ? upgradeConfig.androidApkUrl.trim()
            : upgradeConfig.iosInstallUrl.trim();
    final String androidDownloadUrl = upgradeConfig.androidApkUrl.trim();
    final String iosDownloadUrl = upgradeConfig.iosInstallUrl.trim();

    return _InviteFriendData(
      user: user,
      qrContent: qrContent,
      androidDownloadUrl: androidDownloadUrl,
      iosDownloadUrl: iosDownloadUrl,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).t('inviteFriendCopySuccess')),
        backgroundColor: const Color(0xFF38FFB3),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) {
      return;
    }
    final Uri uri = Uri.parse(url.trim());
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF09072A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('inviteFriendTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -120,
            right: -90,
            child: _GlowOrb(size: 260, color: Color(0x2239E6FF)),
          ),
          const Positioned(
            top: 140,
            left: -100,
            child: _GlowOrb(size: 220, color: Color(0x2238FFB3)),
          ),
          SafeArea(
            child: FutureBuilder<_InviteFriendData>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<_InviteFriendData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorState(i18n);
                }
                return RefreshIndicator(
                  color: const Color(0xFF39E6FF),
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: 214,
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              minWidth: 0,
                              maxWidth: double.infinity,
                              minHeight: 0,
                              maxHeight: double.infinity,
                              child: Image.asset(
                                AppImages.inviteTitle,
                                width: MediaQuery.of(context).size.width - 20,
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: _buildInviteCard(
                              context,
                              i18n,
                              snapshot.data!,
                              AppBootstrapTool.config.inviteRewardRules,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: <Widget>[
                              _buildDownloadButton(
                                label: i18n.t('inviteFriendAndroidDownload'),
                                color: const Color(0xFF4968FF),
                                onTap: snapshot.data!.androidDownloadUrl.isEmpty
                                    ? null
                                    : () => _launchUrl(snapshot.data!.androidDownloadUrl),
                              ),
                              const SizedBox(height: 12),
                              _buildDownloadButton(
                                label: i18n.t('inviteFriendAppleDownload'),
                                color: const Color(0xFFFF4F74),
                                onTap: snapshot.data!.iosDownloadUrl.isEmpty
                                    ? null
                                    : () => _launchUrl(snapshot.data!.iosDownloadUrl),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations i18n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        const SizedBox(height: 140),
        const Icon(Icons.cloud_off_outlined, color: Color(0xFFFF6B6B), size: 56),
        const SizedBox(height: 12),
        Text(
          i18n.t('inviteFriendLoadFailed'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFEAF5FF),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          i18n.t('inviteFriendLoadFailedHint'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9DB1C9),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _refresh,
          child: Text(i18n.t('assetsRetry')),
        ),
      ],
    );
  }

  Widget _buildInviteCard(
    BuildContext context,
    AppLocalizations i18n,
    _InviteFriendData data,
    List<InviteRewardRule> rewardRules,
  ) {
    final String inviteCode = data.user.inviteCode?.trim().isNotEmpty == true
        ? data.user.inviteCode!.trim()
        : '--';
    final bool hasQr = data.qrContent.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3C4CC2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${i18n.t('inviteFriendCodeLabel')}: ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  inviteCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: inviteCode == '--' ? null : () => _copyText(inviteCode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFFA14CFF), Color(0xFF4094FF)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    i18n.t('inviteFriendCopy'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double size = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.of(context).size.width;
                    final double qrSize = (size - 28).toDouble();
                    if (hasQr) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: qrSize,
                          height: qrSize,
                          child: ColoredBox(
                            color: Colors.white,
                            child: PrettyQrView.data(
                              data: data.qrContent,
                              errorCorrectLevel: QrErrorCorrectLevel.M,
                              decoration: const PrettyQrDecoration(
                                background: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: qrSize,
                      height: qrSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFB7C7DE)),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 88, color: Color(0xFF3C4CC2)),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.teamReward);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3C4CC2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '查看推荐奖励',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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

  List<Widget> _buildRewardRules(BuildContext context, List<InviteRewardRule> rewardRules) {
    final List<InviteRewardRule> rules = rewardRules.isEmpty
        ? const <InviteRewardRule>[
            InviteRewardRule(level: 1, percent: 5, amount: 500),
            InviteRewardRule(level: 2, percent: 3, amount: 300),
            InviteRewardRule(level: 3, percent: 2, amount: 200),
          ]
        : rewardRules;
    return rules.map((InviteRewardRule rule) => _buildRuleLine(_formatRewardRuleText(context, rule))).toList();
  }

  String _formatRewardRuleText(BuildContext context, InviteRewardRule rule) {
    final bool isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    final String tierText = isZh ? _zhTierLabel(rule.level) : 'Level ${rule.level}';
    final String percentText = _formatNumber(rule.percent);
    final String amountText = _formatNumber(rule.amount);
    final String rewardText = isZh
        ? '上线可以奖励10000*$percentText%=$amountText'
        : 'referral reward: 10000*$percentText%=$amountText';
    return '$tierText $rewardText';
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _zhTierLabel(int level) {
    switch (level) {
      case 1:
        return '一级';
      case 2:
        return '二级';
      case 3:
        return '三级';
      case 4:
        return '四级';
      case 5:
        return '五级';
      default:
        return '第${level}级';
    }
  }

  Widget _buildRuleLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 8, color: Color(0xFF4A7DFF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4F5B73),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null ? color.withOpacity(0.35) : color,
          borderRadius: BorderRadius.circular(999),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color,
            blurRadius: size * 0.45,
            spreadRadius: size * 0.12,
          ),
        ],
      ),
    );
  }
}

class _InviteFriendData {
  const _InviteFriendData({
    required this.user,
    required this.qrContent,
    required this.androidDownloadUrl,
    required this.iosDownloadUrl,
  });

  final AuthUserProfile user;
  final String qrContent;
  final String androidDownloadUrl;
  final String iosDownloadUrl;
}
