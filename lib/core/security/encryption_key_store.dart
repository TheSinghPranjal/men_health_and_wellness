import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive_ce.dart';

/// Supplies the 256-bit key used to encrypt local stores.
abstract interface class EncryptionKeyStore {
  Future<List<int>> readOrCreateKey();
}

/// Keeps the key in the iOS Keychain / Android Keystore-backed storage.
/// No custom cryptography: the key is random bytes from Hive's secure
/// generator and encryption is Hive's AES-256-CBC implementation.
class SecureEncryptionKeyStore implements EncryptionKeyStore {
  SecureEncryptionKeyStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );

  static const _keyName = 'vm.store.key';
  final FlutterSecureStorage _storage;

  @override
  Future<List<int>> readOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return base64Url.decode(existing);
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyName, value: base64Url.encode(key));
    return key;
  }
}
