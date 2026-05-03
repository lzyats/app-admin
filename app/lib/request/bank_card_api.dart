import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class BankCardItem {
  const BankCardItem({
    required this.bankCardId,
    required this.userId,
    required this.userName,
    required this.currencyType,
    this.bankName,
    this.accountNo,
    this.accountName,
    this.walletAddress,
    this.remark,
    this.createTime,
  });

  final int bankCardId;
  final int userId;
  final String userName;
  final String currencyType;
  final String? bankName;
  final String? accountNo;
  final String? accountName;
  final String? walletAddress;
  final String? remark;
  final String? createTime;

  factory BankCardItem.fromJson(Map<String, dynamic> json) {
    return BankCardItem(
      bankCardId: int.tryParse('${json['bankCardId'] ?? json['bank_card_id'] ?? 0}') ?? 0,
      userId: int.tryParse('${json['userId'] ?? json['user_id'] ?? 0}') ?? 0,
      userName: (json['userName'] ?? json['user_name'] ?? '').toString(),
      currencyType: (json['currencyType'] ?? json['currency_type'] ?? 'CNY').toString(),
      bankName: (json['bankName'] ?? json['bank_name'])?.toString(),
      accountNo: (json['accountNo'] ?? json['account_no'])?.toString(),
      accountName: (json['accountName'] ?? json['account_name'])?.toString(),
      walletAddress: (json['walletAddress'] ?? json['wallet_address'])?.toString(),
      remark: (json['remark'])?.toString(),
      createTime: (json['createTime'] ?? json['create_time'])?.toString(),
    );
  }
}

class BankCardApi {
  BankCardApi._();

  static Future<List<BankCardItem>> getMyBankCards({
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    final res = await HttpClient.get(
      RuoYiEndpoints.bankCardList,
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
      return <BankCardItem>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => BankCardItem.fromJson(item))
        .toList();
  }

  static Future<void> addBankCard({
    required String currencyType,
    String? bankName,
    String? accountNo,
    String? accountName,
    String? walletAddress,
    String? remark,
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.bankCardAdd,
      data: <String, dynamic>{
        'currencyType': currencyType,
        if (bankName != null) 'bankName': bankName,
        if (accountNo != null) 'accountNo': accountNo,
        if (accountName != null) 'accountName': accountName,
        if (walletAddress != null) 'walletAddress': walletAddress,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      },
      encrypt: true,
    );
  }

  static Future<void> deleteBankCard(int bankCardId) async {
    await HttpClient.post(
      RuoYiEndpoints.bankCardDelete,
      data: <String, dynamic>{
        'bankCardId': bankCardId,
      },
      encrypt: true,
    );
  }
}
