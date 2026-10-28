import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/clinician_prep.dart';

class ClinicianPrepRepository {
  ClinicianPrepRepository(this._store);
  final KeyValueStore _store;
  static const _key = 'prep';

  ClinicianPrepState load() {
    final json = _store.read(_key);
    return json == null ? const ClinicianPrepState() : ClinicianPrepState.fromJson(json);
  }

  Future<void> save(ClinicianPrepState s) => _store.write(_key, s.toJson());
  Future<void> clear() => _store.clear();
}

final clinicianPrepRepositoryProvider = Provider<ClinicianPrepRepository>(
  (ref) => ClinicianPrepRepository(ref.watch(appStorageProvider).store(StoreName.clinicianNotes)),
);
