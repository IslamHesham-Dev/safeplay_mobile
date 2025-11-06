// Stub for File operations on web
// This file provides a stub implementation for web platforms

class File {
  final String path;

  File(this.path);

  Future<void> writeAsString(String contents) async {
    throw UnsupportedError('File operations not supported on web');
  }

  String get absolutePath => path;

  File get absolute => this;
}
