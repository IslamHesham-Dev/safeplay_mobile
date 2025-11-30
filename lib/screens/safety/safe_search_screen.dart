import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../../design_system/colors.dart';
import '../../design_system/junior_theme.dart';
import '../../models/browser_control_settings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/browser_control_provider.dart';

class SafeSearchScreen extends StatefulWidget {
  const SafeSearchScreen({super.key, this.childId});

  final String? childId;

  @override
  State<SafeSearchScreen> createState() => _SafeSearchScreenState();
}

class _SafeSearchScreenState extends State<SafeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String? _statusMessage;
  String? _resolvedChildId;
  BrowserControlSettings? _latestSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    final resolvedChildId = widget.childId ?? authProvider.currentChild?.id;
    if (resolvedChildId != null && resolvedChildId != _resolvedChildId) {
      _resolvedChildId = resolvedChildId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BrowserControlProvider>().loadSettings(resolvedChildId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childId = _resolvedChildId;
    if (childId == null) {
      return _buildCenteredMessage(
        icon: Icons.lock_rounded,
        message: 'Sign in as a child to explore the safe browser.',
      );
    }

    return Consumer<BrowserControlProvider>(
      builder: (context, provider, _) {
        final settings = provider.settingsFor(childId);
        final isLoading = provider.isLoading(childId);
        final error = provider.errorFor(childId);

        if (settings == null || isLoading) {
          return _buildCenteredMessage(
            icon: Icons.cloud_download,
            message: 'Loading safe browser preferences...',
            showSpinner: true,
          );
        }

        _latestSettings = settings;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                JuniorTheme.primaryOrange.withOpacity(0.08),
                JuniorTheme.backgroundLight,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(settings),
              _buildSearchField(settings),
              if (settings.allowedSites.isNotEmpty)
                _buildQuickLinks(settings.allowedSites),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafePlayColors.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: SafePlayColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: SafePlayColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(color: SafePlayColors.neutral600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildNavigationControls(),
              _buildProgressBar(),
              Expanded(child: _buildWebView(settings)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenteredMessage({
    required IconData icon,
    required String message,
    bool showSpinner = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: JuniorTheme.primaryBlue),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: JuniorTheme.bodyMedium.copyWith(
                color: JuniorTheme.textSecondary,
              ),
            ),
            if (showSpinner) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BrowserControlSettings settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [JuniorTheme.primaryOrange, JuniorTheme.primaryPink],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: JuniorTheme.primaryOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe Explorer',
                  style: JuniorTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.safeSearchEnabled
                      ? 'Safe search is keeping results clean.'
                      : 'Safe search is off. Results may vary.',
                  style: JuniorTheme.bodySmall.copyWith(
                    color: JuniorTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: JuniorTheme.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_moon,
                    color: JuniorTheme.primaryGreen, size: 16),
                SizedBox(width: 6),
                Text(
                  'Protected',
                  style: TextStyle(
                    color: JuniorTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BrowserControlSettings settings) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'What would you like to explore today?',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(settings),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded),
              color: JuniorTheme.primaryOrange,
              onPressed: () => _performSearch(settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks(List<String> sites) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: sites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final site = sites[index];
          final label = _readableHost(site);
          return ActionChip(
            avatar: const Icon(Icons.language, size: 18),
            label: Text(label),
            onPressed: () => _openUrl(site),
          );
        },
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            enabled: _canGoBack,
            onPressed: _webViewController == null ? null : _goBack,
          ),
          const SizedBox(width: 12),
          _NavButton(
            icon: Icons.arrow_forward_ios_rounded,
            enabled: _canGoForward,
            onPressed: _webViewController == null ? null : _goForward,
          ),
          const SizedBox(width: 12),
          _NavButton(
            icon: Icons.refresh_rounded,
            enabled: _webViewController != null,
            onPressed: () => _webViewController?.reload(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage ?? 'Browsing safely',
              style: JuniorTheme.bodySmall.copyWith(
                color: JuniorTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_progress <= 0 || _progress >= 1) {
      return const SizedBox(height: 2);
    }
    return LinearProgressIndicator(
      value: _progress,
      minHeight: 3,
      valueColor: const AlwaysStoppedAnimation(JuniorTheme.primaryOrange),
      backgroundColor: JuniorTheme.primaryOrange.withOpacity(0.2),
    );
  }

  Widget _buildWebView(BrowserControlSettings settings) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://www.kiddle.co'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (_, url) {
              setState(() {
                _statusMessage = 'Loading ${url?.host ?? ''}';
              });
            },
            shouldOverrideUrlLoading: (_, action) async {
              final url = action.request.url?.toString() ?? '';
              final blockReason = _checkNavigationSafety(url);
              if (blockReason != null) {
                _showBlockedSnack(blockReason);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (_, url) async {
              setState(() {
                _progress = 1;
                _statusMessage = 'Exploring ${url?.host ?? ''}';
              });
              await _updateNavigationAvailability();
            },
            onProgressChanged: (_, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _goBack() async {
    if (_webViewController == null) return;
    if (await _webViewController!.canGoBack()) {
      await _webViewController!.goBack();
      await _updateNavigationAvailability();
    }
  }

  Future<void> _goForward() async {
    if (_webViewController == null) return;
    if (await _webViewController!.canGoForward()) {
      await _webViewController!.goForward();
      await _updateNavigationAvailability();
    }
  }

  Future<void> _updateNavigationAvailability() async {
    final controller = _webViewController;
    if (controller == null) return;
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    setState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  Future<void> _performSearch(BrowserControlSettings settings) async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _webViewController == null) return;

    final blockedKeyword = _findBlockedKeywordInQuery(query, settings);
    if (blockedKeyword != null) {
      _showBlockedSnack(
        'This search contains the blocked word "$blockedKeyword".',
      );
      return;
    }

    final encoded = Uri.encodeComponent(query);
    final url = 'https://www.kiddle.co/search.php?q=$encoded';
    final handledByForm = await _submitQueryThroughKiddleForm(query);
    if (!handledByForm) {
      _openUrl(url);
    }
    FocusScope.of(context).unfocus();
  }

  Future<void> _openUrl(String url) async {
    final controller = _webViewController;
    if (controller == null) return;
    final uri = _normalizeUrl(url);
    final blockReason = _checkNavigationSafety(uri.toString());
    if (blockReason != null) {
      _showBlockedSnack(blockReason);
      return;
    }
    await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(uri.toString())));
    await _updateNavigationAvailability();
  }

  Uri _normalizeUrl(String value) {
    var trimmed = value.trim();
    if (!trimmed.startsWith('http')) {
      trimmed = 'https://$trimmed';
    }
    return Uri.parse(trimmed);
  }

  String? _checkNavigationSafety(String url) {
    final settings = _latestSettings;
    if (settings == null) return null;
    final lowerUrl = url.toLowerCase();
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';

    for (final keyword in settings.blockedKeywords) {
      if (keyword.isNotEmpty && lowerUrl.contains(keyword)) {
        return 'Blocked keyword "$keyword" detected.';
      }
    }

    if (settings.blockSocialMedia &&
        _socialDomains.any((domain) => host.contains(domain))) {
      return 'Social media websites are blocked.';
    }

    if (settings.blockGambling &&
        _gamblingKeywords.any((keyword) => lowerUrl.contains(keyword))) {
      return 'Gambling content is blocked.';
    }

    if (settings.blockViolence &&
        _violenceKeywords.any((keyword) => lowerUrl.contains(keyword))) {
      return 'Violent content is blocked.';
    }

    return null;
  }

  String? _findBlockedKeywordInQuery(
    String query,
    BrowserControlSettings settings,
  ) {
    final normalized = query.toLowerCase();
    for (final keyword in settings.blockedKeywords) {
      final trimmed = keyword.trim().toLowerCase();
      if (trimmed.isNotEmpty && normalized.contains(trimmed)) {
        return trimmed;
      }
    }
    return null;
  }

  Future<bool> _submitQueryThroughKiddleForm(String query) async {
    final controller = _webViewController;
    if (controller == null) return false;
    final escaped = jsonEncode(query);
    try {
      final result = await controller.evaluateJavascript(
        source: '''
          (function() {
            const input = document.querySelector('input[name="q"], input#q');
            if (!input) return 'missing-input';
            input.value = $escaped;
            const form = input.closest('form');
            if (form && typeof form.submit === 'function') {
              form.submit();
              return 'submitted';
            }
            input.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter'}));
            return 'dispatched';
          })();
        ''',
      );
      return result == 'submitted' || result == 'dispatched';
    } catch (error) {
      return false;
    }
  }

  void _showBlockedSnack(String reason) {
    setState(() {
      _statusMessage = reason;
    });
    _showBlockedContentDialog(reason);
  }

  void _showBlockedContentDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                JuniorTheme.primaryOrange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shield icon with animated background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      SafePlayColors.error.withOpacity(0.1),
                      SafePlayColors.error.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SafePlayColors.error.withOpacity(0.15),
                      ),
                    ),
                    Icon(
                      Icons.shield_rounded,
                      size: 40,
                      color: SafePlayColors.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Content Blocked',
                style: JuniorTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: SafePlayColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SafePlayColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SafePlayColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: SafePlayColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reason,
                        style: JuniorTheme.bodyMedium.copyWith(
                          color: SafePlayColors.neutral700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Friendly explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JuniorTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: JuniorTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your parents have set up safe browsing to keep you protected while exploring the web.',
                        style: JuniorTheme.bodySmall.copyWith(
                          color: SafePlayColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // OK button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JuniorTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Got it!',
                        style: JuniorTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _readableHost(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    return uri.host.replaceFirst('www.', '');
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled
              ? JuniorTheme.primaryOrange.withOpacity(0.15)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: enabled ? JuniorTheme.primaryOrange : Colors.grey,
          size: 18,
        ),
      ),
    );
  }
}

const Set<String> _socialDomains = {
  'facebook',
  'instagram',
  'tiktok',
  'snapchat',
  'twitter',
  'discord',
  'reddit',
};

const Set<String> _gamblingKeywords = {
  'bet',
  'casino',
  'poker',
  'lottery',
  'wager',
};

const Set<String> _violenceKeywords = {
  'gun',
  'shoot',
  'fight',
  'blood',
  'killing',
};
