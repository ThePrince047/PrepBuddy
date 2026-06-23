import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/database_helper.dart';

class StatsRepository {
  Future<List<Map<String, dynamic>>> getTestHistory() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('test_history', orderBy: 'completed_at DESC');
  }

  Future<Map<String, dynamic>> getSummaryStats() async {
    final db = await DatabaseHelper.instance.database;
    
    // Total tests
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM test_history');
    final totalTests = totalResult.first['count'] as int? ?? 0;
    
    if (totalTests == 0) {
      return {
        'totalTests': 0,
        'avgScore': 0.0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'totalSkipped': 0,
        'byTopic': <String, Map<String, dynamic>>{},
      };
    }
    
    // Sum stats
    final sumsResult = await db.rawQuery('''
      SELECT 
        SUM(correct) as correct, 
        SUM(wrong) as wrong, 
        SUM(skipped) as skipped,
        SUM(total_questions) as total_q
      FROM test_history
    ''');
    
    final correct = sumsResult.first['correct'] as int? ?? 0;
    final wrong = sumsResult.first['wrong'] as int? ?? 0;
    final skipped = sumsResult.first['skipped'] as int? ?? 0;
    final totalQ = sumsResult.first['total_q'] as int? ?? 0;
    
    final avgScore = totalQ > 0 ? (correct / totalQ) * 100 : 0.0;
    
    // Group by topic
    final topicResult = await db.rawQuery('''
      SELECT 
        topic, 
        COUNT(*) as test_count, 
        SUM(correct) as correct, 
        SUM(total_questions) as total_q
      FROM test_history
      GROUP BY topic
    ''');
    
    final byTopic = <String, Map<String, dynamic>>{};
    for (final row in topicResult) {
      final t = row['topic'] as String;
      final tCorrect = row['correct'] as int? ?? 0;
      final tTotal = row['total_q'] as int? ?? 0;
      byTopic[t] = {
        'testCount': row['test_count'] as int? ?? 0,
        'avgScore': tTotal > 0 ? (tCorrect / tTotal) * 100 : 0.0,
      };
    }
    
    return {
      'totalTests': totalTests,
      'avgScore': avgScore,
      'totalCorrect': correct,
      'totalWrong': wrong,
      'totalSkipped': skipped,
      'byTopic': byTopic,
    };
  }

  Future<Map<String, int>> getDsaProgress() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN is_studied = 1 THEN 1 ELSE 0 END) as studied,
        COUNT(*) as total
      FROM dsa_problems
    ''');
    
    final studied = result.first['studied'] as int? ?? 0;
    final total = result.first['total'] as int? ?? 0;
    
    return {
      'studied': studied,
      'total': total,
    };
  }
}

final statsRepositoryProvider = Provider((ref) => StatsRepository());

final testHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(statsRepositoryProvider).getTestHistory();
});

final statsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(statsRepositoryProvider).getSummaryStats();
});

final dsaProgressProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(statsRepositoryProvider).getDsaProgress();
});
