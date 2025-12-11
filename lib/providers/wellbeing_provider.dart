import 'package:flutter/material.dart';

import '../models/wellbeing_entry.dart';
import '../models/wellbeing_insight.dart';
import '../services/wellbeing_insights_service.dart';
import '../services/wellbeing_service.dart';

class WellbeingProvider extends ChangeNotifier {
  WellbeingProvider(
    this._service, {
    WellbeingInsightsService? insightsService,
  }) : _insightsService = insightsService ?? WellbeingInsightsService();

  final WellbeingService _service;
  final WellbeingInsightsService _insightsService;

  final Map<String, List<WellbeingEntry>> _entriesByChild = {};
  final Map<String, bool> _loadingChild = {};
  final Map<String, List<WellbeingInsight>> _insightsByChild = {};
  final Map<String, bool> _insightsLoading = {};
  final Map<String, String?> _insightsError = {};
  String? _error;

  String? get error => _error;

  List<WellbeingEntry> entriesForChild(String childId) {
    return List.unmodifiable(_entriesByChild[childId] ?? const []);
  }

  List<WellbeingInsight> insightsForChild(String childId) {
    return List.unmodifiable(_insightsByChild[childId] ?? const []);
  }

  bool isLoading(String childId) => _loadingChild[childId] ?? false;

  bool isInsightsLoading(String childId) =>
      _insightsLoading[childId] ?? false;

  String? insightErrorFor(String childId) => _insightsError[childId];

  Future<void> loadEntries(String childId) async {
    if (childId.isEmpty) return;
    _loadingChild[childId] = true;
    notifyListeners();
    try {
      final entries = await _service.fetchEntries(childId);
      _entriesByChild[childId] = entries;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loadingChild[childId] = false;
      notifyListeners();
    }
  }

  Future<void> loadInsights(String childId, String childName) async {
    if (childId.isEmpty) return;
    if (_insightsLoading[childId] == true) return;

    _insightsLoading[childId] = true;
    notifyListeners();
    try {
      final entries = _entriesByChild[childId] ??
          await _service.fetchEntries(childId, limit: 40);

      // Keep local cache in sync if we had to fetch entries for insights
      _entriesByChild[childId] = entries;

      if (entries.isEmpty) {
        _insightsByChild[childId] = const [];
        _insightsError.remove(childId);
        return;
      }

      final insights = await _insightsService.summarize(
        childName: childName,
        entries: entries,
      );
      _insightsByChild[childId] = insights;
      _insightsError.remove(childId);
    } catch (error) {
      _insightsError[childId] = error.toString();
    } finally {
      _insightsLoading[childId] = false;
      notifyListeners();
    }
  }

  Future<void> submitEntry({
    required String childId,
    required String moodLabel,
    required String moodEmoji,
    required int moodScore,
    required int moodIndex,
    String? notes,
  }) async {
    await _service.submitEntry(
      childId: childId,
      moodLabel: moodLabel,
      moodEmoji: moodEmoji,
      moodScore: moodScore,
      moodIndex: moodIndex,
      notes: notes,
    );
    await loadEntries(childId);
  }

  double averageScore(String childId) {
    final entries = _entriesByChild[childId];
    if (entries == null || entries.isEmpty) return 0;
    final total = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.moodScore.toDouble(),
    );
    return total / entries.length;
  }

  WellbeingEntry? latestEntry(String childId) {
    final entries = _entriesByChild[childId];
    if (entries == null || entries.isEmpty) return null;
    return entries.first;
  }

  List<WellbeingEntry> recentEntries(String childId, {int limit = 6}) {
    final entries = _entriesByChild[childId];
    if (entries == null || entries.isEmpty) return const [];
    return entries.take(limit).toList(growable: false);
  }

  List<WellbeingEntry> entriesWithinDays(String childId, int days) {
    final entries = _entriesByChild[childId];
    if (entries == null || entries.isEmpty) return const [];
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries
        .where((entry) => entry.timestamp.isAfter(cutoff))
        .toList(growable: false);
  }
}
