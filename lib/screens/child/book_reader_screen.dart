import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../../design_system/junior_theme.dart';
import '../../models/book.dart';

/// PDF Reader screen for displaying books
class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  void _popWithCompletion([bool completed = true]) {
    Navigator.of(context).pop(completed);
  }

  Future<void> _loadPdf() async {
    try {
      // Load PDF from assets and copy to local file system
      final ByteData data = await rootBundle.load(widget.book.pdfPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = widget.book.pdfPath.split('/').last;
      final file = File('${directory.path}/$fileName');

      // Write PDF to local file
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading book: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final completed = _error == null && _localPath != null;
        _popWithCompletion(completed);
        return false;
      },
      child: Scaffold(
        backgroundColor: JuniorTheme.backgroundLight,
        appBar: AppBar(
          title: Text(
            widget.book.title,
            style: JuniorTheme.headingSmall,
          ),
          backgroundColor: JuniorTheme.primaryBlue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                _popWithCompletion(_error == null && _localPath != null),
          ),
          actions: [
            if (_totalPages > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: JuniorTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _popWithCompletion(false),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : _localPath != null
                    ? PDFView(
                        filePath: _localPath!,
                        enableSwipe: true,
                        swipeHorizontal: true, // Enable horizontal swiping
                        autoSpacing: false,
                        pageFling: true, // Enable page fling gesture
                        onRender: (pages) {
                          if (mounted) {
                            setState(() {
                              _totalPages = pages ?? 0;
                            });
                          }
                        },
                        onPageChanged: (page, total) {
                          if (mounted) {
                            setState(() {
                              _currentPage = page ?? 1;
                              _totalPages = total ?? 0;
                            });
                          }
                        },
                        onViewCreated: (PDFViewController controller) {
                          _pdfViewController = controller;
                        },
                      )
                    : const Center(
                        child: Text('No PDF loaded'),
                      ),
      ),
    );
  }
}
