import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/library_state.dart';

class LibraryRepository {
  LibraryRepository(this._store);
  final KeyValueStore _store;
  static const _key = 'library';

  LibraryState load() {
    final json = _store.read(_key);
    return json == null ? const LibraryState() : LibraryState.fromJson(json);
  }

  Future<void> save(LibraryState state) => _store.write(_key, state.toJson());

  Future<void> clearHistory() async {
    final current = load();
    await save(LibraryState(bookmarks: current.bookmarks));
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(ref.watch(appStorageProvider).store(StoreName.library)),
);
