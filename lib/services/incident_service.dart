import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

class IncidentService {
  IncidentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String incidentsCollection = 'incidents';

  Future<List<Incident>> fetchIncidentsForParent({
    required String parentId,
    String? childId,
    int limit = 10,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(incidentsCollection)
          .where('parentIds', arrayContains: parentId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (childId != null) {
        query = query.where('childId', isEqualTo: childId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Incident.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } on FirebaseException catch (error) {
      if (error.code == 'failed-precondition') {
        // Attempt without orderBy if index is missing
        Query<Map<String, dynamic>> query = _firestore
            .collection(incidentsCollection)
            .where('parentIds', arrayContains: parentId)
            .limit(limit);
        if (childId != null) {
          query = query.where('childId', isEqualTo: childId);
        }
        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => Incident.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();
      }
      rethrow;
    }
  }
}
