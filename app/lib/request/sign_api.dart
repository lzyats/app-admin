import 'dart:convert';

import 'package:myapp/request/app_config_api.dart' show SignRewardRule;
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

export 'package:myapp/request/app_config_api.dart' show SignRewardRule;

class SignRecord {
  const SignRecord({
    required this.signId,
    required this.userId,
    required this.userName,
    required this.signDate,
    required this.consecutiveDays,
    required this.rewardType,
    required this.rewardAmount,
    required this.sourceType,
    required this.sourceNo,
    required this.status,
    required this.remark,
    required this.createTime,
  });

  final int signId;
  final int userId;
  final String userName;
  final String signDate;
  final int consecutiveDays;
  final String rewardType;
  final double rewardAmount;
  final String sourceType;
  final String sourceNo;
  final String status;
  final String remark;
  final String createTime;

  factory SignRecord.fromJson(Map<String, dynamic> json) {
    return SignRecord(
      signId: _asInt(json['signId'] ?? json['sign_id']),
      userId: _asInt(json['userId'] ?? json['user_id']),
      userName: (json['userName'] ?? json['user_name'] ?? '').toString(),
      signDate: (json['signDate'] ?? json['sign_date'] ?? '').toString(),
      consecutiveDays: _asInt(json['consecutiveDays'] ?? json['consecutive_days']),
      rewardType: (json['rewardType'] ?? json['reward_type'] ?? '').toString(),
      rewardAmount: _asDouble(json['rewardAmount'] ?? json['reward_amount']),
      sourceType: (json['sourceType'] ?? json['source_type'] ?? '').toString(),
      sourceNo: (json['sourceNo'] ?? json['source_no'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      createTime: (json['createTime'] ?? json['create_time'] ?? '').toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class SignStatusResponse {
  const SignStatusResponse({
    required this.signedToday,
    required this.consecutiveDays,
    required this.rewardType,
    required this.rewardAmount,
    required this.rewardLabel,
    required this.records,
  });

  final bool signedToday;
  final int consecutiveDays;
  final String rewardType;
  final double rewardAmount;
  final String rewardLabel;
  final List<SignRecord> records;

  factory SignStatusResponse.fromJson(Map<String, dynamic> json) {
    final List<SignRecord> records = <SignRecord>[];
    final dynamic rawRecords = json['records'];
    if (rawRecords is List) {
      for (final dynamic item in rawRecords) {
        if (item is Map<String, dynamic>) {
          records.add(SignRecord.fromJson(item));
        } else if (item is Map) {
          records.add(SignRecord.fromJson(item.cast<String, dynamic>()));
        }
      }
    }
    return SignStatusResponse(
      signedToday: json['signedToday'] == true || json['signedToday'] == 'true' || json['signedToday'] == 1,
      consecutiveDays: _asInt(json['consecutiveDays']),
      rewardType: (json['rewardType'] ?? 'POINT').toString(),
      rewardAmount: _asDouble(json['rewardAmount']),
      rewardLabel: (json['rewardLabel'] ?? '').toString(),
      records: records,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signedToday': signedToday,
      'consecutiveDays': consecutiveDays,
      'rewardType': rewardType,
      'rewardAmount': rewardAmount,
      'rewardLabel': rewardLabel,
      'records': records
          .map((SignRecord item) => <String, dynamic>{
                'signId': item.signId,
                'userId': item.userId,
                'userName': item.userName,
                'signDate': item.signDate,
                'consecutiveDays': item.consecutiveDays,
                'rewardType': item.rewardType,
                'rewardAmount': item.rewardAmount,
                'sourceType': item.sourceType,
                'sourceNo': item.sourceNo,
                'status': item.status,
                'remark': item.remark,
                'createTime': item.createTime,
              })
          .toList(),
    };
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class SignConfigResponse {
  const SignConfigResponse({
    required this.rewardType,
    required this.rewardAmount,
    required this.continuousRewardRule,
  });

  final String rewardType;
  final double rewardAmount;
  final String continuousRewardRule;

  factory SignConfigResponse.fromJson(Map<String, dynamic> json) {
    return SignConfigResponse(
      rewardType: (json['rewardType'] ?? 'POINT').toString(),
      rewardAmount: _asDouble(json['rewardAmount']),
      continuousRewardRule: (json['continuousRewardRule'] ?? json['signContinuousRewardRule'] ?? '[]').toString(),
    );
  }

  List<SignRewardRule> get continuousRewardRules {
    final dynamic decoded = _decodeRule(continuousRewardRule);
    if (decoded is! List) {
      return <SignRewardRule>[];
    }
    final List<SignRewardRule> rules = <SignRewardRule>[];
    for (final dynamic item in decoded) {
      if (item is Map<String, dynamic>) {
        rules.add(SignRewardRule.fromJson(item));
      } else if (item is Map) {
        rules.add(SignRewardRule.fromJson(item.cast<String, dynamic>()));
      }
    }
    return rules;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rewardType': rewardType,
      'rewardAmount': rewardAmount,
      'continuousRewardRule': continuousRewardRule,
    };
  }

  static SignConfigResponse fromAny(dynamic value) {
    if (value is Map<String, dynamic>) {
      return SignConfigResponse.fromJson(value);
    }
    if (value is Map) {
      return SignConfigResponse.fromJson(value.cast<String, dynamic>());
    }
    return const SignConfigResponse(
      rewardType: 'POINT',
      rewardAmount: 1,
      continuousRewardRule: '[]',
    );
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static dynamic _decodeRule(String raw) {
    if (raw.trim().isEmpty) {
      return const <dynamic>[];
    }
    try {
      return jsonDecode(raw);
    } catch (_) {
      return const <dynamic>[];
    }
  }
}

class SignApi {
  SignApi._();

  static Future<SignConfigResponse> getConfig() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.signConfig,
      encrypt: true,
    );
    final dynamic payload = resp.data;
    if (payload is Map<String, dynamic>) {
      return SignConfigResponse.fromJson(payload);
    }
    if (payload is Map) {
      return SignConfigResponse.fromJson(payload.cast<String, dynamic>());
    }
    if (resp.raw.isNotEmpty) {
      return SignConfigResponse.fromAny(resp.raw);
    }
    return const SignConfigResponse(
      rewardType: 'POINT',
      rewardAmount: 1,
      continuousRewardRule: '[]',
    );
  }

  static Future<SignStatusResponse> getStatus() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.signStatus,
      encrypt: true,
    );
    final dynamic payload = resp.data;
    if (payload is Map<String, dynamic>) {
      return SignStatusResponse.fromJson(payload);
    }
    if (resp.raw.isNotEmpty) {
      return SignStatusResponse.fromJson(resp.raw);
    }
    return const SignStatusResponse(
      signedToday: false,
      consecutiveDays: 0,
      rewardType: 'POINT',
      rewardAmount: 0,
      rewardLabel: '',
      records: <SignRecord>[],
    );
  }

  static Future<SignStatusResponse> submit() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.signSubmit,
      encrypt: true,
    );
    final dynamic payload = resp.data;
    if (payload is Map<String, dynamic>) {
      return SignStatusResponse.fromJson(payload);
    }
    if (resp.raw.isNotEmpty) {
      return SignStatusResponse.fromJson(resp.raw);
    }
    return const SignStatusResponse(
      signedToday: false,
      consecutiveDays: 0,
      rewardType: 'POINT',
      rewardAmount: 0,
      rewardLabel: '',
      records: <SignRecord>[],
    );
  }

  static String encodeStatus(SignStatusResponse status) {
    return jsonEncode(status.toJson());
  }

  static SignStatusResponse? decodeStatus(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }
    final dynamic decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return SignStatusResponse.fromJson(decoded);
    }
    if (decoded is Map) {
      return SignStatusResponse.fromJson(decoded.cast<String, dynamic>());
    }
    return null;
  }

  static String encodeConfig(SignConfigResponse config) {
    return jsonEncode(config.toJson());
  }

  static SignConfigResponse? decodeConfig(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }
    final dynamic decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return SignConfigResponse.fromJson(decoded);
    }
    if (decoded is Map) {
      return SignConfigResponse.fromJson(decoded.cast<String, dynamic>());
    }
    return null;
  }
}
