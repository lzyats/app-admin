import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class RealNameApi {
  Future<Map<String, dynamic>> status() async {
    final response = await ApiClient.instance.post(
      RuoYiEndpoints.realNameStatus,
      encrypt: true,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<String> submit({
    required String realName,
    required String idCardNumber,
    required String idCardFront,
    required String idCardBack,
    String? handheldPhoto,
  }) async {
    final response = await ApiClient.instance.post(
      RuoYiEndpoints.realNameSubmit,
      data: {
        'realName': realName,
        'idCardNumber': idCardNumber,
        'idCardFront': idCardFront,
        'idCardBack': idCardBack,
        'handheldPhoto': handheldPhoto,
      },
      encrypt: true,
    );
    return response.msg ?? '提交成功';
  }
}
