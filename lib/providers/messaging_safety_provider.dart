import 'package:flutter/foundation.dart';

import '../models/chat_safety_alert.dart';
import '../models/user_profile.dart';
import '../services/chat_safety_monitoring_service.dart';

class MessagingSafetyProvider extends ChangeNotifier {
  MessagingSafetyProvider(this._monitoringService);

  final ChatSafetyMonitoringService _monitoringService;
  final Map<String, List<ChatSafetyAlert>> _alertsByChild = {};
  final Map<String, DateTime> _lastFetchedAt = {};
  final Set<String> _loadingChildIds = <String>{};
  String? _activeChildId;
  String? _error;
  Duration cacheDuration = const Duration(minutes: 5);

  String? get activeChildId => _activeChildId;
  String? get error => _error;
  DateTime? lastFetchedForChild(String childId) => _lastFetchedAt[childId];

  bool isLoading(String? childId) {
    if (childId == null) return false;
    return _loadingChildIds.contains(childId);
  }

  List<ChatSafetyAlert> alertsForChild(String? childId) {
    if (childId == null) return const [];
    return List.unmodifiable(_alertsByChild[childId] ?? const []);
  }

  Future<void> analyzeChild({
    required UserProfile parent,
    required ChildProfile child,
    bool forceRefresh = false,
  }) async {
    final childId = child.id;
    _activeChildId = childId;

    if (!forceRefresh) {
      final lastFetched = _lastFetchedAt[childId];
      if (lastFetched != null &&
          DateTime.now().difference(lastFetched) < cacheDuration &&
          _alertsByChild.containsKey(childId)) {
        notifyListeners();
        return;
      }
    }

    _loadingChildIds.add(childId);
    _error = null;
    notifyListeners();

    try {
      final alerts = await _monitoringService.analyzeChildConversation(
        child: child,
        parent: parent,
      );
      _alertsByChild[childId] = alerts;
      _lastFetchedAt[childId] = DateTime.now();
    } catch (error, stackTrace) {
      debugPrint('Failed to analyze child messages: $error');
      debugPrintStack(stackTrace: stackTrace);
      _error = error.toString();
    } finally {
      _loadingChildIds.remove(childId);
      notifyListeners();
    }
  }

  void markAlertReviewed(String childId, String alertId) {
    final alerts = _alertsByChild[childId];
    if (alerts == null) return;
    final index = alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) return;
    final updated = [...alerts];
    updated[index] = updated[index].copyWith(reviewed: true);
    _alertsByChild[childId] = updated;
    notifyListeners();
  }

  void clearForChild(String childId) {
    _alertsByChild.remove(childId);
    _lastFetchedAt.remove(childId);
    notifyListeners();
  }
}
