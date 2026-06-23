import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database_helper.dart';

class StudyMaterialsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getMaterials() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT id, category, content, is_bookmarked FROM study_materials ORDER BY id',
    );
    return result.map((row) {
      final content = jsonDecode(row['content'] as String? ?? '{}') as Map<String, dynamic>;
      return {
        'id': row['id'],
        'category': row['category'],
        'is_bookmarked': row['is_bookmarked'],
        'icon': content['icon'] ?? '📚',
        'color': content['color'] ?? '#6C63FF',
        'colorSoft': content['colorSoft'] ?? 'rgba(108,99,255,0.10)',
        'tag': content['tag'] ?? '',
        'topics': content['topics'] ?? [],
        'title': content['title'] ?? row['category'],
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getMaterialById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM study_materials WHERE id = ?',
      [id],
    );
    if (result.isEmpty) return null;
    final row = result.first;
    final content = jsonDecode(row['content'] as String? ?? '{}') as Map<String, dynamic>;
    return {
      'id': row['id'],
      'category': row['category'],
      'is_bookmarked': row['is_bookmarked'],
      ...content,
    };
  }
}

final studyMaterialsRepositoryProvider =
    Provider<StudyMaterialsRepository>((ref) => StudyMaterialsRepository());

final studyMaterialsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(studyMaterialsRepositoryProvider).getMaterials();
});

final studyMaterialDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  return ref.read(studyMaterialsRepositoryProvider).getMaterialById(id);
});
