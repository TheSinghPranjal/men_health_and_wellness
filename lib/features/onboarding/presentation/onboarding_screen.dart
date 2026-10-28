import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_config.dart';
import '../../../app/route_names.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/clay_tokens.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/clay_buttons.dart';
import '../../../core/widgets/clay_components.dart';
import '../../../core/widgets/clay_surface.dart';
import '../../../shared/models/enums.dart';
import '../../privacy_lock/data/device_authenticator.dart';
import '../../reminders/presentation/controllers/reminder_controller.dart';
import '../../settings/domain/user_preferences.dart';
import '../../settings/presentation/controllers/preferences_controller.dart';
import '../../settings/presentation/screens/profile_screen.dart';

enum _Step { welcome, adult, goals, personalise, privacy }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.welcome;
  bool _underage = false;
  bool _wantsReminders = false;
  bool _finishing = false;
  UserPreferences _draft = const UserPreferences();

  void _go(_Step s) => setState(() => _step = s);

  void _back() {
    if (_underage) return setState(() => _underage = false);
    if (_step.index > 0) _go(_Step.values[_step.index - 1]);
  }

  Future<void> _toggleLock(bool enable) async {
    if (enable) {
      final auth = ref.read(deviceAuthenticatorProvider);
      if (!await auth.isAvailable()) {
        if (mounted) showClaySnack(context, 'Set up a device passcode or biometrics first. You can enable this later.');
        return;
      }
      if (!await auth.authenticate('Confirm to turn on app lock')) return;
    }
    setState(() => _draft = _draft.copyWith(appLockEnabled: enable));
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await ref
          .read(preferencesProvider.notifier)
          .update((_) => _draft.copyWith(onboardingComplete: true, adultConfirmed: true));
      if (_wantsReminders) {
        try {
          await ref.read(wellnessReminderProvider.notifier).setEnabled(true);
        } catch (e) {
          if (mounted) showClaySnack(context, userMessageFor(e));
        }
      }
      if (mounted) context.go(Routes.home);
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _underage
        ? const _UnderageStep()
        : switch (_step) {
            _Step.welcome => _WelcomeStep(onNext: () => _go(_Step.adult)),
            _Step.adult => _AdultStep(
              onYes: () {
                setState(() => _draft = _draft.copyWith(adultConfirmed: true));
                _go(_Step.goals);
              },
              onNo: () => setState(() => _underage = true),
            ),
            _Step.goals => _GoalsStep(
              selected: _draft.goals,
              onToggle: (g) => setState(() {
                final goals = {..._draft.goals};
                goals.contains(g) ? goals.remove(g) : goals.add(g);
                _draft = _draft.copyWith(goals: goals);
              }),
              onNext: () => _go(_Step.personalise),
            ),
            _Step.personalise => _PersonaliseStep(
              draft: _draft,
              wantsReminders: _wantsReminders,
              onChanged: (d) => setState(() => _draft = d),
              onReminders: (v) => setState(() => _wantsReminders = v),
              onNext: () => _go(_Step.privacy),
            ),
            _Step.privacy => _PrivacyStep(
              lockEnabled: _draft.appLockEnabled,
              onToggleLock: _toggleLock,
              finishing: _finishing,
              onFinish: _finish,
            ),
          };

    return PopScope(
      canPop: _step == _Step.welcome && !_underage,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_step != _Step.welcome || _underage)
                          ClayIconButton(icon: Icons.arrow_back_rounded, tooltip: 'Back', onPressed: _back)
                        else
                          const SizedBox(height: 48),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.push(Routes.emergency),
                          icon: Icon(Icons.emergency_rounded, color: context.clay.critical, size: 18),
                          label: Text('Urgent help', style: TextStyle(color: context.clay.critical)),
                        ),
                      ],
                    ),
                    if (!_underage) ...[
                      const SizedBox(height: Gap.md),
                      Semantics(
                        label: 'Step ${_step.index + 1} of ${_Step.values.length}',
                        child: ExcludeSemantics(
                          child: Row(
                            children: [
                              for (final s in _Step.values)
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: s.index <= _step.index ? context.clay.accent : context.clay.surfaceSunken,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page, Gap.xxl),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox.square(
            dimension: 120,
            child: ClaySurface(
              radius: 42,
              depth: 1.5,
              color: clay.brand,
              padding: EdgeInsets.zero,
              child: Icon(Icons.favorite_rounded, color: clay.onBrand, size: 56),
            ),
          ),
        ),
        const SizedBox(height: Gap.xxl),
        Text('Welcome to ${AppConfig.standard.appName}', style: context.text.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: Gap.md),
        Text(
          'Understand your sexual health, build healthy routines, and know when professional guidance could help — privately.',
          style: context.text.bodyLarge!.copyWith(color: clay.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Gap.xl),
        for (final (icon, tone, text) in const [
          (Icons.menu_book_rounded, ClayTone.blue, 'Evidence-based guides with sources'),
          (Icons.psychology_rounded, ClayTone.lavender, 'Private reflections — never a diagnosis'),
          (Icons.task_alt_rounded, ClayTone.sage, 'Realistic habits without pressure'),
          (Icons.lock_rounded, ClayTone.teal, 'Encrypted on your device, no account'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.md),
            child: Row(
              children: [
                ClayIconBadge(icon: icon, tone: tone, size: 44),
                const SizedBox(width: Gap.md),
                Expanded(child: Text(text, style: context.text.titleSmall)),
              ],
            ),
          ),
        const SizedBox(height: Gap.lg),
        const SafetyPanel(level: SafetyLevel.caution, title: 'Please note', body: AppConfig.disclaimer),
        ClayButton(label: 'Get started', icon: Icons.arrow_forward_rounded, onPressed: onNext),
      ],
    );
  }
}

class _AdultStep extends StatelessWidget {
  const _AdultStep({required this.onYes, required this.onNo});
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Are you 18 or older?', style: context.text.headlineMedium),
        const SizedBox(height: Gap.md),
        Text('This app discusses adult sexual health and is intended for adults only.', style: context.text.bodyLarge),
        const SizedBox(height: Gap.xxl),
        ClayButton(label: 'Yes, I am 18 or older', onPressed: onYes),
        const SizedBox(height: Gap.md),
        ClayButton(label: 'No, I am under 18', variant: ClayButtonVariant.secondary, onPressed: onNo),
      ],
    );
  }
}

