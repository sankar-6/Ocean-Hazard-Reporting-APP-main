import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../config/environment.dart';

class OfflineApiService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'api_cache.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE api_cache(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            params TEXT,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            expires_at INTEGER NOT NULL,
            UNIQUE(endpoint, params)
          )
        ''');
      },
    );
  }
  
  static Future<void> cacheResponse({
    required String endpoint,
    Map<String, dynamic>? params,
    required Map<String, dynamic> data,
    Duration? cacheDuration,
  }) async {
    final db = await database;
    final duration = cacheDuration ?? EnvironmentConfig.cacheExpiry;
    
    await db.insert(
      'api_cache',
      {
        'endpoint': endpoint,
        'params': params != null ? jsonEncode(params) : null,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expires_at': DateTime.now().add(duration).millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<Map<String, dynamic>?> getCachedResponse({
    required String endpoint,
    Map<String, dynamic>? params,
  }) async {
    final db = await database;
    
    final result = await db.query(
      'api_cache',
      where: 'endpoint = ? AND params = ? AND expires_at > ?',
      whereArgs: [
        endpoint,
        params != null ? jsonEncode(params) : null,
        DateTime.now().millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      try {
        return jsonDecode(result.first['data'] as String) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, remove the corrupted entry
        await db.delete(
          'api_cache',
          where: 'id = ?',
          whereArgs: [result.first['id']],
        );
        return null;
      }
    }
    
    return null;
  }
  
  static Future<void> clearExpiredCache() async {
    final db = await database;
    await db.delete(
      'api_cache',
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }
  
  static Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('api_cache');
  }
  
  static Future<void> clearCacheForEndpoint(String endpoint) async {
    final db = await database;
    await db.delete(
      'api_cache',
      where: 'endpoint = ?',
      whereArgs: [endpoint],
    );
  }
  
  static Future<int> getCacheSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM api_cache');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  static Future<List<Map<String, dynamic>>> getCacheInfo() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        endpoint,
        COUNT(*) as count,
        MIN(timestamp) as oldest,
        MAX(timestamp) as newest
      FROM api_cache 
      GROUP BY endpoint
      ORDER BY count DESC
    ''');
  }
  
  // Offline queue for failed requests
  static Future<void> queueOfflineRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
  }) async {
    final db = await database;
    
    await db.insert('offline_queue', {
      'method': method,
      'endpoint': endpoint,
      'data': data != null ? jsonEncode(data) : null,
      'params': params != null ? jsonEncode(params) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }
  
  static Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    final db = await database;
    return await db.query(
      'offline_queue',
      orderBy: 'timestamp ASC',
    );
  }
  
  static Future<void> removeOfflineRequest(int id) async {
    final db = await database;
    await db.delete(
      'offline_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  static Future<void> incrementRetryCount(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE offline_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }
  
}
