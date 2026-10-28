import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../shared/models/enums.dart';
import '../../../education/presentation/widgets/topic_layout.dart';
import '../../../home/presentation/home_art.dart';
import '../controllers/preferences_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    return HeroHeaderPage(
      title: 'Profile',
      subtitle: 'No account needed. Everything stays on this device.',
      art: const _ProfileArt(),
      children: [
        const _PrivacyHero(),
        const SizedBox(height: Gap.md),
        const _PrivacyPoints(),
        const SectionHeader('Appearance'),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final m in AppThemeMode.values) ...[
                Expanded(
                  child: _ThemeTile(
                    mode: m,
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
        ),
        const SectionHeader('Personalisation'),
        ClayListTile(
          title: 'Goals & preferences',
          subtitle: prefs.goals.isEmpty ? 'None selected' : '${prefs.goals.length} goals selected',
          icon: Icons.track_changes_rounded,
          tone: ClayTone.teal,
          tinted: true,
          onTap: () => context.push(Routes.goals),
        ),
        ClayListTile(
          title: 'What to track',
          subtitle: prefs.progressTrackingEnabled ? '${prefs.trackedMetrics.length} metrics' : 'Tracking off',
          icon: Icons.bar_chart_rounded,
          tone: ClayTone.blue,
          tinted: true,
          onTap: () => context.push(Routes.tracking),
        ),
        if (AppConfig.standard.enableReminders)
          ClayListTile(
            title: 'Reminders',
            subtitle: 'Optional and discreet',
            icon: Icons.notifications_none_rounded,
            tone: ClayTone.lavender,
            tinted: true,
            onTap: () => context.push(Routes.reminders),
          ),
        const SectionHeader('Privacy & safety'),
        ClayListTile(
          title: 'Privacy & data',
          subtitle: prefs.appLockEnabled ? 'App lock on' : 'App lock, export and deletion',
          icon: Icons.shield_rounded,
          tone: ClayTone.teal,
          tinted: true,
          onTap: () => context.push(Routes.privacy),
        ),
        ClayListTile(
          title: 'Urgent help',
          subtitle: 'Emergency warning signs and resources',
          icon: Icons.emergency_rounded,
          tone: ClayTone.rose,
          tinted: true,
          onTap: () => context.push(Routes.emergency),
        ),
        ClayListTile(
          title: 'About & sources',
          subtitle: 'How content is written and reviewed',
          icon: Icons.info_outline_rounded,
          tone: ClayTone.blue,
          tinted: true,
          onTap: () => context.push(Routes.about),
        ),
        const SizedBox(height: Gap.lg),
        Text(AppConfig.disclaimer, style: context.text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Sunrise landscape with an avatar disc. Decorative.
class _ProfileArt extends StatelessWidget {
  const _ProfileArt();

  @override
  Widget build(BuildContext context) {
    final teal = ClayTheme.light.tone(ClayTone.teal);
    return FittedBox(
      child: SizedBox.square(
        dimension: 200,
        child: Stack(
          children: [
            const Positioned(top: 0, right: 0, child: SunriseArt(width: 200)),
            Positioned(
              right: 22,
              top: 18,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFF2FBFA), teal.fill],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: teal.onFill.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: Color(0xFF1C8BA8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  // Fixed in both themes: the privacy card is always deep teal.
  static const _deep = Color(0xFF0F3B4C);
  static const _teal = Color(0xFF155866);
  static const _ink = Color(0xFFF4F7F6);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(ClayTheme.radiusMd);
    return ClaySurface(
      color: _deep,
      depth: 1.3,
      padding: EdgeInsets.zero,
      semanticLabel:
          'Private by design. All your data is stored on this device only. No ads, no tracking, no data leaves your phone.',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(colors: [_deep, _teal]),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Gap.xl - 4),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3FA39B), Color(0xFF1E6E6A)],
                    ),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: Gap.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Private by design', style: context.text.titleMedium!.copyWith(color: _ink).weight(800)),
                      const SizedBox(height: Gap.xs),
                      Text(
                        'All your data is stored on this device only. No ads, no tracking, no data leaves your phone.',
                        style: context.text.bodySmall!.copyWith(color: _ink.withValues(alpha: 0.82), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyPoints extends StatelessWidget {
  const _PrivacyPoints();

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: Gap.lg,
      runSpacing: Gap.sm,
      children: [
        for (final (icon, label) in const [
          (Icons.visibility_off_rounded, 'No ads'),
          (Icons.lock_rounded, 'No tracking'),
          (Icons.phonelink_lock_rounded, 'On-device storage'),
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: clay.textPrimary),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: context.text.labelLarge!.weight(700))),
            ],
          ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.mode, required this.selected, required this.onTap});
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  static const _night = Color(0xFF1F2A44);

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final (icon, detail) = switch (mode) {
      AppThemeMode.system => (Icons.desktop_windows_rounded, 'Follow device settings'),
      AppThemeMode.light => (Icons.light_mode_rounded, 'Clean and bright'),
      AppThemeMode.dark => (Icons.dark_mode_rounded, 'Easy on your eyes'),
    };
    // Each tile previews its own look; selection is shown by border + check.
    final (fill, fg, badge) = switch (mode) {
      AppThemeMode.dark => (_night, const Color(0xFFEDEFF5), const Color(0xFF34405C)),
      AppThemeMode.light => (const Color(0xFFFFFFFF), const Color(0xFF1B2438), const Color(0xFFE6F0FB)),
      AppThemeMode.system => (
        Color.lerp(clay.tone(ClayTone.teal).fill, clay.surface, selected ? 0.1 : 0.5)!,
        clay.textPrimary,
        clay.surface,
      ),
    };
    final iconColor = switch (mode) {
      AppThemeMode.dark => const Color(0xFFF7F4EF),
      AppThemeMode.light => const Color(0xFF1E88E5),
      AppThemeMode.system => clay.tone(ClayTone.teal).onFill,
    };
    return ClaySurface(
      color: fill,
      selected: selected,
      depth: selected ? 0.9 : 0.6,
      padding: const EdgeInsets.all(Gap.md),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      semanticLabel: '${mode.label} theme. $detail${selected ? ', selected' : ''}',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: Gap.sm),
              Text(mode.label, style: context.text.titleSmall!.copyWith(color: fg).weight(800)),
              Text(detail, style: context.text.bodySmall!.copyWith(color: fg.withValues(alpha: 0.75))),
            ],
          ),
          if (selected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: clay.accent, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 16, color: clay.onAccent),
              ),
            ),
        ],
      ),
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
