import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/experiment.dart';

class ExperimentRepository {
  ExperimentRepository(this._store);
  final KeyValueStore _store;

  List<Experiment> all() =>
      [for (final json in _store.readAll().values) ?Experiment.fromJson(json)]
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  Future<void> save(Experiment e) => _store.write(e.id, e.toJson());
  Future<void> delete(String id) => _store.delete(id);
  Future<void> deleteAll() => _store.clear();
}

final experimentRepositoryProvider = Provider<ExperimentRepository>(
  (ref) => ExperimentRepository(ref.watch(appStorageProvider).store(StoreName.experiments)),
);
