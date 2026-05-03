import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/team_reward_api.dart';

class TeamRewardPage extends StatefulWidget {
  const TeamRewardPage({super.key});

  @override
  State<TeamRewardPage> createState() => _TeamRewardPageState();
}

class _TeamRewardPageState extends State<TeamRewardPage> {
  bool _loading = true;
  String? _error;
  TeamRewardInfo _info = const TeamRewardInfo(
    currentTeamLeaderLevel: 0,
    currentUserLevel: 0,
    rules: <TeamRewardRule>[],
  );

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final TeamRewardInfo info = await TeamRewardApi.getInfo();
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(isZh ? '团队奖励' : 'Team Reward'),
        backgroundColor: const Color(0xFF0A1220),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0A1220), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white70)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        children: <Widget>[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Image.asset(
                                  AppImages.teamRewardBanner,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHeader(isZh),
                          const SizedBox(height: 12),
                          _buildTable(isZh),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isZh) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              (isZh ? '当前团队长等级：' : 'Current Team Level: ') + _info.currentTeamLeaderLevel.toString(),
              style: const TextStyle(color: Color(0xFFE9F3FF), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            (isZh ? '自身等级：V' : 'User Lv: V') + _info.currentUserLevel.toString(),
            style: const TextStyle(color: Color(0xFF39E6FF), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(bool isZh) {
    if (_info.rules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xCC101C30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Text(isZh ? '暂无团队等级规则' : 'No team reward rules', style: const TextStyle(color: Color(0xFF9DB1C9))),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 6,
          headingRowHeight: 36,
          dataRowMinHeight: 34,
          dataRowMaxHeight: 40,
          headingTextStyle: const TextStyle(color: Color(0xFFE9F3FF), fontWeight: FontWeight.w700, fontSize: 10),
          dataTextStyle: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 10),
          columns: <DataColumn>[
            DataColumn(label: Text(isZh ? '团队长\n等级' : 'Team\nLevel')),
            DataColumn(label: Text(isZh ? '自身\n等级' : 'User\nLevel')),
            DataColumn(label: Text(isZh ? '直推有效\n用户数' : 'Direct\nUsers')),
            DataColumn(label: Text(isZh ? '团队有效\n用户数' : 'Team\nUsers')),
            DataColumn(label: Text(isZh ? '团队总\n投资(元)' : 'Total\nInvest')),
            DataColumn(label: Text(isZh ? '团队长\n加成(‰)' : 'Leader\nBonus(‰)')),
            DataColumn(label: Text(isZh ? '奖励\n(元)' : 'Reward\n(CNY)')),
          ],
          rows: _info.rules
              .map((TeamRewardRule e) => DataRow(cells: <DataCell>[
                    DataCell(Text(e.teamLevelName.isEmpty ? e.teamLevel.toString() : e.teamLevelName)),
                    DataCell(Text('V${e.requiredUserLevel}')),
                    DataCell(Text(e.requiredDirectUsers.toString())),
                    DataCell(Text(e.requiredTeamUsers.toString())),
                    DataCell(Text(e.requiredTeamInvest.toStringAsFixed(0))),
                    DataCell(Text(e.teamBonusRate.toStringAsFixed(2))),
                    DataCell(Text(e.rewardAmount.toStringAsFixed(2))),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
