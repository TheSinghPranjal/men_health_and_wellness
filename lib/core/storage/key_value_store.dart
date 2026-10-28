/// Repository-facing storage contract.
///
/// Values are JSON-compatible maps. Each record carries its own schema
/// version (`_v`) so individual entries can be migrated lazily.
abstract interface class KeyValueStore {
  Map<String, dynamic>? read(String key);

  /// All readable records. Corrupt entries are skipped (and reported by the
  /// implementation) rather than crashing the caller.
  Map<String, Map<String, dynamic>> readAll();

  Future<void> write(String key, Map<String, dynamic> value);
  Future<void> delete(String key);
  Future<void> deleteAll(Iterable<String> keys);
  Future<void> clear();
}

/// Logical stores. Names are generic so file names on disk reveal nothing
/// about their contents.
enum StoreName {
  meta('s0'),
  preferences('s1'),
  library('s2'),
  reflections('s3'),
  habits('s4'),
  habitCompletions('s5'),
  checkIns('s6'),
  reminders('s7'),
  clinicianNotes('s8'),
  experiments('s9');

  const StoreName(this.fileName);
  final String fileName;
}

/// All persisted stores, opened once at startup.
abstract interface class AppStorage {
  KeyValueStore store(StoreName name);

  /// Removes every locally stored record in every store.
  Future<void> clearAll();
}
