import 'package:equatable/equatable.dart';

/// Categories returned by the AI safety monitor.
enum SafetyCategory {
  profanity,
  bullying,
  sensitiveTopics,
  strangerDanger,
  other;

  static SafetyCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'profanity':
        return SafetyCategory.profanity;
      case 'bullying':
        return SafetyCategory.bullying;
      case 'sensitive':
      case 'sensitive_topics':
      case 'sensitive-topics':
      case 'sensitive topics':
        return SafetyCategory.sensitiveTopics;
      case 'stranger':
      case 'stranger_danger':
      case 'stranger-danger':
      case 'stranger danger':
        return SafetyCategory.strangerDanger;
      default:
        return SafetyCategory.other;
    }
  }

  String get label {
    switch (this) {
      case SafetyCategory.profanity:
        return 'Profanity';
      case SafetyCategory.bullying:
        return 'Bullying';
      case SafetyCategory.sensitiveTopics:
        return 'Sensitive Topics';
      case SafetyCategory.strangerDanger:
        return 'Stranger Danger';
      case SafetyCategory.other:
        return 'Safety Review';
    }
  }
}

/// Represents a single AI-detected chat safety incident.
class ChatSafetyAlert extends Equatable {
  const ChatSafetyAlert({
    required this.id,
    required this.sourceMessageId,
    required this.category,
    required this.severity,
    required this.direction,
    required this.offenderName,
    required this.offenderRole,
    required this.targetName,
    required this.targetRole,
    required this.flaggedText,
    required this.context,
    required this.timestamp,
    required this.confidence,
    this.title,
    this.reason,
    this.reviewed = false,
  });

  final String id;
  final String sourceMessageId;
  final SafetyCategory category;
  final String severity; // low | medium | high
  final String direction; // child_to_teacher | teacher_to_child
  final String offenderName;
  final String offenderRole;
  final String targetName;
  final String targetRole;
  final String flaggedText;
  final String context;
  final DateTime timestamp;
  final double confidence; // 0-1
  final String? title;
  final String? reason;
  final bool reviewed;

  int get confidencePercent =>
      (confidence.isFinite ? (confidence * 100).round().clamp(0, 100) : 0);

  String get severityLabel {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      default:
        return 'Low Priority';
    }
  }

  bool get isHighSeverity => severity.toLowerCase() == 'high';

  String get directionLabel {
    switch (direction) {
      case 'teacher_to_child':
        return 'Teacher → Child';
      case 'child_to_teacher':
        return 'Child → Teacher';
      default:
        return 'Conversation';
    }
  }

  ChatSafetyAlert copyWith({
    bool? reviewed,
  }) {
    return ChatSafetyAlert(
      id: id,
      sourceMessageId: sourceMessageId,
      category: category,
      severity: severity,
      direction: direction,
      offenderName: offenderName,
      offenderRole: offenderRole,
      targetName: targetName,
      targetRole: targetRole,
      flaggedText: flaggedText,
      context: context,
      timestamp: timestamp,
      confidence: confidence,
      title: title,
      reason: reason,
      reviewed: reviewed ?? this.reviewed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sourceMessageId,
        category,
        severity,
        direction,
        offenderName,
        offenderRole,
        targetName,
        targetRole,
        flaggedText,
        context,
        timestamp,
        confidence,
        title,
        reason,
        reviewed,
      ];
}
