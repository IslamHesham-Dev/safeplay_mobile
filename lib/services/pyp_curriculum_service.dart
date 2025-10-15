import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';
import '../models/user_type.dart';

/// PYP Phase Progress Model
class PhaseProgress {
  final String subject;
  final PYPPhase currentPhase;
  final double phaseCompletion;
  final List<String> completedObjectives;
  final List<String> inProgressObjectives;
  final DateTime lastUpdated;

  const PhaseProgress({
    required this.subject,
    required this.currentPhase,
    required this.phaseCompletion,
    required this.completedObjectives,
    required this.inProgressObjectives,
    required this.lastUpdated,
  });

  factory PhaseProgress.fromJson(Map<String, dynamic> json) {
    return PhaseProgress(
      subject: json['subject'] as String,
      currentPhase: PYPPhase.values.firstWhere(
        (e) => e.name == json['currentPhase'],
        orElse: () => PYPPhase.phase1,
      ),
      phaseCompletion: (json['phaseCompletion'] as num).toDouble(),
      completedObjectives: (json['completedObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      inProgressObjectives: (json['inProgressObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'currentPhase': currentPhase.name,
      'phaseCompletion': phaseCompletion,
      'completedObjectives': completedObjectives,
      'inProgressObjectives': inProgressObjectives,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  PhaseProgress copyWith({
    double? phaseCompletion,
    List<String>? completedObjectives,
    List<String>? inProgressObjectives,
    PYPPhase? currentPhase,
  }) {
    return PhaseProgress(
      subject: subject,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseCompletion: phaseCompletion ?? this.phaseCompletion,
      completedObjectives: completedObjectives ?? this.completedObjectives,
      inProgressObjectives: inProgressObjectives ?? this.inProgressObjectives,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Learning Objective Model
class LearningObjective {
  final String id;
  final String title;
  final String description;
  final ActivitySubject subject;
  final PYPPhase phase;
  final List<String> keySkills;

  const LearningObjective({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.phase,
    required this.keySkills,
  });

  factory LearningObjective.fromJson(Map<String, dynamic> json) {
    return LearningObjective(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      subject: ActivitySubject.values.firstWhere(
        (e) => e.name == json['subject'],
      ),
      phase: PYPPhase.values.firstWhere((e) => e.name == json['phase']),
      keySkills:
          (json['keySkills'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject.name,
      'phase': phase.name,
      'keySkills': keySkills,
    };
  }
}

/// PYP Curriculum Service
class PYPCurriculumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String phaseProgressCollection = 'phaseProgress';
  static const String learningObjectivesCollection = 'learningObjectives';

  /// Get phase progress for a child in a subject
  Future<PhaseProgress?> getPhaseProgress(
    String childId,
    String subject,
  ) async {
    try {
      final doc = await _firestore
          .collection(phaseProgressCollection)
          .doc('${childId}_$subject')
          .get();

      if (!doc.exists) {
        // Initialize with Phase 1
        return PhaseProgress(
          subject: subject,
          currentPhase: PYPPhase.phase1,
          phaseCompletion: 0.0,
          completedObjectives: [],
          inProgressObjectives: [],
          lastUpdated: DateTime.now(),
        );
      }

      return PhaseProgress.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting phase progress: $e');
      return null;
    }
  }

  /// Update phase progress
  Future<void> updatePhaseProgress(
    String childId,
    String subject,
    PhaseProgress progress,
  ) async {
    try {
      await _firestore
          .collection(phaseProgressCollection)
          .doc('${childId}_$subject')
          .set(progress.toJson());

      // Check if phase is complete and advance to next phase
      if (progress.phaseCompletion >= 100.0) {
        await _advanceToNextPhase(childId, subject, progress.currentPhase);
      }
    } catch (e) {
      print('Error updating phase progress: $e');
    }
  }

  /// Advance to next phase
  Future<void> _advanceToNextPhase(
    String childId,
    String subject,
    PYPPhase currentPhase,
  ) async {
    final phaseIndex = PYPPhase.values.indexOf(currentPhase);
    if (phaseIndex < PYPPhase.values.length - 1) {
      final nextPhase = PYPPhase.values[phaseIndex + 1];

      final newProgress = PhaseProgress(
        subject: subject,
        currentPhase: nextPhase,
        phaseCompletion: 0.0,
        completedObjectives: [],
        inProgressObjectives: [],
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(phaseProgressCollection)
          .doc('${childId}_$subject')
          .set(newProgress.toJson());
    }
  }

  /// Generate curriculum-aligned activities for a phase
  Future<List<Activity>> generateActivitiesForPhase(
    String subject,
    String phase,
    AgeGroup ageGroup,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .where('subject', isEqualTo: subject)
          .where('pypPhase', isEqualTo: phase)
          .where('ageGroup', isEqualTo: ageGroup.name)
          .get();

      return snapshot.docs
          .map((doc) => Activity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error generating activities for phase: $e');
      return [];
    }
  }

  /// Get next recommended activity
  Future<Activity?> getNextRecommendedActivity(
    String childId,
    String subject,
  ) async {
    try {
      // Get current phase progress
      final progress = await getPhaseProgress(childId, subject);
      if (progress == null) return null;

      // Get activities for current phase
      final childDoc =
          await _firestore.collection('children').doc(childId).get();
      final ageGroup = AgeGroup.values.firstWhere(
        (e) => e.name == childDoc.data()?['ageGroup'],
      );

      final activities = await generateActivitiesForPhase(
        subject,
        progress.currentPhase.name,
        ageGroup,
      );

      // Get completed activity IDs
      final completedSnapshot = await _firestore
          .collection('activityProgress')
          .where('childId', isEqualTo: childId)
          .where('isCompleted', isEqualTo: true)
          .get();

      final completedIds = completedSnapshot.docs
          .map((doc) => doc.data()['activityId'] as String)
          .toSet();

      // Filter out completed activities
      final availableActivities = activities
          .where((activity) => !completedIds.contains(activity.id))
          .toList();

      // Return first available activity
      return availableActivities.isNotEmpty ? availableActivities.first : null;
    } catch (e) {
      print('Error getting next recommended activity: $e');
      return null;
    }
  }

  /// Get learning objectives for a subject and phase
  Future<List<LearningObjective>> getLearningObjectives(
    String subject,
    String phase,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(learningObjectivesCollection)
          .where('subject', isEqualTo: subject)
          .where('phase', isEqualTo: phase)
          .get();

      return snapshot.docs
          .map((doc) => LearningObjective.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error getting learning objectives: $e');
      return [];
    }
  }

  /// Mark learning objective as complete
  Future<void> markObjectiveComplete(
    String childId,
    String objectiveId,
  ) async {
    try {
      // Get the objective to find its subject
      final objectiveDoc = await _firestore
          .collection(learningObjectivesCollection)
          .doc(objectiveId)
          .get();

      if (!objectiveDoc.exists) return;

      final subject = objectiveDoc.data()!['subject'] as String;

      // Get current progress
      final progress = await getPhaseProgress(childId, subject);
      if (progress == null) return;

      // Add objective to completed list
      if (!progress.completedObjectives.contains(objectiveId)) {
        final updatedCompletedObjectives = [
          ...progress.completedObjectives,
          objectiveId,
        ];

        // Remove from in-progress if it exists
        final updatedInProgressObjectives = progress.inProgressObjectives
            .where((id) => id != objectiveId)
            .toList();

        // Calculate new completion percentage
        final allObjectives =
            await getLearningObjectives(subject, progress.currentPhase.name);
        final completion = allObjectives.isEmpty
            ? 0.0
            : (updatedCompletedObjectives.length / allObjectives.length) * 100;

        final updatedProgress = progress.copyWith(
          completedObjectives: updatedCompletedObjectives,
          inProgressObjectives: updatedInProgressObjectives,
          phaseCompletion: completion,
        );

        await updatePhaseProgress(childId, subject, updatedProgress);
      }
    } catch (e) {
      print('Error marking objective complete: $e');
    }
  }

  /// Generate PYP progress report for a child
  Future<Map<String, dynamic>> generatePYPProgressReport(String childId) async {
    try {
      final subjects = [
        ActivitySubject.reading.name,
        ActivitySubject.writing.name,
        ActivitySubject.science.name,
      ];

      final progressMap = <String, PhaseProgress>{};

      for (final subject in subjects) {
        final progress = await getPhaseProgress(childId, subject);
        if (progress != null) {
          progressMap[subject] = progress;
        }
      }

      // Calculate overall progress
      double overallCompletion = 0.0;
      if (progressMap.isNotEmpty) {
        final totalCompletion = progressMap.values.fold<double>(
          0.0,
          (sum, progress) => sum + progress.phaseCompletion,
        );
        overallCompletion = totalCompletion / progressMap.length;
      }

      return {
        'childId': childId,
        'generatedAt': DateTime.now().toIso8601String(),
        'subjectProgress': progressMap.map(
          (subject, progress) => MapEntry(subject, progress.toJson()),
        ),
        'overallCompletion': overallCompletion,
      };
    } catch (e) {
      print('Error generating PYP progress report: $e');
      return {};
    }
  }

  /// Get all phases a child has completed in a subject
  Future<List<PYPPhase>> getCompletedPhases(
    String childId,
    String subject,
  ) async {
    try {
      final progress = await getPhaseProgress(childId, subject);
      if (progress == null) return [];

      // Return all phases up to (but not including) current phase
      final currentIndex = PYPPhase.values.indexOf(progress.currentPhase);
      return PYPPhase.values.sublist(0, currentIndex);
    } catch (e) {
      print('Error getting completed phases: $e');
      return [];
    }
  }
}

