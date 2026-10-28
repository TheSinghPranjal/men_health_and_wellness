import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';
import 'package:men_health_and_wellness/features/reflections/presentation/controllers/reflection_controllers.dart';

import '../helpers/fakes.dart';

void main() {
  test('flow requires an answer, handles exclusive options and saves on request', () async {
    final env = TestEnv();
    final c = env.container();
    final provider = reflectionFlowProvider('erectile');
    final sub = c.listen(provider, (_, _) {});
    final ctrl = c.read(provider.notifier);

    expect(c.read(provider).canContinue, isFalse);
    ctrl.next();
    expect(c.read(provider).index, 0, reason: 'cannot advance without answer');

    ctrl.toggle('gt6m');
    ctrl.next();
    expect(c.read(provider).index, 1);

    // Jump to the multi-select "changes" question.
    ctrl.toggle('often');
    ctrl.next();
    ctrl.toggle('all');
    ctrl.next();
    ctrl.toggle('gradual');
    ctrl.next();
    expect(c.read(provider).question.id, 'changes');
    ctrl.toggle('stress');
    ctrl.toggle('sleep');
    ctrl.toggle('none');
    expect(c.read(provider).currentSelection, {'none'});
    ctrl.toggle('stress');
    expect(c.read(provider).currentSelection, {'stress'});

    while (!c.read(provider).isComplete) {
      ctrl.skip();
    }
    expect(c.read(provider).outcome, isNotNull);
    expect(env.storage.store(StoreName.reflections).data, isEmpty, reason: 'nothing saved by default');

    await ctrl.save();
    expect(env.storage.store(StoreName.reflections).data.length, 1);
    expect(c.read(reflectionHistoryProvider).length, 1);

    await ctrl.save();
    expect(env.storage.store(StoreName.reflections).data.length, 1, reason: 'no duplicate saves');
    sub.close();
  });

  test('history delete and delete-all', () async {
    final env = TestEnv();
    final c = env.container();
    final provider = reflectionFlowProvider('energy');
    final sub = c.listen(provider, (_, _) {});
    final ctrl = c.read(provider.notifier);
    while (!c.read(provider).isComplete) {
      ctrl.skip();
    }
    await ctrl.save();
    final id = c.read(reflectionHistoryProvider).single.id;
    await c.read(reflectionHistoryProvider.notifier).delete(id);
    expect(c.read(reflectionHistoryProvider), isEmpty);
    expect(env.storage.store(StoreName.reflections).data, isEmpty);
    sub.close();
  });

  test('save failure is surfaced and state recovers', () async {
    final env = TestEnv();
    env.storage.store(StoreName.reflections).failWrites = true;
    final c = env.container();
    final provider = reflectionFlowProvider('energy');
    final sub = c.listen(provider, (_, _) {});
    final ctrl = c.read(provider.notifier);
    while (!c.read(provider).isComplete) {
      ctrl.skip();
    }
    await expectLater(ctrl.save(), throwsA(anything));
    expect(c.read(provider).saving, isFalse);
    expect(c.read(provider).savedSessionId, isNull);
    sub.close();
  });
}
