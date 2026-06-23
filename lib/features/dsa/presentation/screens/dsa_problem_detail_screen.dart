import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/dsa_repository.dart';

class DsaProblemDetailScreen extends ConsumerStatefulWidget {
  final String problemId;

  const DsaProblemDetailScreen({super.key, required this.problemId});

  @override
  ConsumerState<DsaProblemDetailScreen> createState() =>
      _DsaProblemDetailScreenState();
}

class _DsaProblemDetailScreenState extends ConsumerState<DsaProblemDetailScreen>
    with TickerProviderStateMixin {
  late TabController _langTabController;
  static const _languages = ['python', 'cpp', 'java', 'javascript', 'c'];
  static const _langLabels = ['Python', 'C++', 'Java', 'JS', 'C'];
  bool _showHints = false;

  @override
  void initState() {
    super.initState();
    _langTabController = TabController(length: _languages.length, vsync: this);
  }

  @override
  void dispose() {
    _langTabController.dispose();
    super.dispose();
  }

  Color _diffColor(String diff) {
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
    final problemAsync = ref.watch(dsaProblemDetailProvider(widget.problemId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Problem Detail', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: problemAsync.when(
        data: (problem) {
          if (problem == null) {
            return const Center(child: Text('Problem not found.'));
          }
          return _buildContent(problem);
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> p) {
    final diff = (p['difficulty'] as String?) ?? 'Medium';
    final solutions = (p['solutions'] as Map<String, String>?) ?? {};
    final hints = (p['step_by_step'] as List<dynamic>?) ?? [];
    final companies = (p['companies'] as List<dynamic>?) ?? [];
    final isStudied = (p['is_studied'] as int?) == 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p['title'] as String,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _diffColor(diff).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      diff,
                      style: TextStyle(
                        color: _diffColor(diff),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      await ref.read(dsaRepositoryProvider).markStudied(
                            p['id'].toString(),
                            !isStudied,
                          );
                      ref.invalidate(dsaProblemDetailProvider(widget.problemId));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isStudied
                            ? context.colors.success.withOpacity(0.15)
                            : context.colors.surfaceGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isStudied ? context.colors.success : context.colors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isStudied ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 14,
                            color: isStudied ? context.colors.success : context.colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isStudied ? 'Studied' : 'Mark Done',
                            style: TextStyle(
                              color: isStudied ? context.colors.success : context.colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Complexity badges
          const SizedBox(height: 16),
          if ((p['time_complexity'] as String? ?? '').isNotEmpty ||
              (p['space_complexity'] as String? ?? '').isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if ((p['time_complexity'] as String? ?? '').isNotEmpty)
                  _complexityChip('⏱ Time', p['time_complexity'] as String),
                if ((p['space_complexity'] as String? ?? '').isNotEmpty)
                  _complexityChip('💾 Space', p['space_complexity'] as String),
              ],
            ),

          // Companies
          if (companies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: companies
                  .cast<String>()
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.secondary.withOpacity(0.3)),
                        ),
                        child: Text(c,
                            style: TextStyle(
                                color: context.colors.secondary, fontSize: 12)),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 20),

          // Problem statement
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Problem Statement', Icons.description_outlined),
                const SizedBox(height: 12),
                Text(
                  p['problem_statement'] as String? ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Approach
          if ((p['approach'] as String? ?? '').isNotEmpty)
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Approach / Explanation', Icons.psychology_outlined),
                  const SizedBox(height: 12),
                  Text(
                    p['approach'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Hints (collapsible)
          if (hints.isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _showHints = !_showHints),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _sectionTitle('Hints', Icons.lightbulb_outline),
                        const Spacer(),
                        Icon(
                          _showHints ? Icons.expand_less : Icons.expand_more,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                    if (_showHints) ...[
                      const SizedBox(height: 12),
                      ...hints.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: context.colors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: TextStyle(
                                        color: context.colors.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.value.toString(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          height: 1.5,
                                          color: context.colors.textSecondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Solutions with language tabs
          if (solutions.isNotEmpty) ...[
            _sectionTitle('Solutions', Icons.code_rounded),
            const SizedBox(height: 12),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.colors.border)),
                    ),
                    child: TabBar(
                      controller: _langTabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicator: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: context.colors.primary,
                      unselectedLabelColor: context.colors.textSecondary,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: _langLabels.map((l) => Tab(text: l)).toList(),
                    ),
                  ),
                  // Code panels
                  SizedBox(
                    height: 340,
                    child: TabBarView(
                      controller: _langTabController,
                      children: _languages.map((lang) {
                        final code = solutions[lang] ?? '// No solution available for $lang';
                        return _buildCodePanel(lang, code);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCodePanel(String lang, String code) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              code,
              language: lang == 'cpp' ? 'cpp' : lang == 'javascript' ? 'javascript' : lang,
              theme: atomOneDarkTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Code copied to clipboard'),
                  backgroundColor: context.colors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.border),
              ),
              child: Icon(Icons.copy_rounded, size: 16, color: context.colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _complexityChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
