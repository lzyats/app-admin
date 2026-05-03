import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class PointAccount {
  const PointAccount({
    required this.availablePoints,
    required this.frozenPoints,
    required this.totalEarned,
    required this.totalSpent,
  });

  final int availablePoints;
  final int frozenPoints;
  final int totalEarned;
  final int totalSpent;

  factory PointAccount.fromJson(Map<String, dynamic> json) {
    return PointAccount(
      availablePoints: _int(json['availablePoints'] ?? json['available_points']),
      frozenPoints: _int(json['frozenPoints'] ?? json['frozen_points']),
      totalEarned: _int(json['totalEarned'] ?? json['total_earned']),
      totalSpent: _int(json['totalSpent'] ?? json['total_spent']),
    );
  }
}

class PointLog {
  const PointLog({
    required this.logId,
    required this.points,
    required this.pointsBefore,
    required this.pointsAfter,
    required this.changeType,
    required this.sourceType,
    required this.sourceNo,
    required this.status,
    required this.createTime,
    required this.remark,
  });

  final int logId;
  final int points;
  final int pointsBefore;
  final int pointsAfter;
  final String changeType;
  final String sourceType;
  final String sourceNo;
  final String status;
  final String createTime;
  final String remark;

  factory PointLog.fromJson(Map<String, dynamic> json) {
    return PointLog(
      logId: _int(json['logId'] ?? json['log_id']),
      points: _int(json['points']),
      pointsBefore: _int(json['pointsBefore'] ?? json['points_before']),
      pointsAfter: _int(json['pointsAfter'] ?? json['points_after']),
      changeType: (json['changeType'] ?? json['change_type'] ?? '').toString(),
      sourceType: (json['sourceType'] ?? json['source_type'] ?? '').toString(),
      sourceNo: (json['sourceNo'] ?? json['source_no'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createTime: (json['createTime'] ?? json['create_time'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
    );
  }
}

class PointApi {
  PointApi._();

  static Future<PointAccount> getMyPointAccount() async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appPointAccount,
      encrypt: true,
    );
    final dynamic data = res.data;
    if (data is Map<String, dynamic>) {
      return PointAccount.fromJson(data);
    }
    if (res.raw['data'] is Map<String, dynamic>) {
      return PointAccount.fromJson(res.raw['data'] as Map<String, dynamic>);
    }
    return const PointAccount(
      availablePoints: 0,
      frozenPoints: 0,
      totalEarned: 0,
      totalSpent: 0,
    );
  }

  static Future<List<PointLog>> getMyPointLogs({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appPointLogList,
      query: <String, dynamic>{
        'pageNum': pageNum,
        'pageSize': pageSize,
      },
      encrypt: true,
    );
    final dynamic data = res.data;
    final dynamic raw = data is Map<String, dynamic>
        ? (data['rows'] ?? data['list'] ?? data['data'])
        : res.raw['rows'];
    if (raw is! List) {
      return <PointLog>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => PointLog.fromJson(item))
        .toList();
  }
}

int _int(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

