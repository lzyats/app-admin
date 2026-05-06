import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/my_team_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/app_image_cache.dart';
import 'package:myapp/widgets/app_network_image.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  bool _loading = true;
  String? _error;
  AuthUserProfile? _profile;
  MyTeamStats _stats = const MyTeamStats(
    inviteCode: '',
    userLevel: 0,
    teamLeaderLevel: 0,
    totalAsset: 0,
    totalIncome: 0,
    directTotalCount: 0,
    directValidCount: 0,
    directValidRate: 0,
    teamTotalCount: 0,
    teamValidCount: 0,
    teamValidRate: 0,
  );
  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final AuthUserProfile profile = await AuthApi.getInfo();
      final MyTeamStats data = await MyTeamApi.getMyStats(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _stats = data;
        _loading = false;
      });
      unawaited(_warmAvatarCache(profile.resolvedAvatarUrl));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = i18n.t('loadFailed');
        _loading = false;
      });
    }
  }

  Future<void> _warmAvatarCache(String? avatarUrl) async {
    final String url = (avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return;
    }
    await AppImageCache.instance.prefetch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A2C),
      appBar: AppBar(
        title: Text(i18n.t('myTeamTitle')),
        centerTitle: true,
        backgroundColor: const Color(0xFF050A2C),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF070D36), Color(0xFF050A2C)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: TextButton(
                        onPressed: () => _load(forceRefresh: true),
                        child: Text(i18n.t('loadFailedRetryTap'), style: const TextStyle(color: Colors.white70)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(forceRefresh: true),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                        children: <Widget>[
                          _buildTopCard(context),
                          const SizedBox(height: 22),
                          _buildTitle(),
                          const SizedBox(height: 10),
                          _buildStatCard(
                            totalLabel: i18n.t('myTeamDirectTotal'),
                            totalValue: _stats.directTotalCount.toString(),
                            validLabel: i18n.t('myTeamDirectValid'),
                            validValue: _stats.directValidCount.toString(),
                            rate: _stats.directValidRate,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            totalLabel: i18n.t('myTeamAllTotal'),
                            totalValue: _stats.teamTotalCount.toString(),
                            validLabel: i18n.t('myTeamAllValid'),
                            validValue: _stats.teamValidCount.toString(),
                            rate: _stats.teamValidRate,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2A2CA7), Color(0xFF1D1E78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x80FFFFFF), width: 1.5),
                ),
                child: ClipOval(
                  child: (_profile?.resolvedAvatarUrl ?? '').isEmpty
                      ? Container(
                          color: const Color(0xFFEFF3FF),
                          child: const Icon(Icons.person, color: Color(0xFF6D78A8), size: 42),
                        )
                      : AppNetworkImage(
                          src: _profile!.resolvedAvatarUrl!,
                          fit: BoxFit.cover,
                          width: 72,
                          height: 72,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFEFF3FF),
                            child: const Icon(Icons.person, color: Color(0xFF6D78A8), size: 42),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${i18n.t('inviteCode')}:  ${_stats.inviteCode.isEmpty ? "--" : _stats.inviteCode}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF7A6431),
                          ),
                          child: Text(
                            'VIP.${_stats.userLevel}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.inviteFriend);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: <Color>[Color(0xFF8B4BFF), Color(0xFF2FB7FF)]),
                  ),
                  child: Text(i18n.t('myTeamInviteNow'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x4FFFFFFF)),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _amountItem(i18n.t('myTeamTotalAssetYuan'), _stats.totalAsset),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _amountItem(i18n.t('myTeamTotalIncome'), _stats.totalIncome),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.teamReward);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x804CE3FF)),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(i18n.t('teamReward')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Color(0x88D5DEFF), fontSize: 14)),
        const SizedBox(height: 10),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[Colors.transparent, Color(0xFF20C9FF)]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(i18n.t('myTeamStatsTitle'), style: const TextStyle(color: Colors.white, fontSize: 34 / 2, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: <Color>[Color(0xFF20C9FF), Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String totalLabel,
    required String totalValue,
    required String validLabel,
    required String validValue,
    required double rate,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x66172257),
        border: Border.all(color: const Color(0x44388FFF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(totalLabel, style: const TextStyle(color: Color(0x88D5DEFF), fontSize: 14)),
                const SizedBox(height: 10),
                Text(totalValue, style: const TextStyle(color: Colors.white, fontSize: 40 / 2, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(validLabel, style: const TextStyle(color: Color(0x88D5DEFF), fontSize: 14)),
                const SizedBox(height: 10),
                Text(validValue, style: const TextStyle(color: Colors.white, fontSize: 40 / 2, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _RateRing(rate: rate),
        ],
      ),
    );
  }
}

class _RateRing extends StatelessWidget {
  const _RateRing({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final double percent = (rate * 100).clamp(0, 100).toDouble();
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: rate.clamp(0, 1),
            strokeWidth: 6,
            backgroundColor: const Color(0x443E4FA6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF29D7FF)),
          ),
          Text('${percent.toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF55C5FF), fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }
}
