import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/miner_api.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/auth_tool.dart';

class MinerClaimPage extends StatefulWidget {
  const MinerClaimPage({super.key});

  @override
  State<MinerClaimPage> createState() => _MinerClaimPageState();
}

class _MinerClaimPageState extends State<MinerClaimPage> {
  bool _loading = true;
  List<dynamic> _miners = <dynamic>[];
  AuthUserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final AuthUserProfile? profile = await AuthTool.getUserProfile();
      final List<dynamic> miners = await MinerApi.fetchAvailable();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _miners = miners;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0;
  }

  int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse('${v ?? 0}') ?? 0;
  }

  String _str(dynamic v) => (v ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    final AuthUserProfile? profile = _profile;
    final int vip = profile?.level ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '节点领取' : 'Claim Node'),
        backgroundColor: const Color(0xFF070A1E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF05071B), Color(0xFF020311)],
          ),
        ),
        child: _loading
            ? Center(
                child: Text(
                  isZh ? '加载中...' : 'Loading...',
                  style: const TextStyle(color: Color(0xFF9DB1C9)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _buildUserCard(i18n, profile, vip),
                  const SizedBox(height: 14),
                  ..._miners.map((dynamic item) {
                    final Map<String, dynamic> m =
                        (item as Map?)?.cast<String, dynamic>() ??
                            <String, dynamic>{};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMinerItem(i18n, m),
                    );
                  }).toList(),
                  if (_miners.isEmpty)
                    Center(
                      child: Text(
                        isZh ? '暂无节点' : 'No nodes',
                        style: const TextStyle(color: Color(0xFF9DB1C9)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildUserCard(AppLocalizations i18n, AuthUserProfile? profile, int vip) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    final String avatar = (profile?.avatar ?? '').trim();
    final String nick = (profile?.nickName ?? profile?.username ?? '').trim();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x332A78FF)),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF0A0E26),
            backgroundImage: avatar.isEmpty ? null : NetworkImage(avatar),
            child: avatar.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF9DB1C9))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  nick.isEmpty ? (isZh ? '用户' : 'User') : nick,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _vipBadge(vip),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A78FF).withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x332A78FF)),
            ),
            child: Text(
              '${isZh ? '等级' : 'Level'} ${vip.clamp(0, 99)}',
              style: const TextStyle(color: Color(0xFF9CCBFF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vipBadge(int vip) {
    final String text = vip <= 0 ? 'VIP.0' : 'VIP.$vip';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFB18BFF), Color(0xFFE2C7FF)],
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1A1033),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMinerItem(AppLocalizations i18n, Map<String, dynamic> miner) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    final int minerId = _int(miner['minerId']);
    final String name = _str(miner['minerName']);
    final double wagPerDay = _num(miner['wagPerDay']);
    final String coverImage = _str(miner['coverImage']).trim();
    final String remark = _str(miner['remark']).trim();
    final int minUserLevel = _int(miner['minUserLevel']);
    final int maxUserLevel = _int(miner['maxUserLevel']);
    final int maxLvl = maxUserLevel <= 0 ? 99 : maxUserLevel;
    final int vip = _profile?.level ?? 0;
    final bool eligible = vip >= minUserLevel && vip <= maxLvl;
    final bool owned = miner['owned'] == true;
    final bool isCurrent = miner['isCurrent'] == true;
    final String? imageUrl = coverImage.isEmpty
        ? null
        : ApiClient.instance.resolveImageUrl(coverImage);

    Future<void> handleClaim() async {
      try {
        await MinerApi.claim(minerId: minerId);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        final String msg = _errorText(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }

    final String actionText = isCurrent
        ? (isZh ? '使用中' : 'In Use')
        : (eligible
            ? (owned ? (isZh ? '更换节点' : 'Change') : (isZh ? '立即领取' : 'Claim Now'))
            : (vip < minUserLevel
                ? (isZh ? '升级至VIP.$minUserLevel可领取' : 'Upgrade to VIP.$minUserLevel')
                : (vip > maxLvl && maxLvl > 0
                    ? (isZh
                        ? '仅VIP.$minUserLevel~VIP.$maxLvl可领取'
                        : 'VIP.$minUserLevel~VIP.$maxLvl only')
                    : (isZh ? '当前等级不可领取' : 'Not eligible'))));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1230),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x332A78FF)),
      ),
      child: Column(
        children: <Widget>[
          _buildMinerSquareImage(imageUrl),
          const SizedBox(height: 12),
          Text(
            name.isEmpty ? (isZh ? '矿机' : 'Miner') : name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isZh ? '日产出' : 'Daily'}: ${wagPerDay.toStringAsFixed(2)}WAG',
            style: const TextStyle(color: Color(0xFF9DB1C9)),
          ),
          const SizedBox(height: 6),
          Text(
            isZh
                ? '等级要求：VIP.${minUserLevel.clamp(0, 99)}~VIP.${maxLvl.clamp(0, 99)}'
                : 'Required: VIP.${minUserLevel.clamp(0, 99)}~VIP.${maxLvl.clamp(0, 99)}',
            style: const TextStyle(color: Color(0xFF6C7BA5), fontSize: 12),
          ),
          if (remark.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              remark,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6C7BA5), fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A78FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isCurrent ? null : (eligible ? handleClaim : null),
              child: Text(actionText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinerSquareImage(String? imageUrl) {
    const double size = 140;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFF0A0E26),
          child: imageUrl == null
              ? _minerSquarePlaceholder(size)
              : Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => _minerSquarePlaceholder(size),
                ),
        ),
      ),
    );
  }

  Widget _minerSquarePlaceholder(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: Icon(Icons.memory, color: Color(0xFF2A78FF), size: 52),
      ),
    );
  }

  String _errorText(Object e) {
    if (e is ApiException) {
      final String raw = e.userMessage.trim();
      if (raw.isEmpty) return '请求失败';
      final String firstLine = raw.split('\n').first.trim();
      return firstLine.isEmpty ? '请求失败' : firstLine;
    }
    final String s = e.toString().trim();
    return s.isEmpty ? '请求失败' : s;
  }
}
