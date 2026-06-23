import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/database_helper.dart';
import '../../../../core/data/sync_service.dart';

class MCQRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();

  Future<List<String>> getTopics() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM mcq_bank ORDER BY category');
    return result.map((e) => e['category'] as String).toList();
  }

  Future<int> getTopicCount(String topic) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM mcq_bank WHERE category = ?', [topic]);
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getQuestions(String topic, int count) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM mcq_bank WHERE category = ? ORDER BY RANDOM() LIMIT ?',
      [topic, count],
    );
    return result.map((row) {
      return {
        'id': row['id'],
        'category': row['category'],
        'question': row['question'],
        'options': jsonDecode(row['options'] as String) as List<dynamic>,
        'correct_answer_index': row['correct_answer_index'],
        'solution': row['solution'],
        'is_bookmarked': row['is_bookmarked'],
      };
    }).toList();
  }

  /// Saves test result to both local SQLite AND Firestore (via SyncService).
  Future<void> saveTestResult({
    required String topic,
    required int total,
    required int correct,
    required int wrong,
    required int skipped,
    required int timeTaken,
    required String mode,
  }) async {
    await _syncService.saveTestResult(
      topic: topic,
      total: total,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
      timeTaken: timeTaken,
      mode: mode,
    );
  }
}

final mcqRepositoryProvider = Provider<MCQRepository>((ref) {
  return MCQRepository();
});

final mcqTopicsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(mcqRepositoryProvider);
  final topics = await repo.getTopics();

  List<Map<String, dynamic>> topicDetails = [];
  for (var topic in topics) {
    final count = await repo.getTopicCount(topic);
    topicDetails.add({
      'title': topic,
      'count': count,
    });
  }
  return topicDetails;
});
