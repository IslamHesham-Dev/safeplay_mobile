import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../constants/env_config.dart';
import '../models/chat_safety_alert.dart';
import '../models/user_profile.dart';
import 'messaging_service.dart';

class ChatSafetyMonitoringException implements Exception {
  const ChatSafetyMonitoringException(this.message);
  final String message;

  @override
  String toString() => 'ChatSafetyMonitoringException: $message';
}

/// Wraps the DeepSeek / OpenRouter API for chat safety classification.
class ChatSafetyMonitoringService {
  ChatSafetyMonitoringService({
    http.Client? httpClient,
    FirebaseFirestore? firestore,
  })  : _client = httpClient ?? http.Client(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _defaultLimit = 30;

  final http.Client _client;
  final FirebaseFirestore _firestore;

  Future<List<ChatSafetyAlert>> analyzeChildConversation({
    required ChildProfile child,
    required UserProfile parent,
    int limit = _defaultLimit,
  }) async {
    if (EnvConfig.openRouterApiKey.isEmpty) {
      throw const ChatSafetyMonitoringException(
        'OPENROUTER_API_KEY is not configured. Provide one via --dart-define.',
      );
    }

    final messages = await _fetchMessages(childId: child.id, limit: limit);
    if (messages.isEmpty) {
      return const [];
    }

    final body = _buildRequestBody(
      parent: parent,
      child: child,
      messages: messages,
    );

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
        'HTTP-Referer': EnvConfig.openRouterReferer,
        'X-Title': EnvConfig.openRouterAppName,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 400) {
      throw ChatSafetyMonitoringException(
        'Safety monitor request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = _extractAssistantContent(decoded);
    final incidentsJson = _decodeIncidents(content);

    final alerts = <ChatSafetyAlert>[];
    final lookup = {
      for (final entry in messages) entry.messageId: entry,
    };

    final incidents = incidentsJson['incidents'];
    if (incidents is List) {
      for (var i = 0; i < incidents.length; i++) {
        final incident = incidents[i];
        if (incident is Map<String, dynamic>) {
          final alert = _mapIncident(
            incident: incident,
            fallbackId: 'incident_$i',
            lookup: lookup,
          );
          if (alert != null) {
            alerts.add(alert);
          }
        }
      }
    }

    alerts.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    );
    return alerts;
  }

  Future<List<_ChatMessage>> _fetchMessages({
    required String childId,
    required int limit,
  }) async {
    final childToTeacherFuture = _firestore
        .collection(MessagingService.teacherInboxCollection)
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    final teacherToChildFuture = _firestore
        .collection(MessagingService.childInboxCollection)
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final results = await Future.wait([
      childToTeacherFuture,
      teacherToChildFuture,
    ]);

    final childToTeacher = results[0]
        .docs
        .map((doc) => _ChatMessage.fromSnapshot(doc, true))
        .toList();
    final teacherToChild = results[1]
        .docs
        .map((doc) => _ChatMessage.fromSnapshot(doc, false))
        .toList();

    final combined = [...childToTeacher, ...teacherToChild];
    combined.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return combined;
  }

  Map<String, dynamic> _buildRequestBody({
    required UserProfile parent,
    required ChildProfile child,
    required List<_ChatMessage> messages,
  }) {
    final serializedConversation =
        messages.map((message) => message.toJson()).toList();

    final instructions = '''
You are SafePlay's “AI Safety Guard,” monitoring messages between a child and their teacher. Review the provided JSON conversation and flag any harmful or concerning messages.

Focus only on these categories:
- profanity (harsh language, insults, swearing)
- bullying (threats, harassment, intimidation)
- sensitive_topics (self-harm, abuse, mental health struggles)
- stranger_danger (attempts to move conversation off platform, requests for personal contact details, inappropriate relationships)

For each concerning message, return JSON following this exact schema:
{
  "incidents": [
    {
      "incident_id": "unique id",
      "message_id": "<direction>:<docId>",
      "category": "profanity|bullying|sensitive|stranger_danger",
      "severity": "low|medium|high",
      "confidence": 0.0-1.0,
      "title": "Short summary like 'Bullying language detected'",
      "flagged_text": "Exact quote or snippet",
      "context": "Why this was flagged and any nuance parents should know",
      "reason": "Optional, plain-language explanation",
      "offender": {"role": "child|teacher", "name": "Display name"},
      "target": {"role": "child|teacher", "name": "Display name"}
    }
  ]
}

If everything is safe, respond with {"incidents": []} and no narration.''';

    final userContext = {
      'parent': {
        'id': parent.id,
        'name': parent.name,
      },
      'child': {
        'id': child.id,
        'name': child.name,
        'ageGroup': child.ageGroup?.name,
      },
      'conversation': serializedConversation,
    };

    return {
      'model': 'deepseek/deepseek-chat-v3.1',
      'temperature': 0.2,
      'messages': [
        {'role': 'system', 'content': instructions},
        {
          'role': 'user',
          'content': jsonEncode(userContext),
        },
      ],
    };
  }

  String _extractAssistantContent(Map<String, dynamic> payload) {
    final choices = payload['choices'];
    if (choices is List && choices.isNotEmpty) {
      final choice = choices.first;
      final message = choice['message'];
      if (message is Map && message['content'] is String) {
        return message['content'] as String;
      }
    }
    throw const ChatSafetyMonitoringException(
      'AI response did not include assistant content.',
    );
  }

  Map<String, dynamic> _decodeIncidents(String content) {
    final trimmed = content.trim();
    try {
      return jsonDecode(trimmed) as Map<String, dynamic>;
    } catch (_) {
      // Attempt to extract JSON block if wrapped in prose/code fences.
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final candidate = trimmed.substring(start, end + 1);
        return jsonDecode(candidate) as Map<String, dynamic>;
      }
      throw ChatSafetyMonitoringException(
        'Unable to parse AI safety response: $content',
      );
    }
  }

