import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:men_health_and_wellness/core/privacy/data_deletion_service.dart';
import 'package:men_health_and_wellness/core/privacy/data_export_service.dart';
import 'package:men_health_and_wellness/core/security/encryption_key_store.dart';
import 'package:men_health_and_wellness/core/storage/hive_storage.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';
import 'package:men_health_and_wellness/core/storage/migrations.dart';
import 'package:men_health_and_wellness/features/daily_log/domain/daily_log.dart';
import 'package:men_health_and_wellness/features/daily_log/presentation/controllers/daily_log_controller.dart';
import 'package:men_health_and_wellness/features/education/presentation/controllers/library_controller.dart';
import 'package:men_health_and_wellness/features/experiment/domain/experiment.dart';
import 'package:men_health_and_wellness/features/reminders/domain/reminder.dart';
import 'package:men_health_and_wellness/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:men_health_and_wellness/features/settings/domain/user_preferences.dart';
import 'package:men_health_and_wellness/features/settings/presentation/controllers/preferences_controller.dart';
import 'package:men_health_and_wellness/shared/models/enums.dart';

import '../helpers/fakes.dart';

class _FixedKey implements EncryptionKeyStore {
  final key = List<int>.generate(32, (i) => i);
  @override
  Future<List<int>> readOrCreateKey() async => key;
}

