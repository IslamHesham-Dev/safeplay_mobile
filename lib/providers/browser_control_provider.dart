import 'package:flutter/foundation.dart';

import '../models/browser_control_settings.dart';
import '../services/browser_control_service.dart';

class BrowserControlProvider extends ChangeNotifier {
  BrowserControlProvider(this._service);

  final BrowserControlService _service;

  final Map<String, BrowserControlSettings> _settingsByChild = {};
  final Set<String> _loadingChildIds = <String>{};
  final Set<String> _savingChildIds = <String>{};
  final Map<String, String?> _errors = {};

  BrowserControlSettings? settingsFor(String childId) =>
      _settingsByChild[childId];
  bool isLoading(String childId) => _loadingChildIds.contains(childId);
  bool isSaving(String childId) => _savingChildIds.contains(childId);
  String? errorFor(String childId) => _errors[childId];

  Future<void> loadSettings(String childId, {bool forceRefresh = false}) async {
    if (childId.isEmpty) return;
    if (!forceRefresh &&
        (_settingsByChild.containsKey(childId) ||
            _loadingChildIds.contains(childId))) {
      return;
    }
    _loadingChildIds.add(childId);
    notifyListeners();
    try {
      final settings = await _service.fetchSettings(childId);
      _settingsByChild[childId] = settings;
      _errors.remove(childId);
    } catch (error) {
      debugPrint('Failed to load browser settings: $error');
      _errors[childId] = error.toString();
    } finally {
      _loadingChildIds.remove(childId);
      notifyListeners();
    }
  }

  Future<void> refresh(String childId) =>
      loadSettings(childId, forceRefresh: true);

  Future<void> setSafeSearch(String childId, bool enabled) =>
      _mutateSettings(
        childId,
        (current) => current.copyWith(safeSearchEnabled: enabled),
      );

  Future<void> setSocialFilter(String childId, bool enabled) =>
      _mutateSettings(
        childId,
        (current) => current.copyWith(blockSocialMedia: enabled),
      );

  Future<void> setGamblingFilter(String childId, bool enabled) =>
      _mutateSettings(
        childId,
        (current) => current.copyWith(blockGambling: enabled),
      );

  Future<void> setViolenceFilter(String childId, bool enabled) =>
      _mutateSettings(
        childId,
        (current) => current.copyWith(blockViolence: enabled),
      );

  Future<void> addBlockedKeyword(String childId, String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value();
    return _mutateSettings(childId, (current) {
      if (current.blockedKeywords.contains(normalized)) {
        return current;
      }
      return current.copyWith(
        blockedKeywords: [...current.blockedKeywords, normalized],
      );
    });
  }

  Future<void> removeBlockedKeyword(String childId, String keyword) {
    return _mutateSettings(childId, (current) {
      final updated =
          current.blockedKeywords.where((item) => item != keyword).toList();
      return current.copyWith(blockedKeywords: updated);
    });
  }

  Future<void> addAllowedSite(String childId, String site) {
    final normalized = _normalizeSite(site);
    if (normalized.isEmpty) return Future.value();
    return _mutateSettings(childId, (current) {
      if (current.allowedSites.contains(normalized)) {
        return current;
      }
      return current.copyWith(
        allowedSites: [...current.allowedSites, normalized],
      );
    });
  }

  Future<void> removeAllowedSite(String childId, String site) {
    return _mutateSettings(childId, (current) {
      final updated =
          current.allowedSites.where((item) => item != site).toList();
      return current.copyWith(allowedSites: updated);
    });
  }

  Future<void> _mutateSettings(
    String childId,
    BrowserControlSettings Function(BrowserControlSettings current) update,
  ) async {
    if (childId.isEmpty) return;
    final current =
        _settingsByChild[childId] ?? BrowserControlSettings.defaults();
    final updated = update(current);
    _settingsByChild[childId] = updated;
    _savingChildIds.add(childId);
    notifyListeners();
    try {
      await _service.saveSettings(childId, updated);
      _errors.remove(childId);
    } catch (error) {
      debugPrint('Failed to save browser settings: $error');
      _errors[childId] = error.toString();
    } finally {
      _savingChildIds.remove(childId);
      notifyListeners();
    }
  }

  String _normalizeSite(String site) {
    var trimmed = site.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }
}
