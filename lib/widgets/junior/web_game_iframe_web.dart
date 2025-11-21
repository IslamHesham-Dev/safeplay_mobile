// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

Widget buildWebGameIframe({
  required String viewType,
  required String url,
  required double minHeight,
  required VoidCallback onLoaded,
}) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen'
      ..allowFullscreen = true;

    iframe.onLoad.listen((event) {
      onLoaded();
    });

    return iframe;
  });

  return SizedBox(
    height: minHeight == 0 ? null : minHeight,
    child: HtmlElementView(viewType: viewType),
  );
}
