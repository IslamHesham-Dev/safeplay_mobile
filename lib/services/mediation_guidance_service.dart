import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/env_config.dart';

/// Generates family-friendly mediation copy using the DeepSeek / OpenRouter API.
class MediationGuidanceService {
  MediationGuidanceService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'deepseek/deepseek-chat-v3.1';

  final http.Client _client;

  Future<String> generateGuidance({
    required String blockedReason,
    required String childName,
  }) async {
    if (EnvConfig.openRouterApiKey.isEmpty) {
      return _fallbackMessage(childName);
    }

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
          'temperature': 0.6,
          'max_tokens': 220,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a caring digital mentor speaking to a child. When a search is blocked, kindly explain (1) why the topic may be unsafe or not age-appropriate and (2) how active mediation—talking with trusted adults—helps more than silent blocking. Use warm, encouraging language, no fear tactics, and end with an invitation to chat with their grown-ups.'
            },
            {
              'role': 'user',
              'content':
                  'Child name: $childName. Blocked reason: $blockedReason. Compose 2 friendly sentences: sentence 1 briefly explains why this search is not suitable right now (in kid terms). Sentence 2 highlights mediation by inviting them to talk to trusted adults for guidance instead of just dealing with a block. Keep tone hopeful and respectful.'
            },
          ],
        }),
      );

      if (response.statusCode >= 400) {
        return _fallbackMessage(childName);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(decoded);
      if (content != null && content.trim().isNotEmpty) {
        return content.trim();
      }
      return _fallbackMessage(childName);
    } catch (_) {
      return _fallbackMessage(childName);
    }
  }

  String _fallbackMessage(String childName) {
    return 'This topic can be tricky or grown-up, so it’s paused for now. Let’s practice mediation—ask your trusted adults about it so they can guide $childName with a safe, caring explanation!';
  }

  String? _extractContent(Map<String, dynamic> response) {
    final choices = response['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      final message = first['message'];
      final content = message?['content'];
      if (content is String) {
        return content;
      }
    }
    return null;
  }
}
