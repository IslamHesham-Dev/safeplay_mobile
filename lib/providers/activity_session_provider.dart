import 'package:flutter/foundation.dart';

import '../models/activity_session_entry.dart';
import '../services/activity_session_service.dart';

class ActivitySessionProvider extends ChangeNotifier {
  ActivitySessionProvider(this._service);

  final ActivitySessionService _service;

  final Map<String, List<ActivitySessionEntry>> _sessionsByChild = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, String?> _errors = {};

  List<ActivitySessionEntry> sessionsFor(String childId) =>
      _sessionsByChild[childId] ?? const [];
  bool isLoading(String childId) => _isLoading[childId] ?? false;
  String? errorFor(String childId) => _errors[childId];

  Future<void> loadSessions(String childId) async {
    if (childId.isEmpty) return;
    if (_isLoading[childId] == true) return;
    _isLoading[childId] = true;
    notifyListeners();
    try {
      final sessions = await _service.fetchSessions(childId);
      _sessionsByChild[childId] = sessions;
      _errors.remove(childId);
    } catch (error) {
      debugPrint('Failed to load activity sessions: $error');
      _errors[childId] = error.toString();
    } finally {
      _isLoading[childId] = false;
      notifyListeners();
    }
  }
}
