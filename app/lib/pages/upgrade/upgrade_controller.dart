import 'package:flutter/foundation.dart';
import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/pages/upgrade/upgrade_service.dart';

class UpgradeController extends ChangeNotifier {
  bool _loading = false;
  bool _upgrading = false;
  UpgradeCheckResult? _result;
  String _messageKey = 'upgradeIdle';

  bool get loading => _loading;
  bool get upgrading => _upgrading;
  UpgradeCheckResult? get result => _result;
  String get messageKey => _messageKey;

  /// 检查远端升级配置并更新状态。
  Future<void> check() async {
    _loading = true;
    _messageKey = 'upgradeChecking';
    notifyListeners();

    try {
      _result = await UpgradeService.checkUpgrade();
      if (_result!.needUpgrade) {
        _messageKey = 'upgradeFound';
      } else {
        _messageKey = 'upgradeLatest';
      }
    } catch (_) {
      _messageKey = 'upgradeCheckFailed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 执行当前平台升级动作。
  Future<void> doUpgrade() async {
    if (_result == null || !_result!.canUpgradeAction) {
      _messageKey = 'upgradeNoAction';
      notifyListeners();
      return;
    }

    _upgrading = true;
    _messageKey = 'upgradeStarting';
    notifyListeners();

    try {
      await UpgradeService.executeUpgrade(_result!);
      _messageKey = 'upgradeTriggered';
    } catch (_) {
      _messageKey = 'upgradeStartFailed';
    } finally {
      _upgrading = false;
      notifyListeners();
    }
  }
}
