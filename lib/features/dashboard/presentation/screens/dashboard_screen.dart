import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../stats/data/stats_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Champ';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Ace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: context.colors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: context.colors.textSecondary),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back, $displayName! 👋',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Hero Stats
            ref.watch(statsSummaryProvider).when(
                  data: (summary) {
                    final totalTests = summary['totalTests'] as int? ?? 0;
                    final avgScore = summary['avgScore'] as double? ?? 0.0;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                onTap: () => context.push('/stats'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Tests',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$totalTests',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                              color: context.colors.secondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                onTap: () => context.push('/stats'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Avg Score',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(height: 8),
                                    Text(
                                      totalTests > 0 ? '${avgScore.round()}%' : '—',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                              color: context.colors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => context.push('/stats'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'View Detailed Performance Analytics',
                                  style: TextStyle(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: context.colors.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  error: (err, st) => GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text('Error loading stats',
                          style: TextStyle(color: context.colors.error)),
                    ),
                  ),
                ),

            const SizedBox(height: 32),
            Text(
              'Preparation Modules',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              title: 'MCQ Question Bank',
              subtitle: '2000+ Aptitude & Technical Questions',
              icon: Icons.library_books,
              route: '/mcq',
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'DSA Coding Prep',
              subtitle: 'Top 150+ Technical Interview Problems',
              icon: Icons.code,
              route: '/dsa',
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Study Materials',
              subtitle: 'Cheat sheets and core concepts',
              icon: Icons.menu_book,
              route: '/study',
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'AI Mock Test',
              subtitle: 'Generate custom paper with Gemini',
              icon: Icons.auto_awesome,
              isAi: true,
              onTapOverride: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('🚀 AI Mock Test coming soon!'),
                    backgroundColor: context.colors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    bool isAi = false,
    String? route,
    VoidCallback? onTapOverride,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: onTapOverride ??
          (route != null ? () => GoRouter.of(context).push(route) : null),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAi
                  ? context.colors.secondary.withOpacity(0.2)
                  : context.colors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isAi ? context.colors.secondary : context.colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.textSecondary),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: TextStyle(
                color: colors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Your progress is saved in the cloud. You can sign in again anytime.',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: Text('Sign Out',
                style: TextStyle(
                    color: colors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