class _UnderageStep extends StatelessWidget {
  const _UnderageStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('This app is for adults', style: context.text.headlineMedium),
        const SizedBox(height: Gap.md),
        Text(
          'Thanks for being honest. If you have questions about your body or sexual health, a doctor, school nurse, or a trusted adult can help.',
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: Gap.xl),
        const SafetyPanel(
          level: SafetyLevel.urgent,
          title: 'If you need urgent help',
          body: 'Contact your local emergency number or a doctor straight away.',
        ),
      ],
    );
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({required this.selected, required this.onToggle, required this.onNext});
  final Set<WellnessGoal> selected;
  final ValueChanged<WellnessGoal> onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('What would you like help with?', style: context.text.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text('Choose any. This only shapes suggestions on this device.', style: context.text.bodyMedium),
        const SizedBox(height: Gap.xl),
        GoalPicker(selected: selected, onToggle: onToggle),
        const SizedBox(height: Gap.lg),
        ClayButton(
          label: selected.isEmpty ? 'Skip for now' : 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _PersonaliseStep extends StatelessWidget {
  const _PersonaliseStep({
    required this.draft,
    required this.wantsReminders,
    required this.onChanged,
    required this.onReminders,
    required this.onNext,
  });

  final UserPreferences draft;
  final bool wantsReminders;
  final ValueChanged<UserPreferences> onChanged;
  final ValueChanged<bool> onReminders;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Make it yours', style: context.text.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text(
          'All optional. Age range helps pick relevant articles; nothing here is shared. We never ask about orientation, relationships or medical history.',
          style: context.text.bodyMedium,
        ),
        const SectionHeader('Age range'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final a in AgeRange.values)
              ClayChoiceChip(
                label: a.label,
                selected: draft.ageRange == a,
                onTap: () => onChanged(draft.copyWith(ageRange: () => draft.ageRange == a ? null : a)),
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
                selected: draft.units == u,
                onTap: () => onChanged(draft.copyWith(units: u)),
              ),
          ],
        ),
        const SizedBox(height: Gap.xl),
        ClaySurface(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: draft.dailyRoutineEnabled,
                onChanged: (v) => onChanged(draft.copyWith(dailyRoutineEnabled: v)),
                title: Text('Daily wellness plan', style: context.text.titleMedium),
                subtitle: Text('A few small suggestions each day', style: context.text.bodySmall),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: draft.progressTrackingEnabled,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    progressTrackingEnabled: v,
                    trackedMetrics: v
                        ? {
                            TrackedMetric.wellnessActivities,
                            TrackedMetric.exercise,
                            TrackedMetric.sleep,
                            TrackedMetric.energy,
                          }
                        : {},
                  ),
                ),
                title: Text('Progress tracking', style: context.text.titleMedium),
                subtitle: Text('Habits, sleep, energy — you choose', style: context.text.bodySmall),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: wantsReminders,
                onChanged: onReminders,
                title: Text('A daily reminder', style: context.text.titleMedium),
                subtitle: Text(
                  'Discreet wording. We\'ll ask for permission when you finish.',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.xl),
        ClayButton(label: 'Continue', icon: Icons.arrow_forward_rounded, onPressed: onNext),
      ],
    );
  }
}

class _PrivacyStep extends StatelessWidget {
  const _PrivacyStep({
    required this.lockEnabled,
    required this.onToggleLock,
    required this.finishing,
    required this.onFinish,
  });
  final bool lockEnabled;
  final ValueChanged<bool> onToggleLock;
  final bool finishing;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your privacy', style: context.text.headlineMedium),
        const SizedBox(height: Gap.xl),
        ClaySurface(
          child: const _PrivacyList(
            items: [
              (Icons.phone_iphone_rounded, 'Everything stays on this device, encrypted.'),
              (Icons.cloud_off_rounded, 'Nothing is sent to a server. No cloud backup in this version.'),
              (Icons.notifications_off_outlined, 'Reminders use discreet wording by default.'),
              (Icons.delete_outline_rounded, 'Delete any or all of your data from Profile → Privacy.'),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        ClaySurface(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: lockEnabled,
            onChanged: onToggleLock,
            title: Text('App lock', style: context.text.titleMedium),
            subtitle: Text('Use biometrics or your device passcode to open the app.', style: context.text.bodySmall),
          ),
        ),
        const SizedBox(height: Gap.xl),
        ClayButton(label: 'Finish', icon: Icons.check_rounded, loading: finishing, onPressed: onFinish),
      ],
    );
  }
}

class _PrivacyList extends StatelessWidget {
  const _PrivacyList({required this.items});
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (icon, text) in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.sm),
          child: Row(
            children: [
              Icon(icon, color: context.clay.accent),
              const SizedBox(width: Gap.md),
              Expanded(child: Text(text, style: context.text.bodyMedium!.weight(600))),
            ],
          ),
        ),
    ],
  );
}
