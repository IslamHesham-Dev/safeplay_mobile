import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../design_system/junior_theme.dart';
import '../../models/web_game.dart';
import '../../utils/orientation_utils.dart';
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
  bool _gameWasPlayed = false; // Track if game was actually played
  bool _showGuide = true; // Show guide first, then game
  final PageController _guidePageController = PageController();
  int _currentGuidePage = 0;

  @override
  void initState() {
    super.initState();
    // Allow players to rotate freely in the detail view
    allowAllDeviceOrientations();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _guidePageController.dispose();
    _exitFullscreenMode(notifyWebView: false, force: true);
    // Reset orientation when leaving
    allowAllDeviceOrientations();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _enterFullscreenMode() async {
    if (_isFullscreen) return;
    // Hide guide and show game
    setState(() {
      _showGuide = false;
      _isFullscreen = true;
      _gameWasPlayed = true; // Mark that game was played
    });
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
      setState(() {
        _isFullscreen = false;
        _showGuide = true; // Return to guide when exiting fullscreen
        _currentGuidePage = 0; // Reset to first page
      });
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await allowAllDeviceOrientations();
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

    // If showing guide, show guide pages
    if (_showGuide) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: _buildGuidePages(safeTop, screenHeight),
      );
    }

    // Otherwise show game (fullscreen)
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) async {
        if (!_isFullscreen || didPop) {
          return;
        }
        await _exitFullscreenMode();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildFullscreenMode(safeTop, screenHeight),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Return true if game was played (they entered fullscreen)
            Navigator.of(context).pop(_gameWasPlayed);
          },
          child: const Icon(Icons.fullscreen_exit),
        ),
      ),
    );
  }

  // Calculate number of guide pages needed
  int _getTotalGuidePages() {
    int pages = 2; // Title+Topics page + Explanation page
    // Learning goals: 3 per page
    int learningGoalPages = (widget.game.learningGoals.length / 3.0).ceil();
    pages += learningGoalPages;
    return pages;
  }

  // Get learning goals for a specific page (0-indexed, excluding title page)
  List<String> _getLearningGoalsForPage(int pageIndex) {
    // Page 0 = Title+Topics
    // Pages 1 to N = Learning Goals (2-3 per page)
    // Last page = Explanation + Warning
    int totalLearningGoalPages = (widget.game.learningGoals.length / 2.5).ceil();
    if (pageIndex <= 0 || pageIndex > totalLearningGoalPages) {
      return [];
    }
    // Fix: Use 3 items per page to avoid overlap (was using 2 as multiplier causing last item to repeat)
    int startIndex = (pageIndex - 1) * 3;
    int endIndex = (startIndex + 3).clamp(0, widget.game.learningGoals.length);
    return widget.game.learningGoals.sublist(startIndex, endIndex);
  }

  // Check if current page is the last page
  bool _isLastGuidePage(int pageIndex) {
    return pageIndex == _getTotalGuidePages() - 1;
  }

  // Get page type
  String _getPageType(int pageIndex) {
    if (pageIndex == 0) return 'title_topics';
    int totalLearningGoalPages = (widget.game.learningGoals.length / 3.0).ceil();
    if (pageIndex > 0 && pageIndex <= totalLearningGoalPages) return 'learning_goals';
    return 'explanation';
  }

  Widget _buildGuidePages(double safeTop, double screenHeight) {
    final totalPages = _getTotalGuidePages();
    
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _guidePageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentGuidePage = index;
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              return _buildGuidePage(index, screenHeight);
            },
          ),
        ),
        _buildGuideNavigationButtons(safeTop),
      ],
    );
  }

  Widget _buildGuidePage(int pageIndex, double screenHeight) {
    final pageType = _getPageType(pageIndex);
    
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 100), // Space for bottom nav
            child: Column(
              children: [
                if (pageType == 'title_topics') ...[
                  _buildHeaderSection(),
                  _buildTopicsSection(),
                ] else if (pageType == 'learning_goals') ...[
                  _buildSimpleHeader('What You\'ll Learn', Icons.check_circle_outline),
                  _buildLearningGoalsPage(pageIndex),
                ] else if (pageType == 'explanation') ...[
                  _buildSimpleHeader('About The Game', Icons.info_outline),
                  _buildExplanationSection(),
                  if (widget.game.warning != null) _buildWarningBox(),
                ],
              ],
            ),
          ),
        ),
        // Page Indicator (Top Center)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_getTotalGuidePages(), (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentGuidePage == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withValues(alpha: _currentGuidePage == index ? 1.0 : 0.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        // Back Button (Top Left)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: _buildBackButton(),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final colorValue = int.parse('FF${widget.game.color}', radix: 16);
    final cardColor = Color(colorValue);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 40,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.game.iconEmoji,
            style: const TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 16),
          Text(
            widget.game.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(
                '${widget.game.estimatedMinutes} mins',
                Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 12),
              _buildTag(
                widget.game.difficulty,
                Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(String title, IconData icon) {
    final colorValue = int.parse('FF${widget.game.color}', radix: 16);
    final cardColor = Color(colorValue);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 30,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TOPICS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: JuniorTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: widget.game.topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: JuniorTheme.primaryOrange.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  topic,
                  style: JuniorTheme.bodyMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: JuniorTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningGoalsPage(int pageIndex) {
    final goals = _getLearningGoalsForPage(pageIndex);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: goals.asMap().entries.map((entry) {
          final goal = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: JuniorTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: JuniorTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    goal,
                    style: JuniorTheme.bodyLarge.copyWith(
                      fontSize: 18,
                      height: 1.5,
                      color: JuniorTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGuideNavigationButtons(double safeTop) {
    final isLastPage = _isLastGuidePage(_currentGuidePage);
    
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (_currentGuidePage > 0)
            TextButton(
              onPressed: () {
                _guidePageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: JuniorTheme.textSecondary.withValues(alpha: 0.2)),
                ),
              ),
              child: Text(
                'Previous',
                style: JuniorTheme.bodyMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: JuniorTheme.textSecondary,
                ),
              ),
            )
          else
            const SizedBox(width: 16),
            
          // Next/Start button
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: _currentGuidePage > 0 ? 16 : 0),
              child: ElevatedButton(
                onPressed: () {
                  if (isLastPage) {
                    _enterFullscreenMode();
                  } else {
                    _guidePageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JuniorTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: JuniorTheme.primaryOrange.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Start Game' : 'Next',
                      style: JuniorTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isLastPage ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(_gameWasPlayed), // Return true if game was played
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenMode(double safeTop, double screenHeight) {
    return Stack(
      children: [
        _buildGameOverlay(
          previewHeight: screenHeight,
          safeTop: safeTop,
          screenHeight: screenHeight,
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _buildBackOrExitButton(),
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
        borderRadius: BorderRadius.zero,
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
              onWebFullscreenExit: () =>
                  _exitFullscreenMode(notifyWebView: false),
            ),
            if (_webViewLoading) _buildLoadingOverlay(cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(Color cardColor) {
    return Container(
      color: cardColor.withValues(alpha: 1),
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
            // Return true if game was played, false otherwise
            Navigator.of(context).pop(_gameWasPlayed);
          } else {
            // If they played the game but exited fullscreen, still return true
            Navigator.of(context).pop(_gameWasPlayed);
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


  Widget _buildExplanationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.game.explanation,
            style: JuniorTheme.bodyMedium.copyWith(
              fontSize: 20,
              height: 1.6,
              color: JuniorTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Very light orange
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.game.warning!,
                  style: JuniorTheme.bodyMedium.copyWith(
                    fontSize: 18,
                    color: JuniorTheme.textPrimary.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
