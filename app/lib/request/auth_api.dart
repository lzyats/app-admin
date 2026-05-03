import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:myapp/tools/auth_tool.dart';

class CaptchaPayload {
  const CaptchaPayload({
    required this.uuid,
    required this.img,
    required this.captchaEnabled,
    required this.imageBase64,
  });

  final String uuid;
  final String img;
  final bool captchaEnabled;
  final String imageBase64;

  factory CaptchaPayload.fromJson(Map<String, dynamic> json) {
    final bool captchaOn = json['captchaEnabled'] == true ||
        json['captchaEnabled'] == 'true' ||
        json['captchaEnabled'] == 1;
    final String uuidStr = (json['uuid'] ?? json['UUID'] ?? '').toString();
    final String imgStr =
        (json['img'] ?? json['image'] ?? json['imageBase64'] ?? '').toString();

    return CaptchaPayload(
      uuid: uuidStr,
      img: imgStr,
      captchaEnabled: captchaOn,
      imageBase64: imgStr,
    );
  }
}

class CaptchaResponse {
  final String uuid;
  final String img;
  final bool captchaEnabled;

  const CaptchaResponse(this.uuid, this.img, this.captchaEnabled);

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) {
    return CaptchaResponse(
      (json['uuid'] ?? '').toString(),
      (json['img'] ?? '').toString(),
      json['captchaEnabled'] == true ||
          json['captchaEnabled'] == 'true' ||
          json['captchaEnabled'] == 1,
    );
  }
}

class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
    required this.code,
    required this.uuid,
  });

  final String username;
  final String password;
  final String code;
  final String uuid;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'code': code,
      'uuid': uuid,
    };
  }
}

class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUserProfile user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawToken = json['token'] ?? json['data'];
    return LoginResponse(
      token: rawToken == null ? '' : rawToken.toString(),
      user: AuthUserProfile.fromJson(json),
    );
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.password,
    required this.nickName,
    required this.inviteCode,
    required this.code,
    required this.uuid,
    this.phonenumber,
    this.email,
  });

  final String username;
  final String password;
  final String nickName;
  final String inviteCode;
  final String code;
  final String uuid;
  final String? phonenumber;
  final String? email;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'nickName': nickName,
      'inviteCode': inviteCode,
      'code': code,
      'uuid': uuid,
      if (phonenumber != null) 'phonenumber': phonenumber,
      if (email != null) 'email': email,
    };
  }
}

class AuthUserProfile {
  const AuthUserProfile({
    required this.userId,
    required this.username,
    required this.nickName,
    this.balance,
    this.usdBalance,
    this.usdExchangeQuota,
    this.payPasswordSet,
    this.securityQuestionSet,
    this.avatar,
    this.email,
    this.phonenumber,
    this.sex,
    this.level,
    this.inviteCode,
    this.levelDetail,
    this.userLevel,
    this.birthday,
    this.remark,
    this.realNameStatus,
    this.growthValue, // 新增成长值字段
    this.teamLeaderLevel,
  });

  final int userId;
  final String username;
  final String nickName;
  final String? balance;
  final String? usdBalance;
  final String? usdExchangeQuota;
  final int? payPasswordSet;
  final int? securityQuestionSet;
  final String? avatar;
  final String? email;
  final String? phonenumber;
  final int? sex;
  final int? level;
  final String? inviteCode;
  final String? levelDetail;
  final int? userLevel;
  final String? birthday;
  final String? remark;
  final int? realNameStatus;
  final int? growthValue; // 新增成长值字段
  final int? teamLeaderLevel;

  String? get resolvedAvatarUrl => ApiClient.instance.resolveImageUrl(avatar);

