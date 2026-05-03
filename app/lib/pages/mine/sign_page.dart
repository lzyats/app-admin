import 'package:flutter/material.dart';

import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/sign_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/sign_config_cache_tool.dart';
import 'package:myapp/tools/sign_cache_tool.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _submitting = false;
  SignConfigResponse _config = const SignConfigResponse(
    rewardType: 'POINT',
    rewardAmount: 1,
    continuousRewardRule: '[]',
  );
  SignStatusResponse _status = const SignStatusResponse(
    signedToday: false,
    consecutiveDays: 0,
    rewardType: 'POINT',
    rewardAmount: 0,
    rewardLabel: '',
    records: <SignRecord>[],
  );

  AppLocalizations get i18n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  String _formatIntegerAmount(double value) {
    return value.round().toString();
  }

  String _rewardText(double amount, String rewardType) {
    final String unit = rewardType.toUpperCase() == 'MONEY'
        ? i18n.t('currencyYuan')
        : i18n.t('currencyPoints');
    return '+${_formatAmount(amount)}$unit';
  }

  Future<int> _currentUserId() async {
    final AuthUserProfile? profile = await AuthTool.getUserProfile();
    return profile?.userId ?? 0;
  }

  List<SignRewardRule> _rules() {
    final List<SignRewardRule> rules = _config.continuousRewardRules;
    if (rules.isNotEmpty) {
      return rules;
    }
    return <SignRewardRule>[
      SignRewardRule(day: 1, amount: _config.rewardAmount),
    ];
  }

  int _activeRuleDay() {
    final List<SignRewardRule> rules = _rules();
    if (rules.isEmpty) {
      return 1;
    }
    final int maxDay = rules.last.day;
    if (_status.consecutiveDays <= 0) {
      return 1;
    }
    if (_status.consecutiveDays > maxDay) {
      return maxDay;
    }
    return _status.consecutiveDays;
  }

  double _currentRewardAmount() {
    final List<SignRewardRule> rules = _rules();
    if (rules.isEmpty) {
      return _config.rewardAmount;
    }
    final int day = _status.signedToday ? _status.consecutiveDays : (_status.consecutiveDays + 1);
    SignRewardRule selected = rules.first;
    for (final SignRewardRule rule in rules) {
      if (day >= rule.day) {
        selected = rule;
      } else {
        break;
      }
    }
    return selected.amount;
  }

  Future<void> _loadPageData({bool forceRemote = false}) async {
    try {
      final int userId = await _currentUserId();
      final String today = _todayKey();
      SignStatusResponse? cachedStatus;
      SignConfigResponse? cachedConfig;
      if (!forceRemote) {
        final String? cached = await SignCacheTool.getTodayStatus(userId: userId, day: today);
        cachedStatus = cached == null ? null : SignApi.decodeStatus(cached);
        final String? cachedConfigRaw = await SignConfigCacheTool.getConfig();
        cachedConfig = cachedConfigRaw == null ? null : SignApi.decodeConfig(cachedConfigRaw);
        if (cachedStatus != null || cachedConfig != null) {
          if (!mounted) {
            return;
          }
          setState(() {
            if (cachedStatus != null) {
              _status = cachedStatus!;
            }
            if (cachedConfig != null) {
              _config = cachedConfig!;
            }
            _loading = false;
            _loadFailed = false;
          });
        }
      }

      SignStatusResponse? status = cachedStatus;
      if (forceRemote || status == null) {
        try {
          status = await SignApi.getStatus();
          await SignCacheTool.saveTodayStatus(
            userId: userId,
            day: today,
            rawJson: SignApi.encodeStatus(status),
          );
        } catch (_) {
          status = cachedStatus;
        }
      }

      SignConfigResponse? config = cachedConfig;
      if (forceRemote || config == null) {
        try {
          config = await SignApi.getConfig();
          await SignConfigCacheTool.saveConfig(SignApi.encodeConfig(config));
        } catch (_) {
          config = cachedConfig ?? _config;
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        if (status != null) {
          _status = status;
        }
        if (config != null) {
          _config = config;
        }
        _loading = false;
        _loadFailed = status == null;
      });
      if (status == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(i18n.t('signLoadFailed')),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i18n.t('signLoadFailed')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  Future<void> _submitSign() async {
    if (_status.signedToday || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    try {
      final SignStatusResponse status = await SignApi.submit();
      final int userId = await _currentUserId();
      final String today = _todayKey();
      await SignCacheTool.saveTodayStatus(
        userId: userId,
        day: today,
        rawJson: SignApi.encodeStatus(status),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _status = status;
        _submitting = false;
      });
      await _showSuccessDialog(status);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i18n.t('signSubmitFailed')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  Future<void> _showSuccessDialog(SignStatusResponse status) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'sign-success',
      barrierColor: Colors.black.withOpacity(0.64),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Positioned(
                    top: -72,
                    child: Image.asset(
                      AppImages.signSuccess,
                      width: 132,
                      height: 132,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 62),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          i18n.t('signSuccessTitle'),
                          style: const TextStyle(
                            color: Color(0xFF222B45),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _rewardText(status.rewardAmount, status.rewardType),
                          style: const TextStyle(
                            color: Color(0xFFE56245),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          i18n.t('signSuccessHint'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF7C8497),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: <Color>[Color(0xFF5B5CE2), Color(0xFF4BA5C8)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                i18n.t('commonConfirm'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFFB347)),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111D31),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33FFB347)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            i18n.t('signLoadFailed'),
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            i18n.t('signLoadFailedHint'),
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _loadPageData(forceRemote: true),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFFFFB347), Color(0xFFFF7A59)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  i18n.t('signRetry'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignButton() {
    final bool disabled = _status.signedToday || _submitting;
    return GestureDetector(
      onTap: disabled ? null : _submitSign,
      child: Opacity(
        opacity: disabled ? 0.68 : 1,
        child: SizedBox(
          width: 220,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(
                  AppImages.signButtonBg,
                  fit: BoxFit.fill,
                ),
              ),
              if (_submitting)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              else
                Text(
                  _status.signedToday ? i18n.t('signTodaySigned') : i18n.t('signButton'),
                  style: const TextStyle(
                    color: Color(0xFFCE5A3A),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(SignRewardRule rule, bool active, bool reachedMax) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFFF0C8), Color(0xFFFFD87A)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF15233A), Color(0xFF101B2D)],
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? const Color(0xFFFFCC66) : const Color(0x334CE3FF),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'D${rule.day}',
            style: TextStyle(
              color: active ? const Color(0xFFCE5A3A) : const Color(0xFF9DB1C9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatIntegerAmount(rule.amount),
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: active ? const Color(0xFFCE5A3A) : const Color(0xFFEAF5FF),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reachedMax && active ? i18n.t('signMaxReward') : _status.rewardType.toUpperCase() == 'MONEY'
                ? i18n.t('currencyYuan')
                : i18n.t('currencyPoints'),
            style: TextStyle(
              color: active ? const Color(0xFFCE5A3A) : const Color(0xFF9DB1C9),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(SignRecord record) {
    final String rewardText = _rewardText(record.rewardAmount, record.rewardType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x2239E6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFF9DB1C9), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  i18n.t('signRecordSuccess'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.createTime.isNotEmpty ? record.createTime : record.signDate,
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            rewardText,
            style: const TextStyle(
              color: Color(0xFFE56245),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBody() {
    final List<SignRewardRule> rules = _rules();
    final int activeDay = _activeRuleDay();
    final bool reachedMax = rules.isNotEmpty && _status.consecutiveDays >= rules.last.day;
    final String expectedReward = _rewardText(_currentRewardAmount(), _status.rewardType);
    return RefreshIndicator(
      color: const Color(0xFFFFB347),
      onRefresh: () => _loadPageData(forceRemote: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              AppImages.signHero,
              width: 208,
              height: 208,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 0),
            Text(
              _status.signedToday
                  ? i18n.t('signTodaySigned')
                  : '${i18n.t('signTodayReward')} $expectedReward',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFEAF5FF),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            _buildSignButton(),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFF1D3558), Color(0xFF12324A), Color(0xFF0E5B57)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          i18n.t('signInviteTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          i18n.t('signInviteSubtitle'),
                          style: const TextStyle(
                            color: Color(0xFF95B0C7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRouter.inviteFriend),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[Color(0xFFA84CFF), Color(0xFF3E8BFF)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        i18n.t('signInviteButton'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                const SizedBox(width: 18),
                Expanded(
                  child: Container(height: 1.2, color: const Color(0xFF2FA7FF)),
                ),
                const SizedBox(width: 12),
                Text(
                  i18n.t('signRewardRules'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(height: 1.2, color: const Color(0xFF2FA7FF)),
                ),
                const SizedBox(width: 18),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: rules.map((SignRewardRule rule) {
                  final bool active = _status.signedToday ? rule.day == activeDay : rule.day == 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildRuleCard(rule, active, reachedMax),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Text(
                  i18n.t('signHistoryTitle'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${i18n.t('signCurrentStreak')} ${_status.consecutiveDays} ${i18n.t('signDayUnit')}',
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_status.records.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D31),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x334CE3FF)),
                ),
                child: Text(
                  i18n.t('signNoHistory'),
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 13,
                  ),
                ),
              )
            else
              Column(
                children: _status.records.map(_buildRecordItem).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C24),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('signTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -80,
            right: -70,
            child: _GlowBlob(
              size: 210,
              colors: <Color>[Color(0x22FFCE73), Color(0x00000000)],
            ),
          ),
          const Positioned(
            top: 140,
            left: -90,
            child: _GlowBlob(
              size: 180,
              colors: <Color>[Color(0x1A54A9FF), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: _loading
                ? _buildLoadingState()
                : _loadFailed && _status.records.isEmpty
                    ? _buildErrorCard()
                    : _buildPageBody(),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
