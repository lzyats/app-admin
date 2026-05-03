import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class RechargeOrder {
  const RechargeOrder({
    required this.rechargeId,
    required this.orderNo,
    required this.userId,
    required this.userName,
    required this.currencyType,
    required this.rechargeMethod,
    required this.amount,
    required this.status,
    this.walletId,
    this.rejectReason,
    this.submitTime,
    this.reviewTime,
    this.reviewUserName,
    this.remark,
  });

  final int rechargeId;
  final String orderNo;
  final int userId;
  final String userName;
  final String currencyType;
  final String rechargeMethod;
  final double amount;
  final int status;
  final int? walletId;
  final String? rejectReason;
  final String? submitTime;
  final String? reviewTime;
  final String? reviewUserName;
  final String? remark;

  factory RechargeOrder.fromJson(Map<String, dynamic> json) {
    return RechargeOrder(
      rechargeId: int.tryParse('${json['rechargeId'] ?? json['recharge_id'] ?? 0}') ?? 0,
      orderNo: (json['orderNo'] ?? json['order_no'] ?? '').toString(),
      userId: int.tryParse('${json['userId'] ?? json['user_id'] ?? 0}') ?? 0,
      userName: (json['userName'] ?? json['user_name'] ?? '').toString(),
      currencyType: (json['currencyType'] ?? json['currency_type'] ?? 'CNY').toString(),
      rechargeMethod: (json['rechargeMethod'] ?? json['recharge_method'] ?? 'RMB').toString(),
      amount: double.tryParse('${json['amount'] ?? 0}') ?? 0,
      status: int.tryParse('${json['status'] ?? 0}') ?? 0,
      walletId: _parseNullableInt(json['walletId'] ?? json['wallet_id']),
      rejectReason: (json['rejectReason'] ?? json['reject_reason'])?.toString(),
      submitTime: (json['submitTime'] ?? json['submit_time'])?.toString(),
      reviewTime: (json['reviewTime'] ?? json['review_time'])?.toString(),
      reviewUserName: (json['reviewUserName'] ?? json['review_user_name'])?.toString(),
      remark: (json['remark'])?.toString(),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    final String raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }
}

class RechargeApi {
  RechargeApi._();

  static Future<void> submitRecharge({
    required double amount,
    required String currencyType,
    required String rechargeMethod,
    String? remark,
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.rechargeSubmit,
      data: <String, dynamic>{
        'amount': amount,
        'currencyType': currencyType,
        'rechargeMethod': rechargeMethod,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      },
      encrypt: true,
    );
  }

  static Future<List<RechargeOrder>> getMyRechargeList({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final res = await HttpClient.get(
      RuoYiEndpoints.rechargeList,
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
      return <RechargeOrder>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => RechargeOrder.fromJson(item))
        .toList();
  }
}
