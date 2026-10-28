import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:men_health_and_wellness/app/app.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';
import 'package:men_health_and_wellness/core/storage/storage_providers.dart';
import 'package:men_health_and_wellness/features/privacy_lock/data/device_authenticator.dart';
import 'package:men_health_and_wellness/features/reminders/data/reminder_scheduler.dart';
import 'package:men_health_and_wellness/features/reminders/domain/reminder.dart';
import 'package:men_health_and_wellness/features/settings/domain/user_preferences.dart';

/// In-memory store with JSON round-tripping semantics (values are copied).
class InMemoryStore implements KeyValueStore {
  final Map<String, Map<String, dynamic>> data = {};
  bool failWrites = false;

  @override
  Map<String, dynamic>? read(String key) => data[key] == null ? null : Map.of(data[key]!);

  @override
  Map<String, Map<String, dynamic>> readAll() => {for (final e in data.entries) e.key: Map.of(e.value)};

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    if (failWrites) throw Exception('write failed');
    data[key] = Map.of(value);
  }

  @override
  Future<void> delete(String key) async => data.remove(key);

  @override
  Future<void> deleteAll(Iterable<String> keys) async => keys.toList().forEach(data.remove);

  @override
  Future<void> clear() async => data.clear();
}

class InMemoryAppStorage implements AppStorage {
  final stores = {for (final n in StoreName.values) n: InMemoryStore()};

  @override
  InMemoryStore store(StoreName name) => stores[name]!;

  @override
  Future<void> clearAll() async {
    for (final s in stores.values) {
      await s.clear();
    }
  }

  bool get isEmpty => stores.values.every((s) => s.data.isEmpty);
}

class FakeReminderScheduler implements ReminderScheduler {
  bool grant = true;
  final scheduled = <String, ReminderSpec>{};
  int cancelAllCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> schedule(ReminderSpec spec) async => scheduled[spec.id] = spec;

  @override
  Future<void> cancel(String specId) async => scheduled.remove(specId);

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }
}

class FakeAuthenticator implements DeviceAuthenticator {
  bool available = true;
  bool succeed = true;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeed;
  }
}

final fixedNow = DateTime(2026, 10, 28, 9, 30); // a Wednesday

class TestEnv {
  TestEnv({UserPreferences? prefs}) {
    if (prefs != null) storage.store(StoreName.preferences).data['user'] = prefs.toJson();
  }

  final storage = InMemoryAppStorage();
  final scheduler = FakeReminderScheduler();
  final auth = FakeAuthenticator();
  DateTime now = fixedNow;

  List<Override> get overrides => [
    appStorageProvider.overrideWithValue(storage),
    reminderSchedulerProvider.overrideWithValue(scheduler),
    deviceAuthenticatorProvider.overrideWithValue(auth),
    clockProvider.overrideWithValue(() => now),
  ];

  ProviderContainer container() => ProviderContainer.test(overrides: overrides);

  Widget app() => ProviderScope(overrides: overrides, child: const VitalMenApp());
}

const onboarded = UserPreferences(onboardingComplete: true, adultConfirmed: true);
