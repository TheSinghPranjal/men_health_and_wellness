import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../security/encryption_key_store.dart';
import 'key_value_store.dart';

/// Hive-backed [KeyValueStore] that stores JSON strings.
///
/// JSON (instead of generated type adapters) keeps serialization explicit,
/// avoids adapter-ID bookkeeping, and makes record-level migration simple.
class HiveKeyValueStore implements KeyValueStore {
  HiveKeyValueStore(this._box);
  final Box<String> _box;

  @override
  Map<String, dynamic>? read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return _decode(key, raw);
  }

  @override
  Map<String, Map<String, dynamic>> readAll() {
    final result = <String, Map<String, dynamic>>{};
    for (final key in _box.keys.cast<String>()) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final decoded = _decode(key, raw);
      if (decoded != null) result[key] = decoded;
    }
    return result;
  }

  Map<String, dynamic>? _decode(String key, String raw) {
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (e, s) {
      AppLogger.error('storage.decode_failed', e, s);
      return null;
    }
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) => _guard(() => _box.put(key, jsonEncode(value)));

  @override
  Future<void> delete(String key) => _guard(() => _box.delete(key));

  @override
  Future<void> deleteAll(Iterable<String> keys) => _guard(() => _box.deleteAll(keys));

  @override
  Future<void> clear() => _guard(() => _box.clear());

  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
    } catch (e, s) {
      AppLogger.error('storage.write_failed', e, s);
      throw const StorageException();
    }
  }
}

class HiveAppStorage implements AppStorage {
  HiveAppStorage._(this._stores);
  final Map<StoreName, HiveKeyValueStore> _stores;

  /// Opens every store encrypted with AES-256 using a key held in the
  /// platform keystore (see docs/PRIVACY.md for the threat model).
  static Future<HiveAppStorage> open({required EncryptionKeyStore keyStore, String? directory}) async {
    if (directory == null) {
      await Hive.initFlutter('vm_data');
    } else {
      Hive.init(directory);
    }
    final cipher = HiveAesCipher(await keyStore.readOrCreateKey());
    final stores = <StoreName, HiveKeyValueStore>{};
    for (final name in StoreName.values) {
      stores[name] = HiveKeyValueStore(await _openBox(name.fileName, cipher));
    }
    return HiveAppStorage._(stores);
  }

  static Future<Box<String>> _openBox(String name, HiveCipher cipher) async {
    try {
      return await Hive.openBox<String>(name, encryptionCipher: cipher);
    } catch (e, s) {
      // Unreadable box (e.g. key lost after an OS restore). The data cannot
      // be decrypted, so start clean instead of blocking app launch.
      AppLogger.error('storage.open_failed_resetting', e, s);
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<String>(name, encryptionCipher: cipher);
    }
  }

  @override
  KeyValueStore store(StoreName name) => _stores[name]!;

  @override
  Future<void> clearAll() async {
    for (final store in _stores.values) {
      await store.clear();
    }
  }
}
