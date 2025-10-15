import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/activity.dart';
import '../models/user_type.dart';

/// Offline storage service using SQLite for caching and sync queues.
class OfflineStorageService {
  static const _dbName = 'safeplay.db';
  static const _dbVersion = 2;
  static const _tableActivities = 'activities';
  static const _tableProgress = 'activity_progress';
  static const _tableSyncQueue = 'sync_queue';
  static const _syncStatusSynced = 'synced';
  static const _syncStatusPending = 'pending';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async =>
          _upgradeSchema(db, oldVersion, newVersion),
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableActivities (
        id TEXT PRIMARY KEY,
        ageGroup TEXT NOT NULL,
        subject TEXT NOT NULL,
        payload TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_activities_age ON $_tableActivities(ageGroup)');

    await db.execute('''
      CREATE TABLE $_tableProgress (
        id TEXT PRIMARY KEY,
        childId TEXT NOT NULL,
        activityId TEXT NOT NULL,
        status TEXT NOT NULL,
        payload TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT '$_syncStatusSynced',
        lastSyncedAt TEXT
      )
    ''');

    await db
        .execute('CREATE INDEX idx_progress_child ON $_tableProgress(childId)');
    await db.execute(
        'CREATE INDEX idx_progress_sync ON $_tableProgress(syncStatus)');

    await db.execute('''
      CREATE TABLE $_tableSyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        lastAttempt TEXT,
        error TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_sync_entity ON $_tableSyncQueue(entityType, entityId)');
    await db.execute(
        'CREATE INDEX idx_sync_created ON $_tableSyncQueue(createdAt)');
  }

  Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS $_tableActivities');
      await db.execute('DROP TABLE IF EXISTS $_tableProgress');
      await db.execute('DROP TABLE IF EXISTS $_tableSyncQueue');
      await _createSchema(db);
    }
  }

  // ---------------------------------------------------------------------------
  // Activity caching
  // ---------------------------------------------------------------------------

  Future<void> upsertActivities(List<Activity> activities) async {
    if (activities.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    final timestamp = DateTime.now().toIso8601String();
    for (final activity in activities) {
      final payload = jsonEncode(activity.toJson());
      batch.insert(
        _tableActivities,
        {
          'id': activity.id,
          'ageGroup': activity.ageGroup.name,
          'subject': activity.subject.name,
          'payload': payload,
          'updatedAt': timestamp,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertActivity(Activity activity) async {
    await upsertActivities([activity]);
  }

  Future<List<Activity>> getActivitiesByAgeGroup(AgeGroup ageGroup) async {
    final db = await database;
    final rows = await db.query(
      _tableActivities,
      where: 'ageGroup = ?',
      whereArgs: [ageGroup.name],
      orderBy: 'updatedAt DESC',
    );
    return rows
        .map((row) => _activityFromRow(row))
        .whereType<Activity>()
        .toList(growable: false);
  }

  Future<Activity?> getActivity(String activityId) async {
    final db = await database;
    final rows = await db.query(
      _tableActivities,
      where: 'id = ?',
      whereArgs: [activityId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _activityFromRow(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Progress caching
  // ---------------------------------------------------------------------------

  Future<void> upsertProgress(
    ActivityProgress progress, {
    required bool synced,
  }) async {
    final db = await database;
    final payload = jsonEncode(progress.toJson());
    final now = DateTime.now().toIso8601String();

    await db.insert(
      _tableProgress,
      {
        'id': progress.id,
        'childId': progress.childId,
        'activityId': progress.activityId,
        'status': progress.status.rawValue,
        'payload': payload,
        'updatedAt': progress.updatedAt.toIso8601String(),
        'syncStatus': synced ? _syncStatusSynced : _syncStatusPending,
        'lastSyncedAt': synced ? now : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityProgress>> getProgressForChild(String childId) async {
    final db = await database;
    final rows = await db.query(
      _tableProgress,
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'updatedAt DESC',
    );
    return rows
        .map((row) => _progressFromRow(row))
        .whereType<ActivityProgress>()
        .toList(growable: false);
  }

  Future<ActivityProgress?> getProgressById(String progressId) async {
    final db = await database;
    final rows = await db.query(
      _tableProgress,
      where: 'id = ?',
      whereArgs: [progressId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _progressFromRow(rows.first);
  }

  Future<void> deleteProgress(String progressId) async {
    final db = await database;
    await db.delete(
      _tableProgress,
      where: 'id = ?',
      whereArgs: [progressId],
    );
  }

  // ---------------------------------------------------------------------------
  // Sync queue helpers
  // ---------------------------------------------------------------------------

  Future<void> queueSyncItem({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert(
      _tableSyncQueue,
      {
        'entityType': entityType,
        'entityId': entityId,
        'operation': operation,
        'data': jsonEncode(data),
        'createdAt': DateTime.now().toIso8601String(),
        'attempts': 0,
        'error': null,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems(
      {int limit = 50}) async {
    final db = await database;
    final rows = await db.query(
      _tableSyncQueue,
      orderBy: 'createdAt ASC',
      limit: limit,
    );

    return rows.map((row) {
      final dataJson = row['data'] as String? ?? '{}';
      final decoded = jsonDecode(dataJson) as Map<String, dynamic>;
      return {
        ...row,
        'data': decoded,
      };
    }).toList(growable: false);
  }

  Future<void> markSyncItemCompleted(int id) async {
    final db = await database;
    await db.delete(
      _tableSyncQueue,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSyncItemFailed(int id, String error) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE $_tableSyncQueue
         SET attempts = attempts + 1,
             lastAttempt = ?,
             error = ?
       WHERE id = ?
      ''',
      [DateTime.now().toIso8601String(), error, id],
    );
  }

  Future<void> clearQueuedItems(
      {required String entityType, required String entityId}) async {
    final db = await database;
    await db.delete(
      _tableSyncQueue,
      where: 'entityType = ? AND entityId = ?',
      whereArgs: [entityType, entityId],
    );
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableActivities);
    await db.delete(_tableProgress);
  }

  Future<int> getCacheSize() async {
    final db = await database;
    final counts = await db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM $_tableActivities) AS activities,
        (SELECT COUNT(*) FROM $_tableProgress) AS progress,
        (SELECT COUNT(*) FROM $_tableSyncQueue) AS pending
    ''');
    final row = counts.first;
    return (row['activities'] as int? ?? 0) +
        (row['progress'] as int? ?? 0) +
        (row['pending'] as int? ?? 0);
  }

  Activity? _activityFromRow(Map<String, Object?> row) {
    final payload = row['payload'] as String?;
    if (payload == null) return null;
    final Map<String, dynamic> json = jsonDecode(payload);
    json['id'] = json['id'] ?? row['id'];
    json['ageGroup'] = json['ageGroup'] ?? row['ageGroup'];
    json['subject'] = json['subject'] ?? row['subject'];
    return Activity.fromJson(json);
  }

  ActivityProgress? _progressFromRow(Map<String, Object?> row) {
    final payload = row['payload'] as String?;
    if (payload == null) return null;
    final Map<String, dynamic> json = jsonDecode(payload);
    json['id'] = json['id'] ?? row['id'];
    json['childId'] = json['childId'] ?? row['childId'];
    json['activityId'] = json['activityId'] ?? row['activityId'];
    json['status'] = json['status'] ?? row['status'];
    return ActivityProgress.fromJson(json);
  }

  Future<void> close() async {
    if (_database == null) return;
    await _database!.close();
    _database = null;
  }
}
