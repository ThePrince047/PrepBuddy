import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/stats_repository.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    
    return '${dt.day} $month ${dt.year}, $hour:$minute $ampm';
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Practice Mode';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  Color _scoreColor(double pct) {
    if (pct >= 80) return context.colors.success;
    if (pct >= 50) return context.colors.warning;
    return context.colors.error;
  }

  void _refreshStats() {
    ref.invalidate(statsSummaryProvider);
    ref.invalidate(testHistoryProvider);
    ref.invalidate(dsaProgressProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Statistics refreshed'),
        backgroundColor: context.colors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(statsSummaryProvider);
    final historyAsync = ref.watch(testHistoryProvider);
    final dsaAsync = ref.watch(dsaProgressProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Performance Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: context.colors.textPrimary),
            tooltip: 'Refresh Stats',
            onPressed: _refreshStats,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          dividerColor: context.colors.border,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Test History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // SUMMARY TAB
          summaryAsync.when(
            data: (summary) {
              final totalTests = summary['totalTests'] as int? ?? 0;
              final avgScore = summary['avgScore'] as double? ?? 0.0;
              final totalCorrect = summary['totalCorrect'] as int? ?? 0;
              final totalWrong = summary['totalWrong'] as int? ?? 0;
              final totalSkipped = summary['totalSkipped'] as int? ?? 0;
              final byTopic = summary['byTopic'] as Map<String, Map<String, dynamic>>? ?? {};

              if (totalTests == 0) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Overview Metrics
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            child: Column(
                              children: [
                                Icon(Icons.assignment_turned_in_outlined, color: context.colors.secondary, size: 28),
                                const SizedBox(height: 10),
                                Text(
                                  '$totalTests',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tests Taken',
                                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            child: Column(
                              children: [
                                Icon(Icons.analytics_outlined, color: context.colors.primary, size: 28),
                                const SizedBox(height: 10),
                                Text(
                                  '${avgScore.round()}%',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _scoreColor(avgScore),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Average Score',
                                  style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // DSA Progress Section
                    dsaAsync.when(
                      data: (dsa) {
                        final studied = dsa['studied'] ?? 0;
                        final total = dsa['total'] ?? 0;
                        final pct = total > 0 ? (studied / total) : 0.0;
                        return GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.code_rounded, color: context.colors.primary, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DSA Progress',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$studied / $total Problems',
                                    style: TextStyle(color: context.colors.secondary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  minHeight: 8,
                                  backgroundColor: context.colors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.secondary),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(pct * 100).round()}% Completed',
                                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    // Questions Correctness Breakdown
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pie_chart_outline, color: context.colors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Answer Accuracy',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildCorrectnessRatioBar(totalCorrect, totalWrong, totalSkipped),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBreakdownLegend('Correct', totalCorrect, context.colors.success),
                              _buildBreakdownLegend('Wrong', totalWrong, context.colors.error),
                              _buildBreakdownLegend('Skipped', totalSkipped, context.colors.warning),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Performance by Topic
                    Text(
                      'Topic Breakdown',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ...byTopic.entries.map((entry) {
                      final topicName = entry.key;
                      final topicData = entry.value;
                      final tTests = topicData['testCount'] as int? ?? 0;
                      final tScore = topicData['avgScore'] as double? ?? 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      topicName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${tScore.round()}% avg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _scoreColor(tScore),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '$tTests test${tTests > 1 ? "s" : ""} completed',
                                    style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: tScore / 100,
                                        minHeight: 5,
                                        backgroundColor: context.colors.border,
                                        valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(tScore)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
            error: (e, st) => Center(child: Text('Error loading stats summary: $e')),
          ),

          // HISTORY TAB
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = history[index];
                  final topic = record['topic'] as String? ?? 'Mock Test';
                  final correct = record['correct'] as int? ?? 0;
                  final total = record['total_questions'] as int? ?? 0;
                  final timeTaken = record['time_taken'] as int? ?? 0;
                  final mode = record['mode'] as String? ?? 'Practice';
                  final completedAt = record['completed_at'] as String? ?? '';
                  final double pct = total > 0 ? (correct / total) * 100 : 0.0;

                  final isExam = mode.toLowerCase() == 'exam';

                  return GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isExam ? context.colors.secondary : context.colors.primary).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isExam ? Icons.timer_outlined : Icons.school_outlined,
                                    size: 13,
                                    color: isExam ? context.colors.secondary : context.colors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isExam ? 'Exam' : 'Practice',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isExam ? context.colors.secondary : context.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(completedAt),
                              style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          topic,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$correct / $total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _scoreColor(pct),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${pct.round()}%)',
                                  style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.schedule_outlined, color: context.colors.textSecondary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(timeTaken),
                                  style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
            error: (e, st) => Center(child: Text('Error loading history: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 72, color: context.colors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text(
              'No Records Found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Take mock tests and practice problems to see your detailed statistics page here!',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/dashboard');
              },
              child: const Text('Back to Modules'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
        ),
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCorrectnessRatioBar(int correct, int wrong, int skipped) {
    final total = correct + wrong + skipped;
    if (total == 0) return const SizedBox.shrink();

    final pctCorrect = correct / total;
    final pctWrong = wrong / total;
    final pctSkipped = skipped / total;

    return Container(
      height: 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (correct > 0)
            Expanded(
              flex: math.max(1, (pctCorrect * 100).round()),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.success,
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(8),
                    right: (wrong == 0 && skipped == 0) ? const Radius.circular(8) : Radius.zero,
                  ),
                ),
              ),
            ),
          if (wrong > 0)
            Expanded(
              flex: math.max(1, (pctWrong * 100).round()),
              child: Container(
                color: context.colors.error,
              ),
            ),
          if (skipped > 0)
            Expanded(
              flex: math.max(1, (pctSkipped * 100).round()),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.warning,
                  borderRadius: BorderRadius.horizontal(
                    right: const Radius.circular(8),
                    left: (correct == 0 && wrong == 0) ? const Radius.circular(8) : Radius.zero,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
