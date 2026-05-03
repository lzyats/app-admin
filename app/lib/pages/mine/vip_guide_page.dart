import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/user_level_api.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/widgets/app_network_image.dart';

class VipGuidePage extends StatefulWidget {
  const VipGuidePage({super.key});

  @override
  State<VipGuidePage> createState() => _VipGuidePageState();
}

class _VipGuidePageState extends State<VipGuidePage> {
  bool _loading = true;
  AuthUserProfile? _profile;
  List<UserLevelOption> _levels = <UserLevelOption>[];
  int _growthValue = 0; // 新增成长值变量
  String? _error;

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final AuthUserProfile? cached = await AuthTool.getUserProfile();
      final AuthUserProfile profile =
          refresh ? await AuthApi.getInfo() : (cached ?? await AuthApi.getInfo());
      if (refresh || cached == null) {
        await AuthTool.saveUserProfile(profile);
      }
      final List<UserLevelOption> levels =
          await UserLevelApi.getOptions(forceRefresh: refresh);
      if (mounted) {
        setState(() {
          _profile = profile;
          _levels = levels;
          _growthValue = profile.growthValue ?? 0; // 获取成长值
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  int get _vipLevel => _profile?.level ?? 0;

  UserLevelOption? get _currentLevelOption {
    final int vip = _vipLevel;
    for (final item in _levels) {
      if (item.level == vip) {
        return item;
      }
    }
    return null;
  }

  String get _displayName {
    final p = _profile;
    if (p == null) {
      return i18n.t('mineUserNameDefault');
    }
    if (p.nickName.isNotEmpty) {
      return p.nickName;
    }
    return p.username.isNotEmpty ? p.username : i18n.t('mineUserNameDefault');
  }

  String? get _avatarUrl => _profile?.resolvedAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(isZh ? 'VIP说明' : 'VIP Guide'),
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
              Color(0xFF14233A),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _load(refresh: true),
            color: const Color(0xFF39E6FF),
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
                : _error != null
                    ? ListView(
                        children: <Widget>[
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              isZh ? '加载失败' : 'Load failed',
                              style: const TextStyle(
                                color: Color(0xFFE9F3FF),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9DB1C9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => _load(refresh: true),
                              child: Text(isZh ? '重试' : 'Retry'),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        children: <Widget>[
                          _buildTopCard(isZh),
                          const SizedBox(height: 20),
                          _buildTitle(isZh),
                          const SizedBox(height: 16),
                          ..._levels
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _buildLevelRow(e, isZh),
                                  ))
                              .toList(),
                          if (_levels.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                  isZh ? '暂无等级数据' : 'No level data',
                                  style: const TextStyle(
                                    color: Color(0xFF9DB1C9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(bool isZh) {
    final String levelText = 'V$_vipLevel';
    final UserLevelOption? current = _currentLevelOption;
    final String scoreText = _growthValue.toString();

    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334CE3FF)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xCC101C30),
            Color(0xCC0B1630),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 14,
            left: 14,
            child: Row(
              children: <Widget>[
                _buildAvatar(),
                const SizedBox(width: 10),
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x6639E6FF),
                border: Border.all(color: const Color(0x334CE3FF)),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color: Color(0xFFE9F3FF),
                size: 30,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: Text(
              levelText,
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Color(0xFF39E6FF),
                letterSpacing: 1.0,
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 22,
            child: Text(
              (isZh ? '成长值：' : 'Growth Value: ') + scoreText,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isZh) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 26,
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0x0039E6FF), Color(0xFF39E6FF)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isZh ? '级别可增加加息参照表' : 'VIP Bonus Reference',
            style: const TextStyle(
              color: Color(0xFFE9F3FF),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 26,
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF39E6FF), Color(0x0039E6FF)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(UserLevelOption item, bool isZh) {
    final bool isCurrent = item.level == _vipLevel;
    final String leftTag = 'V${item.level}';
    final String amountText = _formatAmount(item.requiredGrowthValue.toDouble());
    final String bonusText = item.investBonus.toStringAsFixed(3);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? const Color(0xFF39E6FF) : const Color(0x1A4CE3FF),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x332B6EFF),
              border: Border.all(color: const Color(0x334CE3FF)),
            ),
            alignment: Alignment.center,
            child: Text(
              leftTag,
              style: const TextStyle(
                color: Color(0xFF39E6FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.levelName.isEmpty
                      ? (isZh ? 'VIP${item.level}' : 'VIP ${item.level}')
                      : item.levelName,
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  (isZh ? '成长值：' : 'Growth Value: ') + amountText,
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                bonusText,
                style: const TextStyle(
                  color: Color(0xFF39E6FF),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isZh ? '会员加成' : 'Bonus',
                style: const TextStyle(
                  color: Color(0xFF9DB1C9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final String? avatarUrl = _avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0x334CE3FF),
        child: Icon(Icons.person, color: Color(0xFFE9F3FF), size: 18),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: 36,
        height: 36,
        child: AppNetworkImage(
          src: avatarUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    final String raw = value.toStringAsFixed(2);
    return raw.endsWith('.00') ? raw.substring(0, raw.length - 3) : raw;
  }
}
