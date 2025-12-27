import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';
import 'dart:ui';

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

  final TextEditingController formController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Navigation items with education-friendly colors
  final List<ModernNavItem> _navItems = const [
    ModernNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      activeColor: Color(0xFF6366F1), // Indigo
    ),
    ModernNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
      activeColor: Color(0xFF10B981), // Emerald
    ),
    ModernNavItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Forum',
      activeColor: Color(0xFF8B5CF6), // Purple
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    _fadeController.dispose();
    formController.dispose();
    otpController.dispose();
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

      DocumentSnapshot consentDoc =
          await _firestore.collection('consents').doc(userId).get();

      if (mounted) {
        setState(() {
          hasSeenConsent = consentDoc.exists;
          isCheckingConsent = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching consent data: $e");

      if (mounted) {
        setState(() {
          hasSeenConsent = false;
          isCheckingConsent = false;
        });
      }
    }
  }

  void submitConsent() async {
    setState(() {
      hasSeenConsent = true;
    });
  }

  void _onNavTap(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      BlocProvider(
        create: (_) => sl<HomeBloc>()..add(const LoadCarouselItems()),
        child: const HomePage(),
      ),
      const ExplorePage(),
      BlocProvider(
        create: (_) => sl<ForumBloc>(),
        child: const ForumPage(),
      ),
    ];

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          appBar: _buildModernAppBar(),
          backgroundColor: AppColors.background,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedSwitcher(
              duration: AppDurations.animationMedium,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey<int>(index),
                child: screens[index],
              ),
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
                      padding: EdgeInsets.all(AppDimensions.spaceL),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceM),
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
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.background,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: AppDimensions.borderRadiusS,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
          SizedBox(width: AppDimensions.spaceS),
          Text(
            AppStrings.appName,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user == null) {
              return Padding(
                padding: EdgeInsets.only(right: AppDimensions.spaceS),
                child: ScaleTapWidget(
                  onTap: () => context.go('/login'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: AppColors.primary,
                          size: AppDimensions.iconS,
                        ),
                        SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          'Sign In',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
