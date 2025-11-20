/// Book model for the library
class Book {
  final String id;
  final String title;
  final String pdfPath;
  final String? thumbnailPath;

  const Book({
    required this.id,
    required this.title,
    required this.pdfPath,
    this.thumbnailPath,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      pdfPath: json['pdfPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pdfPath': pdfPath,
      'thumbnailPath': thumbnailPath,
    };
  }
}


