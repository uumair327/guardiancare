import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Education-friendly WebView page with modern design
/// Features progress indicator, navigation controls, and smooth animations
class WebViewPage extends StatefulWidget {

  const WebViewPage({
    super.key,
    required this.url,
    this.title,
  });
  final String url;
  final String? title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  bool _isLoading = true;
  int _loadingProgress = 0;
  String _currentUrl = '';
  String _pageTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title ?? 'Loading...';
    _initAnimations();
    _initWebView();
  }

  void _initAnimations() {
    _headerAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: AppCurves.emphasizedDecelerate,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: AppCurves.emphasizedDecelerate,
    ));
    _headerAnimController.forward();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.videoBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _currentUrl = url;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              final canGoBack = await _controller.canGoBack();
              final canGoForward = await _controller.canGoForward();
              final title = await _controller.getTitle();
              setState(() {
                _isLoading = false;
                _canGoBack = canGoBack;
                _canGoForward = canGoForward;
                if (title != null && title.isNotEmpty) {
                  _pageTitle = title;
                }
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage =
                    'HTTP Error: ${error.response?.statusCode ?? 'Unknown'}';
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Block YouTube URLs - use video player instead
            if (request.url.startsWith('https://www.youtube.com/') ||
                request.url.startsWith('https://youtu.be/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.videoBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: _hasError ? _buildErrorState() : _buildWebView(),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: const BoxDecoration(
            color: AppColors.videoSurface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium, // Approx 0.2
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(child: _buildTitleSection()),
              _buildMenuButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return ScaleTapWidget(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _pageTitle,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              _currentUrl.startsWith('https')
                  ? Icons.lock_rounded
                  : Icons.lock_open_rounded,
              color: _currentUrl.startsWith('https')
                  ? AppColors.emergencyGreen
                  : AppColors.error,
              size: 12,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _getDomainFromUrl(_currentUrl),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return ScaleTapWidget(
      onTap: () {
        HapticFeedback.lightImpact();
        _showOptionsMenu();
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedContainer(
      duration: AppDurations.animationShort,
      height: _isLoading ? 3 : 0,
      child: _isLoading
          ? LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: AppColors.videoSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.videoPrimary,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildWebView() {
    return RepaintBoundary(
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && _loadingProgress < 30) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.videoBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.videoPrimary, AppColors.videoPrimaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.videoPrimary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.language_rounded,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Loading page...',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              _getDomainFromUrl(_currentUrl),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Unable to load page',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Please check your internet connection',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            ScaleTapWidget(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.videoPrimary,
                      AppColors.videoPrimaryDark
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.videoPrimary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.spaceS),
                    Text(
                      'Try Again',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceL,
        vertical: AppDimensions.spaceM,
      ),
      decoration: BoxDecoration(
        color: AppColors.videoSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.arrow_back_ios_rounded,
            enabled: _canGoBack,
            onTap: () async {
              HapticFeedback.lightImpact();
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          _buildNavButton(
            icon: Icons.arrow_forward_ios_rounded,
            enabled: _canGoForward,
            onTap: () async {
              HapticFeedback.lightImpact();
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          _buildNavButton(
            icon: Icons.refresh_rounded,
            enabled: !_isLoading,
            onTap: () {
              HapticFeedback.lightImpact();
              _controller.reload();
            },
          ),
          _buildNavButton(
            icon: Icons.share_rounded,
            enabled: true,
            onTap: () {
              HapticFeedback.lightImpact();
              _shareUrl();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ScaleTapWidget(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.white.withValues(alpha: 0.03),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.3),
          size: 22,
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _WebViewOptionsSheet(
        currentUrl: _currentUrl,
        pageTitle: _pageTitle,
        onRefresh: () {
          Navigator.pop(ctx);
          _controller.reload();
        },
        onCopyLink: () {
          Navigator.pop(ctx);
          _copyToClipboard();
        },
        onOpenInBrowser: () {
          Navigator.pop(ctx);
          _openInBrowser();
        },
      ),
    );
  }

  void _shareUrl() {
    // For now, just copy to clipboard
    _copyToClipboard();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        backgroundColor: AppColors.emergencyGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
      ),
    );
  }

  void _openInBrowser() {
    // This would typically use url_launcher
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening in browser...'),
        backgroundColor: AppColors.videoPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
      ),
    );
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } on Object {
      return url;
    }
  }
}

/// Options bottom sheet for webview
class _WebViewOptionsSheet extends StatelessWidget {

  const _WebViewOptionsSheet({
    required this.currentUrl,
    required this.pageTitle,
    required this.onRefresh,
    required this.onCopyLink,
    required this.onOpenInBrowser,
  });
  final String currentUrl;
  final String pageTitle;
  final VoidCallback onRefresh;
  final VoidCallback onCopyLink;
  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spaceM),
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.videoSurface,
        borderRadius: AppDimensions.borderRadiusXL,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            // Page info
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceM),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                borderRadius: AppDimensions.borderRadiusM,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceS),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.videoPrimary,
                          AppColors.videoPrimaryDark
                        ],
                      ),
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pageTitle,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUrl,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            // Options
            _buildOptionItem(
              icon: Icons.refresh_rounded,
              title: 'Refresh page',
              onTap: onRefresh,
            ),
            _buildOptionItem(
              icon: Icons.link_rounded,
              title: 'Copy link',
              onTap: onCopyLink,
            ),
            _buildOptionItem(
              icon: Icons.open_in_browser_rounded,
              title: 'Open in browser',
              onTap: onOpenInBrowser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ScaleTapWidget(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.05),
            borderRadius: AppDimensions.borderRadiusM,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.white.withValues(alpha: 0.7),
                size: 22,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
