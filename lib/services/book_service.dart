import 'package:flutter/material.dart';
import '../models/book.dart';

/// Service to manage books and generate thumbnails
class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final Map<String, ImageProvider> _thumbnailCache = {};

  /// Get all available books
  Future<List<Book>> getBooks() async {
    // List of books in assets/books with their corresponding thumbnails
    final books = [
      Book(
        id: '1',
        title: 'Hamza Adventure 6',
        pdfPath: 'assets/books/hamza_adventure-6.pdf',
        thumbnailPath: 'assets/books/thumbnails/hamza_adventure-6.PNG',
      ),
      Book(
        id: '2',
        title: 'Hamza Adventure 7',
        pdfPath: 'assets/books/hamza_adventure-7.pdf',
        thumbnailPath: 'assets/books/thumbnails/hamza_adventure-7.PNG',
      ),
      Book(
        id: '3',
        title: 'Hugh Adventure',
        pdfPath: 'assets/books/hugh_adventure.pdf',
        thumbnailPath: 'assets/books/thumbnails/hugh_adventure.PNG',
      ),
      Book(
        id: '4',
        title: 'Nada Adventure',
        pdfPath: 'assets/books/nada_adventure.pdf',
        thumbnailPath: 'assets/books/thumbnails/nada_adventure.PNG',
      ),
      Book(
        id: '5',
        title: 'Sarah Adventure 2',
        pdfPath: 'assets/books/Sarah_adventure-2.pdf',
        thumbnailPath: 'assets/books/thumbnails/sarah_adventure-2.PNG',
      ),
      Book(
        id: '6',
        title: 'Youssef Adventure',
        pdfPath: 'assets/books/youssef_adventure.pdf',
        thumbnailPath: 'assets/books/thumbnails/youssef_adventure.PNG',
      ),
    ];

    return books;
  }

  /// Generate thumbnail from PDF first page
  /// Returns null to show placeholder - thumbnail generation can be added later
  Future<ImageProvider?> generateBookThumbnail(String pdfPath) async {
    // For now, return null to show placeholder icon
    // Thumbnail generation from PDF can be implemented later with a working PDF package
    return null;
  }

  /// Clear thumbnail cache
  void clearCache() {
    _thumbnailCache.clear();
  }
}
