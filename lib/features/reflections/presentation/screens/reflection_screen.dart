import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/reflection.dart';
import '../../domain/reflection_catalog.dart';
import '../../domain/reflection_rules.dart';
import '../controllers/reflection_controllers.dart';
import '../widgets/outcome_view.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key, required this.reflectionId});
  final String reflectionId;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final reflection = ReflectionCatalog.byId(widget.reflectionId);
    if (reflection == null) {
      return const ClayPage(
        title: 'Reflection',
        children: [
          EmptyState(icon: Icons.search_off_rounded, title: 'Not found', message: 'This reflection is unavailable.'),
        ],
      );
    }
    if (!_started) return _Intro(reflection: reflection, onStart: () => setState(() => _started = true));

    final provider = reflectionFlowProvider(widget.reflectionId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    // Back steps through questions; from the summary it leaves the flow.
    return PopScope(
      canPop: state.isComplete,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!controller.back()) setState(() => _started = false);
      },
      child: state.isComplete
          ? _Result(state: state, controller: controller)
          : _Question(state: state, controller: controller),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.reflection, required this.onStart});
  final Reflection reflection;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tone = context.clay.tone(reflection.tone);
    return ClayPage(
      title: reflection.title,
      subtitle: reflection.subtitle,
      children: [
        ClaySurface(
          color: tone.fill,
          depth: 1.3,
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClayIconBadge(icon: reflection.icon, tone: reflection.tone, size: 56),
              const SizedBox(height: Gap.lg),
              Text(reflection.intro, style: context.text.bodyLarge!.copyWith(color: tone.onFill)),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        const _PrivacyPoint(icon: Icons.phone_iphone_rounded, text: 'Answers stay on this device.'),
        const _PrivacyPoint(icon: Icons.save_outlined, text: 'Nothing is saved unless you tap "Save" at the end.'),
        const _PrivacyPoint(icon: Icons.skip_next_rounded, text: 'You can go back, skip or stop at any time.'),
        const _PrivacyPoint(
          icon: Icons.medical_information_outlined,
          text: 'The summary is educational and never a diagnosis.',
        ),
        const SizedBox(height: Gap.xl),
        ClayButton(label: 'Begin', icon: Icons.arrow_forward_rounded, onPressed: onStart),
      ],
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.md),
    child: Row(
      children: [
        Icon(icon, color: context.clay.accent, size: 22),
        const SizedBox(width: Gap.md),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _Question extends StatelessWidget {
  const _Question({required this.state, required this.controller});
  final ReflectionFlowState state;
  final ReflectionFlowController controller;

  @override
  Widget build(BuildContext context) {
    final q = state.question;
    final total = state.reflection.questions.length;
    return ClayPage(
      title: q.prompt,
      subtitle: q.helper,
      bottom: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, Gap.md),
          child: Row(
            children: [
              Expanded(
                child: ClayButton(label: 'Skip', variant: ClayButtonVariant.quiet, onPressed: controller.skip),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                flex: 2,
                child: ClayButton(
                  label: state.isLast ? 'See summary' : 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: state.canContinue ? controller.next : null,
                ),
              ),
            ],
          ),
        ),
      ),
      children: [
        Semantics(
          label: 'Question ${state.index + 1} of $total',
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 10,
                    backgroundColor: context.clay.surfaceSunken,
                  ),
                ),
              ),
              const SizedBox(width: Gap.md),
              Text('${state.index + 1}/$total', style: context.text.labelMedium),
            ],
          ),
        ),
        const SizedBox(height: Gap.xl),
        for (final o in q.options)
          ClayOptionTile(
            label: o.label,
            multi: q.type == QuestionType.multi,
            selected: state.currentSelection.contains(o.id),
            onTap: () => controller.toggle(o.id),
          ),
      ],
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.state, required this.controller});
  final ReflectionFlowState state;
  final ReflectionFlowController controller;

  Future<void> _save(BuildContext context) async {
    try {
      await controller.save();
      if (context.mounted) showClaySnack(context, 'Saved privately on this device');
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = state.savedSessionId != null;
    return ClayPage(
      title: 'Your summary',
      subtitle: state.reflection.title,
      children: [
        OutcomeView(outcome: state.outcome!),
        const SizedBox(height: Gap.xl),
        ClayButton(
          label: saved ? 'Saved to your private history' : 'Save to my private history',
          icon: saved ? Icons.check_rounded : Icons.lock_outline_rounded,
          loading: state.saving,
          onPressed: saved ? null : () => _save(context),
        ),
        const SizedBox(height: Gap.md),
        Text(
          saved
              ? 'You can delete it any time from My Health → Saved reflections.'
              : 'Optional. Saved reflections are encrypted on this device and never leave it.',
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Gap.md),
        ClayButton(label: 'Start again', variant: ClayButtonVariant.quiet, onPressed: controller.restart),
      ],
    );
  }
}

/// Saved reflections, with individual and bulk deletion.
class ReflectionHistoryScreen extends ConsumerWidget {
  const ReflectionHistoryScreen({super.key});

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete all saved reflections?',
      message: 'This permanently removes every saved reflection from this device.',
      confirmLabel: 'Delete all',
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(reflectionHistoryProvider.notifier).deleteAll();
      if (context.mounted) showClaySnack(context, 'All saved reflections deleted');
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(reflectionHistoryProvider);
    final format = DateFormat.yMMMd().add_jm();
    return ClayPage(
      title: 'Saved reflections',
      subtitle: 'Stored encrypted on this device only.',
      children: [
        if (sessions.isEmpty)
          const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No saved reflections',
            message: 'Reflections are only saved when you choose to at the end.',
          )
        else ...[
          for (final s in sessions) _SessionTile(session: s, subtitle: format.format(s.completedAt)),
          const SizedBox(height: Gap.lg),
          ClayButton(
            label: 'Delete all saved reflections',
            icon: Icons.delete_outline_rounded,
            variant: ClayButtonVariant.danger,
            onPressed: () => _deleteAll(context, ref),
          ),
        ],
      ],
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session, required this.subtitle});
  final ReflectionSession session;
  final String subtitle;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete this reflection?',
      message: 'It will be permanently removed from this device.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(reflectionHistoryProvider.notifier).delete(session.id);
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflection = ReflectionCatalog.byId(session.reflectionId);
    if (reflection == null) return const SizedBox.shrink();
    return ClayListTile(
      title: reflection.title,
      subtitle: subtitle,
      icon: reflection.icon,
      tone: reflection.tone,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClayPage(
            title: reflection.title,
            subtitle: subtitle,
            children: [OutcomeView(outcome: const ReflectionRules().evaluate(reflection, session.answers))],
          ),
        ),
      ),
      trailing: IconButton(
        tooltip: 'Delete reflection',
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: () => _delete(context, ref),
      ),
    );
  }
}
