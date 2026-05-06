import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class CardPackageItem {
  const CardPackageItem({
    required this.cardId,
    required this.userCouponId,
    required this.userTrialId,
    required this.cardName,
    required this.cardType,
    required this.userStatus,
    required this.isUsing,
    required this.remainingSeconds,
    required this.startTime,
    required this.endTime,
    required this.grantType,
    required this.remark,
    this.templateStartTime,
    this.templateEndTime,
    this.canStart = false,
    this.scopeType,
    this.productIdsJson,
    this.minAmount,
    this.discountAmount,
    this.bonusPrincipal,
    this.bonusRate,
    this.experiencePrincipal,
    this.minExperienceUnits,
    this.maxExperienceUnits,
    this.trialLevel,
    this.validDays,
    this.originalLevel,
    this.currentLevel,
  });

  final int cardId;
  final int userCouponId;
  final int userTrialId;
  final String cardName;
  final String cardType;
  final String userStatus;
  final bool isUsing;
  final int remainingSeconds;
  final DateTime? startTime;
  final DateTime? endTime;
  final String grantType;
  final String? remark;
  final DateTime? templateStartTime;
  final DateTime? templateEndTime;
  final bool canStart;
  final String? scopeType;
  final String? productIdsJson;
  final double? minAmount;
  final double? discountAmount;
  final double? bonusPrincipal;
  final double? bonusRate;
  final double? experiencePrincipal;
  final int? minExperienceUnits;
  final int? maxExperienceUnits;
  final int? trialLevel;
  final int? validDays;
  final int? originalLevel;
  final int? currentLevel;

  factory CardPackageItem.fromJson(Map<String, dynamic> json) {
    return CardPackageItem(
      cardId: int.tryParse('${json['cardId'] ?? json['card_id'] ?? 0}') ?? 0,
      userCouponId: int.tryParse('${json['userCouponId'] ?? json['user_coupon_id'] ?? 0}') ?? 0,
      userTrialId: int.tryParse('${json['userTrialId'] ?? json['user_trial_id'] ?? 0}') ?? 0,
      cardName: (json['cardName'] ?? json['card_name'] ?? '').toString(),
      cardType: (json['cardType'] ?? json['card_type'] ?? '').toString(),
      userStatus: (json['userStatus'] ?? json['user_status'] ?? '').toString(),
      isUsing: _parseBool(json['isUsing'] ?? json['is_using'] ?? json['userStatus'] ?? json['user_status']),
      remainingSeconds: int.tryParse('${json['remainingSeconds'] ?? json['remaining_seconds'] ?? 0}') ?? 0,
      startTime: _parseDateTime(json['startTime'] ?? json['start_time']),
      endTime: _parseDateTime(json['endTime'] ?? json['end_time']),
      grantType: (json['grantType'] ?? json['grant_type'] ?? '').toString(),
      remark: (json['remark'])?.toString(),
      templateStartTime: _parseDateTime(json['templateStartTime'] ?? json['template_start_time']),
      templateEndTime: _parseDateTime(json['templateEndTime'] ?? json['template_end_time']),
      canStart: _parseBool(json['canStart'] ?? json['can_start']),
      scopeType: (json['scopeType'] ?? json['scope_type'])?.toString(),
      productIdsJson: (json['productIdsJson'] ?? json['product_ids_json'])?.toString(),
      minAmount: _parseDouble(json['minAmount'] ?? json['min_amount']),
      discountAmount: _parseDouble(json['discountAmount'] ?? json['discount_amount']),
      bonusPrincipal: _parseDouble(json['bonusPrincipal'] ?? json['bonus_principal']),
      bonusRate: _parseDouble(json['bonusRate'] ?? json['bonus_rate']),
      experiencePrincipal: _parseDouble(json['experiencePrincipal'] ?? json['experience_principal']),
      minExperienceUnits: _parseInt(json['minExperienceUnits'] ?? json['min_experience_units']),
      maxExperienceUnits: _parseInt(json['maxExperienceUnits'] ?? json['max_experience_units']),
      trialLevel: _parseInt(json['trialLevel'] ?? json['trial_level']),
      validDays: _parseInt(json['validDays'] ?? json['valid_days']),
      originalLevel: _parseInt(json['originalLevel'] ?? json['original_level']),
      currentLevel: _parseInt(json['currentLevel'] ?? json['current_level']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return int.tryParse(text);
  }

  static bool _parseBool(dynamic value) {
    if (value == null) {
      return false;
    }
    if (value is bool) {
      return value;
    }
    final String text = value.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes' || text == 'y';
  }
}

class CardPackageApi {
  CardPackageApi._();

  static Future<List<CardPackageItem>> fetchCoupons() async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appCardPackageCoupons,
      encrypt: true,
      retry: true,
    );
    return _parseList(res.data);
  }

  static Future<List<CardPackageItem>> fetchTrials() async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appCardPackageTrials,
      encrypt: true,
      retry: true,
    );
    return _parseList(res.data);
  }

  static Future<CardPackageItem> useTrialCard(int userTrialId) async {
    return startTrialCard(userTrialId);
  }

  static Future<CardPackageItem> startTrialCard(int userTrialId) async {
    final res = await HttpClient.post(
      RuoYiEndpoints.appCardPackageTrialStart,
      data: <String, dynamic>{
        'userTrialId': userTrialId,
      },
      encrypt: true,
      retry: false,
    );
    final dynamic raw = res.data;
    if (raw is Map<String, dynamic>) {
      final dynamic nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return CardPackageItem.fromJson(nested);
      }
      return CardPackageItem.fromJson(raw);
    }
    if (res.raw is Map<String, dynamic>) {
      final Map<String, dynamic> rawMap = res.raw as Map<String, dynamic>;
      final dynamic nested = rawMap['data'];
      if (nested is Map<String, dynamic>) {
        return CardPackageItem.fromJson(nested);
      }
      return CardPackageItem.fromJson(rawMap);
    }
    throw Exception('Invalid trial card response');
  }

  static Future<CardPackageItem> endTrialCard(int userTrialId) async {
    final res = await HttpClient.post(
      RuoYiEndpoints.appCardPackageTrialEnd,
      data: <String, dynamic>{
        'userTrialId': userTrialId,
      },
      encrypt: true,
      retry: false,
    );
    final dynamic raw = res.data;
    if (raw is Map<String, dynamic>) {
      final dynamic nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return CardPackageItem.fromJson(nested);
      }
      return CardPackageItem.fromJson(raw);
    }
    if (res.raw is Map<String, dynamic>) {
      final Map<String, dynamic> rawMap = res.raw as Map<String, dynamic>;
      final dynamic nested = rawMap['data'];
      if (nested is Map<String, dynamic>) {
        return CardPackageItem.fromJson(nested);
      }
      return CardPackageItem.fromJson(rawMap);
    }
    throw Exception('Invalid trial card response');
  }

  static List<CardPackageItem> _parseList(dynamic raw) {
    if (raw is! List) {
      return <CardPackageItem>[];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CardPackageItem.fromJson)
        .toList();
  }
}

