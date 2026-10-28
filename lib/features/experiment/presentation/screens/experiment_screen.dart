import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/experiment.dart';
import '../controllers/experiment_controller.dart';

class ExperimentScreen extends ConsumerWidget {
  const ExperimentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiments = ref.watch(experimentProvider);
    final active = experiments.where((e) => e.active).firstOrNull;
    final past = experiments.where((e) => !e.active).toList();
    return ClayPage(
      title: 'Personal experiment',
      subtitle: 'Your goal, your pace. No streaks, no scores, stop any time.',
      children: [
        if (active == null) const _StartForm() else _ActiveExperiment(experiment: active),
        if (past.isNotEmpty) ...[
          const SectionHeader('Past experiments'),
          for (final e in past) _PastTile(experiment: e),
        ],
        const SizedBox(height: Gap.lg),
        SafetyPanel(
          title: 'Support is available',
          body:
              'If a habit feels out of control or is causing significant distress, a psychologist or sex therapist can help without judgment.',
          action: 'Read: porn & expectations',
          onAction: () => context.push(Routes.article('porn-and-expectations')),
        ),
      ],
    );
  }
}

class _StartForm extends ConsumerStatefulWidget {
  const _StartForm();

  @override
  ConsumerState<_StartForm> createState() => _StartFormState();
}

class _StartFormState extends ConsumerState<_StartForm> {
  final _formKey = GlobalKey<FormState>();
  final _goal = TextEditingController();
  bool _busy = false;

  static const _examples = [
    'Take a two-week break from pornography and notice how I feel',
    'Only watch on weekends for a month',
    'Put my phone outside the bedroom at night',
  ];

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(experimentProvider.notifier).start(_goal.text);
      if (mounted) showClaySnack(context, 'Experiment started. Be curious, not critical.');
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClaySurface(
            color: context.clay.tone(ClayTone.slate).fill,
            depth: 1.2,
            padding: const EdgeInsets.all(Gap.xl),
            child: Text(
              'Some people find it useful to change a habit for a while and observe how they feel. This is optional, and what you notice is information — not proof of anything.',
              style: context.text.bodyLarge!.copyWith(color: context.clay.tone(ClayTone.slate).onFill),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text('What would you like to try?', style: context.text.titleMedium),
          const SizedBox(height: Gap.md),
          TextFormField(
            controller: _goal,
            maxLines: 3,
            minLines: 2,
            maxLength: Experiment.maxGoalLength,
            validator: Experiment.validateGoal,
            decoration: const InputDecoration(hintText: 'In your own words'),
          ),
          const SizedBox(height: Gap.sm),
          Text('Ideas', style: context.text.labelMedium),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final e in _examples)
                ClayChoiceChip(
                  label: e,
                  selected: false,
                  icon: Icons.lightbulb_outline_rounded,
                  onTap: () => _goal.text = e,
                ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          ClayButton(label: 'Start experiment', icon: Icons.science_outlined, loading: _busy, onPressed: _start),
        ],
      ),
    );
  }
}

class _ActiveExperiment extends ConsumerStatefulWidget {
  const _ActiveExperiment({required this.experiment});
  final Experiment experiment;

  @override
  ConsumerState<_ActiveExperiment> createState() => _ActiveExperimentState();
}

class _ActiveExperimentState extends ConsumerState<_ActiveExperiment> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(experimentProvider.notifier).addObservation(_note.text);
      _note.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  Future<void> _end() async {
    final ok = await showConfirmDialog(
      context,
      title: 'End this experiment?',
      message: 'Your observations are kept until you delete them. There is no right or wrong outcome.',
      confirmLabel: 'End experiment',
    );
    if (!ok) return;
    try {
      await ref.read(experimentProvider.notifier).end();
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.experiment;
    final now = ref.watch(clockProvider)();
    final day = Dates.dayOf(now).difference(Dates.dayOf(e.startedAt)).inDays + 1;
    final format = DateFormat.MMMd().add_jm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClaySurface(
          color: context.clay.tone(ClayTone.teal).fill,
          depth: 1.2,
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClayTag('Day $day', tone: ClayTone.teal, icon: Icons.calendar_today_rounded),
              const SizedBox(height: Gap.md),
              Text(e.goal, style: context.text.titleLarge!.copyWith(color: context.clay.tone(ClayTone.teal).onFill)),
            ],
          ),
        ),
        const SectionHeader('Add an observation'),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _note,
            maxLines: 3,
            minLines: 1,
            maxLength: Experiment.maxObservationLength,
            validator: Experiment.validateObservation,
            decoration: const InputDecoration(hintText: 'How are you feeling? Anything you noticed?'),
          ),
        ),
        ClayButton(
          label: 'Add observation',
          icon: Icons.add_rounded,
          variant: ClayButtonVariant.secondary,
          onPressed: _add,
        ),
        if (e.observations.isNotEmpty) ...[
          const SectionHeader('Your observations'),
          for (final o in e.observations)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: ClaySurface(
                sunken: true,
                depth: 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(format.format(o.at), style: context.text.labelMedium),
                    const SizedBox(height: Gap.xs),
                    Text(o.text, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: Gap.lg),
        ClayButton(label: 'End experiment', variant: ClayButtonVariant.quiet, onPressed: _end),
      ],
    );
  }
}

class _PastTile extends ConsumerWidget {
  const _PastTile({required this.experiment});
  final Experiment experiment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = DateFormat.yMMMd();
    return ClayListTile(
      title: experiment.goal,
      subtitle:
          '${f.format(experiment.startedAt)} – ${f.format(experiment.endedAt!)} · ${experiment.observations.length} observations',
      icon: Icons.science_outlined,
      trailing: IconButton(
        tooltip: 'Delete experiment',
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Delete experiment?',
            message: 'The goal and all observations will be permanently deleted.',
            confirmLabel: 'Delete',
            destructive: true,
          );
          if (!ok) return;
          try {
            await ref.read(experimentProvider.notifier).delete(experiment.id);
          } catch (e) {
            if (context.mounted) showClaySnack(context, userMessageFor(e));
          }
        },
      ),
    );
  }
}
