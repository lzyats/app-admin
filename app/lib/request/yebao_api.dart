import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  return double.tryParse('${value ?? 0}') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return <dynamic>[];
}

Map<String, dynamic> _extractPayload(dynamic raw, dynamic fallbackRaw) {
  final dynamic source = raw is Map<String, dynamic> ? raw : fallbackRaw;
  if (source is Map<String, dynamic>) {
    return _asMap(source['data'] ?? source['rows'] ?? source['list'] ?? source);
  }
  if (source is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(source);
    return _asMap(map['data'] ?? map['rows'] ?? map['list'] ?? map);
  }
  return <String, dynamic>{};
}

List<dynamic> _extractRows(dynamic raw, dynamic fallbackRaw) {
  final dynamic source = raw is Map<String, dynamic> ? raw : fallbackRaw;
  if (source is Map<String, dynamic>) {
    return _asList(source['data'] ?? source['rows'] ?? source['list'] ?? source);
  }
  if (source is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(source);
    return _asList(map['data'] ?? map['rows'] ?? map['list'] ?? map);
  }
  if (source is List) {
    return source;
  }
  return <dynamic>[];
}

class YebaoConfig {
  const YebaoConfig({
    required this.configId,
    required this.configName,
    required this.annualRate,
    required this.unitAmount,
    required this.status,
  });

  final int configId;
  final String configName;
  final double annualRate;
  final double unitAmount;
  final String status;

