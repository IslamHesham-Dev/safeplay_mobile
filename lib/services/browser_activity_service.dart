import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/browser_activity_entry.dart';

class BrowserActivityService {
  BrowserActivityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'browserActivity';
  static const _defaultLimit = 40;

  Future<void> logSearch({
    required String childId,
    required String query,
  }) async {
    final tags = _inferTags(query);
    await _logEvent(
      childId: childId,
      summary: 'Search request recorded',
      activityType: 'search',
      category: _categoryFor(tags, fallback: 'Search'),
      tags: tags,
      metadata: {
        'query': query,
      },
    );
  }

  Future<void> logVisit({
    required String childId,
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? 'website';
    final tags = _inferTags(host);
    await _logEvent(
      childId: childId,
      summary: 'Visited $host',
      activityType: 'visit',
      category: _categoryFor(tags, fallback: 'Site Visit'),
      tags: tags,
      metadata: {
        'url': url,
        'host': host,
      },
    );
  }

  Future<void> logBlocked({
    required String childId,
    required String reason,
  }) async {
    final tags = _inferTags(reason)..add('blocked');
    await _logEvent(
      childId: childId,
      summary: 'Blocked content attempt',
      activityType: 'blocked',
      category: 'Safety Block',
      tags: tags,
      metadata: {
        'reason': reason,
      },
    );
  }

  Future<List<BrowserActivityEntry>> fetchRecentActivity(
    String childId, {
    int limit = _defaultLimit,
  }) async {
    final query = await _firestore
        .collection(_collection)
        .doc(childId)
        .collection('events')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map(BrowserActivityEntry.fromSnapshot)
        .toList(growable: false);
  }

  Future<void> _logEvent({
    required String childId,
    required String activityType,
    required String category,
    required String summary,
    required Set<String> tags,
    Map<String, dynamic>? metadata,
  }) async {
    final document = _firestore
        .collection(_collection)
        .doc(childId)
        .collection('events')
        .doc();
    await document.set({
      'childId': childId,
      'activityType': activityType,
      'category': category,
      'summary': summary,
      'tags': tags.toList(),
      'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Set<String> _inferTags(String text) {
    final lower = text.toLowerCase();
    final tags = <String>{};

    if (_educationKeywords.any(lower.contains)) {
      tags.add('educational');
    }
    if (_entertainmentKeywords.any(lower.contains)) {
      tags.add('entertainment');
    }
    if (_violenceKeywords.any(lower.contains)) {
      tags.add('violent');
    }
    if (_gamblingKeywords.any(lower.contains)) {
      tags.add('gambling');
    }
    if (_socialKeywords.any(lower.contains)) {
      tags.add('social');
    }
    if (_newsKeywords.any(lower.contains)) {
      tags.add('current-events');
    }
    if (tags.isEmpty) {
      tags.add('general');
    }
    return tags;
  }

  String _categoryFor(Set<String> tags, {required String fallback}) {
    if (tags.contains('violent')) return 'Sensitive Content';
    if (tags.contains('gambling')) return 'Sensitive Content';
    if (tags.contains('social')) return 'Social Platforms';
    if (tags.contains('current-events')) return 'Current Events';
    if (tags.contains('entertainment')) return 'Entertainment';
    if (tags.contains('educational')) return 'Learning';
    return fallback;
  }
}

const _educationKeywords = {
  'math',
  'science',
  'history',
  'lesson',
  'learn',
  'educ',
  'study',
  'space',
  'biology',
  'chemistry',
  'physics',
};

const _entertainmentKeywords = {
  'cartoon',
  'game',
  'games',
  'music',
  'movie',
  'videos',
  'fun',
  'play',
};

const _violenceKeywords = {
  'fight',
  'gun',
  'blood',
  'kill',
  'weapon',
  'shoot',
  'war',
};

const _gamblingKeywords = {
  'bet',
  'casino',
  'slots',
  'poker',
  'lottery',
  'roulette',
  'gamble',
};

const _socialKeywords = {
  'facebook',
  'instagram',
  'tiktok',
  'discord',
  'snapchat',
  'twitter',
  'social',
};

const _newsKeywords = {
  'news',
  'headline',
  'report',
  'article',
  'breaking',
  'update',
  'today',
};
