// services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/feature_vector.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  Database? _database;
  final String _tableName = 'biometric_templates';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'face_auth.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        features TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        hash TEXT NOT NULL
      )
    ''');
  }

  Future<bool> storeTemplate(FeatureVector template) async {
    try {
      print(
        '=== DATABASE: Storing template for userId: ${template.userId} ===',
      );
      final db = await database;
      final templateData = template.toMap();

      // Create hash for integrity verification
      final hash = _createHash(templateData['features']);
      templateData['hash'] = hash;

      final result = await db.insert(_tableName, templateData);
      print('Template stored with ID: $result');

      // Verify the insert by querying back
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE userId = ?',
        [template.userId],
      );
      print(
        'Total templates for userId ${template.userId}: ${count.first['count']}',
      );

      return true;
    } catch (e) {
      print('Template storage error: $e');
      return false;
    }
  }

  Future<List<FeatureVector>> getTemplates(String userId) async {
    try {
      print('=== DATABASE: Retrieving templates for userId: $userId ===');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      print('Found ${maps.length} raw database records for userId: $userId');

      final templates = <FeatureVector>[];
      for (int i = 0; i < maps.length; i++) {
        final map = maps[i];
        print(
          'Processing record $i: userId=${map['userId']}, timestamp=${map['timestamp']}',
        );

        try {
          // Verify hash integrity
          final expectedHash = _createHash(map['features']);
          if (expectedHash != map['hash']) {
            print('WARNING: Template integrity check failed for record $i');
            continue;
          }

          final template = FeatureVector.fromMap(map);
          templates.add(template);
          print(
            'Successfully loaded template $i with ${template.features.length} features',
          );
        } catch (e) {
          print('Error processing record $i: $e');
        }
      }

      print('=== DATABASE: Returning ${templates.length} valid templates ===');
      return templates;
    } catch (e) {
      print('Template retrieval error: $e');
      return [];
    }
  }

  Future<bool> deleteTemplates(String userId) async {
    try {
      final db = await database;
      await db.delete(_tableName, where: 'userId = ?', whereArgs: [userId]);
      return true;
    } catch (e) {
      print('Template deletion error: $e');
      return false;
    }
  }

  String _createHash(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
