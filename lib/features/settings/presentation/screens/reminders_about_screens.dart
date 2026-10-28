import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_config.dart';
import '../../../../app/route_names.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../education/data/content/sources.dart';
import '../../../education/presentation/widgets/article_widgets.dart';
import '../../../habits/presentation/controllers/habit_controllers.dart';
import '../../../habits/presentation/widgets/habit_widgets.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../reminders/presentation/controllers/reminder_controller.dart';
import '../controllers/preferences_controller.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(wellnessReminderProvider);
    final discreet = ref.watch(preferencesProvider.select((p) => p.discreetNotifications));
    final habitReminders = ref.watch(habitsProvider).where((h) => h.reminder != null).toList();
    final controller = ref.read(wellnessReminderProvider.notifier);
    void onError(Object e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }

    final (title, body) = ReminderWording.wellness(discreet: discreet);

    return ClayPage(
      title: 'Reminders',
      subtitle: 'Optional, gentle, and never guilt-driven. Notification permission is asked only when you turn one on.',
      children: [
        ClaySurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: reminder.enabled,
                onChanged: (v) => controller.setEnabled(v).catchError(onError),
                title: Text('Daily wellness reminder', style: context.text.titleMedium),
                subtitle: Text('A nudge for your check-in or routine.', style: context.text.bodySmall),
              ),
              if (reminder.enabled) ...[
                const SizedBox(height: Gap.sm),
                ClayListTile(
                  title: 'Time',
                  subtitle: reminder.time.format(context),
                  icon: Icons.schedule_rounded,
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: reminder.time);
                    if (t != null) await controller.setTime(t).catchError(onError);
                  },
                ),
                WeekdayPicker(
                  selected: reminder.weekdays,
                  onToggle: (d) {
                    try {
                      controller.toggleDay(d).catchError(onError);
                    } on AppException catch (e) {
                      onError(e);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        const SectionHeader('Preview'),
        ClaySurface(
          sunken: true,
          depth: 0.3,
          child: Row(
            children: [
              ClayIconBadge(icon: Icons.notifications_rounded, tone: ClayTone.slate, size: 40),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    Text(body, style: context.text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        TextButton(
          onPressed: () => context.push(Routes.privacy),
          child: Text(discreet ? 'Wording: discreet (change in Privacy)' : 'Wording: descriptive (change in Privacy)'),
        ),
        const SectionHeader('Habit reminders'),
        if (habitReminders.isEmpty)
          Text('Add a reminder time when creating or editing a habit.', style: context.text.bodySmall)
        else
          for (final h in habitReminders) HabitCard(habit: h),
        const SizedBox(height: Gap.lg),
        Text(
          'Reminders depend on your device allowing notifications. If they don\'t appear, check notification settings for this app.',
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.standard;
    return ClayPage(
      title: 'About ${config.appName}',
      subtitle: config.tagline,
      children: [
        const SafetyPanel(
          level: SafetyLevel.caution,
          title: 'Educational, not medical advice',
          body: AppConfig.disclaimer,
        ),
        const SectionHeader('How content is made'),
        ClaySurface(
          child: const BulletList([
            'Articles are written from public guidance by health bodies and clinical societies (NHS, NIDDK, AUA, EAU, ISSM, SMSNA, FDA).',
            'Each article separates what the evidence supports from what remains uncertain.',
            'Every article shows its sources, a written date and a next-review date.',
            'Articles are labelled "Awaiting clinical review" until a qualified clinician has signed them off.',
            'Recommendations are rule-based and transparent. Nothing is inferred from your browsing.',
          ]),
        ),
        const SectionHeader('Source register'),
        const SourceList(sources: Src.all),
        const SectionHeader('Privacy policy'),
        Text(
          'A full privacy policy must be published before public release. This build stores data only on your device and sends nothing to any server.',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Gap.lg),
        Text('Typeface: Nunito, SIL Open Font License 1.1.', style: context.text.bodySmall),
        Text('Version 1.0.0', style: context.text.bodySmall),
      ],
    );
  }
}
