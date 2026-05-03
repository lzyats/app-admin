import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class TeamRewardRule {
  const TeamRewardRule({
    required this.teamLevel,
    required this.teamLevelName,
    required this.requiredUserLevel,
    required this.requiredDirectUsers,
    required this.requiredTeamUsers,
    required this.requiredTeamInvest,
    required this.rewardAmount,
    required this.teamBonusRate,
  });

  final int teamLevel;
  final String teamLevelName;
  final int requiredUserLevel;
  final int requiredDirectUsers;
  final int requiredTeamUsers;
  final double requiredTeamInvest;
  final double rewardAmount;
  final double teamBonusRate;

  factory TeamRewardRule.fromJson(Map<String, dynamic> json) {
    return TeamRewardRule(
      teamLevel: _toInt(json['teamLevel']),
      teamLevelName: (json['teamLevelName'] ?? '').toString(),
      requiredUserLevel: _toInt(json['requiredUserLevel']),
      requiredDirectUsers: _toInt(json['requiredDirectUsers']),
      requiredTeamUsers: _toInt(json['requiredTeamUsers']),
      requiredTeamInvest: _toDouble(json['requiredTeamInvest']),
      rewardAmount: _toDouble(json['rewardAmount']),
      teamBonusRate: _toDouble(json['teamBonusRate']),
    );
  }
}

class TeamRewardInfo {
  const TeamRewardInfo({
    required this.currentTeamLeaderLevel,
    required this.currentUserLevel,
    required this.rules,
  });

  final int currentTeamLeaderLevel;
  final int currentUserLevel;
  final List<TeamRewardRule> rules;
}

class TeamRewardApi {
  TeamRewardApi._();

  static Future<TeamRewardInfo> getInfo() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.appTeamRewardInfo,
      encrypt: true,
    );
    final dynamic data = resp.data;
    if (data is! Map<String, dynamic>) {
      return const TeamRewardInfo(
        currentTeamLeaderLevel: 0,
        currentUserLevel: 0,
        rules: <TeamRewardRule>[],
      );
    }
    final List<dynamic> rawRules = (data['rules'] as List<dynamic>?) ?? <dynamic>[];
    final List<TeamRewardRule> rules = rawRules
        .whereType<Map<String, dynamic>>()
        .map(TeamRewardRule.fromJson)
        .toList();
    return TeamRewardInfo(
      currentTeamLeaderLevel: _toInt(data['currentTeamLeaderLevel']),
      currentUserLevel: _toInt(data['currentUserLevel']),
      rules: rules,
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
