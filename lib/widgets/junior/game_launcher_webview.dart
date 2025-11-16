import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Shared WebView widget that loads an external game page, injects cleanup JS,
/// and notifies Flutter when the child taps Play/exit inside the web content.
class GameLauncherWebView extends StatefulWidget {
  const GameLauncherWebView({
    super.key,
    required this.gameUrl,
    required this.previewHeight,
    required this.isFullscreen,
    this.onControllerReady,
    required this.onGamePlay,
    required this.onExitRequested,
    this.onLoadingChanged,
  });

  /// The target URL that hosts the embedded game.
  final String gameUrl;

  /// Height used when the WebView renders as a preview tile.
  final double previewHeight;

  /// Whether the WebView is currently expanded to fullscreen.
  final bool isFullscreen;

  /// Called when the native controller is ready.
  final ValueChanged<InAppWebViewController>? onControllerReady;

  /// Triggered when the injected JS detects a tap on the Play/canvas area.
  final VoidCallback onGamePlay;

  /// Triggered when the page requests to exit fullscreen (via JS callback).
  final VoidCallback onExitRequested;

  /// Optional loading callback so parents can show custom overlays.
  final ValueChanged<bool>? onLoadingChanged;

  @override
  State<GameLauncherWebView> createState() => _GameLauncherWebViewState();
}

class _GameLauncherWebViewState extends State<GameLauncherWebView> {
  static const String _preHideScript = '''
  (function() {
    try {
      document.documentElement.style.visibility = 'hidden';
      document.documentElement.style.backgroundColor = '#000';
      if (document.body) {
        document.body.style.visibility = 'hidden';
        document.body.style.backgroundColor = '#000';
      }
    } catch (err) {
      console.warn('pre-hide error', err);
    }
  })();
  ''';
  static const String _cleanupScript = r'''
(function () {
  const MAX_ATTEMPTS = 12;
  let attempts = 0;

  function notifyAppPlay() {
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('onGamePlay', { source: location.href });
      }
    } catch (err) {
      console.warn('notifyAppPlay error', err);
    }
  }

  function notifyExit() {
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('onExitFullscreen', { source: location.href });
      }
    } catch (err) {}
  }

  function attachPlayHooks(target) {
    if (!target) return;
    ['#play-button', '.play-button', 'canvas', 'object', 'ruffle-embed'].forEach(function (selector) {
      target.querySelectorAll(selector).forEach(function (node) {
        node.addEventListener('click', function () {
          setTimeout(notifyAppPlay, 150);
        }, { capture: true, passive: true });
      });
    });
  }

  function removeSiteChrome() {
    ['.cc-window', '.cc-compliance', '.adsbygoogle', 'ins.adsbygoogle', '#cse-search-box', 'form[action*="cse"]', '#PING_IFRAME_FORM_DETECTION'].forEach(function (selector) {
      document.querySelectorAll(selector).forEach(function (node) {
        node.remove();
      });
    });
  }

  function cleanup() {
    if (document.getElementById('__app_game_wrapper')) {
      return true;
    }
    attempts += 1;
    try {
      const ruffle = document.querySelector('ruffle-embed[src*="food_chains"]') ||
        document.querySelector('object[title="Food Chains"] ruffle-embed') ||
        document.querySelector('object[title="Food Chains"]') ||
        document.querySelector('ruffle-embed');

      if (!ruffle) {
        return false;
      }

      const rootGameNode = ruffle.closest('object') || ruffle;
      document.documentElement.style.visibility = 'hidden';
      document.documentElement.style.backgroundColor = '#000';
      document.body.style.visibility = 'hidden';

      const gameWrapper = document.createElement('div');
      gameWrapper.id = '__app_game_wrapper';
      Object.assign(gameWrapper.style, {
        position: 'absolute',
        top: '0',
        left: '0',
        right: '0',
        bottom: '0',
        width: '100vw',
        height: '100vh',
        background: '#000',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
        boxSizing: 'border-box',
        padding: '0',
        margin: '0',
      });

      try {
        gameWrapper.appendChild(rootGameNode);
      } catch (err) {
        console.warn('Failed to move game node', err);
      }

      try {
        rootGameNode.style.width = '100%';
        rootGameNode.style.height = '100%';
        rootGameNode.style.maxWidth = '100%';
        rootGameNode.style.maxHeight = '100%';
        rootGameNode.style.display = 'flex';
        rootGameNode.style.alignItems = 'center';
        rootGameNode.style.justifyContent = 'center';
        rootGameNode.style.margin = 'auto';
      } catch (err) {}

      const innerCanvas = rootGameNode.querySelector && rootGameNode.querySelector('canvas');
      if (innerCanvas) {
        innerCanvas.style.width = 'auto';
        innerCanvas.style.height = 'auto';
        innerCanvas.style.maxWidth = '100%';
        innerCanvas.style.maxHeight = '100%';
        innerCanvas.style.objectFit = 'contain';
        innerCanvas.style.touchAction = 'none';
        innerCanvas.style.display = 'block';
        innerCanvas.style.margin = 'auto';
      }

      document.documentElement.style.height = '100%';
      document.body.innerHTML = '';
      Object.assign(document.body.style, {
        margin: '0',
        height: '100%',
        background: '#f0f6ff',
        display: 'flex',
        flexDirection: 'column',
      });

      document.body.appendChild(gameWrapper);
      document.body.style.visibility = 'visible';
      document.documentElement.style.visibility = 'visible';

      attachPlayHooks(rootGameNode);
      removeSiteChrome();

      return true;
    } catch (error) {
      console.error('Cleanup error', error);
      return false;
    }
  }

  function start() {
    if (cleanup()) {
      return;
    }
    if (attempts < MAX_ATTEMPTS) {
      setTimeout(start, 400);
    }
  }

  start();

  window.__exitFullscreen = function () {
    notifyExit();
  };
})();
''';

