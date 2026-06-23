import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/dsa_repository.dart';

class DsaTopicsScreen extends ConsumerWidget {
  const DsaTopicsScreen({super.key});

  // Map category keys to display icons
  static const _icons = {
    'PATTERN': Icons.grid_view_rounded,
    'ARRAY': Icons.view_array_rounded,
    'STRING': Icons.text_fields_rounded,
    'LINKED_LIST': Icons.link_rounded,
    'STACK': Icons.layers_rounded,
    'QUEUE': Icons.queue_rounded,
    'TREE': Icons.account_tree_rounded,
    'GRAPH': Icons.hub_rounded,
    'DYNAMIC_PROGRAMMING': Icons.memory_rounded,
    'SORTING': Icons.sort_rounded,
    'SEARCHING': Icons.search_rounded,
    'RECURSION': Icons.loop_rounded,
    'MATH': Icons.calculate_rounded,
    'BIT': Icons.electrical_services_rounded,
  };

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF00D2FF),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF14B8A6),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(dsaCategoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('DSA Coding Prep', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No DSA problems found. Check DB seeding.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final color = _colors[index % _colors.length];
              final icon = _icons[cat['title'].toString().toUpperCase()] ?? Icons.code_rounded;
              return GlassCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                onTap: () => context.push('/dsa/list', extra: cat['title']),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const Spacer(),
                    Text(
                      _formatCategory(cat['title'].toString()),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat['count']} Problems',
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
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

  String _formatCategory(String raw) {
    return raw
        .split('.')
        .last
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
