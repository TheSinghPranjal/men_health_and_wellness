import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/privacy_lock/presentation/app_lock_gate.dart';
import '../features/settings/presentation/controllers/preferences_controller.dart';
import 'app_config.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

class VitalMenApp extends ConsumerWidget {
  const VitalMenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(preferencesProvider.select((p) => p.themeMode.mode));
    return MaterialApp.router(
      title: AppConfig.standard.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
