import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class InvestContractPreview {
  const InvestContractPreview({
    required this.investorNo,
    required this.realName,
    required this.platformName,
    required this.amount,
    required this.cycleDays,
    required this.rate,
    required this.contractText,
    required this.signedBefore,
  });

  final String investorNo;
  final String realName;
  final String platformName;
  final double amount;
  final int cycleDays;
  final double rate;
  final String contractText;
  final bool signedBefore;

  factory InvestContractPreview.fromJson(Map<String, dynamic> json) {
    return InvestContractPreview(
      investorNo: '${json['investorNo'] ?? ''}',
      realName: '${json['realName'] ?? ''}',
      platformName: '${json['platformName'] ?? '投资平台'}',
      amount: _toDouble(json['amount']),
      cycleDays: _toInt(json['cycleDays']),
      rate: _toDouble(json['rate']),
      contractText: '${json['contractTemplate'] ?? json['contractSample'] ?? ''}',
      signedBefore: _toBool(json['signedBefore']),
    );
  }
}

class InvestOrderApi {
  const InvestOrderApi._();

  static Future<InvestContractPreview> previewContract({
    required int productId,
    required String productName,
    required double amount,
    required int cycleDays,
    required double singleRate,
  }) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.post(
      RuoYiEndpoints.appInvestOrderContractPreview,
      encrypt: true,
      data: <String, dynamic>{
        'productId': productId,
        'productName': productName,
        'amount': amount,
        'cycleDays': cycleDays,
        'singleRate': singleRate,
      },
    );
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw)
        : response.raw['data'] ?? response.raw;
    final Map<String, dynamic> map =
        payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{};
    return InvestContractPreview.fromJson(map);
  }

  static Future<ApiResponse<dynamic>> submit({
    required int productId,
    required double amount,
    required int purchaseShares,
    required String payPwd,
    required bool agreed,
    required String signatureData,
    required String contractText,
    required String clientReqNo,
    required bool groupMode,
    int? userCouponId,
    String? joinGroupNo,
  }) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.appInvestOrderSubmit,
      encrypt: true,
      data: <String, dynamic>{
        'productId': productId,
        'amount': amount,
        'purchaseShares': purchaseShares,
        'payPwd': payPwd,
        'agreed': agreed,
        'signatureData': signatureData,
        'contractText': contractText,
        'clientReqNo': clientReqNo,
        'userCouponId': userCouponId,
        'groupMode': groupMode ? 1 : 0,
        'groupNo': (joinGroupNo ?? '').trim(),
      },
    );
  }

  static Future<InvestOrderListData> fetchOrderList({String tab = 'total'}) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appInvestOrderList,
      encrypt: true,
      query: <String, dynamic>{'tab': tab},
    );
    final Map<String, dynamic> map = _extractMap(response.data, response.raw);
    return InvestOrderListData.fromJson(map);
  }

  static Future<InvestIncomeData> fetchIncomeData() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appInvestOrderIncomes,
      encrypt: true,
    );
    final Map<String, dynamic> map = _extractMap(response.data, response.raw);
    return InvestIncomeData.fromJson(map);
  }

  static Future<InvestOrderDetailData> fetchOrderDetail(int orderId) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appInvestOrderDetail,
      encrypt: true,
      query: <String, dynamic>{'orderId': orderId},
    );
    final Map<String, dynamic> map = _extractMap(response.data, response.raw);
    return InvestOrderDetailData.fromJson(map);
  }

  static Future<List<InvestWalletLogItem>> fetchWalletInvestLogs() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appUserWalletInvestLogs,
      encrypt: true,
    );
    final List<dynamic> rows = _extractList(response.data, response.raw);
    return rows
        .whereType<Map>()
        .map((dynamic item) => InvestWalletLogItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<PagedWalletLogData> fetchWalletLogs({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appUserWalletLogList,
      encrypt: true,
      query: <String, dynamic>{
        'pageNum': pageNum,
        'pageSize': pageSize,
      },
    );
    final Map<String, dynamic> map = _extractMap(response.data, response.raw);
    final List<dynamic> rows = _toList(map['rows']);
    return PagedWalletLogData(
      pageNum: _toInt(map['pageNum']),
      pageSize: _toInt(map['pageSize']),
      total: _toInt(map['total']),
      rows: rows
          .whereType<Map>()
          .map((dynamic item) => InvestWalletLogItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class PagedWalletLogData {
  const PagedWalletLogData({
    required this.pageNum,
    required this.pageSize,
    required this.total,
    required this.rows,
  });

  final int pageNum;
  final int pageSize;
  final int total;
  final List<InvestWalletLogItem> rows;
}

class InvestOrderListData {
  const InvestOrderListData({
    required this.tab,
    required this.totalCount,
    required this.runningCount,
    required this.endedCount,
    required this.list,
  });

  final String tab;
  final int totalCount;
  final int runningCount;
  final int endedCount;
  final List<InvestOrderListItem> list;

  factory InvestOrderListData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rows = _toList(json['list']);
    return InvestOrderListData(
      tab: '${json['tab'] ?? 'total'}',
      totalCount: _toInt(json['totalCount']),
      runningCount: _toInt(json['runningCount']),
      endedCount: _toInt(json['endedCount']),
      list: rows
          .whereType<Map>()
          .map((dynamic item) => InvestOrderListItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class InvestOrderListItem {
  const InvestOrderListItem({
    required this.orderId,
    required this.orderNo,
    required this.productId,
    required this.productName,
    required this.currency,
    required this.investAmount,
    required this.couponId,
    required this.userCouponId,
    required this.couponName,
    required this.couponType,
    required this.couponDiscountAmount,
    required this.payAmount,
    required this.effectiveRate,
    required this.expectedIncome,
    required this.cycleDays,
    required this.status,
    required this.createTime,
    required this.endTime,
    required this.groupMode,
    required this.groupId,
    required this.groupNo,
    required this.groupStatus,
    required this.groupDeadlineTime,
    required this.groupCountdownSeconds,
  });

  final int orderId;
  final String orderNo;
  final int productId;
  final String productName;
  final String currency;
  final double investAmount;
  final int couponId;
  final int userCouponId;
  final String couponName;
  final String couponType;
  final double couponDiscountAmount;
  final double payAmount;
  final double effectiveRate;
  final double expectedIncome;
  final int cycleDays;
  final String status;
  final DateTime? createTime;
  final DateTime? endTime;
  final bool groupMode;
  final int groupId;
  final String groupNo;
  final String groupStatus;
  final DateTime? groupDeadlineTime;
  final int groupCountdownSeconds;

  factory InvestOrderListItem.fromJson(Map<String, dynamic> json) {
    return InvestOrderListItem(
      orderId: _toInt(json['orderId']),
      orderNo: '${json['orderNo'] ?? ''}',
      productId: _toInt(json['productId']),
      productName: '${json['productName'] ?? ''}',
      currency: '${json['currency'] ?? 'CNY'}'.toUpperCase(),
      investAmount: _toDouble(json['investAmount']),
      couponId: _toInt(json['couponId']),
      userCouponId: _toInt(json['userCouponId']),
      couponName: '${json['couponName'] ?? ''}',
      couponType: '${json['couponType'] ?? ''}',
      couponDiscountAmount: _toDouble(json['couponDiscountAmount']),
      payAmount: _toDouble(json['payAmount']),
      effectiveRate: _toDouble(json['effectiveRate']),
      expectedIncome: _toDouble(json['expectedIncome']),
      cycleDays: _toInt(json['cycleDays']),
      status: '${json['status'] ?? '0'}',
      createTime: _toDateTime(json['createTime']),
      endTime: _toDateTime(json['endTime']),
      groupMode: '${json['groupMode'] ?? '0'}' == '1',
      groupId: _toInt(json['groupId']),
      groupNo: '${json['groupNo'] ?? ''}',
      groupStatus: '${json['groupStatus'] ?? '9'}',
      groupDeadlineTime: _toDateTime(json['groupDeadlineTime']),
      groupCountdownSeconds: _toInt(json['groupCountdownSeconds']),
    );
  }
}

class InvestIncomeData {
  const InvestIncomeData({
    required this.receivedInterest,
    required this.pendingInterest,
    required this.receivedPrincipal,
    required this.pendingPrincipal,
    required this.summaryByCurrency,
    required this.logs,
  });

  final double receivedInterest;
  final double pendingInterest;
  final double receivedPrincipal;
  final double pendingPrincipal;
  final List<InvestIncomeCurrencySummary> summaryByCurrency;
  final List<InvestIncomeLogItem> logs;

  factory InvestIncomeData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rows = _toList(json['logs']);
    final List<dynamic> summaryRows = _toList(json['summaryByCurrency']);
    return InvestIncomeData(
      receivedInterest: _toDouble(json['receivedInterest']),
      pendingInterest: _toDouble(json['pendingInterest']),
      receivedPrincipal: _toDouble(json['receivedPrincipal']),
      pendingPrincipal: _toDouble(json['pendingPrincipal']),
      summaryByCurrency: summaryRows
          .whereType<Map>()
          .map((dynamic item) => InvestIncomeCurrencySummary.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      logs: rows
          .whereType<Map>()
          .map((dynamic item) => InvestIncomeLogItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class InvestIncomeCurrencySummary {
  const InvestIncomeCurrencySummary({
    required this.currency,
    required this.receivedInterest,
    required this.pendingInterest,
    required this.receivedPrincipal,
    required this.pendingPrincipal,
  });

  final String currency;
  final double receivedInterest;
  final double pendingInterest;
  final double receivedPrincipal;
  final double pendingPrincipal;

  factory InvestIncomeCurrencySummary.fromJson(Map<String, dynamic> json) {
    return InvestIncomeCurrencySummary(
      currency: '${json['currency'] ?? 'CNY'}'.toUpperCase(),
      receivedInterest: _toDouble(json['receivedInterest']),
      pendingInterest: _toDouble(json['pendingInterest']),
      receivedPrincipal: _toDouble(json['receivedPrincipal']),
      pendingPrincipal: _toDouble(json['pendingPrincipal']),
    );
  }
}

class InvestIncomeLogItem {
  const InvestIncomeLogItem({
    required this.planId,
    required this.orderNo,
    required this.productName,
    required this.currency,
    required this.couponId,
    required this.userCouponId,
    required this.couponName,
    required this.couponType,
    required this.couponDiscountAmount,
    required this.payAmount,
    required this.planType,
    required this.planAmount,
    required this.status,
    required this.planTime,
    required this.execTime,
  });

  final int planId;
  final String orderNo;
  final String productName;
  final String currency;
  final int couponId;
  final int userCouponId;
  final String couponName;
  final String couponType;
  final double couponDiscountAmount;
  final double payAmount;
  final String planType;
  final double planAmount;
  final String status;
  final DateTime? planTime;
  final DateTime? execTime;

  factory InvestIncomeLogItem.fromJson(Map<String, dynamic> json) {
    return InvestIncomeLogItem(
      planId: _toInt(json['planId']),
      orderNo: '${json['orderNo'] ?? ''}',
      productName: '${json['productName'] ?? ''}',
      currency: '${json['currency'] ?? 'CNY'}'.toUpperCase(),
      couponId: _toInt(json['couponId']),
      userCouponId: _toInt(json['userCouponId']),
      couponName: '${json['couponName'] ?? ''}',
      couponType: '${json['couponType'] ?? ''}',
      couponDiscountAmount: _toDouble(json['couponDiscountAmount']),
      payAmount: _toDouble(json['payAmount']),
      planType: '${json['planType'] ?? ''}',
      planAmount: _toDouble(json['planAmount']),
      status: '${json['status'] ?? '0'}',
      planTime: _toDateTime(json['planTime']),
      execTime: _toDateTime(json['execTime']),
    );
  }
}

class InvestOrderDetailData {
  const InvestOrderDetailData({
    required this.order,
    required this.plans,
    required this.hasCoupon,
  });

  final InvestOrderListItem order;
  final List<InvestOrderPlanItem> plans;
  final bool hasCoupon;

  factory InvestOrderDetailData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> orderMap = _toMap(json['order']);
    final List<dynamic> planRows = _toList(json['plans']);
    return InvestOrderDetailData(
      order: InvestOrderListItem.fromJson(orderMap),
      plans: planRows
          .whereType<Map>()
          .map((dynamic item) => InvestOrderPlanItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      hasCoupon: _toBool(json['hasCoupon']) || _hasCoupon(orderMap),
    );
  }
}

class InvestOrderPlanItem {
  const InvestOrderPlanItem({
    required this.planId,
    required this.orderId,
    required this.userId,
    required this.planType,
    required this.stageNo,
    required this.planTime,
    required this.planRate,
    required this.planAmount,
    required this.status,
    required this.execTime,
    required this.remark,
  });

  final int planId;
  final int orderId;
  final int userId;
  final String planType;
  final int stageNo;
  final DateTime? planTime;
  final double planRate;
  final double planAmount;
  final String status;
  final DateTime? execTime;
  final String remark;

  factory InvestOrderPlanItem.fromJson(Map<String, dynamic> json) {
    return InvestOrderPlanItem(
      planId: _toInt(json['planId']),
      orderId: _toInt(json['orderId']),
      userId: _toInt(json['userId']),
      planType: '${json['planType'] ?? ''}',
      stageNo: _toInt(json['stageNo']),
      planTime: _toDateTime(json['planTime']),
      planRate: _toDouble(json['planRate']),
      planAmount: _toDouble(json['planAmount']),
      status: '${json['status'] ?? ''}',
      execTime: _toDateTime(json['execTime']),
      remark: '${json['remark'] ?? ''}',
    );
  }
}

class InvestWalletLogItem {
  const InvestWalletLogItem({
    required this.logId,
    required this.type,
    required this.currencyType,
    required this.amount,
    required this.status,
    required this.orderNo,
    required this.remark,
    required this.createTime,
  });

  final int logId;
  final String type;
  final String currencyType;
  final double amount;
  final String status;
  final String orderNo;
  final String remark;
  final DateTime? createTime;

  factory InvestWalletLogItem.fromJson(Map<String, dynamic> json) {
    return InvestWalletLogItem(
      logId: _toInt(json['logId']),
      type: '${json['type'] ?? ''}',
      currencyType: '${json['currencyType'] ?? 'CNY'}'.toUpperCase(),
      amount: _toDouble(json['amount']),
      status: '${json['status'] ?? ''}',
      orderNo: '${json['orderNo'] ?? ''}',
      remark: '${json['remark'] ?? ''}',
      createTime: _toDateTime(json['createTime']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse('${value ?? 0}') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final String text = '${value ?? ''}'.trim().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

DateTime? _toDateTime(dynamic value) {
  final String raw = '${value ?? ''}'.trim();
  if (raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

List<dynamic> _toList(dynamic value) {
  if (value is List) {
    return value;
  }
  return <dynamic>[];
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

bool _hasCoupon(Map<String, dynamic> json) {
  return _toInt(json['userCouponId']) > 0 ||
      _toDouble(json['couponDiscountAmount']) > 0 ||
      '${json['couponName'] ?? ''}'.trim().isNotEmpty ||
      (_toDouble(json['payAmount']) > 0 && (_toDouble(json['payAmount']) - _toDouble(json['investAmount'])).abs() > 0.000001);
}

Map<String, dynamic> _extractMap(dynamic data, Map<String, dynamic> raw) {
  final dynamic payload = data is Map<String, dynamic> ? (data['data'] ?? data) : (raw['data'] ?? raw);
  if (payload is Map<String, dynamic>) {
    return payload;
  }
  if (payload is Map) {
    return Map<String, dynamic>.from(payload);
  }
  return <String, dynamic>{};
}

List<dynamic> _extractList(dynamic data, Map<String, dynamic> raw) {
  final dynamic payload = data is Map<String, dynamic> ? (data['data'] ?? data) : (raw['data'] ?? raw);
  if (payload is List) {
    return payload;
  }
  if (payload is Map<String, dynamic>) {
    final dynamic rows = payload['rows'] ?? payload['list'] ?? payload['data'];
    if (rows is List) {
      return rows;
    }
  }
  if (payload is Map) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
    final dynamic rows = map['rows'] ?? map['list'] ?? map['data'];
    if (rows is List) {
      return rows;
    }
  }
  return <dynamic>[];
}