  AuthUserProfile copyWith({
    int? userId,
    String? username,
    String? nickName,
    String? balance,
    String? usdBalance,
    String? usdExchangeQuota,
    int? payPasswordSet,
    int? securityQuestionSet,
    String? avatar,
    String? email,
    String? phonenumber,
    int? sex,
    int? level,
    String? inviteCode,
    String? levelDetail,
    int? userLevel,
    String? birthday,
    String? remark,
    int? realNameStatus,
    int? growthValue, // 新增成长值字段
    int? teamLeaderLevel,
  }) {
    return AuthUserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      nickName: nickName ?? this.nickName,
      balance: balance ?? this.balance,
      usdBalance: usdBalance ?? this.usdBalance,
      usdExchangeQuota: usdExchangeQuota ?? this.usdExchangeQuota,
      payPasswordSet: payPasswordSet ?? this.payPasswordSet,
      securityQuestionSet: securityQuestionSet ?? this.securityQuestionSet,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      sex: sex ?? this.sex,
      level: level ?? this.level,
      inviteCode: inviteCode ?? this.inviteCode,
      levelDetail: levelDetail ?? this.levelDetail,
      userLevel: userLevel ?? this.userLevel,
      birthday: birthday ?? this.birthday,
      remark: remark ?? this.remark,
      realNameStatus: realNameStatus ?? this.realNameStatus,
      growthValue: growthValue ?? this.growthValue, // 新增成长值字段
      teamLeaderLevel: teamLeaderLevel ?? this.teamLeaderLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': username,
      'nickName': nickName,
      if (balance != null) 'balance': balance,
      if (usdBalance != null) 'usdBalance': usdBalance,
      if (usdExchangeQuota != null) 'usdExchangeQuota': usdExchangeQuota,
      if (payPasswordSet != null) 'payPasswordSet': payPasswordSet,
      if (securityQuestionSet != null)
        'securityQuestionSet': securityQuestionSet,
      if (avatar != null) 'avatar': avatar,
      if (email != null) 'email': email,
      if (phonenumber != null) 'phonenumber': phonenumber,
      if (sex != null) 'sex': sex,
      if (level != null) 'level': level,
      if (inviteCode != null) 'inviteCode': inviteCode,
      if (levelDetail != null) 'levelDetail': levelDetail,
      if (userLevel != null) 'userLevel': userLevel,
      if (birthday != null) 'birthday': birthday,
      if (remark != null) 'remark': remark,
      if (realNameStatus != null) 'realNameStatus': realNameStatus,
      if (growthValue != null) 'growthValue': growthValue,
      if (teamLeaderLevel != null) 'teamLeaderLevel': teamLeaderLevel,
    };
  }

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? user;
    final userData = json['user'];
    if (userData is Map<String, dynamic>) {
      user = userData;
    }

    return AuthUserProfile(
      userId: _getIntValue(user?['userId'] ?? json['userId']),
      username: _getStringValue(user?['userName'] ?? json['userName']),
      nickName: _getStringValue(user?['nickName'] ?? json['nickName']),
      balance: _getStringValue(user?['balance'] ?? json['balance'],
          allowEmpty: true),
      usdBalance: _getStringValue(user?['usdBalance'] ?? json['usdBalance'],
          allowEmpty: true),
      usdExchangeQuota: _getStringValue(
          user?['usdExchangeQuota'] ?? json['usdExchangeQuota'],
          allowEmpty: true),
      payPasswordSet: _getNullableIntValue(user?['payPasswordSet'] ??
          user?['pay_password_set'] ??
          json['payPasswordSet'] ??
          json['pay_password_set']),
      securityQuestionSet: _getNullableIntValue(user?['securityQuestionSet'] ??
          user?['security_question_set'] ??
          json['securityQuestionSet'] ??
          json['security_question_set']),
      avatar:
          _getStringValue(user?['avatar'] ?? json['avatar'], allowEmpty: true),
      email: _getStringValue(user?['email'] ?? json['email'], allowEmpty: true),
      phonenumber: _getStringValue(user?['phonenumber'] ?? json['phonenumber'],
          allowEmpty: true),
      sex: _getIntValue(user?['sex'] ?? json['sex']),
      level: _getIntValue(user?['level'] ?? json['level']),
      inviteCode: _getStringValue(user?['inviteCode'] ?? json['inviteCode'],
          allowEmpty: true),
      levelDetail: _getStringValue(user?['levelDetail'] ?? json['levelDetail'],
          allowEmpty: true),
      userLevel: _getIntValue(user?['userLevel'] ?? json['userLevel']),
      birthday: _getStringValue(user?['birthday'] ?? json['birthday'],
          allowEmpty: true),
      remark:
          _getStringValue(user?['remark'] ?? json['remark'], allowEmpty: true),
      realNameStatus:
          _getIntValue(user?['realNameStatus'] ?? json['realNameStatus']),
      growthValue: _getNullableIntValue(
          user?['growthValue'] ?? user?['growth_value'] ?? json['growthValue'] ?? json['growth_value']),
      teamLeaderLevel: _getNullableIntValue(
          user?['teamLeaderLevel'] ?? user?['team_leader_level'] ?? json['teamLeaderLevel'] ?? json['team_leader_level']),
    );
  }

  static int _getIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _getStringValue(dynamic value, {bool allowEmpty = false}) {
    if (value == null) return '';
    final str = value.toString();
    if (!allowEmpty && str.isEmpty) return '';
    return str;
  }

  static int? _getNullableIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return int.tryParse(trimmed);
    }
    return null;
  }
}