  factory YebaoConfig.fromJson(Map<String, dynamic> json) {
    return YebaoConfig(
      configId: _toInt(json['configId'] ?? json['config_id']),
      configName: (json['configName'] ?? json['config_name'] ?? '').toString(),
      annualRate: _toDouble(json['annualRate'] ?? json['annual_rate']),
      unitAmount: _toDouble(json['unitAmount'] ?? json['unit_amount']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class YebaoOrderItem {
  const YebaoOrderItem({
    required this.orderId,
    required this.orderNo,
    required this.shares,
    required this.unitAmount,
    required this.principalAmount,
    required this.annualRate,
    required this.settledIncome,
    required this.investTime,
    required this.lastSettleTime,
    required this.nextSettleTime,
    required this.status,
  });

  final int orderId;
  final String orderNo;
  final int shares;
  final double unitAmount;
  final double principalAmount;
  final double annualRate;
  final double settledIncome;
  final DateTime? investTime;
  final DateTime? lastSettleTime;
  final DateTime? nextSettleTime;
  final String status;

  factory YebaoOrderItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty) {
        return null;
      }
      return DateTime.tryParse(text.replaceFirst(' ', 'T'));
    }

    return YebaoOrderItem(
      orderId: _toInt(json['orderId'] ?? json['order_id']),
      orderNo: (json['orderNo'] ?? json['order_no'] ?? '').toString(),
      shares: _toInt(json['shares']),
      unitAmount: _toDouble(json['unitAmount'] ?? json['unit_amount']),
      principalAmount: _toDouble(json['principalAmount'] ?? json['principal_amount']),
      annualRate: _toDouble(json['annualRate'] ?? json['annual_rate']),
      settledIncome: _toDouble(json['settledIncome'] ?? json['settled_income']),
      investTime: parseDate(json['investTime'] ?? json['invest_time']),
      lastSettleTime: parseDate(json['lastSettleTime'] ?? json['last_settle_time']),
      nextSettleTime: parseDate(json['nextSettleTime'] ?? json['next_settle_time']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class YebaoIncomeLogItem {
  const YebaoIncomeLogItem({
    required this.incomeId,
    required this.incomeNo,
    required this.orderNo,
    required this.shares,
    required this.principalAmount,
    required this.annualRate,
    required this.settleDays,
    required this.incomeAmount,
    required this.settleTime,
    required this.status,
  });

  final int incomeId;
  final String incomeNo;
  final String orderNo;
  final int shares;
  final double principalAmount;
  final double annualRate;
  final int settleDays;
  final double incomeAmount;
  final DateTime? settleTime;
  final String status;

  factory YebaoIncomeLogItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      final String text = (value ?? '').toString().trim();
      if (text.isEmpty) {
        return null;
      }
      return DateTime.tryParse(text.replaceFirst(' ', 'T'));
    }

    return YebaoIncomeLogItem(
      incomeId: _toInt(json['incomeId'] ?? json['income_id']),
      incomeNo: (json['incomeNo'] ?? json['income_no'] ?? '').toString(),
      orderNo: (json['orderNo'] ?? json['order_no'] ?? '').toString(),
      shares: _toInt(json['shares']),
      principalAmount: _toDouble(json['principalAmount'] ?? json['principal_amount']),
      annualRate: _toDouble(json['annualRate'] ?? json['annual_rate']),
      settleDays: _toInt(json['settleDays'] ?? json['settle_days']),
      incomeAmount: _toDouble(json['incomeAmount'] ?? json['income_amount']),
      settleTime: parseDate(json['settleTime'] ?? json['settle_time']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class YebaoDetail {
  const YebaoDetail({
    required this.config,
    required this.orders,
    required this.incomeLogs,
    required this.totalPrincipal,
    required this.totalIncome,
    required this.todayIncome,
    required this.orderCount,
  });

  final YebaoConfig? config;
  final List<YebaoOrderItem> orders;
  final List<YebaoIncomeLogItem> incomeLogs;
  final double totalPrincipal;
  final double totalIncome;
  final double todayIncome;
  final int orderCount;

  factory YebaoDetail.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> configMap = _asMap(json['config']);
    final List<dynamic> orderRows = _asList(json['orders']);
    final List<dynamic> incomeRows = _asList(json['incomeLogs']);
    return YebaoDetail(
      config: configMap.isEmpty ? null : YebaoConfig.fromJson(configMap),
      orders: orderRows
          .whereType<Map>()
          .map((dynamic item) => YebaoOrderItem.fromJson(_asMap(item)))
          .toList(),
      incomeLogs: incomeRows
          .whereType<Map>()
          .map((dynamic item) => YebaoIncomeLogItem.fromJson(_asMap(item)))
          .toList(),
      totalPrincipal: _toDouble(json['totalPrincipal'] ?? json['total_principal']),
      totalIncome: _toDouble(json['totalIncome'] ?? json['total_income']),
      todayIncome: _toDouble(json['todayIncome'] ?? json['today_income']),
      orderCount: _toInt(json['orderCount'] ?? json['order_count']),
    );
  }
}

class YebaoApi {
  const YebaoApi._();

  static Future<YebaoDetail> fetchMyDetail() async {
    final response = await HttpClient.get(
      RuoYiEndpoints.appYebaoMy,
      encrypt: true,
      retry: true,
    );
    final Map<String, dynamic> payload = _extractPayload(response.data, response.raw);
    return YebaoDetail.fromJson(payload);
  }

  static Future<List<YebaoOrderItem>> fetchMyOrders() async {
    final response = await HttpClient.get(
      RuoYiEndpoints.appYebaoOrders,
      encrypt: true,
      retry: true,
    );
    final List<dynamic> rows = _extractRows(response.data, response.raw);
    return rows
        .whereType<Map>()
        .map((dynamic item) => YebaoOrderItem.fromJson(_asMap(item)))
        .toList();
  }

  static Future<List<YebaoIncomeLogItem>> fetchMyIncomeLogs() async {
    final response = await HttpClient.get(
      RuoYiEndpoints.appYebaoIncomes,
      encrypt: true,
      retry: true,
    );
    final List<dynamic> rows = _extractRows(response.data, response.raw);
    return rows
        .whereType<Map>()
        .map((dynamic item) => YebaoIncomeLogItem.fromJson(_asMap(item)))
        .toList();
  }

  static Future<void> purchase({
    required int shares,
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.appYebaoPurchase,
      data: <String, dynamic>{
        'shares': shares,
      },
      encrypt: true,
      retry: false,
    );
  }

  static Future<void> redeem({
    required int orderId,
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.appYebaoRedeem,
      data: <String, dynamic>{
        'orderId': orderId,
      },
      encrypt: true,
      retry: false,
    );
  }
}
