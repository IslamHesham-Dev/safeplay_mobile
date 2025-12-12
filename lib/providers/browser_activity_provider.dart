import 'package:flutter/foundation.dart';

import '../models/browser_activity_entry.dart';
import '../models/browser_activity_insight.dart';
import '../services/browser_activity_insights_service.dart';
import '../services/browser_activity_service.dart';

class BrowserActivityProvider extends ChangeNotifier {
  BrowserActivityProvider(
    this._activityService,
    this._insightsService,
  );

  final BrowserActivityService _activityService;
  final BrowserActivityInsightsService _insightsService;

  final Map<String, List<BrowserActivityEntry>> _entriesByChild = {};
  final Map<String, List<BrowserActivityInsight>> _insightsByChild = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, String?> _errors = {};

  List<BrowserActivityEntry> entriesFor(String childId) =>
      _entriesByChild[childId] ?? const [];

  List<BrowserActivityInsight> insightsFor(String childId) =>
      _insightsByChild[childId] ?? const [];

  bool isLoading(String childId) => _isLoading[childId] ?? false;
  String? errorFor(String childId) => _errors[childId];

  Future<void> loadActivity(
    String childId,
    String childName, {
    String localeCode = 'en',
  }) async {
    if (childId.isEmpty) return;
    if (_isLoading[childId] == true) return;
    _isLoading[childId] = true;
    notifyListeners();
    try {
      final entries = await _activityService.fetchRecentActivity(childId);
      _entriesByChild[childId] = entries;
      _errors.remove(childId);

      if (entries.isEmpty) {
        _insightsByChild[childId] = const [];
      } else {
        final insights = await _insightsService.summarize(
          childName: childName,
          entries: entries,
          localeCode: localeCode,
        );
        _insightsByChild[childId] = insights;
      }
    } catch (error) {
      debugPrint('Failed to load browser activity: $error');
      _errors[childId] = error.toString();
    } finally {
      _isLoading[childId] = false;
      notifyListeners();
    }
  }
}
