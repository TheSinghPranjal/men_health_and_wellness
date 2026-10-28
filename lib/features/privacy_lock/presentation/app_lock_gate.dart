import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_config.dart';
import '../../../app/theme/clay_tokens.dart';
import '../../../core/widgets/clay_buttons.dart';
import '../../../core/widgets/clay_surface.dart';
import '../../settings/presentation/controllers/preferences_controller.dart';
import '../data/device_authenticator.dart';

/// Whether the UI is currently locked.
class AppLockController extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).appLockEnabled;

  void lock() {
    if (ref.read(preferencesProvider).appLockEnabled) state = true;
  }

  Future<bool> unlock() async {
    final ok = await ref.read(deviceAuthenticatorProvider).authenticate('Unlock ${AppConfig.standard.appName}');
    if (ok) state = false;
    return ok;
  }
}

final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);

/// Wraps the whole app. Locks after the app has been in the background for
/// [timeout], and hides content in the app switcher while lock is enabled.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child, this.timeout = const Duration(seconds: 30)});
  final Widget child;
  final Duration timeout;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _obscured = false;
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptIfLocked());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final enabled = ref.read(preferencesProvider).appLockEnabled;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (enabled && !_prompting) setState(() => _obscured = true);
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final away = _backgroundedAt == null ? Duration.zero : DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (enabled && away >= widget.timeout) ref.read(appLockProvider.notifier).lock();
        setState(() => _obscured = false);
        _promptIfLocked();
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _promptIfLocked() async {
    if (!ref.read(appLockProvider) || _prompting) return;
    _prompting = true;
    try {
      await ref.read(appLockProvider.notifier).unlock();
    } finally {
      _prompting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    return Stack(
      children: [
        ExcludeSemantics(excluding: locked, child: widget.child),
        if (locked || _obscured)
          Positioned.fill(
            child: _LockScreen(locked: locked, onUnlock: _promptIfLocked),
          ),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.locked, required this.onUnlock});
  final bool locked;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Material(
      color: clay.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Gap.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 96,
                child: ClaySurface(
                  radius: 34,
                  depth: 1.3,
                  color: clay.tone(ClayTone.teal).fill,
                  padding: EdgeInsets.zero,
                  child: Icon(Icons.lock_rounded, size: 44, color: clay.tone(ClayTone.teal).onFill),
                ),
              ),
              const SizedBox(height: Gap.xl),
              Text(AppConfig.standard.appName, style: context.text.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('Locked for your privacy', style: context.text.bodyMedium),
              if (locked) ...[
                const SizedBox(height: Gap.xxl),
                ClayButton(label: 'Unlock', icon: Icons.fingerprint_rounded, onPressed: onUnlock),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
