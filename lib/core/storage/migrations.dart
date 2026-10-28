import '../logging/app_logger.dart';
import 'key_value_store.dart';

/// A forward-only migration from `from` to `from + 1`.
class Migration {
  const Migration(this.from, this.run);
  final int from;
  final Future<void> Function(AppStorage storage) run;
}

/// Runs pending migrations in order and records the resulting version.
///
/// Version 1 is the initial schema. Add new migrations to [migrations] and
/// bump [currentVersion]; never edit a migration that has shipped.
class StorageMigrator {
  StorageMigrator(this.storage, {List<Migration>? migrations, int? currentVersion})
    : migrations = migrations ?? const [],
      currentVersion = currentVersion ?? latestVersion;

  static const latestVersion = 1;
  static const _key = 'schema';

  final AppStorage storage;
  final List<Migration> migrations;
  final int currentVersion;

  int get storedVersion => (storage.store(StoreName.meta).read(_key)?['version'] as int?) ?? 0;

  Future<void> run() async {
    var version = storedVersion;
    if (version == 0) {
      // Fresh install: nothing to migrate.
      version = currentVersion;
    }
    while (version < currentVersion) {
      final step = migrations.where((m) => m.from == version).firstOrNull;
      if (step == null) {
        AppLogger.warn('storage.migration_missing', {'from': version});
        break;
      }
      await step.run(storage);
      version++;
      AppLogger.info('storage.migrated', {'to': version});
    }
    await storage.store(StoreName.meta).write(_key, {'version': version});
  }
}
