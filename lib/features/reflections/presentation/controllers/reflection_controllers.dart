import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../data/reflection_repository.dart';
import '../../domain/reflection.dart';
import '../../domain/reflection_catalog.dart';
import '../../domain/reflection_rules.dart';

final reflectionRulesProvider = Provider((ref) => const ReflectionRules());

@immutable
class ReflectionFlowState {
  const ReflectionFlowState({
    required this.reflection,
    this.index = 0,
    this.answers = const {},
    this.outcome,
    this.savedSessionId,
    this.saving = false,
  });

  final Reflection reflection;
  final int index;
  final ReflectionAnswers answers;
  final ReflectionOutcome? outcome;
  final String? savedSessionId;
  final bool saving;

  ReflectionQuestion get question => reflection.questions[index];
  bool get isLast => index == reflection.questions.length - 1;
  bool get isComplete => outcome != null;
  double get progress => (index + 1) / reflection.questions.length;
  Set<String> get currentSelection => answers[question.id] ?? const {};
  bool get canContinue => question.optional || currentSelection.isNotEmpty;

  ReflectionFlowState copyWith({
    int? index,
    ReflectionAnswers? answers,
    ReflectionOutcome? Function()? outcome,
    String? Function()? savedSessionId,
    bool? saving,
  }) => ReflectionFlowState(
    reflection: reflection,
    index: index ?? this.index,
    answers: answers ?? this.answers,
    outcome: outcome != null ? outcome() : this.outcome,
    savedSessionId: savedSessionId != null ? savedSessionId() : this.savedSessionId,
    saving: saving ?? this.saving,
  );
}

/// Drives one pass through a reflection. Answers live in memory and are
/// discarded when the screen closes unless the user saves them.
class ReflectionFlowController extends Notifier<ReflectionFlowState> {
  ReflectionFlowController(this.reflectionId);
  final String reflectionId;

  @override
  ReflectionFlowState build() {
    final reflection = ReflectionCatalog.byId(reflectionId);
    if (reflection == null) throw ArgumentError.value(reflectionId, 'reflectionId');
    return ReflectionFlowState(reflection: reflection);
  }

  void toggle(String optionId) {
    final q = state.question;
    final option = q.options.firstWhere((o) => o.id == optionId);
    final current = {...state.currentSelection};
    Set<String> next;
    if (q.type == QuestionType.single) {
      next = {optionId};
    } else if (option.exclusive) {
      next = current.contains(optionId) ? {} : {optionId};
    } else {
      final exclusiveIds = q.options.where((o) => o.exclusive).map((o) => o.id);
      current.removeAll(exclusiveIds);
      current.contains(optionId) ? current.remove(optionId) : current.add(optionId);
      next = current;
    }
    state = state.copyWith(answers: {...state.answers, q.id: next});
  }

  void next() {
    if (!state.canContinue) return;
    if (state.isLast) {
      final outcome = ref.read(reflectionRulesProvider).evaluate(state.reflection, state.answers);
      state = state.copyWith(outcome: () => outcome);
    } else {
      state = state.copyWith(index: state.index + 1);
    }
  }

  void skip() {
    final answers = {...state.answers}..remove(state.question.id);
    state = state.copyWith(answers: answers);
    if (state.isLast) {
      state = state.copyWith(
        outcome: () => ref.read(reflectionRulesProvider).evaluate(state.reflection, state.answers),
      );
    } else {
      state = state.copyWith(index: state.index + 1);
    }
  }

  /// Returns false when already on the first question.
  bool back() {
    if (state.isComplete) {
      state = state.copyWith(outcome: () => null);
      return true;
    }
    if (state.index == 0) return false;
    state = state.copyWith(index: state.index - 1);
    return true;
  }

  Future<void> save() async {
    if (state.saving || state.savedSessionId != null || !state.isComplete) return;
    state = state.copyWith(saving: true);
    try {
      final session = ReflectionSession(
        id: const Uuid().v4(),
        reflectionId: reflectionId,
        completedAt: ref.read(clockProvider)(),
        answers: state.answers,
      );
      await ref.read(reflectionRepositoryProvider).save(session);
      ref.read(reflectionHistoryProvider.notifier).insert(session);
      state = state.copyWith(savedSessionId: () => session.id, saving: false);
    } catch (_) {
      state = state.copyWith(saving: false);
      rethrow;
    }
  }

  void restart() => state = ReflectionFlowState(reflection: state.reflection);
}

final reflectionFlowProvider = NotifierProvider.autoDispose
    .family<ReflectionFlowController, ReflectionFlowState, String>(ReflectionFlowController.new);

class ReflectionHistoryController extends Notifier<List<ReflectionSession>> {
  @override
  List<ReflectionSession> build() => ref.watch(reflectionRepositoryProvider).all();

  void insert(ReflectionSession s) {
    // `state` may be freshly built from storage and already contain it.
    if (state.any((x) => x.id == s.id)) return;
    state = [s, ...state];
  }

  Future<void> delete(String id) async {
    await ref.read(reflectionRepositoryProvider).delete(id);
    state = state.where((s) => s.id != id).toList();
  }

  Future<void> deleteAll() async {
    await ref.read(reflectionRepositoryProvider).deleteAll();
    state = const [];
  }
}

final reflectionHistoryProvider = NotifierProvider<ReflectionHistoryController, List<ReflectionSession>>(
  ReflectionHistoryController.new,
);
