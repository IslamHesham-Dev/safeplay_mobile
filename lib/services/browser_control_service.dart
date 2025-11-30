import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/browser_control_settings.dart';

class BrowserControlService {
  BrowserControlService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'browserControls';

  Future<BrowserControlSettings> fetchSettings(String childId) async {
    if (childId.isEmpty) {
      return BrowserControlSettings.defaults();
    }
    final doc =
        await _firestore.collection(_collection).doc(childId).get();
    if (!doc.exists || doc.data() == null) {
      return BrowserControlSettings.defaults();
    }
    return BrowserControlSettings.fromMap(doc.data()!);
  }

  Future<void> saveSettings(
    String childId,
    BrowserControlSettings settings,
  ) async {
    if (childId.isEmpty) return;
    await _firestore.collection(_collection).doc(childId).set(
          {
            ...settings.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }
}
