import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(loc.t('label.language_prompt')),
      content: Text(
        loc.t('label.language_description'),
        style: const TextStyle(height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(const Locale('en')),
          child: Text(loc.t('lang.english')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(const Locale('ar')),
          child: Text(loc.t('lang.arabic')),
        ),
      ],
    );
  }
}
