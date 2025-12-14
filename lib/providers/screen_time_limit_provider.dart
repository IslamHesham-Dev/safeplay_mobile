import 'package:flutter/foundation.dart';

import '../models/screen_time_limit_settings.dart';
import '../services/screen_time_limit_service.dart';

class ScreenTimeLimitProvider extends ChangeNotifier {
  ScreenTimeLimitProvider(this._service);

  final ScreenTimeLimitService _service;

  final Map<String, ScreenTimeLimitSettings> _settingsByChild = {};
  final Set<String> _loadingChildIds = <String>{};
  final Set<String> _savingChildIds = <String>{};
  final Map<String, String?> _errors = {};

  ScreenTimeLimitSettings? settingsFor(String childId) =>
      _settingsByChild[childId];

  bool isLoading(String childId) => _loadingChildIds.contains(childId);

  bool isSaving(String childId) => _savingChildIds.contains(childId);

  String? errorFor(String childId) => _errors[childId];

  Future<void> loadSettings(String childId) async {
    if (childId.isEmpty || _loadingChildIds.contains(childId)) return;
    _loadingChildIds.add(childId);
    notifyListeners();
    try {
      final settings = await _service.fetchSettings(childId);
      _settingsByChild[childId] = settings;
      _errors.remove(childId);
    } catch (error) {
      _errors[childId] = error.toString();
    } finally {
      _loadingChildIds.remove(childId);
      notifyListeners();
    }
  }

  Future<void> setLimit(
    String childId, {
    required bool isEnabled,
    required int dailyLimitMinutes,
  }) async {
    if (childId.isEmpty) return;
    _savingChildIds.add(childId);
    notifyListeners();
    try {
      final updated = await _service.updateLimit(
        childId,
        isEnabled: isEnabled,
        dailyLimitMinutes: dailyLimitMinutes,
      );
      _settingsByChild[childId] = updated;
      _errors.remove(childId);
    } catch (error) {
      _errors[childId] = error.toString();
    } finally {
      _savingChildIds.remove(childId);
      notifyListeners();
    }
  }

  Future<void> unlockLimit(String childId) async {
    if (childId.isEmpty) return;
    _savingChildIds.add(childId);
    notifyListeners();
    try {
      final updated = await _service.unlock(childId);
      _settingsByChild[childId] = updated;
      _errors.remove(childId);
    } catch (error) {
      _errors[childId] = error.toString();
    } finally {
      _savingChildIds.remove(childId);
      notifyListeners();
    }
  }

  Future<ScreenTimeLimitSettings?> recordUsage(
    String childId,
    int minutes,
  ) async {
    if (childId.isEmpty || minutes <= 0) return _settingsByChild[childId];
    try {
      final updated = await _service.recordUsage(childId, minutes);
      _settingsByChild[childId] = updated;
      _errors.remove(childId);
      notifyListeners();
      return updated;
    } catch (error) {
      _errors[childId] = error.toString();
      notifyListeners();
      return null;
    }
  }

  /// Real-time stream of settings for a child, updates local cache.
  Stream<ScreenTimeLimitSettings> watchSettings(String childId) {
    if (childId.isEmpty) {
      return const Stream.empty();
    }
    return _service.listenSettings(childId).map((settings) {
      _settingsByChild[childId] = settings;
      _errors.remove(childId);
      notifyListeners();
      return settings;
    });
  }
}
