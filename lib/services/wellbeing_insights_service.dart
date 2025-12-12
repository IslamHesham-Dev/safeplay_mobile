import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/env_config.dart';
import '../models/wellbeing_entry.dart';
import '../models/wellbeing_insight.dart';

/// Generates privacy-safe wellbeing summaries from recent check-ins.
class WellbeingInsightsService {
  WellbeingInsightsService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'deepseek/deepseek-chat-v3.1';

  Future<List<WellbeingInsight>> summarize({
    required String childName,
    required List<WellbeingEntry> entries,
    String localeCode = 'en',
  }) async {
    if (entries.isEmpty) {
      return const [];
    }
    if (EnvConfig.openRouterApiKey.isEmpty) {
      return _fallbackInsights(entries, localeCode);
    }

    final payload = entries
        .map((entry) => {
              'mood_label': entry.moodLabel,
              'mood_score': entry.moodScore,
              'note': entry.notes ?? '',
              'timestamp': entry.timestamp.toIso8601String(),
            })
        .toList();

    try {
      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          if (EnvConfig.openRouterReferer.isNotEmpty)
            'HTTP-Referer': EnvConfig.openRouterReferer,
          if (EnvConfig.openRouterAppName.isNotEmpty)
            'X-Title': EnvConfig.openRouterAppName,
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.3,
          'max_tokens': 280,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a wellbeing coach summarizing children\'s self check-ins for parents. Stay privacy-preserving: use trends, counts, and changes, not exact quotes. Offer gentle, supportive framing and simple next-step nudges. Respond as JSON array of {summary, category, timeframe, tone}. Language: ${localeCode == 'ar' ? 'Arabic' : 'English'}.'
            },
            {
              'role': 'user',
              'content':
                  'Child name: $childName. Recent check-ins (most recent first): ${jsonEncode(payload)}. Create 2-3 short insights about mood trends, notable swings, and when to check in with the child. Keep it kind and concise.'
            },
          ],
        }),
      );

      if (response.statusCode >= 400) {
        return _fallbackInsights(entries, localeCode);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(decoded);
      if (content == null) {
        return _fallbackInsights(entries, localeCode);
      }
      final parsed = jsonDecode(content);
      if (parsed is List) {
        return parsed
            .whereType<Map<String, dynamic>>()
            .map(WellbeingInsight.fromJson)
            .toList();
      }
      return _fallbackInsights(entries, localeCode);
    } catch (_) {
      return _fallbackInsights(entries, localeCode);
    }
  }

  String? _extractContent(Map<String, dynamic> response) {
    final choices = response['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      final message = first['message'];
      final content = message?['content'];
      if (content is String) {
        return content.trim();
      }
    }
    return null;
  }

  List<WellbeingInsight> _fallbackInsights(
    List<WellbeingEntry> entries,
    String localeCode,
  ) {
    final total = entries.fold<int>(0, (sum, e) => sum + e.moodScore);
    final avgScore = entries.isEmpty ? 0 : total / entries.length;
    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.moodLabel] = (moodCounts[entry.moodLabel] ?? 0) + 1;
    }
    final topMood = moodCounts.entries.isNotEmpty
        ? moodCounts.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          )
        : null;
    final noteCount = entries.where((e) => (e.notes ?? '').trim().isNotEmpty).length;

    return [
      WellbeingInsight(
        summary: localeCode == 'ar'
            ? 'متوسط درجة المزاج هو ${avgScore.toStringAsFixed(0)} عبر أحدث التسجيلات.'
            : 'Average mood score is ${avgScore.toStringAsFixed(0)} across recent check-ins.',
        category: localeCode == 'ar' ? 'اتجاه المزاج' : 'Mood trend',
        timeframe:
            localeCode == 'ar' ? 'أحدث التسجيلات' : 'Recent check-ins',
        tone: avgScore >= 70
            ? 'positive'
            : avgScore >= 50
                ? 'neutral'
                : 'caution',
      ),
      if (topMood != null)
        WellbeingInsight(
          summary: localeCode == 'ar'
              ? 'أكثر مزاج تكرر: ${topMood.key} (ظهر ${topMood.value} مرة).'
              : 'Most common mood: ${topMood.key} (seen ${topMood.value} time${topMood.value == 1 ? '' : 's'}).',
          category: localeCode == 'ar' ? 'أكثر مزاج شيوعًا' : 'Top mood',
          timeframe:
              localeCode == 'ar' ? 'أحدث التسجيلات' : 'Recent check-ins',
          tone: 'neutral',
        ),
      WellbeingInsight(
        summary: noteCount > 0
            ? (localeCode == 'ar'
                ? '$noteCount تسجيل يحتوي على ملاحظة شخصية. محادثة سريعة قد تساعدك أكثر.'
                : '$noteCount check-in${noteCount == 1 ? '' : 's'} included a personal note. A quick chat could help you learn more.')
            : (localeCode == 'ar'
                ? 'لا توجد ملاحظات مضافة مؤخرًا. اسأل طفلك كيف يشعر اليوم.'
                : 'No notes were added recently. Consider asking how they are doing today.'),
        category: localeCode == 'ar' ? 'تنبيه رعاية' : 'Care prompt',
        timeframe: localeCode == 'ar' ? 'هذا الأسبوع' : 'This week',
        tone: 'supportive',
      ),
    ];
  }
}
