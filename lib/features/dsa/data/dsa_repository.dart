import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';

class DsaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM dsa_problems GROUP BY category ORDER BY category',
    );
    return result
        .map((e) => {'title': e['category'] as String, 'count': e['count'] as int})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getProblemsByCategory(String category) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT id, title, difficulty, is_studied, is_bookmarked FROM dsa_problems WHERE category = ? ORDER BY id',
      [category],
    );
    return result
        .map((e) => {
              'id': e['id'],
              'title': e['title'],
              'difficulty': e['difficulty'],
              'is_studied': e['is_studied'],
              'is_bookmarked': e['is_bookmarked'],
            })
        .toList();
  }

  Future<Map<String, dynamic>?> getProblemById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM dsa_problems WHERE id = ?',
      [id],
    );
    if (result.isEmpty) return null;
    final row = result.first;
    return {
      'id': row['id'],
      'category': row['category'],
      'title': row['title'],
      'difficulty': row['difficulty'],
      'problem_statement': row['problem_statement'],
      'companies': jsonDecode(row['companies'] as String? ?? '[]'),
      'approach': row['approach'],
      'time_complexity': row['time_complexity'],
      'space_complexity': row['space_complexity'],
      'solutions': _parseSolutions(row['solutions'] as String? ?? '{}'),
      'step_by_step': jsonDecode(row['step_by_step'] as String? ?? '[]'),
      'is_studied': row['is_studied'],
      'is_bookmarked': row['is_bookmarked'],
    };
  }

  Future<void> markStudied(String id, bool studied) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE dsa_problems SET is_studied = ? WHERE id = ?',
      [studied ? 1 : 0, id],
    );
  }

  Map<String, String> _parseSolutions(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }
}

final dsaRepositoryProvider = Provider<DsaRepository>((ref) => DsaRepository());

final dsaCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(dsaRepositoryProvider).getCategories();
});

final dsaProblemsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  return ref.read(dsaRepositoryProvider).getProblemsByCategory(category);
});

final dsaProblemDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  return ref.read(dsaRepositoryProvider).getProblemById(id);
});
