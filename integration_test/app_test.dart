import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';

import '../test/helpers/fakes.dart';
import '../test/helpers/pump.dart';

/// End-to-end journey through the real widget tree. Storage, notifications
/// and device authentication are replaced with in-memory fakes so the run is
/// deterministic and contains no real personal data. "Relaunch" re-pumps the
/// app on the same storage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('core journeys', (tester) async {
    final env = TestEnv();
    await pumpApp(tester, env);

    // 1–2. Onboarding, skipping optional personalisation.
    await scrollAndTap(tester, find.text('Get started'));
    await tester.tap(find.text('Yes, I am 18 or older'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Skip for now'));
    await scrollAndTap(tester, find.text('Continue'));
    await scrollAndTap(tester, find.text('Finish'));
    await scrollTo(tester, find.text('Explore your health'));

    // 3. Read and bookmark an article.
    await tester.tap(find.bySemanticsLabel('Learn tab'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Erectile health'));
    await scrollAndTap(tester, find.text('Understanding erectile dysfunction (ED)'));
    await tester.tap(find.byTooltip('Bookmark article'));
    await tester.pumpAndSettle();
    expect(env.storage.store(StoreName.library).data['library']!['bookmarks'], ['understanding-ed']);
    await tester.tap(find.byTooltip('Back').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back').hitTestable().first);
    await tester.pumpAndSettle();

    // 4–5. Complete a reflection, review its summary, save it.
    await tester.tap(find.bySemanticsLabel('My Health tab'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Erection health reflection'));
    await scrollAndTap(tester, find.text('Begin'));
    await tester.tap(find.text('More than 6 months'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Most or all of the time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    while (find.text('Your summary').evaluate().isEmpty) {
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Consider booking an appointment with a clinician'), findsOneWidget);
    await scrollAndTap(tester, find.text('Save to my private history'));
    expect(env.storage.store(StoreName.reflections).data, hasLength(1));
    await tester.tap(find.byTooltip('Back').hitTestable().first);
    await tester.pumpAndSettle();

    // 6. Create and complete a habit (enable tracking first).
    await tester.tap(find.bySemanticsLabel('Progress tab'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Choose what to track'));
    await tester.tap(find.text('Progress tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back').hitTestable().first);
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Add a habit'));
    await scrollAndTap(tester, find.text('Breathing practice'));
    await scrollAndTap(tester, find.text('Create habit'));
    await scrollAndTap(tester, find.bySemanticsLabel('Mark Breathing practice done today'));
    expect(env.storage.store(StoreName.habitCompletions).data, hasLength(1));

    // 7. Reminder preferences.
    await tester.tap(find.bySemanticsLabel('Profile tab'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Reminders'));
    await tester.tap(find.text('Daily wellness reminder'));
    await tester.pumpAndSettle();
    expect(env.scheduler.scheduled['wellness']!.body, 'Your wellness reminder is ready.');
    await tester.tap(find.byTooltip('Back').hitTestable().first);
    await tester.pumpAndSettle();

    // 8. App lock.
    await scrollAndTap(tester, find.text('Privacy & data'));
    await scrollAndTap(tester, find.text('App lock'));
    expect(env.storage.store(StoreName.preferences).data['user']!['appLockEnabled'], isTrue);

    // 9. Delete selected history (saved reflections).
    await scrollAndTap(tester, find.text('Delete saved reflections'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(env.storage.store(StoreName.reflections).data, isEmpty);
    expect(env.storage.store(StoreName.habits).data, isNotEmpty, reason: 'selective deletion');

    // 11a. Relaunch: data persisted, lock engages.
    env.auth.succeed = true;
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(env.app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to VitalMen'), findsNothing);
    expect(env.auth.prompts, greaterThan(1));

    // 10. Delete everything.
    await tester.tap(find.bySemanticsLabel('Profile tab'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Privacy & data'));
    await scrollAndTap(tester, find.text('Delete all my data'));
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();
    expect(env.storage.isEmpty, isTrue);
    expect(env.scheduler.scheduled, isEmpty);

    // 11b. Relaunch after deletion starts fresh.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(env.app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to VitalMen'), findsOneWidget);
  });
}