  bool _isLoading = true;
  int _loadingGeneration = 0;
  Timer? _loadingTimeout;

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (loading) {
      _loadingGeneration++;
      if (!_isLoading) {
        setState(() => _isLoading = true);
      }
      widget.onLoadingChanged?.call(true);
      final generation = _loadingGeneration;
      _loadingTimeout?.cancel();
      _loadingTimeout = Timer(const Duration(seconds: 20), () {
        if (!mounted || generation != _loadingGeneration) return;
        if (_isLoading) {
          setState(() => _isLoading = false);
          widget.onLoadingChanged?.call(false);
        }
      });
      return;
    }

    final generation = ++_loadingGeneration;
    _loadingTimeout?.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || generation != _loadingGeneration) {
        return;
      }
      if (_isLoading) {
        setState(() => _isLoading = false);
      }
      widget.onLoadingChanged?.call(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      constraints: BoxConstraints(
        minHeight: widget.isFullscreen ? 0 : widget.previewHeight,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          InAppWebView(
            key: ValueKey('junior-game-${widget.gameUrl}'),
            initialUrlRequest: URLRequest(url: WebUri(widget.gameUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              allowsAirPlayForMediaPlayback: true,
              allowsPictureInPictureMediaPlayback: true,
              useHybridComposition: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              domStorageEnabled: true,
              databaseEnabled: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {
              widget.onControllerReady?.call(controller);

              controller.addJavaScriptHandler(
                handlerName: 'onGamePlay',
                callback: (args) {
                  widget.onGamePlay();
                  return {'handled': true};
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'onExitFullscreen',
                callback: (args) {
                  widget.onExitRequested();
                  return {'handled': true};
                },
              );
            },
            onLoadStart: (controller, url) {
              _setLoading(true);
              controller.evaluateJavascript(source: _preHideScript);
            },
            onLoadStop: (controller, url) async {
              await Future.delayed(const Duration(milliseconds: 3000));
              try {
                await controller.evaluateJavascript(source: _cleanupScript);
              } catch (e) {
                debugPrint('Cleanup JS error: $e');
              }
              await Future.delayed(const Duration(milliseconds: 1000));
              _setLoading(false);
            },
            onProgressChanged: (controller, progress) {
              if (progress >= 80) {
                _setLoading(false);
              }
            },
            onReceivedError: (controller, request, error) {
              debugPrint('WebView error: $error');
              _setLoading(false);
            },
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('WebView Console: ${consoleMessage.message}');
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
