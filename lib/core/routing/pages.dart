import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/features.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> with SingleTickerProviderStateMixin {
  int index = 0;
  bool hasSeenConsent = false;
  bool isCheckingConsent = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;

  final TextEditingController formController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Create blocs once and reuse them across rebuilds
  late final HomeBloc _homeBloc;
  late final ForumBloc _forumBloc;

  // Navigation items with education-friendly colors
  final List<ModernNavItem> _navItems = const [
    ModernNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      activeColor: AppColors.primary, // Primary red - matches home page
    ),
    ModernNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
      activeColor: AppColors.cardEmerald, // Emerald
    ),
    ModernNavItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Forum',
      activeColor: AppColors.videoPrimary, // Purple
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize blocs once - they will persist across locale changes
    _homeBloc = sl<HomeBloc>()..add(const LoadCarouselItems());
    _forumBloc = sl<ForumBloc>();
    _pageController = PageController(initialPage: index);

    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _checkAndShowConsent();

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _checkAndShowConsent();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    formController.dispose();
    otpController.dispose();
    _homeBloc.close();
    _forumBloc.close();
    super.dispose();
  }

  Future<void> _checkAndShowConsent() async {
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        if (mounted) {
          setState(() {
            hasSeenConsent = true;
            isCheckingConsent = false;
          });
        }
        return;
      }

      final DocumentSnapshot consentDoc =
          await _firestore.collection('consents').doc(userId).get();

      if (mounted) {
        setState(() {
          hasSeenConsent = consentDoc.exists;
          isCheckingConsent = false;
        });
      }
    } on Object catch (e) {
      Log.e("Error fetching consent data: $e");

      if (mounted) {
        setState(() {
          hasSeenConsent = false;
          isCheckingConsent = false;
        });
      }
    }
  }

  Future<void> submitConsent() async {
    setState(() {
      hasSeenConsent = true;
    });
  }

  void _onNavTap(int newIndex) {
    _pageController.animateToPage(
      newIndex,
      duration: AppDurations.animationMedium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use existing blocs instead of creating new ones on each build
    final screens = <Widget>[
      BlocProvider.value(
        value: _homeBloc,
        child: const HomePage(),
      ),
      ExplorePage(
        onNavigateToHome: () {
          _pageController.animateToPage(
            0,
            duration: AppDurations.animationMedium,
            curve: Curves.easeOutCubic,
          );
        },
        onNavigateToForum: () {
          _pageController.animateToPage(
            2,
            duration: AppDurations.animationMedium,
            curve: Curves.easeOutCubic,
          );
        },
      ),
      BlocProvider.value(
        value: _forumBloc,
        child: ForumPage(
          onNavigateToExplore: () {
            _pageController.animateToPage(
              1,
              duration: AppDurations.animationMedium,
              curve: Curves.easeOutCubic,
            );
          },
        ),
      ),
    ];

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          backgroundColor: context.colors.background,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              onPageChanged: (newIndex) {
                setState(() => index = newIndex);
              },
              physics: const BouncingScrollPhysics(),
              children: screens,
            ),
          ),
          bottomNavigationBar: ModernBottomNav(
            currentIndex: index,
            onTap: _onNavTap,
            items: _navItems,
          ),
        ),

        // Loading overlay
        if (isCheckingConsent)
          Positioned.fill(
            child: Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceL),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(
                      'Loading...',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Consent form overlay
        if (!hasSeenConsent && !isCheckingConsent)
          Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: AppColors.overlayDark,
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ConsentBloc>(),
                  child: EnhancedConsentFormPage(
                    onSubmit: submitConsent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
