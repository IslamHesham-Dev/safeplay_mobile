import 'package:flutter/widgets.dart';

Widget buildWebGameIframe({
  required String viewType,
  required String url,
  required double minHeight,
  required VoidCallback onLoaded,
}) {
  throw UnsupportedError('Web iframe view is only available on Flutter web.');
}
