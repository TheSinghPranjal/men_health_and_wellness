import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme/app_theme.dart';
import 'core/logging/app_logger.dart';
import 'core/security/encryption_key_store.dart';
import 'core/storage/hive_storage.dart';
import 'core/storage/migrations.dart';
import 'core/storage/storage_providers.dart';
import 'features/reminders/data/reminder_scheduler.dart';

/// Opens encrypted storage, runs migrations and starts the app. If storage
/// cannot be opened, shows a recoverable error screen instead of crashing.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    AppLogger.error('flutter.error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  try {
    final storage = await HiveAppStorage.open(keyStore: SecureEncryptionKeyStore());
    await StorageMigrator(storage).run();
    final scheduler = LocalReminderScheduler();
    // Notification setup must never block launch.
    scheduler.initialize().catchError((Object e, StackTrace s) => AppLogger.error('reminders.init_failed', e, s));

    runApp(
      ProviderScope(
        overrides: [
          appStorageProvider.overrideWithValue(storage),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const VitalMenApp(),
      ),
    );
  } catch (e, s) {
    AppLogger.error('bootstrap.failed', e, s);
    runApp(_StartupError(onRetry: bootstrap));
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storage_rounded, size: 48),
                const SizedBox(height: 16),
                const Text('We couldn\'t open your private storage.', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the app. If this keeps happening, free up device storage.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
