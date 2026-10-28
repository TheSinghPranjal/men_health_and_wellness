import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/user_preferences.dart';

class PreferencesRepository {
  PreferencesRepository(this._store);
  final KeyValueStore _store;
  static const _key = 'user';

  UserPreferences load() {
    final json = _store.read(_key);
    return json == null ? const UserPreferences() : UserPreferences.fromJson(json);
  }

  Future<void> save(UserPreferences prefs) => _store.write(_key, prefs.toJson());
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(appStorageProvider).store(StoreName.preferences)),
);
