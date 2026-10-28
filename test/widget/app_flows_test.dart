import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';
import 'package:men_health_and_wellness/features/settings/domain/user_preferences.dart';
import 'package:men_health_and_wellness/shared/models/enums.dart';

import '../helpers/fakes.dart';
import '../helpers/pump.dart';

void main() {
  group('onboarding', () {
    testWidgets('completes all steps and lands on home', (tester) async {
      final env = TestEnv();
      await pumpApp(tester, env);

      expect(find.text('Welcome to VitalMen'), findsOneWidget);
      expect(find.textContaining('does not diagnose'), findsOneWidget);
      await scrollAndTap(tester, find.text('Get started'));

      await tester.tap(find.text('Yes, I am 18 or older'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reduce performance anxiety'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Continue'));

      // Skip optional personalisation.
      await scrollAndTap(tester, find.text('Continue'));
      await scrollAndTap(tester, find.text('Finish'));

      await scrollTo(tester, find.text('Explore your health'));
      expect(find.text('Explore your health'), findsOneWidget);
      final saved = UserPreferences.fromJson(env.storage.store(StoreName.preferences).data['user']!);
      expect(saved.onboardingComplete, isTrue);
      expect(saved.goals, {WellnessGoal.anxiety});
      expect(env.scheduler.scheduled, isEmpty, reason: 'no reminder without opt-in');
    });

    testWidgets('under-18 users cannot continue', (tester) async {
      await pumpApp(tester, TestEnv());
      await scrollAndTap(tester, find.text('Get started'));
      await tester.tap(find.text('No, I am under 18'));
      await tester.pumpAndSettle();
      expect(find.text('This app is for adults'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.text('Finish'), findsNothing);
    });

    testWidgets('emergency guidance is reachable before onboarding', (tester) async {
      await pumpApp(tester, TestEnv());
      await tester.tap(find.text('Urgent help'));
      await tester.pumpAndSettle();
      expect(find.text('Seek emergency care for'), findsOneWidget);
      expect(find.textContaining('4 hours'), findsOneWidget);
    });
  });

  group('shell', () {
    testWidgets('bottom tabs navigate', (tester) async {
      await pumpApp(tester, TestEnv(prefs: onboarded));
      for (final (tab, title) in const [
        ('Learn', 'Browse Topics'),
        ('My Health', 'Private reflections'),
        ('Progress', 'Tracking is off'),
        ('Profile', 'Appearance'),
      ]) {
        await tester.tap(find.bySemanticsLabel('$tab tab'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(title), 200, scrollable: visibleScrollable);
        expect(find.text(title), findsOneWidget, reason: tab);
      }
    });

    testWidgets('theme switching persists', (tester) async {
      final env = TestEnv(prefs: onboarded);
      await pumpApp(tester, env);
      await tester.tap(find.bySemanticsLabel('Profile tab'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(env.storage.store(StoreName.preferences).data['user']!['themeMode'], 'dark');
    });
  });

  group('library', () {
    testWidgets('search finds articles and bookmark persists', (tester) async {
      final env = TestEnv(prefs: onboarded);
      await pumpApp(tester, env);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'viagra');
      await tester.pumpAndSettle();
      expect(find.text('Erectile dysfunction treatments explained'), findsOneWidget);

      await tester.tap(find.text('Erectile dysfunction treatments explained'));
      await tester.pumpAndSettle();
      expect(find.textContaining('nitrate medicines'), findsWidgets);

      await tester.tap(find.byTooltip('Bookmark article'));
      await tester.pumpAndSettle();
      expect(env.storage.store(StoreName.library).data['library']!['bookmarks'], ['ed-treatments']);
      expect(find.byTooltip('Remove bookmark'), findsOneWidget);
    });

    testWidgets('search with no results shows an empty state', (tester) async {
      await pumpApp(tester, TestEnv(prefs: onboarded));
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzzzqqq');
      await tester.pumpAndSettle();
      expect(find.text('No matching articles'), findsOneWidget);
    });
  });

  group('reflection', () {
    testWidgets('completes, shows non-diagnostic summary, saves only on request', (tester) async {
      final env = TestEnv(prefs: onboarded);
      await pumpApp(tester, env);
      await tester.tap(find.bySemanticsLabel('My Health tab'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Sleep, stress & energy reflection'));
      await scrollAndTap(tester, find.text('Begin'));

      await tester.tap(find.text('Less than 6 hours'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Your summary'), findsOneWidget);
      expect(find.text('This is not a diagnosis'), findsOneWidget);
      expect(env.storage.store(StoreName.reflections).data, isEmpty);

      await scrollAndTap(tester, find.text('Save to my private history'));
      expect(env.storage.store(StoreName.reflections).data, hasLength(1));
    });
  });

  group('habits', () {
    testWidgets('validates and creates a habit, then marks it done', (tester) async {
      final env = TestEnv(
        prefs: onboarded.copyWith(progressTrackingEnabled: true, trackedMetrics: {TrackedMetric.wellnessActivities}),
      );
      await pumpApp(tester, env);
      await tester.tap(find.bySemanticsLabel('Progress tab'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Add a habit'));

      await scrollAndTap(tester, find.text('Create habit'));
      expect(find.text('Give your habit a name'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Brisk walk'), -300, scrollable: visibleScrollable);
      await scrollAndTap(tester, find.text('Brisk walk'));
      await scrollAndTap(tester, find.text('Create habit'));

      expect(env.storage.store(StoreName.habits).data, hasLength(1));
      await scrollAndTap(tester, find.bySemanticsLabel('Mark Brisk walk done today'));
      expect(env.storage.store(StoreName.habitCompletions).data.keys.single, endsWith('|2026-10-28'));
    });
  });

  group('privacy', () {
    testWidgets('delete all data requires confirmation and returns to onboarding', (tester) async {
      final env = TestEnv(prefs: onboarded);
      env.storage.store(StoreName.checkIns).data['2026-10-27'] = {'day': '2026-10-27', 'energy': 3};
      await pumpApp(tester, env);
      await tester.tap(find.bySemanticsLabel('Profile tab'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Privacy & data'));
      await scrollAndTap(tester, find.text('Delete all my data'));

      expect(find.text('Delete all my data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(env.storage.store(StoreName.checkIns).data, isNotEmpty);

      await scrollAndTap(tester, find.text('Delete all my data'));
      await tester.tap(find.text('Delete everything'));
      await tester.pumpAndSettle();
      expect(env.storage.isEmpty, isTrue);
      expect(find.text('Welcome to VitalMen'), findsOneWidget);
    });

    testWidgets('app lock requires successful device authentication', (tester) async {
      final env = TestEnv(prefs: onboarded)..auth.succeed = false;
      await pumpApp(tester, env);
      await tester.tap(find.bySemanticsLabel('Profile tab'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Privacy & data'));
      await scrollAndTap(tester, find.text('App lock'));
      expect(env.storage.store(StoreName.preferences).data['user']!['appLockEnabled'], isFalse);

      env.auth.succeed = true;
      await scrollAndTap(tester, find.text('App lock'));
      expect(env.storage.store(StoreName.preferences).data['user']!['appLockEnabled'], isTrue);
    });

    testWidgets('locked app shows lock screen on launch until authenticated', (tester) async {
      final env = TestEnv(prefs: onboarded.copyWith(appLockEnabled: true))..auth.succeed = false;
      await pumpApp(tester, env);
      expect(find.text('Locked for your privacy'), findsOneWidget);
      env.auth.succeed = true;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text('Locked for your privacy'), findsNothing);
    });
  });

  testWidgets('critical controls have accessible labels', (tester) async {
    await pumpApp(tester, TestEnv(prefs: onboarded));
    expect(find.bySemanticsLabel('Urgent help'), findsWidgets);
    expect(find.bySemanticsLabel('Home tab'), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsWidgets);
  });
}
