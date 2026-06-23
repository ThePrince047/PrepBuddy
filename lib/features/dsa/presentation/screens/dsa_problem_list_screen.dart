import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/dsa_repository.dart';

class DsaProblemListScreen extends ConsumerWidget {
  final String category;

  const DsaProblemListScreen({super.key, required this.category});

  Color _diffColor(BuildContext context, String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return context.colors.success;
      case 'hard':
        return context.colors.error;
      default:
        return context.colors.warning;
    }
  }

  String _formatCategory(String raw) {
    return raw
        .split('.')
        .last
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(dsaProblemsProvider(category));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          _formatCategory(category),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: problemsAsync.when(
        data: (problems) {
          if (problems.isEmpty) {
            return const Center(child: Text('No problems found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: problems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = problems[index];
              final diff = (p['difficulty'] as String?) ?? 'Medium';
              final isStudied = (p['is_studied'] as int?) == 1;

              return GlassCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/dsa/detail', extra: p['id']),
                child: Row(
                  children: [
                    // Index badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _diffColor(context, diff).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  diff,
                                  style: TextStyle(
                                    color: _diffColor(context, diff),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isStudied) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.colors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, size: 11, color: context.colors.success),
                                      SizedBox(width: 3),
                                      Text(
                                        'Studied',
                                        style: TextStyle(
                                          color: context.colors.success,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.colors.textSecondary, size: 20),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
