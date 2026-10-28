import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/app/app_router.dart';
import 'package:men_health_and_wellness/app/route_names.dart';
import 'package:men_health_and_wellness/features/education/data/content/content_library.dart';
import 'package:men_health_and_wellness/features/settings/domain/user_preferences.dart';
import 'package:men_health_and_wellness/shared/models/enums.dart';

import '../helpers/fakes.dart';

/// Renders every screen on a small phone with enlarged text in both themes
/// and fails on any layout overflow or exception.
void main() {
  final routes = [
    Routes.home,
    Routes.learn,
    Routes.health,
    Routes.progress,
    Routes.profile,
    Routes.emergency,
    Routes.search,
    Routes.myths,
    Routes.bookmarks,
    for (final c in ['erectile', 'treatments']) Routes.category(c),
    for (final t in ['erectile', 'ejaculation', 'intimacy', 'stress', 'porn']) Routes.topic(t),
    for (final r in ['erectile', 'ejaculation', 'desire', 'energy', 'porn']) Routes.reflection(r),
    Routes.reflectionHistory,
    for (final e in ['breathing', 'relaxation', 'grounding']) Routes.exercise(e),
    Routes.clinicianPrep,
    Routes.experiment,
    Routes.checkIn,
    Routes.checkInHistory,
    Routes.habitNew,
    Routes.habits,
    Routes.privacy,
    Routes.reminders,
    Routes.tracking,
    Routes.goals,
    Routes.about,
    for (final a in bundledArticles) Routes.article(a.id),
  ];

  for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
    testWidgets('all screens render (${mode.name}, 320dp, 1.3x text)', (tester) async {
      tester.view.physicalSize = const Size(960, 1920);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final env = TestEnv(
        prefs: UserPreferences(
          onboardingComplete: true,
          adultConfirmed: true,
          themeMode: mode,
          progressTrackingEnabled: true,
          trackedMetrics: TrackedMetric.values.toSet(),
          goals: WellnessGoal.values.toSet(),
        ),
      );
      await tester.pumpWidget(env.app());
      await tester.pumpAndSettle();
      final router = ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(appRouterProvider);

      for (final route in routes) {
        router.go(route);
        await tester.pumpAndSettle();
        // Scroll through the page so lazily built content is laid out too.
        final scrollable = find.byType(Scrollable).hitTestable();
        if (scrollable.evaluate().isNotEmpty) {
          for (var i = 0; i < 6; i++) {
            await tester.drag(scrollable.first, const Offset(0, -700), warnIfMissed: false);
            await tester.pumpAndSettle();
          }
        }
        expect(tester.takeException(), isNull, reason: route);
      }
    });
  }

  testWidgets('onboarding renders on a small phone', (tester) async {
    tester.view.physicalSize = const Size(960, 1920);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(TestEnv().app());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
