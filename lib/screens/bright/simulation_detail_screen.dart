import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../models/simulation.dart' as sim;
import '../../utils/orientation_utils.dart';

const Map<String, String> _simulationVoiceoverAssets = {
  'states-of-matter':
      'audio/voiceovers/science/states_of_matter/1.mp3',
  'balloons-static-electricity':
      'audio/voiceovers/science/balloons_and_static/1.mp3',
  'density': 'audio/voiceovers/science/exploring_density/1.mp3',
  'area-model-introduction':
      'audio/voiceovers/math/area_model/1.mp3',
  'equality-explorer-basics':
      'audio/voiceovers/math/equality_explorer/1.mp3',
};

/// Simulation Detail & Launch Page
/// Replicates the UI design from the DIY Bubble Wand reference
class SimulationDetailScreen extends StatefulWidget {
  final sim.Simulation simulation;
  final Color? cardColor; // Color from the dashboard card
  final Future<void> Function()? onVoiceoverStart;
  final Future<void> Function()? onVoiceoverEnd;

  const SimulationDetailScreen({
    super.key,
    required this.simulation,
    this.cardColor,
    this.onVoiceoverStart,
    this.onVoiceoverEnd,
  });

  @override
  State<SimulationDetailScreen> createState() => _SimulationDetailScreenState();
}

class _SimulationDetailScreenState extends State<SimulationDetailScreen> {
  bool _isFullscreen = false;
  bool _gameWasPlayed = false; // Track if game was actually played
  final ScrollController _scrollController = ScrollController();
  final PageController _guidePageController = PageController();
  int _currentGuidePage = 0;
  bool _showInitialOverlay = false;
  Timer? _overlayTimer;
  Timer? _previewOverlayTimer;
  final AudioPlayer _voiceoverPlayer = AudioPlayer();
  bool _voiceoverActive = false;
  StreamSubscription<void>? _voiceoverCompleteSubscription;

