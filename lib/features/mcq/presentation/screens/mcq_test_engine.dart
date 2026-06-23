import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/mcq_repository.dart';

class McqTestEngine extends ConsumerStatefulWidget {
  final String topic;
  final int count;
  final String mode;

  const McqTestEngine({
    super.key,
    required this.topic,
    required this.count,
    required this.mode,
  });

  @override
  ConsumerState<McqTestEngine> createState() => _McqTestEngineState();
}

class _McqTestEngineState extends ConsumerState<McqTestEngine>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  // selectedAnswers[i] = index the user chose (-1 = skipped)
  final Map<int, int> _selectedAnswers = {};
  bool _isAnswered = false; // only used in Practice mode

  // Exam mode timer
  Timer? _timer;
  int _secondsLeft = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool get isPractice => widget.mode == 'Practice';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = ref.read(mcqRepositoryProvider);
    final questions = await repo.getQuestions(widget.topic, widget.count);
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _isLoading = false;
      if (!isPractice) {
        _secondsLeft = widget.count * 60; // 1 min per question for Exam mode
        _startTimer();
      }
    });
    _slideController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
          _submitExam();
        }
      });
    });
  }

  void _selectAnswer(int optionIndex) {
    if (!isPractice && _selectedAnswers.containsKey(_currentIndex)) return;
    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
      if (isPractice) _isAnswered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _slideController.reset();
      setState(() {
        _currentIndex++;
        _isAnswered = false;
      });
      _slideController.forward();
    } else {
      _submitExam();
    }
  }

  void _submitExam() {
    _timer?.cancel();
    int correct = 0, wrong = 0, skipped = 0;
    for (int i = 0; i < _questions.length; i++) {
      final selected = _selectedAnswers[i] ?? -1;
      if (selected == -1) {
        skipped++;
      } else if (selected == _questions[i]['correct_answer_index']) {
        correct++;
      } else {
        wrong++;
      }
    }
    // Save result to DB
    ref.read(mcqRepositoryProvider).saveTestResult(
          topic: widget.topic,
          total: _questions.length,
          correct: correct,
          wrong: wrong,
          skipped: skipped,
          timeTaken: isPractice ? 0 : (widget.count * 60) - _secondsLeft,
          mode: widget.mode,
        );

    context.pushReplacement('/mcq/results', extra: {
      'topic': widget.topic,
      'total': _questions.length,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'mode': widget.mode,
      'questions': _questions,
      'selectedAnswers': _selectedAnswers,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return context.colors.success;
      case 'hard':
        return context.colors.error;
      default:
        return context.colors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('No questions found for this topic.'),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final options = (q['options'] as List<dynamic>).cast<String>();
    final correctIdx = q['correct_answer_index'] as int;
    final selectedIdx = _selectedAnswers[_currentIndex] ?? -1;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Q ${_currentIndex + 1} / ${_questions.length}',
                                  style: TextStyle(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceGlass,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: context.colors.border),
                                ),
                                child: Text(
                                  widget.topic,
                                  style: TextStyle(
                                    color: context.colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            q['question'] as String,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options
                    ...options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final text = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOptionTile(
                          idx: idx,
                          text: text,
                          selectedIdx: selectedIdx,
                          correctIdx: correctIdx,
                          onTap: () => _selectAnswer(idx),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Solution (Practice mode only, after answer)
                    if (isPractice && _isAnswered && q['solution'] != null && (q['solution'] as String).isNotEmpty)
                      _buildSolutionCard(q['solution'] as String),

                    const SizedBox(height: 24),

                    // Action button
                    if (!isPractice || _isAnswered)
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _currentIndex < _questions.length - 1 ? 'Next Question →' : 'Submit Test',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),

                    // Skip (Exam mode)
                    if (!isPractice && !_selectedAnswers.containsKey(_currentIndex))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextButton(
                          onPressed: _nextQuestion,
                          child: Text(
                            'Skip Question',
                            style: TextStyle(color: context.colors.textSecondary.withOpacity(0.7)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: context.colors.surface,
              title: const Text('Quit Test?'),
              content: const Text('Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.pop();
                  },
                  child: Text('Quit', style: TextStyle(color: context.colors.error)),
                ),
              ],
            ),
          );
        },
      ),
      title: Text(
        isPractice ? 'Practice Mode' : 'Exam Mode',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (!isPractice)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsLeft < 60
                  ? context.colors.error.withOpacity(0.2)
                  : context.colors.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _secondsLeft < 60 ? context.colors.error : context.colors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsLeft < 60 ? context.colors.error : context.colors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_secondsLeft),
                  style: TextStyle(
                    color: _secondsLeft < 60 ? context.colors.error : context.colors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _questions.length;
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(color: context.colors.border),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.secondary],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required int idx,
    required String text,
    required int selectedIdx,
    required int correctIdx,
    required VoidCallback onTap,
  }) {
    Color borderColor = context.colors.border;
    Color bgColor = context.colors.surfaceGlass;
    Color textColor = context.colors.textPrimary;
    IconData? trailingIcon;

    if (selectedIdx != -1) {
      if (idx == correctIdx && (isPractice || !isPractice)) {
        // Show correct only in Practice after answer, or in Exam after submit (never here since engine doesn't show correct in exam)
        if (isPractice && _isAnswered) {
          borderColor = context.colors.success;
          bgColor = context.colors.success.withOpacity(0.1);
          trailingIcon = Icons.check_circle;
        }
      }
      if (isPractice && _isAnswered && idx == selectedIdx && idx != correctIdx) {
        borderColor = context.colors.error;
        bgColor = context.colors.error.withOpacity(0.1);
        textColor = context.colors.error;
        trailingIcon = Icons.cancel;
      }
      if (!isPractice && idx == selectedIdx) {
        borderColor = context.colors.primary;
        bgColor = context.colors.primary.withOpacity(0.1);
      }
    }

    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: (selectedIdx == -1 || (!isPractice)) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letters[idx],
                  style: TextStyle(
                    color: borderColor == context.colors.border ? context.colors.textSecondary : borderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: borderColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(String solution) {
    return Column(
      children: [
        const SizedBox(height: 8),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.lightbulb, color: context.colors.secondary, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Solution',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.secondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                solution,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: context.colors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
