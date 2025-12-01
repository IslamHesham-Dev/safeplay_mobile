import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores AI-safe browser preferences per child.
class BrowserControlSettings {
  const BrowserControlSettings({
    required this.safeSearchEnabled,
    required this.blockSocialMedia,
    required this.blockGambling,
    required this.blockViolence,
    required this.blockedKeywords,
    required this.allowedSites,
    this.updatedAt,
  });

  final bool safeSearchEnabled;
  final bool blockSocialMedia;
  final bool blockGambling;
  final bool blockViolence;
  final List<String> blockedKeywords;
  final List<String> allowedSites;
  final DateTime? updatedAt;

  static const List<String> defaultAllowedSites = [
    'https://www.nationalgeographic.com/kids',
    'https://www.nasa.gov/kids-club/',
    'https://kidshealth.org',
    'https://www.coolmath4kids.com/',
    'https://www.britannica.com/kids',
  ];

  static const Set<String> socialFilterKeywords = {
    'facebook',
    'instagram',
    'tiktok',
    'snapchat',
    'twitter',
    'discord',
    'reddit',
    'social media',
  };

  static const Set<String> gamblingFilterKeywords = {
    'casino',
    'betting',
    'bet',
    'slot',
    'poker',
    'lottery',
    'wager',
    'roulette',
  };

  static const Set<String> violenceFilterKeywords = {
    'blood',
    'gun',
    'shooting',
    'fight',
    'murder',
    'killing',
    'knife',
    'gore',
  };

  factory BrowserControlSettings.defaults() {
    return const BrowserControlSettings(
      safeSearchEnabled: true,
      blockSocialMedia: false,
      blockGambling: false,
      blockViolence: false,
      blockedKeywords: <String>[],
      allowedSites: defaultAllowedSites,
    );
  }

  BrowserControlSettings copyWith({
    bool? safeSearchEnabled,
    bool? blockSocialMedia,
    bool? blockGambling,
    bool? blockViolence,
    List<String>? blockedKeywords,
    List<String>? allowedSites,
    DateTime? updatedAt,
  }) {
    return BrowserControlSettings(
      safeSearchEnabled: safeSearchEnabled ?? this.safeSearchEnabled,
      blockSocialMedia: blockSocialMedia ?? this.blockSocialMedia,
      blockGambling: blockGambling ?? this.blockGambling,
      blockViolence: blockViolence ?? this.blockViolence,
      blockedKeywords:
          blockedKeywords ?? List<String>.from(this.blockedKeywords),
      allowedSites: allowedSites ?? List<String>.from(this.allowedSites),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BrowserControlSettings.fromMap(Map<String, dynamic> data) {
    final blockedList = (data['blockedKeywords'] as List?)
            ?.map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        const <String>[];
    final lowerBlocked =
        blockedList.map((value) => value.toLowerCase()).toList(growable: false);
    final allowedList = (data['allowedSites'] as List?)
            ?.map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        const <String>[];
    final updatedAt = data['updatedAt'];

    final hasSocialKeywords = lowerBlocked.any(
        (word) => BrowserControlSettings.socialFilterKeywords.contains(word));
    final hasGamblingKeywords = lowerBlocked.any(
        (word) => BrowserControlSettings.gamblingFilterKeywords.contains(word));
    final hasViolenceKeywords = lowerBlocked.any(
        (word) => BrowserControlSettings.violenceFilterKeywords.contains(word));

    return BrowserControlSettings(
      safeSearchEnabled: data['safeSearchEnabled'] as bool? ?? true,
      blockSocialMedia:
          (data['blockSocialMedia'] as bool? ?? false) && hasSocialKeywords,
      blockGambling:
          (data['blockGambling'] as bool? ?? false) && hasGamblingKeywords,
      blockViolence:
          (data['blockViolence'] as bool? ?? false) && hasViolenceKeywords,
      blockedKeywords: blockedList,
      allowedSites: allowedList.isEmpty ? defaultAllowedSites : allowedList,
      updatedAt: updatedAt is Timestamp
          ? updatedAt.toDate()
          : (updatedAt is DateTime ? updatedAt : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'safeSearchEnabled': safeSearchEnabled,
      'blockSocialMedia': blockSocialMedia,
      'blockGambling': blockGambling,
      'blockViolence': blockViolence,
      'blockedKeywords': blockedKeywords,
      'allowedSites': allowedSites,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
