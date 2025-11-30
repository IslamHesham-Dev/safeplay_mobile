import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/env_config.dart';
import '../models/browser_activity_entry.dart';
import '../models/browser_activity_insight.dart';

class BrowserActivityInsightsService {
  BrowserActivityInsightsService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'deepseek/deepseek-chat-v3.1';

  Future<List<BrowserActivityInsight>> summarize({
    required String childName,
    required List<BrowserActivityEntry> entries,
  }) async {
    if (entries.isEmpty) {
      return const [];
    }
    if (EnvConfig.openRouterApiKey.isEmpty) {
      return _fallbackInsights(entries);
    }

    final payload = entries
        .map((entry) => {
              'activity_type': entry.activityType,
              'category': entry.category,
              'timestamp': entry.timestamp.toIso8601String(),
              'tags': entry.tags,
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
          'temperature': 0.4,
          'max_tokens': 300,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You summarize children\'s browsing activity for parents. Provide meta-level information only: aggregate counts, themes, or patterns. Never quote exact search queries, URLs, or private details. Highlight mediation by explicitly noting when conversations might help. Respond as JSON array with objects containing "summary", "category", "timeframe", "tone".'
            },
            {
              'role': 'user',
              'content':
                  'Child name: $childName. Recent events (most recent first): ${jsonEncode(payload)}. Produce 3 concise insights that respect privacy, e.g., "Watched three science videos this week." Each insight should stay abstract and, when relevant, suggest active mediation or guidance.'
            },
          ],
        }),
      );

      if (response.statusCode >= 400) {
        return _fallbackInsights(entries);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(decoded);
      if (content == null) {
        return _fallbackInsights(entries);
      }
      final parsed = jsonDecode(content);
      if (parsed is List) {
        return parsed
            .whereType<Map<String, dynamic>>()
            .map(BrowserActivityInsight.fromJson)
            .toList();
      }
      return _fallbackInsights(entries);
    } catch (_) {
      return _fallbackInsights(entries);
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

  List<BrowserActivityInsight> _fallbackInsights(
    List<BrowserActivityEntry> entries,
  ) {
    final grouped = <String, int>{};
    for (final entry in entries) {
      final key = entry.category;
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    return grouped.entries.take(3).map((entry) {
      final summary =
          'Noticed ${entry.value} ${entry.key.toLowerCase()} activities recently.';
      return BrowserActivityInsight(
        summary: summary,
        category: entry.key,
        timeframe: 'Recent activity',
        tone: entry.key.toLowerCase().contains('sensitive')
            ? 'caution'
            : 'positive',
      );
    }).toList();
  }
}
