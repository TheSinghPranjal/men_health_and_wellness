import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/privacy/data_deletion_service.dart';
import '../../../../core/privacy/data_export_service.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../daily_log/presentation/controllers/daily_log_controller.dart';
import '../../../education/presentation/controllers/library_controller.dart';
import '../../../experiment/presentation/controllers/experiment_controller.dart';
import '../../../habits/presentation/controllers/habit_controllers.dart';
import '../../../privacy_lock/data/device_authenticator.dart';
import '../../../reflections/presentation/controllers/reflection_controllers.dart';
import '../../../reminders/presentation/controllers/reminder_controller.dart';
import '../controllers/preferences_controller.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  Future<void> _toggleLock(BuildContext context, WidgetRef ref, bool enable) async {
    final auth = ref.read(deviceAuthenticatorProvider);
    if (enable) {
      if (!await auth.isAvailable()) {
        if (context.mounted) showClaySnack(context, 'Set up a passcode or biometrics on your device to use app lock.');
        return;
      }
      if (!await auth.authenticate('Confirm to turn on app lock')) return;
    }
    try {
      await ref.read(preferencesProvider.notifier).update((p) => p.copyWith(appLockEnabled: enable));
      if (context.mounted) showClaySnack(context, enable ? 'App lock is on' : 'App lock is off');
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  Future<void> _toggleDiscreet(BuildContext context, WidgetRef ref, bool discreet) async {
    try {
      await ref.read(preferencesProvider.notifier).update((p) => p.copyWith(discreetNotifications: discreet));
      await ref.read(wellnessReminderProvider.notifier).resync();
      await ref.read(habitsProvider.notifier).resyncReminders();
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  Future<void> _deleteCategory(
    BuildContext context, {
    required String what,
    required Future<void> Function() action,
  }) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete $what?',
      message: 'This permanently removes $what from this device. It cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    try {
      await action();
      if (context.mounted) showClaySnack(context, 'Deleted');
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  Future<void> _deleteEverything(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete all my data?',
      message:
          'Every preference, bookmark, reflection, habit, check-in, note and reminder will be permanently deleted from this device. The app will restart at the welcome screen.',
      confirmLabel: 'Delete everything',
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(dataDeletionServiceProvider).deleteEverything();
      if (context.mounted) context.go(Routes.onboarding);
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    return ClayPage(
      title: 'Privacy & data',
      children: [
        const _DataFacts(),
        const SectionHeader('Protection'),
        if (AppConfig.standard.enableAppLock)
          ClaySurface(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.appLockEnabled,
              onChanged: (v) => _toggleLock(context, ref, v),
              title: Text('App lock', style: context.text.titleMedium),
              subtitle: Text(
                'Require biometrics or your device passcode after 30 seconds away.',
                style: context.text.bodySmall,
              ),
            ),
          ),
        const SizedBox(height: Gap.md),
        ClaySurface(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: prefs.discreetNotifications,
            onChanged: (v) => _toggleDiscreet(context, ref, v),
            title: Text('Discreet notifications', style: context.text.titleMedium),
            subtitle: Text(
              'Lock-screen text says only "Your wellness reminder is ready."',
              style: context.text.bodySmall,
            ),
          ),
        ),
        const SectionHeader('Your data'),
        ClayListTile(
          title: 'Export my data',
          subtitle: 'Copy selected data as JSON',
          icon: Icons.ios_share_rounded,
          tone: ClayTone.blue,
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const _ExportSheet(),
          ),
        ),
        ClayListTile(
          title: 'Clear reading history',
          subtitle: 'Recently viewed and read articles (keeps bookmarks)',
          icon: Icons.history_toggle_off_rounded,
          onTap: () => _deleteCategory(
            context,
            what: 'your reading history',
            action: ref.read(libraryProvider.notifier).clearHistory,
          ),
        ),
        ClayListTile(
          title: 'Delete saved reflections',
          subtitle: '${ref.watch(reflectionHistoryProvider).length} saved',
          icon: Icons.psychology_outlined,
          onTap: () => _deleteCategory(
            context,
            what: 'all saved reflections',
            action: ref.read(reflectionHistoryProvider.notifier).deleteAll,
          ),
        ),
        ClayListTile(
          title: 'Delete check-ins & journal',
          subtitle: '${ref.watch(dailyLogProvider).length} entries',
          icon: Icons.edit_note_rounded,
          onTap: () =>
              _deleteCategory(context, what: 'all check-ins', action: ref.read(dailyLogProvider.notifier).deleteAll),
        ),
        ClayListTile(
          title: 'Delete habits',
          subtitle: '${ref.watch(habitsProvider).length} habits and their history',
          icon: Icons.task_alt_rounded,
          onTap: () =>
              _deleteCategory(context, what: 'all habits', action: ref.read(habitsProvider.notifier).deleteAll),
        ),
        ClayListTile(
          title: 'Delete experiments',
          subtitle: '${ref.watch(experimentProvider).length} experiments',
          icon: Icons.science_outlined,
          onTap: () => _deleteCategory(
            context,
            what: 'all experiments',
            action: ref.read(experimentProvider.notifier).deleteAll,
          ),
        ),
        const SizedBox(height: Gap.lg),
        ClayButton(
          label: 'Delete all my data',
          icon: Icons.delete_forever_rounded,
          variant: ClayButtonVariant.danger,
          onPressed: () => _deleteEverything(context, ref),
        ),
      ],
    );
  }
}

class _DataFacts extends StatelessWidget {
  const _DataFacts();

  static const facts = [
    (
      Icons.phone_iphone_rounded,
      'Stored on this device',
      'Preferences, reflections, habits and notes are encrypted (AES-256) with a key held in your device\'s secure keystore.',
    ),
    (
      Icons.cloud_off_rounded,
      'Nothing sent to a server',
      'This version has no account, no cloud backup and no analytics. Articles are bundled and work offline.',
    ),
    (Icons.block_rounded, 'No advertising', 'No ad or tracking SDKs. Your health information is never sold or shared.'),
    (
      Icons.open_in_new_rounded,
      'Links leave the app',
      'Source links open in your browser, which has its own privacy policy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClaySurface(
      child: Column(
        children: [
          for (final (icon, title, body) in facts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClayIconBadge(icon: icon, tone: ClayTone.teal, size: 40),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleSmall!.weight(800)),
                        Text(body, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExportSheet extends ConsumerStatefulWidget {
  const _ExportSheet();

  @override
  ConsumerState<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<_ExportSheet> {
  final Set<ExportCategory> _selected = {
    ExportCategory.checkIns,
    ExportCategory.habits,
    ExportCategory.habitCompletions,
  };

  Future<void> _export() async {
    final json = ref.read(dataExportServiceProvider).export(_selected, ref.read(clockProvider)());
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    Navigator.of(context).pop();
    showClaySnack(context, 'Copied. Paste it somewhere private, then clear your clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page, Gap.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Export my data', style: context.text.titleLarge),
              const SizedBox(height: Gap.sm),
              Text(
                'Choose what to include. The export is copied to your clipboard, which other apps may be able to read.',
                style: context.text.bodySmall,
              ),
              const SizedBox(height: Gap.lg),
              for (final c in ExportCategory.values)
                CheckboxListTile(
                  value: _selected.contains(c),
                  onChanged: (v) => setState(() => v == true ? _selected.add(c) : _selected.remove(c)),
                  title: Text(c.label),
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: Gap.lg),
              ClayButton(
                label: 'Copy to clipboard',
                icon: Icons.copy_rounded,
                onPressed: _selected.isEmpty ? null : _export,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
