import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/key_value_store.dart';
import '../storage/storage_providers.dart';

enum ExportCategory {
  checkIns('Check-ins', StoreName.checkIns),
  habits('Habits', StoreName.habits),
  habitCompletions('Habit completions', StoreName.habitCompletions),
  reflections('Saved reflections', StoreName.reflections),
  experiments('Experiments', StoreName.experiments),
  clinicianNotes('Appointment checklist', StoreName.clinicianNotes);

  const ExportCategory(this.label, this.store);
  final String label;
  final StoreName store;
}

/// Produces a JSON export of the categories the user selects. The export
/// is handed to the user (clipboard); the app never sends it anywhere.
class DataExportService {
  DataExportService(this._storage);
  final AppStorage _storage;

  String export(Set<ExportCategory> categories, DateTime now) {
    final data = <String, dynamic>{
      'exportedAt': now.toIso8601String(),
      'format': 1,
      for (final c in categories) c.name: _storage.store(c.store).readAll(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

final dataExportServiceProvider = Provider((ref) => DataExportService(ref.watch(appStorageProvider)));