  // Get the card color with fallback to default blue
  Color get _cardColor => widget.cardColor ?? const Color(0xFF5B9BD5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePlaySimulationVoiceover();
    });
  }

  @override
  void dispose() {
    _guidePageController.dispose();
    _scrollController.dispose();
    _overlayTimer?.cancel();
    _previewOverlayTimer?.cancel();
    _voiceoverCompleteSubscription?.cancel();
    unawaited(_voiceoverPlayer.stop());
    unawaited(_notifyVoiceoverEnded());
    _voiceoverPlayer.dispose();
    // Reset orientation when leaving
    allowAllDeviceOrientations();
    super.dispose();
  }

  Future<void> _maybePlaySimulationVoiceover() async {
    final voiceoverPath =
        _simulationVoiceoverAssets[widget.simulation.id];
    if (voiceoverPath == null) return;
    try {
      if (widget.onVoiceoverStart != null) {
        await widget.onVoiceoverStart!.call();
      }
      _voiceoverActive = true;
      _voiceoverCompleteSubscription?.cancel();
      await _voiceoverPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _voiceoverPlayer.setReleaseMode(ReleaseMode.stop);
      await _voiceoverPlayer.setVolume(1.0);
      await _voiceoverPlayer.stop();
      await _voiceoverPlayer.play(
        AssetSource(voiceoverPath),
      );
      _voiceoverCompleteSubscription =
          _voiceoverPlayer.onPlayerComplete.listen((_) {
        unawaited(_notifyVoiceoverEnded());
      });
      debugPrint(
          'Playing simulation voiceover for ${widget.simulation.id}');
    } catch (e, stack) {
      debugPrint('Error playing simulation voiceover: $e');
      debugPrint('$stack');
      await _notifyVoiceoverEnded();
    }
  }

  Future<void> _notifyVoiceoverEnded() async {
    if (!_voiceoverActive) return;
    _voiceoverActive = false;
    _voiceoverCompleteSubscription?.cancel();
    _voiceoverCompleteSubscription = null;
    if (widget.onVoiceoverEnd != null) {
      try {
        await widget.onVoiceoverEnd!.call();
      } catch (e) {
        debugPrint('Error resuming background music after voiceover: $e');
      }
    }
  }

  Future<void> _enterFullscreen() async {
    _overlayTimer?.cancel();
    setState(() {
      _isFullscreen = true;
      _gameWasPlayed = true; // Mark that game was played
      _showInitialOverlay = true;
    });
    _overlayTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showInitialOverlay = false);
      }
    });

    // Set landscape orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide system UI
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return _buildFullscreenView();
    }
    
    // Always show guide if not fullscreen (guide handles the "start" transition)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildGuidePages(),
    );
  }

  // Calculate number of guide pages needed
  int _getTotalGuidePages() {
    int pages = 2; // Title+Topics page + Explanation page
    // Learning goals: 3 per page
    int learningGoalPages = (widget.simulation.learningGoals.length / 3.0).ceil();
    pages += learningGoalPages;
    return pages;
  }

  // Get learning goals for a specific page (0-indexed, excluding title page)
  List<String> _getLearningGoalsForPage(int pageIndex) {
    // Page 0 = Title+Topics
    // Pages 1 to N = Learning Goals (2-3 per page)
    // Last page = Explanation + Warning
    int totalLearningGoalPages = (widget.simulation.learningGoals.length / 2.5).ceil();
    if (pageIndex <= 0 || pageIndex > totalLearningGoalPages) {
      return [];
    }
    // Fix: Use 3 items per page to avoid overlap (was using 2 as multiplier causing last item to repeat)
    int startIndex = (pageIndex - 1) * 3;
    int endIndex = (startIndex + 3).clamp(0, widget.simulation.learningGoals.length);
    return widget.simulation.learningGoals.sublist(startIndex, endIndex);
  }

  // Check if current page is the last page
  bool _isLastGuidePage(int pageIndex) {
    return pageIndex == _getTotalGuidePages() - 1;
  }

  // Get page type
  String _getPageType(int pageIndex) {
    if (pageIndex == 0) return 'title_topics';
    int totalLearningGoalPages = (widget.simulation.learningGoals.length / 3.0).ceil();
    if (pageIndex > 0 && pageIndex <= totalLearningGoalPages) return 'learning_goals';
    return 'explanation';
  }

  Widget _buildGuidePages() {
    final totalPages = _getTotalGuidePages();
    final safeTop = MediaQuery.of(context).padding.top;
    
    return Stack(
      children: [
        Column(
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
                  return _buildGuidePage(index);
                },
              ),
            ),
            _buildGuideNavigationButtons(),
          ],
        ),
        // Page Indicator (Top Center)
        Positioned(
          top: safeTop + 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
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
          top: safeTop + 8,
          left: 16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(false), // Return false - game not played
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidePage(int pageIndex) {
    final pageType = _getPageType(pageIndex);
    
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            if (pageType == 'title_topics') ...[
              _buildHeaderSection(),
              _buildTopicsSection(),
            ] else if (pageType == 'learning_goals') ...[
              _buildSimpleHeader('Learning Goals', Icons.check_circle_outline),
              _buildLearningGoalsPage(pageIndex),
            ] else if (pageType == 'explanation') ...[
              _buildSimpleHeader('Scientific Explanation', Icons.lightbulb_outline),
              _buildScientificExplanationSection(),
              _buildWarningSection(),
            ],
          ],
        ),
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
                    color: _cardColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: _cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    goal,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
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

  Widget _buildGuideNavigationButtons() {
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
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                ),
              ),
              child: Text(
                'Previous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Nunito',
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
                    _enterFullscreen();
                  } else {
                    _guidePageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: _cardColor.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Start Sim' : 'Next',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isLastPage ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                      size: 28,
                      color: Colors.white,
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

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 40,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.science_rounded, size: 72, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            widget.simulation.title,
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
                '${widget.simulation.estimatedMinutes} mins',
                Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 12),
              _buildTag(
                widget.simulation.difficulty,
                Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 30,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withValues(alpha: 0.3),
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
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: widget.simulation.topics.map((topic) {
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
                    color: _cardColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _cardColor,
                    fontFamily: 'Nunito',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildScientificExplanationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.simulation.scientificExplanation,
            style: TextStyle(
              fontSize: 20,
              height: 1.6,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
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
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.simulation.warning,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    height: 1.4,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFullscreenView() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.simulation.iframeUrl),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useHybridComposition: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                domStorageEnabled: true,
                databaseEnabled: true,
                transparentBackground: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
              ),
              onLoadStop: (controller, _) {},
            ),
          ),
          if (_showInitialOverlay)
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.08,
            child: IgnorePointer(
              child: Container(color: Colors.black),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black.withValues(alpha: 0.6),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    // Return true if game was played (they entered fullscreen)
                    Navigator.of(context).pop(_gameWasPlayed);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
