import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/clinician_prep_repository.dart';
import '../../domain/clinician_prep.dart';

class ClinicianPrepController extends Notifier<ClinicianPrepState> {
  @override
  ClinicianPrepState build() => ref.watch(clinicianPrepRepositoryProvider).load();

  Future<void> toggle(String itemKey) => _save(state.toggle(itemKey));
  Future<void> setNote(String sectionId, String text) => _save(state.withNote(sectionId, text));

  Future<void> clear() async {
    await ref.read(clinicianPrepRepositoryProvider).clear();
    state = const ClinicianPrepState();
  }

  Future<void> _save(ClinicianPrepState next) async {
    await ref.read(clinicianPrepRepositoryProvider).save(next);
    state = next;
  }
}

final clinicianPrepProvider = NotifierProvider<ClinicianPrepController, ClinicianPrepState>(
  ClinicianPrepController.new,
);
