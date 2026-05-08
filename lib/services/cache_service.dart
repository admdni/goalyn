import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _boxName = 'cache';
  static const _defaultTtlMinutes = 10;

  static Box get _box => Hive.box(_boxName);

  /// Save data with a timestamp
  static Future<void> put(String key, dynamic data, {int? ttlMinutes}) async {
    final entry = {
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttlMinutes ?? _defaultTtlMinutes,
    };
    await _box.put(key, entry);
  }

  /// Get cached data if not expired, returns null if expired or missing
  static dynamic get(String key) {
    final entry = _box.get(key);
    if (entry == null) return null;

    final map = Map<String, dynamic>.from(entry as Map);
    final timestamp = map['timestamp'] as int;
    final ttl = map['ttl'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;

    if (age > ttl * 60 * 1000) return null; // expired

    try {
      return jsonDecode(map['data'] as String);
    } catch (_) {
      return null;
    }
  }

  /// Get cached data even if expired (for offline fallback)
  static dynamic getStale(String key) {
    final entry = _box.get(key);
    if (entry == null) return null;

    final map = Map<String, dynamic>.from(entry as Map);
    try {
      return jsonDecode(map['data'] as String);
    } catch (_) {
      return null;
    }
  }

  /// Clear all cache
  static Future<void> clearAll() async {
    await _box.clear();
  }
}
