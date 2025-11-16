import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../models/simulation.dart' as sim;

/// Simulation Detail & Launch Page
/// Replicates the UI design from the DIY Bubble Wand reference
class SimulationDetailScreen extends StatefulWidget {
  final sim.Simulation simulation;

  const SimulationDetailScreen({
    super.key,
    required this.simulation,
  });

  @override
  State<SimulationDetailScreen> createState() => _SimulationDetailScreenState();
}

class _SimulationDetailScreenState extends State<SimulationDetailScreen> {
  static const double _detailTitleFontSize = 32;
  static const double _detailHeadingFontSize = 26;
  static const double _detailBodyFontSize = 18;
  static const double _detailChipFontSize = 18;
  static const double _detailLabelFontSize = 18;
  bool _isFullscreen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    setState(() => _isFullscreen = true);

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

  Future<void> _exitFullscreen() async {
    setState(() => _isFullscreen = false);

    // Return to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Show system UI
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return _buildFullscreenView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Top section: Simulation preview (fixed)
            _buildTopPreviewSection(),

            // Bottom section: Scrollable content
            Expanded(
              child: _buildScrollableContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPreviewSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.5, // Take half the screen
      margin: const EdgeInsets.all(0), // Remove margin to fill space
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            // WebView preview
            InAppWebView(
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
              ),
              onWebViewCreated: (controller) {
                // Controller created
              },
              onLoadStop: (controller, url) async {
                // Inject JavaScript to detect fullscreen changes
                await controller.evaluateJavascript(source: '''
                  document.addEventListener('fullscreenchange', function() {
                    if (document.fullscreenElement) {
                      window.flutter_inappwebview.callHandler('enterFullscreen');
                    } else {
                      window.flutter_inappwebview.callHandler('exitFullscreen');
                    }
                  });
                ''');
              },
            ),

            // Back button overlay (top-left)
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Sound button overlay (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Blue curved title bar
          _buildTitleBar(),

          // Orange topics section
          _buildTopicsSection(),

          // Blue learning goals section
          _buildLearningGoalsSection(),

          // Orange scientific explanation section
          _buildScientificExplanationSection(),

          // Yellow warning section
          _buildWarningSection(),

          // Start Simulation button section with blue background
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF5B9BD5), // Blue
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), // Straight corners
          topRight: Radius.circular(0), // Straight corners
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Title only
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.simulation.title,
                  style: TextStyle(
                    fontSize: _detailTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Tags aligned to the right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Time badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.simulation.estimatedMinutes} mins',
                  style: TextStyle(
                    fontSize: _detailLabelFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Difficulty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB4D47E), // Light green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.simulation.difficulty,
                  style: TextStyle(
                    fontSize: _detailLabelFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Heart icon
              const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 24,
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
      decoration: const BoxDecoration(
        color: Color(0xFFFDB462), // Orange
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: Color(0xFF1565C0),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Topics',
                style: TextStyle(
                  fontSize: _detailHeadingFontSize,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              Text(
                'TIP: Tap to mark ✓',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.simulation.topics.map((topic) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    fontSize: _detailChipFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningGoalsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF5B9BD5), // Blue
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Learning Goals',
                style: TextStyle(
                  fontSize: _detailHeadingFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              Text(
                'TIP: Tap step when done',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.simulation.learningGoals.asMap().entries.map((entry) {
            int index = entry.key;
            String goal = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: _detailLabelFontSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B9BD5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal,
                      style: TextStyle(
                        fontSize: _detailBodyFontSize,
                        color: Colors.white,
                        height: 1.5,
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

  Widget _buildScientificExplanationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFDB462), // Orange
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF1565C0),
                size: 24,
              ),
              SizedBox(width: 8),
          Text(
            'Scientific Explanation',
            style: TextStyle(
              fontSize: _detailHeadingFontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
              fontFamily: 'Nunito',
            ),
          ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.simulation.scientificExplanation,
            style: TextStyle(
              fontSize: _detailBodyFontSize,
              color: Colors.black.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF5B9BD5), // Blue
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFDB462),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Warning',
                style: TextStyle(
                  fontSize: _detailHeadingFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.simulation.warning,
            style: TextStyle(
              fontSize: _detailBodyFontSize,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B9BD5),
            const Color(0xFF4A8CC5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Custom curved top edge using ClipPath
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _enterFullscreen,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF5B9BD5),
                        size: 26,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Start Simulation',
                        style: TextStyle(
                          fontSize: _detailHeadingFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Help us improve',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
          // Fullscreen WebView
          InAppWebView(
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
            ),
            onWebViewCreated: (controller) {
              // Controller created for fullscreen view
            },
          ),

          // Exit fullscreen button
          SafeArea(
            child: Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _exitFullscreen,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.fullscreen_exit,
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
