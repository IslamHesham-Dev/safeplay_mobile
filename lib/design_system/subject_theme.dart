import 'package:flutter/material.dart';

import '../models/activity.dart';
import 'colors.dart';

class SubjectTheme {
  static Color color(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return SafePlayColors.brandTeal500;
      case ActivitySubject.reading:
        return SafePlayColors.juniorPurple;
      case ActivitySubject.writing:
        return SafePlayColors.juniorPink;
      case ActivitySubject.science:
        return SafePlayColors.brightTeal;
      case ActivitySubject.social:
        return SafePlayColors.brandOrange600;
      case ActivitySubject.art:
        return SafePlayColors.juniorLime;
      case ActivitySubject.music:
        return SafePlayColors.brightDeepPurple;
      case ActivitySubject.coding:
        return SafePlayColors.brightIndigo;
    }
  }

  static IconData icon(ActivitySubject subject) {
    switch (subject) {
      case ActivitySubject.math:
        return Icons.calculate_outlined;
      case ActivitySubject.reading:
        return Icons.menu_book_outlined;
      case ActivitySubject.writing:
        return Icons.create_outlined;
      case ActivitySubject.science:
        return Icons.science_outlined;
      case ActivitySubject.social:
        return Icons.public_outlined;
      case ActivitySubject.art:
        return Icons.brush_outlined;
      case ActivitySubject.music:
        return Icons.music_note_outlined;
      case ActivitySubject.coding:
        return Icons.memory_outlined;
    }
  }

  static String label(ActivitySubject subject) => subject.displayName;
}
