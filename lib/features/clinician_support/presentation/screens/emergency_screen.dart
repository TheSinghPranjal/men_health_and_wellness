import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../education/presentation/widgets/article_widgets.dart';

/// Emergency guidance. Reachable from every tab, from onboarding and before
/// onboarding is completed; never gated by any flow.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const _signs = [
    'An erection lasting 4 hours or longer, especially if painful.',
    'Chest pain, fainting or severe breathlessness during sexual activity.',
    'Sudden, severe pain in the testicles.',
    'A serious injury to the genitals, including a sudden "snap" with pain, swelling or bruising.',
    'Swelling of the face or throat, or difficulty breathing (severe allergic reaction).',
    'Sudden loss of vision or hearing after taking an ED medicine.',
  ];

  Future<void> _openDialer(BuildContext context) async {
    final ok = await launchUrl(Uri(scheme: 'tel'));
    if (!ok && context.mounted) {
      showClaySnack(context, 'Could not open the phone app. Please dial your local emergency number.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    return ClayPage(
      title: 'Urgent help',
      subtitle: 'If any of these apply, get emergency care now. Do not wait.',
      children: [
        ClaySurface(
          color: clay.critical,
          depth: 1.3,
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emergency_rounded, color: clay.onCritical, size: 30),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      'Seek emergency care for',
                      style: context.text.titleLarge!.copyWith(color: clay.onCritical),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              for (final s in _signs)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gap.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.error_rounded, size: 18, color: clay.onCritical),
                      ),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(s, style: context.text.bodyLarge!.copyWith(color: clay.onCritical).weight(700)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        ClayButton(
          label: 'Open phone to call emergency services',
          icon: Icons.phone_rounded,
          variant: ClayButtonVariant.danger,
          onPressed: () => _openDialer(context),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          'Use your local emergency number — for example 911 (US and Canada), 999 (UK) or 112 (EU and many other countries).',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Gap.xl),
        const SafetyPanel(
          level: SafetyLevel.urgent,
          title: 'Chest pain during sex',
          body:
              'Stop sexual activity and call emergency services. If you have taken an ED medicine (such as sildenafil or tadalafil), tell the emergency team. Do not take nitrate medicine (such as GTN) unless a clinician urgently tells you to.',
        ),
        const SafetyPanel(
          level: SafetyLevel.caution,
          title: 'If you are struggling emotionally',
          body:
              'If you feel unable to cope or are thinking about harming yourself, contact your local emergency number or a doctor now, or reach out to someone you trust.',
        ),
        const SectionHeader('Not an emergency, but worth checking'),
        ClaySurface(
          child: const BulletList([
            'Persistent or recurrent erection difficulties.',
            'Painful sex, or a new or worsening curve of the penis.',
            'Blood in semen or urine.',
            'Persistent low desire with fatigue or low mood.',
            'Ongoing ejaculation difficulties or significant distress.',
          ]),
        ),
        const SizedBox(height: Gap.lg),
        ClayButton(
          label: 'Prepare for an appointment',
          icon: Icons.checklist_rounded,
          variant: ClayButtonVariant.secondary,
          onPressed: () => context.push(Routes.clinicianPrep),
        ),
      ],
    );
  }
}
