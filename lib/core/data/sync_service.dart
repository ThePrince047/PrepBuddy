import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// Status of the sync operation, used by the UI to show progress.
enum SyncStatus { idle, syncing, success, failed, noInternet }

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _lastSyncKey = 'last_data_sync_ms';
  // Re-sync content every 24 hours at most
  static const int _syncIntervalHours = 24;

  Future<SyncStatus> syncAll({bool force = false}) async {
    final user = _auth.currentUser;
    if (user == null) return SyncStatus.idle;

    try {
      // Check if we should re-sync based on time
      if (!force && !await _shouldSync()) {
        return SyncStatus.success; // Already synced recently
      }

      // Sync question/material data
      await _syncMcqBank();
      await _syncDsaProblems();
      await _syncStudyMaterials();

      // Save timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      return SyncStatus.success;
    } on FirebaseException catch (e) {
      print('❌ Sync failed (Firebase): ${e.message}');
      return SyncStatus.failed;
    } catch (e) {
      print('❌ Sync failed: $e');
      return SyncStatus.failed;
    }
  }

  /// Check if enough time has passed since last sync
  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);
    if (lastSync == null) return true;
    final hoursSinceSync = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastSync))
        .inHours;
    return hoursSinceSync >= _syncIntervalHours;
  }

  Future<void> _syncMcqBank() async {
    print('🔄 Syncing MCQ bank from Firestore...');
    final db = await DatabaseHelper.instance.database;

    // Fetch in batches using subcollections per category
    final categories = await _firestore.collection('mcq_bank').get();
    int count = 0;

    for (final catDoc in categories.docs) {
      final questions = await _firestore
          .collection('mcq_bank')
          .doc(catDoc.id)
          .collection('questions')
          .get();

      final batch = db.batch();
      for (final qDoc in questions.docs) {
        final data = qDoc.data();
        batch.insert(
          'mcq_bank',
          {
            'id': int.tryParse(data['id']?.toString() ?? '') ?? qDoc.id.hashCode,
            'category': data['category'] ?? catDoc.id,
            'question': data['question'] ?? '',
            'options': data['options'] is List
                ? jsonEncode(data['options'])
                : (data['options'] ?? '[]'),
            'correct_answer_index': data['correct_answer_index'] ?? 0,
            'solution': data['solution'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
      await batch.commit(noResult: true);
    }
    print('✅ MCQ sync done: $count questions');
  }

  Future<void> _syncDsaProblems() async {
    print('🔄 Syncing DSA problems from Firestore...');
    final db = await DatabaseHelper.instance.database;
    final snapshot = await _firestore.collection('dsa_problems').get();
    int count = 0;

    final batch = db.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      batch.insert(
        'dsa_problems',
        {
          'id': data['id']?.toString() ?? doc.id,
          'category': data['category'] ?? 'General',
          'title': data['title'] ?? '',
          'difficulty': data['difficulty'] ?? 'Medium',
          'problem_statement': data['problem_statement'] ?? '',
          'companies': data['companies'] is List
              ? jsonEncode(data['companies'])
              : (data['companies'] ?? '[]'),
          'approach': data['approach'] ?? '',
          'time_complexity': data['time_complexity'] ?? '',
          'space_complexity': data['space_complexity'] ?? '',
          'solutions': data['solutions'] is Map
              ? jsonEncode(data['solutions'])
              : (data['solutions'] ?? '{}'),
          'step_by_step': data['step_by_step'] is List
              ? jsonEncode(data['step_by_step'])
              : (data['step_by_step'] ?? '[]'),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }
    await batch.commit(noResult: true);
    print('✅ DSA sync done: $count problems');
  }

  Future<void> _syncStudyMaterials() async {
    print('🔄 Syncing study materials from Firestore...');
    final db = await DatabaseHelper.instance.database;
    final snapshot = await _firestore.collection('study_materials').get();
    int count = 0;

    final batch = db.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      batch.insert(
        'study_materials',
        {
          'id': data['id'] ?? doc.id.hashCode,
          'category': data['category'] ?? '',
          'content': data['content'] is Map || data['content'] is List
              ? jsonEncode(data['content'])
              : (data['content'] ?? '{}'),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }
    await batch.commit(noResult: true);
    print('✅ Study materials sync done: $count materials');
  }

  // ─── User Stats ──────────────────────────────────────────────────────────────

  /// Save test result both to local SQLite and to Firestore for this user.
  Future<void> saveTestResult({
    required String topic,
    required int total,
    required int correct,
    required int wrong,
    required int skipped,
    required int timeTaken,
    required String mode,
  }) async {
    final user = _auth.currentUser;
    final timestamp = DateTime.now().toIso8601String();
    final data = {
      'topic': topic,
      'total_questions': total,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'time_taken': timeTaken,
      'mode': mode,
      'completed_at': timestamp,
    };

    // Save to local SQLite
    final db = await DatabaseHelper.instance.database;
    await db.insert('test_history', data);

    // Save to Firestore if logged in
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('test_history')
            .add(data);
      } catch (e) {
        print('⚠️ Cloud stats save failed: $e');
      }
    }
  }

  /// Fetch cloud stats from Firestore and merge into local SQLite.
  Future<void> syncUserStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('test_history')
          .get();

      final db = await DatabaseHelper.instance.database;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        await db.insert('test_history', {
          'topic': data['topic'] ?? '',
          'total_questions': data['total_questions'] ?? 0,
          'correct': data['correct'] ?? 0,
          'wrong': data['wrong'] ?? 0,
          'skipped': data['skipped'] ?? 0,
          'time_taken': data['time_taken'] ?? 0,
          'mode': data['mode'] ?? 'practice',
          'completed_at': data['completed_at'] ?? '',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      print('✅ User stats synced: ${snapshot.docs.length} entries');
    } catch (e) {
      print('⚠️ User stats sync failed: $e');
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());
