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
        title: 'A Planet Like Ours',
        pdfPath:
            'assets/books/A Planet Like Ours (Frank Murphy) (Z-Library).pdf',
        thumbnailPath: 'assets/books/thumbnails/A planet like ours.PNG',
      ),
      Book(
        id: '2',
        title: 'Lulu & Rocky in Rocky Mountain',
        pdfPath:
            'assets/books/Lulu  Rocky in Rocky Mountain National Park (Barbara Joosse) (Z-Library).pdf',
        thumbnailPath: 'assets/books/thumbnails/Lulu & Rocky.PNG',
      ),
      Book(
        id: '3',
        title: 'Pirates Don\'t Dance',
        pdfPath:
            'assets/books/Pirates Dont Dance (Shawna J. C. Tenney) (Z-Library).pdf',
        thumbnailPath: 'assets/books/thumbnails/Pirates Dont Dance.PNG',
      ),
      Book(
        id: '4',
        title: 'The Ant and the Grasshopper',
        pdfPath:
            'assets/books/The Ant and the Grasshopper (Melissa Rothman) (Z-Library).pdf',
        thumbnailPath:
            'assets/books/thumbnails/The Ant and The Grasshopper.PNG',
      ),
      Book(
        id: '5',
        title: 'The Lion King',
        pdfPath: 'assets/books/The Lion King (.) (Z-Library).pdf',
        thumbnailPath: 'assets/books/thumbnails/The Lion King.PNG',
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
