import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test parsing questionBank.json', () {
    final file = File('assets/data/questionBank.json');
    final content = file.readAsStringSync();
    try {
      final json = jsonDecode(content);
      print('Parsed questionBank successfully, items: ${json.length}');
    } catch (e) {
      print('Failed to parse questionBank.json: $e');
      throw e;
    }
  });

  test('Test parsing codingBank.json', () {
    final file = File('assets/data/codingBank.json');
    final content = file.readAsStringSync();
    try {
      final json = jsonDecode(content);
      print('Parsed codingBank successfully, items: ${json.length}');
    } catch (e) {
      print('Failed to parse codingBank.json: $e');
      throw e;
    }
  });
}