class AuthApi {
  AuthApi._();

  static Future<AuthUserProfile>? _pendingGetInfo;
  static const Duration _userProfileCacheMaxAge = Duration(minutes: 5);

  static Future<CaptchaPayload> captcha() async {
    try {
      final ApiResponse<dynamic> resp = await ApiClient.instance.get(
        RuoYiEndpoints.captchaImage,
        encrypt: true,
        retry: false,
      );

      final Map<String, dynamic>? payload =
          _asStringKeyMap(resp.raw.isNotEmpty ? resp.raw : resp.data);
      if (payload != null) {
        if (kDebugMode) {
          debugPrint(
              'AuthApi.captcha parsed uuid=${payload['uuid']} enabled=${payload['captchaEnabled']}');
        }
        return CaptchaPayload.fromJson(payload);
      }

      return const CaptchaPayload(
          uuid: '', img: '', captchaEnabled: true, imageBase64: '');
    } catch (e) {
      return const CaptchaPayload(
          uuid: '', img: '', captchaEnabled: true, imageBase64: '');
    }
  }

  static Future<CaptchaResponse> getCaptcha() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.captchaImage,
      encrypt: true,
      retry: false,
    );

    final Map<String, dynamic>? payload =
        _asStringKeyMap(resp.raw.isNotEmpty ? resp.raw : resp.data);
    if (payload != null) {
      return CaptchaResponse.fromJson(payload);
    }
    return const CaptchaResponse('', '', true);
  }

  static Future<LoginResponse> login(LoginRequest request) async {
    if (kDebugMode) {
      debugPrint('AuthApi.login payload=${request.toJson()}');
    }
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.appLogin,
      data: request.toJson(),
      encrypt: true,
      retry: false,
    );

    if (resp.raw.isNotEmpty) {
      return LoginResponse.fromJson(resp.raw);
    } else {
      return const LoginResponse(
          token: '',
          user: AuthUserProfile(userId: 0, username: '', nickName: ''));
    }
  }

  static Future<String> loginWithParams({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) async {
    final LoginRequest request = LoginRequest(
      username: username,
      password: password,
      code: code,
      uuid: uuid,
    );
    final LoginResponse response = await login(request);
    await AuthTool.login(response.token);
    await AuthTool.saveUserProfile(response.user);
    return response.token;
  }

  static Future<bool> logout() async {
    await ApiClient.instance.post(
      RuoYiEndpoints.logout,
      encrypt: true,
    );
    return true;
  }

  static Future<AuthUserProfile> getInfo({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final AuthUserProfile? cached = await AuthTool.getUserProfile();
      if (cached != null && cached.userId > 0) {
        final AuthUserProfile? fresh = await AuthTool.getFreshUserProfile(
          maxAge: _userProfileCacheMaxAge,
        );
        if (fresh == null) {
          unawaited(_refreshInfoInBackground());
        }
        return cached;
      }
    }

    final Future<AuthUserProfile>? pending = _pendingGetInfo;
    if (pending != null) {
      return pending;
    }

    final Future<AuthUserProfile> request = _fetchInfo();
    _pendingGetInfo = request;
    try {
      return await request;
    } on ApiException catch (e) {
      if (e.code == 401 || e.code == 10001 || e.code == 10002) {
        rethrow;
      }
      final AuthUserProfile? cached = await AuthTool.getUserProfile();
      if (cached != null && cached.userId > 0) {
        return cached;
      }
      rethrow;
    } catch (_) {
      final AuthUserProfile? cached = await AuthTool.getUserProfile();
      if (cached != null && cached.userId > 0) {
        return cached;
      }
      rethrow;
    } finally {
      if (identical(_pendingGetInfo, request)) {
        _pendingGetInfo = null;
      }
    }
  }

  static Future<void> _refreshInfoInBackground() async {
    if (_pendingGetInfo != null) {
      return;
    }
    try {
      await _fetchInfo();
    } catch (_) {}
  }

  static Future<AuthUserProfile> _fetchInfo() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.getInfo,
      encrypt: true,
    );

    final dynamic payload = resp.data;
    if (payload is Map<String, dynamic>) {
      final AuthUserProfile profile = AuthUserProfile.fromJson(payload);
      await AuthTool.saveUserProfile(profile);
      return profile;
    }

    if (resp.raw.isNotEmpty) {
      final AuthUserProfile profile = AuthUserProfile.fromJson(resp.raw);
      await AuthTool.saveUserProfile(profile);
      return profile;
    }

    const AuthUserProfile profile =
        AuthUserProfile(userId: 0, username: '', nickName: '');
    return profile;
  }

  static Future<LoginResponse> register(RegisterRequest request) async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.appRegister,
      data: request.toJson(),
      encrypt: true,
      retry: false,
    );
    final Map<String, dynamic>? payload =
        _asStringKeyMap(resp.raw.isNotEmpty ? resp.raw : resp.data);
    if (payload != null) {
      return LoginResponse.fromJson(payload);
    }
    return const LoginResponse(
        token: '', user: AuthUserProfile(userId: 0, username: '', nickName: ''));
  }

  static Future<String> registerWithParams({
    required String username,
    required String password,
    required String inviteCode,
    required String code,
    required String uuid,
  }) async {
    final RegisterRequest request = RegisterRequest(
      username: username,
      password: password,
      nickName: username,
      inviteCode: inviteCode,
      code: code,
      uuid: uuid,
    );
    final LoginResponse response = await register(request);
    await AuthTool.login(response.token);
    await AuthTool.saveUserProfile(response.user);
    return response.token;
  }

  static Future<ApiResponse<dynamic>> verifyPayPassword(String password) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.verifyPayPassword,
      data: {
        'payPwd': password,
        'password': password,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updateLoginPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.updatePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updatePayPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.updatePayPassword,
      data: {
        'oldPayPwd': oldPassword,
        'newPayPwd': newPassword,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> setPayPassword(String password) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.setPayPassword,
      data: {
        'payPassword': password,
        'password': password,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> setPayPwd(
      int userId, String password) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.setPayPassword,
      data: {
        'userId': userId,
        'payPassword': password,
        'password': password,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updateProfile(
      {String? email, String? phonenumber, String? nickName}) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.updateUserInfo,
      data: {
        if (email != null) 'email': email,
        if (phonenumber != null) 'phonenumber': phonenumber,
        if (nickName != null) 'nickName': nickName,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updatePasswordWithSecurityQuestions({
    String? oldPassword,
    required String newPassword,
    required List<SecurityAnswerBody> answers,
  }) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.updatePasswordBySecurity,
      data: {
        if (oldPassword != null) 'oldPassword': oldPassword,
        'newPassword': newPassword,
        'answers': answers.map((a) => a.toJson()).toList(),
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updatePayPasswordWithSecurityQuestions({
    String? oldPassword,
    required String newPassword,
    required List<SecurityAnswerBody> answers,
  }) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.updatePayPasswordBySecurity,
      data: {
        if (oldPassword != null) 'oldPassword': oldPassword,
        'newPassword': newPassword,
        'answers': answers.map((a) => a.toJson()).toList(),
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updatePassword(
      {required String oldPassword, required String newPassword}) async {
    return updateLoginPassword(
        oldPassword: oldPassword, newPassword: newPassword);
  }

  static Future<ApiResponse<dynamic>> updatePayPwd(
      dynamic userId, String oldPassword, String newPassword) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.updatePayPassword,
      data: {
        if (userId != null) 'userId': userId,
        'oldPayPwd': oldPassword,
        'newPayPwd': newPassword,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> resetPayPassword({
    required String newPassword,
    required String code,
    required String uuid,
  }) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.resetPayPassword,
      data: {
        'newPayPwd': newPassword,
        'newPassword': newPassword,
        'code': code,
        'uuid': uuid,
      },
      encrypt: true,
      retry: false,
    );
  }

  static Future<ApiResponse<dynamic>> forgotPasswordBySecurity({
    required String username,
    required String newPassword,
    required List<SecurityAnswerBody> answers,
    required String code,
    required String uuid,
  }) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.forgotPasswordBySecurity,
      data: {
        'username': username,
        'newPassword': newPassword,
        'answers': answers.map((a) => a.toJson()).toList(),
        'code': code,
        'uuid': uuid,
      },
      encrypt: true,
      retry: false,
    );
  }

  static Future<List<UserSecurityQuestion>> getUserSecurityQuestions(
      String username) async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.getUserSecurityQuestions,
      data: {'username': username},
      encrypt: true,
    );

    if (resp.data is List) {
      final List<dynamic> dataList = resp.data as List<dynamic>;
      return dataList
          .map((item) => UserSecurityQuestion.fromJson(item))
          .toList();
    }
    return [];
  }

  static Future<List<SecurityQuestion>> getSecurityQuestions(
      {String lang = 'zh'}) async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.securityQuestions,
      data: {'lang': lang},
      encrypt: true,
    );

    if (resp.data is List) {
      final List<dynamic> dataList = resp.data as List<dynamic>;
      return dataList
          .map(
              (item) => SecurityQuestion.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<List<UserSecurityAnswer>> getMySecurityAnswers() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.getMySecurityAnswers,
      encrypt: true,
    );

    if (resp.data is List) {
      final List<dynamic> dataList = resp.data as List<dynamic>;
      return dataList
          .map((item) =>
              UserSecurityAnswer.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<ApiResponse<dynamic>> saveSecurityQuestions(
      List<SecurityQuestionAnswer> answers) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.saveSecurityQuestions,
      data: answers.map((a) => a.toJson()).toList(),
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> setSecurityAnswers(
      List<SecurityAnswerBody> answers) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.saveSecurityQuestions,
      data: answers.map((a) => a.toJson()).toList(),
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> updateUserInfo(
      Map<String, dynamic> userInfo) async {
    return ApiClient.instance.put(
      RuoYiEndpoints.updateUserInfo,
      data: userInfo,
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> getMyPointAccount() async {
    return ApiClient.instance.get(
      RuoYiEndpoints.appPointAccount,
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> getMyPointLogs({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    return ApiClient.instance.get(
      RuoYiEndpoints.appPointLogList,
      query: {
        'pageNum': pageNum,
        'pageSize': pageSize,
      },
      encrypt: true,
    );
  }

  static Future<ApiResponse<dynamic>> exchangeCurrency(
      String fromCurrency, String toCurrency, double amount) async {
    return ApiClient.instance.post(
      RuoYiEndpoints.appUserExchangeCurrency,
      data: {
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'amount': double.parse(amount.toStringAsFixed(2)),
      },
      encrypt: true,
    );
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}

class UserSecurityQuestion {
  const UserSecurityQuestion({
    required this.questionId,
    required this.questionText,
  });

  final int questionId;
  final String questionText;

  factory UserSecurityQuestion.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return UserSecurityQuestion(
        questionId: int.tryParse(json['questionId']?.toString() ?? '') ?? 0,
        questionText: (json['questionText'] ?? '').toString(),
      );
    }
    return const UserSecurityQuestion(questionId: 0, questionText: '');
  }
}

class SecurityQuestionAnswer {
  const SecurityQuestionAnswer({
    required this.questionId,
    required this.answer,
  });

  final int questionId;
  final String answer;

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }
}

class UserSecurityAnswer {
  const UserSecurityAnswer({
    required this.answerId,
    required this.userId,
    required this.questionId,
    required this.answer,
    this.questionText,
  });

  final int answerId;
  final int userId;
  final int questionId;
  final String answer;
  final String? questionText;

  factory UserSecurityAnswer.fromJson(Map<String, dynamic> json) {
    return UserSecurityAnswer(
      answerId: int.tryParse(json['answerId']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      questionId: int.tryParse(json['questionId']?.toString() ?? '') ?? 0,
      answer: (json['answer'] ?? '').toString(),
      questionText: (json['questionText'] ?? '').toString(),
    );
  }
}

class SecurityQuestion {
  const SecurityQuestion({
    required this.questionId,
    required this.questionText,
  });

  final int questionId;
  final String questionText;

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      questionId: int.tryParse(json['questionId']?.toString() ?? '') ?? 0,
      questionText: (json['questionText'] ?? '').toString(),
    );
  }
}

class SecurityAnswerBody {
  const SecurityAnswerBody({
    required this.questionId,
    required this.answer,
  });

  final int questionId;
  final String answer;

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }
}
