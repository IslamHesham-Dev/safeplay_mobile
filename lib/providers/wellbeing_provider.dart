import 'package:flutter/material.dart';

import '../models/wellbeing_entry.dart';
import '../services/wellbeing_service.dart';

class WellbeingProvider extends ChangeNotifier {
  WellbeingProvider(this._service);

  final WellbeingService _service;

  final Map<String, List<WellbeingEntry>> _entriesByChild = {};
  final Map<String, bool> _loadingChild = {};
  String? _error;

  String? get error => _error;

  List<WellbeingEntry> entriesForChild(String childId) {
    return List.unmodifiable(_entriesByChild[childId] ?? const []);
  }

  bool isLoading(String childId) => _loadingChild[childId] ?? false;

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
