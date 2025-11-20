import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

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
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  PdfDocument? _document;
  late final TurnPageController _turnPageController;
  final Map<int, Future<PdfPageImage?>> _pageImageCache = {};

  @override
  void initState() {
    super.initState();
    _turnPageController = TurnPageController();
    _loadPdf();
  }

  @override
  void dispose() {
    _turnPageController.dispose();
    _document?.close();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      final ByteData data = await rootBundle.load(widget.book.pdfPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final document = await PdfDocument.openData(bytes);

      if (mounted) {
        setState(() {
          _document = document;
          _totalPages = document.pagesCount;
          _isLoading = false;
          _currentPage = 1;
        });
      }
      _prefetchInitialPages();
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: JuniorTheme.headingSmall,
        ),
        backgroundColor: JuniorTheme.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : _document != null && _totalPages > 0
                  ? _buildFlipBook()
                  : const Center(
                      child: Text(
                        'No pages available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
    );
  }

  void _prefetchInitialPages() {
    if (_totalPages <= 0) return;
    _renderPageImage(0);
    if (_totalPages > 1) {
      _renderPageImage(1);
    }
  }

  Future<PdfPageImage?> _renderPageImage(int index) {
    final document = _document;
    if (document == null) return Future.value(null);

    return _pageImageCache.putIfAbsent(index, () async {
      final page = await document.getPage(index + 1);
      try {
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFFFF',
          quality: 100,
          forPrint: true,
        );
        return image;
      } finally {
        await page.close();
      }
    });
  }

  Widget _buildFlipBook() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final bookWidth = availableWidth > 900 ? 900.0 : availableWidth;
        final bookHeight = availableHeight > 900 ? 900.0 : availableHeight;

        return Center(
          child: SizedBox(
            width: bookWidth,
            height: bookHeight,
            child: TurnPageView.builder(
              controller: _turnPageController,
              itemCount: _totalPages,
              animationTransitionPoint: 0.45,
              overleafColorBuilder: (_) => Colors.grey.shade300,
              overleafBorderColorBuilder: (_) =>
                  Colors.black.withValues(alpha: 0.1),
              overleafBorderWidthBuilder: (_) => 1.0,
              onSwipe: (_) => _updateDisplayedPage(),
              onTap: (_) => _updateDisplayedPage(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: _buildPage(index),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _updateDisplayedPage() {
    if (!mounted || _totalPages == 0) return;
    setState(() {
      _currentPage =
          (_turnPageController.currentIndex + 1).clamp(1, _totalPages);
    });
  }

  Widget _buildPage(int index) {
    return FutureBuilder<PdfPageImage?>(
      future: _renderPageImage(index),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildPageLoader();
        }

        final image = snapshot.data;
        if (image == null) {
          return _buildPageError(index);
        }

        final pageWidth = (image.width ?? 1).toDouble();
        final pageHeight = (image.height ?? 1).toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 25,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColoredBox(
              color: Colors.white,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: pageWidth,
                    height: pageHeight,
                    child: Image.memory(
                      image.bytes,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageLoader() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildPageError(int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load page ${index + 1}',
            textAlign: TextAlign.center,
            style: JuniorTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
