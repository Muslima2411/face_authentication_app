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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
      final db = await database;
      final templateData = template.toMap();
      
      // Create hash for integrity verification
      final hash = _createHash(templateData['features']);
      templateData['hash'] = hash;

      await db.insert(_tableName, templateData);
      return true;
    } catch (e) {
      print('Template storage error: $e');
      return false;
    }
  }

  Future<List<FeatureVector>> getTemplates(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return maps.map((map) {
        // Verify hash integrity
        final expectedHash = _createHash(map['features']);
        if (expectedHash != map['hash']) {
          throw Exception('Template integrity check failed');
        }
        return FeatureVector.fromMap(map);
      }).toList();
    } catch (e) {
      print('Template retrieval error: $e');
      return [];
    }
  }

  Future<bool> deleteTemplates(String userId) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'userId = ?',
        whereArgs: [userId],
      );
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
