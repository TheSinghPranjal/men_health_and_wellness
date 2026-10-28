import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/experiment_repository.dart';
import '../../domain/experiment.dart';

class ExperimentController extends Notifier<List<Experiment>> {
  @override
  List<Experiment> build() => ref.watch(experimentRepositoryProvider).all();

  Experiment? get active => state.where((e) => e.active).firstOrNull;

  Future<void> start(String goal) async {
    final error = Experiment.validateGoal(goal);
    if (error != null) throw ValidationException(error);
    if (active != null) throw const ValidationException('Finish your current experiment first.');
    final e = Experiment(id: const Uuid().v4(), goal: goal.trim(), startedAt: ref.read(clockProvider)());
    await ref.read(experimentRepositoryProvider).save(e);
    state = [e, ...state];
  }

  Future<void> addObservation(String text) async {
    final error = Experiment.validateObservation(text);
    if (error != null) throw ValidationException(error);
    final current = active;
    if (current == null) return;
    final next = current.copyWith(
      observations: [
        Observation(at: ref.read(clockProvider)(), text: text.trim()),
        ...current.observations,
      ],
    );
    await _replace(next);
  }

  Future<void> end() async {
    final current = active;
    if (current == null) return;
    await _replace(current.copyWith(endedAt: ref.read(clockProvider)()));
  }

  Future<void> delete(String id) async {
    await ref.read(experimentRepositoryProvider).delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> deleteAll() async {
    await ref.read(experimentRepositoryProvider).deleteAll();
    state = const [];
  }

  Future<void> _replace(Experiment e) async {
    await ref.read(experimentRepositoryProvider).save(e);
    state = [for (final x in state) x.id == e.id ? e : x];
  }
}

final experimentProvider = NotifierProvider<ExperimentController, List<Experiment>>(ExperimentController.new);
