import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class WithdrawWalletItem {
  const WithdrawWalletItem({
    required this.walletId,
    required this.userId,
    required this.userName,
    required this.currencyType,
    required this.totalInvest,
    required this.availableBalance,
    required this.usdExchangeQuota,
    required this.frozenAmount,
    required this.profitAmount,
    required this.pendingAmount,
    required this.totalRecharge,
    required this.totalWithdraw,
  });

  final int walletId;
  final int userId;
  final String userName;
  final String currencyType;
  final double totalInvest;
  final double availableBalance;
  final double usdExchangeQuota;
  final double frozenAmount;
  final double profitAmount;
  final double pendingAmount;
  final double totalRecharge;
  final double totalWithdraw;

  factory WithdrawWalletItem.fromJson(Map<String, dynamic> json) {
    return WithdrawWalletItem(
      walletId: int.tryParse('${json['walletId'] ?? json['wallet_id'] ?? 0}') ?? 0,
      userId: int.tryParse('${json['userId'] ?? json['user_id'] ?? 0}') ?? 0,
      userName: (json['userName'] ?? json['user_name'] ?? '').toString(),
      currencyType: (json['currencyType'] ?? json['currency_type'] ?? 'CNY').toString(),
      totalInvest: double.tryParse('${json['totalInvest'] ?? json['total_invest'] ?? 0}') ?? 0,
      availableBalance: double.tryParse('${json['availableBalance'] ?? json['available_balance'] ?? 0}') ?? 0,
      usdExchangeQuota: double.tryParse('${json['usdExchangeQuota'] ?? json['usd_exchange_quota'] ?? 0}') ?? 0,
      frozenAmount: double.tryParse('${json['frozenAmount'] ?? json['frozen_amount'] ?? 0}') ?? 0,
      profitAmount: double.tryParse('${json['profitAmount'] ?? json['profit_amount'] ?? 0}') ?? 0,
      pendingAmount: double.tryParse('${json['pendingAmount'] ?? json['pending_amount'] ?? 0}') ?? 0,
      totalRecharge: double.tryParse('${json['totalRecharge'] ?? json['total_recharge'] ?? 0}') ?? 0,
      totalWithdraw: double.tryParse('${json['totalWithdraw'] ?? json['total_withdraw'] ?? 0}') ?? 0,
    );
  }
}

class WithdrawApi {
  WithdrawApi._();

  static Future<List<WithdrawOrder>> getMyWithdrawList({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final res = await HttpClient.get(
      RuoYiEndpoints.withdrawList,
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
      return <WithdrawOrder>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => WithdrawOrder.fromJson(item))
        .toList();
  }

  static Future<List<WithdrawWalletItem>> getWallets() async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appUserWallets,
      encrypt: true,
      retry: true,
    );
    final dynamic raw = res.data;
    if (raw is! List) {
      return <WithdrawWalletItem>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => WithdrawWalletItem.fromJson(item))
        .toList();
  }

  static Future<void> submitWithdraw({
    required double amount,
    required String currencyType,
    required String withdrawMethod,
    required int bankCardId,
    required String requestNo,
    String? remark,
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.withdrawSubmit,
      data: <String, dynamic>{
        'amount': amount,
        'currencyType': currencyType,
        'withdrawMethod': withdrawMethod,
        'bankCardId': bankCardId,
        'requestNo': requestNo,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      },
      encrypt: true,
    );
  }
}

class WithdrawOrder {
  const WithdrawOrder({
    required this.withdrawId,
    required this.orderNo,
    required this.requestNo,
    required this.userId,
    required this.userName,
    required this.currencyType,
    required this.withdrawMethod,
    required this.amount,
    required this.status,
    this.rejectReason,
    this.submitTime,
    this.reviewTime,
    this.reviewUserName,
    this.remark,
  });

  final int withdrawId;
  final String orderNo;
  final String requestNo;
  final int userId;
  final String userName;
  final String currencyType;
  final String withdrawMethod;
  final double amount;
  final int status;
  final String? rejectReason;
  final String? submitTime;
  final String? reviewTime;
  final String? reviewUserName;
  final String? remark;

  factory WithdrawOrder.fromJson(Map<String, dynamic> json) {
    return WithdrawOrder(
      withdrawId: int.tryParse('${json['withdrawId'] ?? json['withdraw_id'] ?? 0}') ?? 0,
      orderNo: (json['orderNo'] ?? json['order_no'] ?? '').toString(),
      requestNo: (json['requestNo'] ?? json['request_no'] ?? '').toString(),
      userId: int.tryParse('${json['userId'] ?? json['user_id'] ?? 0}') ?? 0,
      userName: (json['userName'] ?? json['user_name'] ?? '').toString(),
      currencyType: (json['currencyType'] ?? json['currency_type'] ?? 'CNY').toString(),
      withdrawMethod: (json['withdrawMethod'] ?? json['withdraw_method'] ?? '').toString(),
      amount: double.tryParse('${json['amount'] ?? 0}') ?? 0,
      status: int.tryParse('${json['status'] ?? 0}') ?? 0,
      rejectReason: (json['rejectReason'] ?? json['reject_reason'])?.toString(),
      submitTime: (json['submitTime'] ?? json['submit_time'])?.toString(),
      reviewTime: (json['reviewTime'] ?? json['review_time'])?.toString(),
      reviewUserName: (json['reviewUserName'] ?? json['review_user_name'])?.toString(),
      remark: (json['remark'])?.toString(),
    );
  }
}
