import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Pumps the full app on a phone-sized surface.
Future<void> pumpApp(WidgetTester tester, TestEnv env) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(env.app());
  await tester.pumpAndSettle();
}

/// The vertical scrollable of the page currently on screen (offstage tabs
/// in the indexed stack are not hit-testable, so they are excluded).
Finder get visibleScrollable => find.byType(Scrollable).hitTestable().first;

Future<void> scrollTo(WidgetTester tester, Finder finder, {double delta = 300}) async {
  await tester.scrollUntilVisible(finder, delta, scrollable: visibleScrollable);
  await tester.pumpAndSettle();
}

/// Scrolls the visible page until [finder] is visible, then taps it.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300, scrollable: visibleScrollable);
  await tester.pumpAndSettle();
  // Centre it so floating chrome (the tab bar) can't cover it.
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
