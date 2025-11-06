import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../scripts/extract_question_templates_from_source.dart';

// Import dart:io only for non-web platforms
import 'dart:io' if (dart.library.html) '../utils/file_stub.dart' as io;

/// Widget to export question templates from source code to JSON
/// This extracts data directly from the seeding scripts (no Firebase needed)
class QuestionTemplateExporter extends StatefulWidget {
  const QuestionTemplateExporter({super.key});

  @override
  State<QuestionTemplateExporter> createState() =>
      _QuestionTemplateExporterState();
}

class _QuestionTemplateExporterState extends State<QuestionTemplateExporter> {
  bool _loading = false;
  String? _jsonData;
  String? _error;
  int _totalCount = 0;

  Future<void> _exportTemplates() async {
    setState(() {
      _loading = true;
      _error = null;
      _jsonData = null;
    });

    try {
      print('📥 Extracting question templates from source code...');

      // Extract templates directly from source code (no Firebase needed)
      final jsonString = exportQuestionTemplatesToJson();

      // Parse to get count
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final templates = data['templates'] as List;

      print('✅ Extracted ${templates.length} templates from source');

      setState(() {
        _jsonData = jsonString;
        _totalCount = templates.length;
        _loading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      print('Error: $e');
      print(stackTrace);
    }
  }

  Future<void> _saveToFile() async {
    if (_jsonData == null) return;

    if (kIsWeb) {
      // For web, just copy to clipboard (file save requires download trigger)
      await Clipboard.setData(ClipboardData(text: _jsonData!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ JSON copied! Paste into a text file and save as .json'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // For mobile/desktop, save to file
      // Note: This code path is only executed on non-web platforms
      try {
        // On non-web, io.File refers to dart:io.File
        // ignore: undefined_class
        final file = io.File('question_templates_export.json');
        await file.writeAsString(_jsonData!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ File saved to: ${file.absolute.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error saving file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Question Templates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _exportTemplates,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_loading ? 'Exporting...' : 'Export to JSON'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_jsonData != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✅ Exported $_totalCount questions successfully!',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveToFile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save to File'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_jsonData != null) {
                          await Clipboard.setData(
                              ClipboardData(text: _jsonData!));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ JSON copied to clipboard!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy JSON'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _jsonData!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
