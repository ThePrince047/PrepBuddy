import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/study_materials_repository.dart';

class StudyMaterialDetailScreen extends ConsumerWidget {
  final int materialId;

  const StudyMaterialDetailScreen({super.key, required this.materialId});

  Color _getIconColor(BuildContext context, String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return context.colors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matAsync = ref.watch(studyMaterialDetailProvider(materialId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: matAsync.when(
        data: (mat) {
          if (mat == null) return Center(child: Text('Not found.', style: TextStyle(color: context.colors.textPrimary)));
          return _buildContent(context, mat);
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: context.colors.textPrimary))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> mat) {
    final colorHex = mat['color'] as String? ?? '#6C63FF';
    final accentColor = _getIconColor(context, colorHex);
    final topics = (mat['topics'] as List<dynamic>?) ?? [];

    return CustomScrollView(
      slivers: [
        // Hero header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(mat['icon'] as String? ?? '📚',
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mat['title'] as String,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22, color: context.colors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mat['tag'] as String? ?? '',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Topics
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final topic = topics[index] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildTopic(context, topic, accentColor),
              );
            },
            childCount: topics.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildTopic(BuildContext context, Map<String, dynamic> topic, Color accentColor) {
    final title = topic['title'] as String? ?? '';
    final type = topic['type'] as String? ?? 'items';
    final items = (topic['items'] as List<dynamic>?) ?? [];
    final rows = (topic['rows'] as List<dynamic>?) ?? [];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.25)),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Render based on type
          if (type == 'tricks') _buildTricksList(context, items),
          if (type == 'table' && rows.isNotEmpty) _buildTable(context, rows, accentColor),
          if (type == 'items' || type == 'formula') _buildFormulaList(context, items, accentColor),
        ],
      ),
    );
  }

  Widget _buildFormulaList(
      BuildContext context, List<dynamic> items, Color accentColor) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value as Map<String, dynamic>;
        final isLast = entry.key == items.length - 1;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String? ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: context.colors.codePanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Text(
                          item['formula'] as String? ?? '',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((item['note'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['note'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            if (!isLast)
              Divider(
                height: 20,
                color: context.colors.border.withOpacity(0.5),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTricksList(BuildContext context, List<dynamic> items) {
    return Column(
      children: items.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.value.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: context.colors.textPrimary,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTable(
      BuildContext context, List<dynamic> rows, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Table(
        border: TableBorder.all(
          color: context.colors.border,
          borderRadius: BorderRadius.circular(10),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: accentColor.withOpacity(0.12)),
            children: ['Value', 'Rule / Fraction']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        h,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Data rows
          ...rows.asMap().entries.map((e) {
            List<String> row;
            if (e.value is List) {
              row = (e.value as List).map((c) => c.toString()).toList();
            } else if (e.value is String) {
              final str = e.value as String;
              if (str.contains('->')) {
                final parts = str.split('->');
                row = [parts[0].trim(), parts.sublist(1).join('->').trim()];
              } else {
                row = [str, ''];
              }
            } else {
              row = [e.value.toString(), ''];
            }

            // Ensure exactly 2 columns for TableRow
            while (row.length < 2) {
              row.add('');
            }
            if (row.length > 2) {
              row = row.sublist(0, 2);
            }

            final isEven = e.key.isEven;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven
                    ? context.colors.surfaceGlass.withOpacity(0.3)
                    : Colors.transparent,
              ),
              children: row
                  .map((cell) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(
                          cell,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.colors.textPrimary,
                              ),
                        ),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
