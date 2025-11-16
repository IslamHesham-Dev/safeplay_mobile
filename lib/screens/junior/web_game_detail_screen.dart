import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../models/web_game.dart';
import '../../design_system/junior_theme.dart';
import '../../widgets/junior/game_launcher_webview.dart';

/// Detail screen for web-based games with canvas isolation
class WebGameDetailScreen extends StatefulWidget {
  final WebGame game;

  const WebGameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<WebGameDetailScreen> createState() => _WebGameDetailScreenState();
}

class _WebGameDetailScreenState extends State<WebGameDetailScreen> {
  InAppWebViewController? _webViewController;
  bool _webViewLoading = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait for detail view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _exitFullscreenMode(notifyWebView: false, force: true);
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _enterFullscreenMode() async {
    if (_isFullscreen) return;
    setState(() => _isFullscreen = true);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitFullscreenMode({
    bool notifyWebView = true,
    bool force = false,
  }) async {
    if (!_isFullscreen && !force) {
      return;
    }
    if (_isFullscreen) {
      setState(() => _isFullscreen = false);
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    if (notifyWebView) {
      try {
        await _webViewController?.evaluateJavascript(
          source: "if(window.__exitFullscreen){window.__exitFullscreen();}",
        );
      } catch (_) {
        // Ignore errors when the controller is not ready
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeTop = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;
    // Preview takes 40% of screen height in detail mode
    final previewHeight = _isFullscreen ? screenHeight : screenHeight * 0.4;

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) async {
        if (!_isFullscreen || didPop) {
          return;
        }
        await _exitFullscreenMode();
      },
      child: Scaffold(
        backgroundColor: _isFullscreen ? Colors.black : Colors.white,
        body: _isFullscreen
            ? _buildFullscreenMode(safeTop, screenHeight)
            : _buildDetailMode(safeTop, screenHeight, previewHeight),
        floatingActionButton: _isFullscreen
            ? FloatingActionButton(
                onPressed: () => _exitFullscreenMode(),
                child: const Icon(Icons.fullscreen_exit),
              )
            : null,
      ),
    );
  }

  Widget _buildFullscreenMode(double safeTop, double screenHeight) {
    return Stack(
      children: [
        // Game takes full screen
        _buildGameOverlay(
          previewHeight: screenHeight,
          safeTop: safeTop,
          screenHeight: screenHeight,
        ),
        // Exit button
        Positioned(
          top: 16,
          left: 16,
          child: _buildBackOrExitButton(),
        ),
      ],
    );
  }

  Widget _buildDetailMode(
      double safeTop, double screenHeight, double previewHeight) {
    return Column(
      children: [
        // Top section: Game preview (40% height)
        SizedBox(
          height: previewHeight,
          child: Stack(
            children: [
              _buildGameOverlay(
                previewHeight: previewHeight,
                safeTop: safeTop,
                screenHeight: previewHeight,
              ),
              // Back button
              Positioned(
                top: safeTop + 16,
                left: 16,
                child: _buildBackOrExitButton(),
              ),
            ],
          ),
        ),
        // Bottom section: Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTitleBar(),
                _buildTopicsSection(),
                _buildLearningGoalsSection(),
                _buildExplanationSection(),
                if (widget.game.warning != null) _buildWarningBox(),
                _buildStartButton(),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverlay({
    required double previewHeight,
    required double safeTop,
    required double screenHeight,
  }) {
    final colorValue =
        int.tryParse('FF${widget.game.color}', radix: 16) ?? 0xFF4CAF50;
    final cardColor = Color(colorValue);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isFullscreen ? 0 : 0,
      left: 0,
      right: 0,
      height: screenHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.zero, // Straight corners always
        child: Stack(
          children: [
            GameLauncherWebView(
              gameUrl: widget.game.websiteUrl,
              previewHeight: previewHeight,
              isFullscreen: _isFullscreen,
              onControllerReady: (controller) {
                _webViewController = controller;
              },
              onGamePlay: _enterFullscreenMode,
              onExitRequested: () => _exitFullscreenMode(notifyWebView: false),
              onLoadingChanged: (loading) {
                if (!mounted) return;
                setState(() => _webViewLoading = loading);
              },
            ),
            if (_webViewLoading) _buildLoadingOverlay(cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(Color cardColor) {
    return Container(
      color: cardColor.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.game.iconEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.game.title}...',
              style: JuniorTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackOrExitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (_isFullscreen) {
            await _exitFullscreenMode();
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isFullscreen ? Icons.close : Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    final colorValue = int.parse('FF${widget.game.color}', radix: 16);
    final cardColor = Color(colorValue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                widget.game.iconEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.game.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.game.estimatedMinutes} mins',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.game.difficulty,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDB462).withValues(alpha: 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category,
                color: JuniorTheme.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Topics',
                style: JuniorTheme.headingMedium.copyWith(
                  fontSize: 22,
                  color: JuniorTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.game.topics
                .map((topic) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: JuniorTheme.shadowLight,
                      ),
                      child: Text(
                        topic,
                        style: JuniorTheme.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: JuniorTheme.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningGoalsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You\'ll Learn',
            style: JuniorTheme.headingMedium.copyWith(
              fontSize: 22,
              color: JuniorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.game.learningGoals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: JuniorTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal,
                      style: JuniorTheme.bodyLarge.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: JuniorTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExplanationSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: JuniorTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'About This Game',
                style: JuniorTheme.headingSmall.copyWith(
                  fontSize: 20,
                  color: JuniorTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.game.explanation,
            style: JuniorTheme.bodyMedium.copyWith(
              fontSize: 16,
              height: 1.6,
              color: JuniorTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBC02D), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber,
            color: Color(0xFFF57C00),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.game.warning!,
              style: JuniorTheme.bodyMedium.copyWith(
                fontSize: 14,
                color: JuniorTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ElevatedButton(
        onPressed: () => _enterFullscreenMode(),
        style: ElevatedButton.styleFrom(
          backgroundColor: JuniorTheme.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 28),
            const SizedBox(width: 12),
            Text(
              'Start Game',
              style: JuniorTheme.headingMedium.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
