import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../shared/models/enums.dart';
import '../controllers/preferences_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    return ClayPage(
      title: 'Profile',
      subtitle: 'No account needed. Everything stays on this device.',
      showBack: false,
      children: [
        ClaySurface(
          color: context.clay.brand,
          depth: 1.3,
          padding: const EdgeInsets.all(Gap.xl),
          child: Row(
            children: [
              Icon(Icons.shield_moon_rounded, color: context.clay.onBrand, size: 36),
              const SizedBox(width: Gap.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Private by design', style: context.text.titleMedium!.copyWith(color: context.clay.onBrand)),
                    const SizedBox(height: 2),
                    Text(
                      'Encrypted on-device storage · no ads · no tracking SDKs',
                      style: context.text.bodySmall!.copyWith(color: context.clay.onBrand.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Appearance'),
        Row(
          children: [
            for (final m in AppThemeMode.values) ...[
              Expanded(
                child: ClayChoiceChip(
                  label: m.label,
                  selected: prefs.themeMode == m,
                  onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(m).catchError((Object e) {
                    if (context.mounted) showClaySnack(context, userMessageFor(e));
                  }),
                ),
              ),
              if (m != AppThemeMode.values.last) const SizedBox(width: Gap.sm),
            ],
          ],
        ),
        const SectionHeader('Personalisation'),
        ClayListTile(
          title: 'Goals & preferences',
          subtitle: prefs.goals.isEmpty ? 'None selected' : '${prefs.goals.length} goals selected',
          icon: Icons.flag_rounded,
          tone: ClayTone.peach,
          onTap: () => context.push(Routes.goals),
        ),
        ClayListTile(
          title: 'What to track',
          subtitle: prefs.progressTrackingEnabled ? '${prefs.trackedMetrics.length} metrics' : 'Tracking off',
          icon: Icons.insights_rounded,
          tone: ClayTone.sage,
          onTap: () => context.push(Routes.tracking),
        ),
        if (AppConfig.standard.enableReminders)
          ClayListTile(
            title: 'Reminders',
            subtitle: 'Optional and discreet',
            icon: Icons.notifications_none_rounded,
            tone: ClayTone.lavender,
            onTap: () => context.push(Routes.reminders),
          ),
        const SectionHeader('Privacy & safety'),
        ClayListTile(
          title: 'Privacy & data',
          subtitle: prefs.appLockEnabled ? 'App lock on' : 'App lock, export and deletion',
          icon: Icons.lock_outline_rounded,
          tone: ClayTone.teal,
          onTap: () => context.push(Routes.privacy),
        ),
        ClayListTile(
          title: 'Urgent help',
          subtitle: 'Emergency warning signs',
          icon: Icons.emergency_rounded,
          tone: ClayTone.rose,
          onTap: () => context.push(Routes.emergency),
        ),
        ClayListTile(
          title: 'About & sources',
          subtitle: 'How content is written and reviewed',
          icon: Icons.info_outline_rounded,
          tone: ClayTone.blue,
          onTap: () => context.push(Routes.about),
        ),
        const SizedBox(height: Gap.lg),
        Text(AppConfig.disclaimer, style: context.text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    void onError(Object e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }

    return ClayPage(
      title: 'Goals & preferences',
      subtitle: 'Used only on this device to suggest content. Change any time.',
      children: [
        GoalPicker(selected: prefs.goals, onToggle: (g) => controller.toggleGoal(g).catchError(onError)),
        const SectionHeader('Age range (optional)'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final a in AgeRange.values)
              ClayChoiceChip(
                label: a.label,
                selected: prefs.ageRange == a,
                onTap: () => controller
                    .update((p) => p.copyWith(ageRange: () => p.ageRange == a ? null : a))
                    .catchError(onError),
              ),
          ],
        ),
        const SectionHeader('Units'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final u in Units.values)
              ClayChoiceChip(
                label: u.label,
                selected: prefs.units == u,
                onTap: () => controller.update((p) => p.copyWith(units: u)).catchError(onError),
              ),
          ],
        ),
        const SizedBox(height: Gap.xl),
        ClaySurface(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: prefs.dailyRoutineEnabled,
            onChanged: (v) => controller.update((p) => p.copyWith(dailyRoutineEnabled: v)).catchError(onError),
            title: Text('Daily wellness plan', style: context.text.titleMedium),
            subtitle: Text('Show a few suggested actions on Home.', style: context.text.bodySmall),
          ),
        ),
      ],
    );
  }
}

class GoalPicker extends StatelessWidget {
  const GoalPicker({super.key, required this.selected, required this.onToggle});
  final Set<WellnessGoal> selected;
  final ValueChanged<WellnessGoal> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final g in WellnessGoal.values)
          ClayOptionTile(label: g.label, multi: true, selected: selected.contains(g), onTap: () => onToggle(g)),
      ],
    );
  }
}

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    void onError(Object e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }

    return ClayPage(
      title: 'What to track',
      subtitle:
          'Everything is optional. You never need to track sexual activity, erections, ejaculation or pornography use.',
      children: [
        ClaySurface(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: prefs.progressTrackingEnabled,
            onChanged: (v) => controller
                .update(
                  (p) => p.copyWith(
                    progressTrackingEnabled: v,
                    trackedMetrics: v && p.trackedMetrics.isEmpty
                        ? {
                            TrackedMetric.wellnessActivities,
                            TrackedMetric.exercise,
                            TrackedMetric.sleep,
                            TrackedMetric.energy,
                          }
                        : null,
                  ),
                )
                .catchError(onError),
            title: Text('Progress tracking', style: context.text.titleMedium),
            subtitle: Text('Turn on to see the Progress dashboard.', style: context.text.bodySmall),
          ),
        ),
        if (prefs.progressTrackingEnabled) ...[
          const SectionHeader('Metrics'),
          for (final m in TrackedMetric.values)
            ClayOptionTile(
              label: m.label,
              multi: true,
              selected: prefs.trackedMetrics.contains(m),
              onTap: () => controller.toggleMetric(m).catchError(onError),
            ),
          const SizedBox(height: Gap.sm),
          Text(
            'Turning a metric off hides it; existing entries stay until you delete them in Privacy & data.',
            style: context.text.bodySmall,
          ),
        ],
      ],
    );
  }
}