  ChatSafetyAlert? _mapIncident({
    required Map<String, dynamic> incident,
    required String fallbackId,
    required Map<String, _ChatMessage> lookup,
  }) {
    final messageId = incident['message_id']?.toString();
    final source = messageId != null ? lookup[messageId] : null;
    if (source == null && messageId == null) {
      return null;
    }

    final id =
        incident['incident_id']?.toString() ?? '${messageId ?? fallbackId}';
    final category = SafetyCategory.fromString(incident['category']?.toString());
    final severity =
        (incident['severity']?.toString().toLowerCase()) ?? 'medium';
    final confidenceValue = incident['confidence'];
    var confidence = confidenceValue is num
        ? confidenceValue.toDouble()
        : double.tryParse(confidenceValue?.toString() ?? '') ?? 0.75;
    if (confidence.isNaN || confidence.isInfinite) {
      confidence = 0.75;
    }

    final offender = incident['offender'];
    final target = incident['target'];

    return ChatSafetyAlert(
      id: id,
      sourceMessageId: messageId ?? source?.messageId ?? fallbackId,
      category: category,
      severity: severity,
      direction: source?.direction ?? 'conversation',
      offenderName: (offender is Map
              ? offender['name']?.toString()
              : source?.senderName) ??
          'Unknown',
      offenderRole: (offender is Map
              ? offender['role']?.toString()
              : source?.senderRole) ??
          'child',
      targetName:
          (target is Map ? target['name']?.toString() : source?.recipientName) ??
              'Recipient',
      targetRole:
          (target is Map ? target['role']?.toString() : source?.recipientRole) ??
              'teacher',
      flaggedText: incident['flagged_text']?.toString() ??
          source?.body ??
          'Flagged content not provided',
      context: incident['context']?.toString() ??
          incident['reason']?.toString() ??
          'The AI monitor flagged this message for review.',
      timestamp: source?.timestamp ?? DateTime.now(),
      confidence: confidence.clamp(0, 1),
      title: incident['title']?.toString(),
      reason: incident['reason']?.toString(),
    );
  }
}

class _ChatMessage {
  _ChatMessage({
    required this.messageId,
    required this.body,
    required this.senderName,
    required this.senderRole,
    required this.recipientName,
    required this.recipientRole,
    required this.direction,
    required this.timestamp,
  });

  final String messageId;
  final String body;
  final String senderName;
  final String senderRole;
  final String recipientName;
  final String recipientRole;
  final String direction;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'body': body,
      'senderName': senderName,
      'senderRole': senderRole,
      'recipientName': recipientName,
      'recipientRole': recipientRole,
      'direction': direction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static _ChatMessage fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isFromChild,
  ) {
    final data = doc.data();
    final body = data['message']?.toString() ?? '';
    final teacherName = data['teacherName']?.toString() ?? 'Teacher';
    final childName = data['childName']?.toString() ?? 'Child';
    final createdAt = data['createdAt'];
    DateTime timestamp;
    if (createdAt is Timestamp) {
      timestamp = createdAt.toDate();
    } else if (createdAt is DateTime) {
      timestamp = createdAt;
    } else if (createdAt is num) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(createdAt.toInt());
    } else if (createdAt is String) {
      timestamp = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    final direction = isFromChild ? 'child_to_teacher' : 'teacher_to_child';
    final senderName = isFromChild ? childName : teacherName;
    final recipientName = isFromChild ? teacherName : childName;

    return _ChatMessage(
      messageId: '$direction:${doc.id}',
      body: body,
      senderName: senderName,
      senderRole: isFromChild ? 'child' : 'teacher',
      recipientName: recipientName,
      recipientRole: isFromChild ? 'teacher' : 'child',
      direction: direction,
      timestamp: timestamp,
    );
  }
}
