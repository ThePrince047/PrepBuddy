import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data/sync_service.dart';
import '../../../auth/data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusMessage = 'Starting up...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for at least 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedInPref = prefs.getBool('is_logged_in') ?? false;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null && isLoggedInPref) {
      // Firebase might still be restoring the session, wait a bit
      user = await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    }

    if (user == null) {
      // Not logged in — go to login
      context.go('/login');
      return;
    }

    // User is logged in — sync data from Firestore
    setState(() => _statusMessage = 'Syncing your data...');

    try {
      final syncService = ref.read(syncServiceProvider);
      // Sync both content data and user stats
      await Future.wait([
        syncService.syncAll(),
        syncService.syncUserStats(),
      ]);
    } catch (e) {
      // Non-fatal — app can work offline with cached SQLite data
      debugPrint('Sync warning: $e');
    }

    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = colors.primary;
    final secondary = colors.secondary;
    final bgColor = colors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    bgColor,
                    Color.lerp(bgColor, primary, 0.08)!,
                    Color.lerp(bgColor, secondary, 0.05)!,
                  ]
                : [
                    bgColor,
                    Color.lerp(bgColor, primary, 0.05)!,
                    Color.lerp(bgColor, secondary, 0.04)!,
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: primary.withOpacity(isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withOpacity(isDark ? 0.5 : 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(isDark ? 0.3 : 0.15),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.code_rounded,
                      size: 80,
                      color: primary,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 36),

              // App Name
              Text(
                'Interview Ace',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -1,
                    ),
              )
                  .animate(delay: 300.ms)
                  .slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Master your technical interviews',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 60),

              // Status message
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary.withOpacity(0.7),
                    ),
              ).animate(delay: 800.ms).fadeIn(),

              const SizedBox(height: 16),

              // Loading indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primary.withOpacity(0.6),
                ),
              ).animate(delay: 800.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
