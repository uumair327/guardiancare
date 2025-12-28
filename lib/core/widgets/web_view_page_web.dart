import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Web-specific WebView implementation using iframe
/// This is used on web platform where webview_flutter is not available
class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  bool _isLoading = true;
  String _currentUrl = '';
  String _pageTitle = '';
  late String _viewId;
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title ?? 'Loading...';
    _viewId = 'webview-${DateTime.now().millisecondsSinceEpoch}';
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
    _iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
      ..allowFullscreen = true;

    _iframe!.onLoad.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    _iframe!.onError.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Register the view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _iframe!,
    );
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: _buildWebView(),
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
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildBackButton(),
              SizedBox(width: AppDimensions.spaceM),
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
        padding: EdgeInsets.all(AppDimensions.spaceS),
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
        SizedBox(height: 2),
        Row(
          children: [
            Icon(
              _currentUrl.startsWith('https') 
                  ? Icons.lock_rounded 
                  : Icons.lock_open_rounded,
              color: _currentUrl.startsWith('https')
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              size: 12,
            ),
            SizedBox(width: 4),
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
        padding: EdgeInsets.all(AppDimensions.spaceS),
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
          ? const LinearProgressIndicator(
              backgroundColor: Color(0xFF1A1A2E),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF8B5CF6),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildWebView() {
    return HtmlElementView(viewType: _viewId);
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceL,
        vertical: AppDimensions.spaceM,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
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
            icon: Icons.refresh_rounded,
            enabled: true,
            onTap: () {
              HapticFeedback.lightImpact();
              _iframe?.src = _currentUrl;
              setState(() {
                _isLoading = true;
              });
            },
          ),
          _buildNavButton(
            icon: Icons.open_in_new_rounded,
            enabled: true,
            onTap: () {
              HapticFeedback.lightImpact();
              html.window.open(_currentUrl, '_blank');
            },
          ),
          _buildNavButton(
            icon: Icons.share_rounded,
            enabled: true,
            onTap: () {
              HapticFeedback.lightImpact();
              _copyToClipboard();
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
        padding: EdgeInsets.all(AppDimensions.spaceM),
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
          _iframe?.src = _currentUrl;
          setState(() {
            _isLoading = true;
          });
        },
        onCopyLink: () {
          Navigator.pop(ctx);
          _copyToClipboard();
        },
        onOpenInBrowser: () {
          Navigator.pop(ctx);
          html.window.open(_currentUrl, '_blank');
        },
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        backgroundColor: const Color(0xFF22C55E),
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
    } catch (e) {
      return url;
    }
  }
}

/// Options bottom sheet for webview
class _WebViewOptionsSheet extends StatelessWidget {
  final String currentUrl;
  final String pageTitle;
  final VoidCallback onRefresh;
  final VoidCallback onCopyLink;
  final VoidCallback onOpenInBrowser;

  const _WebViewOptionsSheet({
    required this.currentUrl,
    required this.pageTitle,
    required this.onRefresh,
    required this.onCopyLink,
    required this.onOpenInBrowser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spaceM),
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: AppDimensions.borderRadiusXL,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceM),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                borderRadius: AppDimensions.borderRadiusM,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppDimensions.spaceS),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceM),
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
                        SizedBox(height: 2),
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
            SizedBox(height: AppDimensions.spaceL),
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
              title: 'Open in new tab',
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
      padding: EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ScaleTapWidget(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceM),
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
              SizedBox(width: AppDimensions.spaceM),
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
