import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class UpgradeApi {
  const UpgradeApi._();

  /// 获取服务端升级配置。
  static Future<UpgradeConfig> fetchUpgradeConfig() async {
    final response = await HttpClient.get(
      RuoYiEndpoints.upgradeConfig,
      encrypt: false,
      retry: true,
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return UpgradeConfig.fromJson(data);
    }
    if (data is Map) {
      return UpgradeConfig.fromJson(Map<String, dynamic>.from(data));
    }
    return UpgradeConfig.fromJson(const <String, dynamic>{});
  }
}