void main() {
  group('HiveAppStorage', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('vm_test'));
    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('persists encrypted records, skips corrupt ones, clears all', () async {
      var storage = await HiveAppStorage.open(keyStore: _FixedKey(), directory: dir.path);
      await storage.store(StoreName.checkIns).write('a', {'x': 1});
      await Hive.box<String>(StoreName.checkIns.fileName).put('bad', '{not json');
      expect(storage.store(StoreName.checkIns).readAll().keys, ['a']);

      // Encrypted on disk: the plaintext value should not appear in the file.
      await Hive.close();
      final file = File('${dir.path}/${StoreName.checkIns.fileName}.hive');
      expect(String.fromCharCodes(await file.readAsBytes()).contains('"x":1'), isFalse);

      storage = await HiveAppStorage.open(keyStore: _FixedKey(), directory: dir.path);
      expect(storage.store(StoreName.checkIns).read('a'), {'x': 1});
      await storage.clearAll();
      expect(storage.store(StoreName.checkIns).readAll(), isEmpty);
    });
  });

  group('StorageMigrator', () {
    test('fresh install records latest version', () async {
      final s = InMemoryAppStorage();
      await StorageMigrator(s).run();
      expect(s.store(StoreName.meta).data['schema'], {'version': StorageMigrator.latestVersion});
    });

    test('runs pending migrations in order', () async {
      final s = InMemoryAppStorage();
      await s.store(StoreName.meta).write('schema', {'version': 1});
      final ran = <int>[];
      await StorageMigrator(
        s,
        currentVersion: 3,
        migrations: [Migration(2, (_) async => ran.add(2)), Migration(1, (_) async => ran.add(1))],
      ).run();
      expect(ran, [1, 2]);
      expect(s.store(StoreName.meta).data['schema'], {'version': 3});
    });
  });

  group('preferences', () {
    test('tolerant parsing falls back to safe defaults', () {
      final p = UserPreferences.fromJson({
        'goals': ['desire', 'bogus'],
        'themeMode': 'neon',
      });
      expect(p.goals, {WellnessGoal.desire});
      expect(p.themeMode, AppThemeMode.system);
      expect(p.discreetNotifications, isTrue);
      expect(p.onboardingComplete, isFalse);
    });

    test('tracks() requires tracking enabled', () {
      const p = UserPreferences(trackedMetrics: {TrackedMetric.energy});
      expect(p.tracks(TrackedMetric.energy), isFalse);
      expect(p.copyWith(progressTrackingEnabled: true).tracks(TrackedMetric.energy), isTrue);
    });

    test('failed save does not change state', () async {
      final env = TestEnv();
      env.storage.store(StoreName.preferences).failWrites = true;
      final c = env.container();
      await expectLater(c.read(preferencesProvider.notifier).setThemeMode(AppThemeMode.dark), throwsA(anything));
      expect(c.read(preferencesProvider).themeMode, AppThemeMode.system);
    });
  });

  group('deletion', () {
    test('delete everything clears every store, cancels reminders and resets state', () async {
      final env = TestEnv(prefs: onboarded);
      final c = env.container();
      await c.read(libraryProvider.notifier).toggleBookmark('understanding-ed');
      await c.read(dailyLogProvider.notifier).save(DailyLog(day: fixedNow, energy: 3));
      await c.read(wellnessReminderProvider.notifier).setEnabled(true);
      expect(env.scheduler.scheduled, isNotEmpty);

      await c.read(dataDeletionServiceProvider).deleteEverything();

      expect(env.storage.isEmpty, isTrue);
      expect(env.scheduler.cancelAllCalls, 1);
      expect(c.read(preferencesProvider).onboardingComplete, isFalse);
      expect(c.read(libraryProvider).bookmarks, isEmpty);
      expect(c.read(dailyLogProvider), isEmpty);
    });

    test('library clear history keeps bookmarks', () async {
      final c = TestEnv().container();
      await c.read(libraryProvider.notifier).toggleBookmark('a');
      await c.read(libraryProvider.notifier).markViewed('b');
      await c.read(libraryProvider.notifier).clearHistory();
      expect(c.read(libraryProvider).bookmarks, ['a']);
      expect(c.read(libraryProvider).recent, isEmpty);
    });
  });

  test('export includes only selected categories', () {
    final s = InMemoryAppStorage();
    s.store(StoreName.checkIns).data['2026-10-28'] = {'energy': 3};
    s.store(StoreName.reflections).data['r'] = {'secret': true};
    final json = DataExportService(s).export({ExportCategory.checkIns}, fixedNow);
    expect(json, contains('2026-10-28'));
    expect(json.contains('secret'), isFalse);
  });

  group('reminders', () {
    test('permission denial throws and leaves reminder off', () async {
      final env = TestEnv()..scheduler.grant = false;
      final c = env.container();
      await expectLater(c.read(wellnessReminderProvider.notifier).setEnabled(true), throwsA(anything));
      expect(c.read(wellnessReminderProvider).enabled, isFalse);
      expect(env.scheduler.scheduled, isEmpty);
    });

    test('discreet wording contains no sensitive terms', () {
      final (title, body) = ReminderWording.wellness(discreet: true);
      final (ht, hb) = ReminderWording.habit('Kegel practice', discreet: true);
      final text = '$title $body $ht $hb'.toLowerCase();
      for (final w in ['ed', 'erect', 'ejacul', 'libido', 'porn', 'kegel', 'sex']) {
        expect(RegExp('\\b$w').hasMatch(text), isFalse, reason: w);
      }
    });

    test('notification ids are stable and distinct per weekday', () {
      expect(notificationId('wellness', 1), notificationId('wellness', 1));
      final ids = {for (var d = 1; d <= 7; d++) notificationId('wellness', d)};
      expect(ids.length, 7);
      expect(ids.every((i) => i >= 0), isTrue);
    });

    test('rescheduling with new time replaces spec', () async {
      final env = TestEnv();
      final c = env.container();
      await c.read(wellnessReminderProvider.notifier).setEnabled(true);
      await c.read(wellnessReminderProvider.notifier).setTime(const TimeOfDay(hour: 7, minute: 0));
      expect(env.scheduler.scheduled['wellness']!.time, const TimeOfDay(hour: 7, minute: 0));
    });
  });

  group('validators', () {
    test('daily log', () {
      expect(DailyLogValidator.exerciseMinutes('abc'), isNotNull);
      expect(DailyLogValidator.exerciseMinutes('-5'), isNotNull);
      expect(DailyLogValidator.exerciseMinutes('2000'), isNotNull);
      expect(DailyLogValidator.exerciseMinutes('30'), isNull);
      expect(DailyLogValidator.exerciseMinutes(''), isNull);
    });

    test('experiment', () {
      expect(Experiment.validateGoal('  '), isNotNull);
      expect(Experiment.validateGoal('x' * 201), isNotNull);
      expect(Experiment.validateGoal('Take a break'), isNull);
    });

    test('daily log rejects out-of-range ratings when parsing', () {
      final log = DailyLog.fromJson({'day': '2026-10-28', 'energy': 9, 'stress': 2})!;
      expect(log.energy, isNull);
      expect(log.stress, 2);
    });

    test('empty daily log is deleted rather than stored', () async {
      final env = TestEnv();
      final c = env.container();
      await c.read(dailyLogProvider.notifier).save(DailyLog(day: fixedNow, energy: 4));
      expect(env.storage.store(StoreName.checkIns).data, isNotEmpty);
      await c.read(dailyLogProvider.notifier).save(DailyLog(day: fixedNow));
      expect(env.storage.store(StoreName.checkIns).data, isEmpty);
    });
  });
}
