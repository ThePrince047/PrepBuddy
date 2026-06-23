import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class McqResultsScreen extends StatefulWidget {
  final String topic;
  final int total;
  final int correct;
  final int wrong;
  final int skipped;
  final String mode;
  final List<Map<String, dynamic>> questions;
  final Map<int, int> selectedAnswers;

  const McqResultsScreen({
    super.key,
    required this.topic,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.mode,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  State<McqResultsScreen> createState() => _McqResultsScreenState();
}

class _McqResultsScreenState extends State<McqResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnim;
  bool _showReview = false;

  double get percentage =>
      widget.total == 0 ? 0 : (widget.correct / widget.total) * 100;

  Color get scoreColor {
    if (percentage >= 80) return context.colors.success;
    if (percentage >= 50) return context.colors.warning;
    return context.colors.error;
  }

  String get grade {
    if (percentage >= 90) return 'Excellent! 🏆';
    if (percentage >= 75) return 'Great Job! ⭐';
    if (percentage >= 50) return 'Good Effort! 💪';
    return 'Keep Practising! 📚';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Test Results', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Go Home',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score ring
            _buildScoreCard(),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(child: _buildStatChip('Correct', widget.correct, context.colors.success, Icons.check_circle)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatChip('Wrong', widget.wrong, context.colors.error, Icons.cancel)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatChip('Skipped', widget.skipped, context.colors.warning, Icons.remove_circle)),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/mcq'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Try Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showReview = !_showReview),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(_showReview ? Icons.expand_less : Icons.expand_more, size: 18),
                    label: Text(_showReview ? 'Hide Review' : 'Review Answers'),
                  ),
                ),
              ],
            ),

            // Question review
            if (_showReview) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Question Review',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 12),
              ...widget.questions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final selected = widget.selectedAnswers[idx] ?? -1;
                final correct = q['correct_answer_index'] as int;
                final options = (q['options'] as List<dynamic>).cast<String>();
                final isCorrect = selected == correct;
                final isSkipped = selected == -1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isSkipped
                                        ? context.colors.warning
                                        : isCorrect
                                            ? context.colors.success
                                            : context.colors.error)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSkipped
                                        ? Icons.remove_circle_outline
                                        : isCorrect
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                    size: 13,
                                    color: isSkipped
                                        ? context.colors.warning
                                        : isCorrect
                                            ? context.colors.success
                                            : context.colors.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Q${idx + 1} – ${isSkipped ? "Skipped" : isCorrect ? "Correct" : "Wrong"}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSkipped
                                          ? context.colors.warning
                                          : isCorrect
                                              ? context.colors.success
                                              : context.colors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          q['question'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        if (!isSkipped && !isCorrect)
                          _buildReviewOption('Your answer', options[selected], context.colors.error),
                        _buildReviewOption('Correct answer', options[correct], context.colors.success),
                        if (q['solution'] != null && (q['solution'] as String).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            q['solution'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.colors.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            widget.topic,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            grade,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _scoreAnim,
              builder: (context, _) {
                final animatedPct = percentage * _scoreAnim.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 3,
                        centerSpaceRadius: 56,
                        sections: [
                          PieChartSectionData(
                            value: animatedPct,
                            color: scoreColor,
                            radius: 22,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - animatedPct,
                            color: context.colors.surfaceGlass,
                            radius: 18,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${animatedPct.round()}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '${widget.correct}/${widget.total}',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.surfaceGlass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Text(
              widget.mode == 'Exam' ? '🎯 Exam Mode' : '📖 Practice Mode',
              style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildReviewOption(String label, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
