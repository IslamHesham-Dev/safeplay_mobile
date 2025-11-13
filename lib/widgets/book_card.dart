import 'package:flutter/material.dart';
import '../models/book.dart';
import '../design_system/junior_theme.dart';

/// Book card widget for displaying books in the library
class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 150,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: widget.book.thumbnailPath != null
                      ? Image.asset(
                          widget.book.thumbnailPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Title
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Text(
                  widget.book.title,
                  style: JuniorTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JuniorTheme.primaryBlue.withValues(alpha: 0.15),
            JuniorTheme.primaryGreen.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 64,
            color: JuniorTheme.primaryBlue.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.book.title,
              style: JuniorTheme.bodySmall.copyWith(
                color: JuniorTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
