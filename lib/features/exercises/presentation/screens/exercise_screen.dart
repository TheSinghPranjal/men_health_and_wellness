import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../../shared/models/enums.dart';
import '../../../daily_log/presentation/controllers/daily_log_controller.dart';
import '../../../settings/presentation/controllers/preferences_controller.dart';
import '../../domain/exercise.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  bool _finished = false;

  Future<void> _complete() async {
    setState(() => _finished = true);
    final prefs = ref.read(preferencesProvider);
    if (!prefs.tracks(TrackedMetric.stressSessions)) {
      showClaySnack(context, 'Nicely done.');
      return;
    }
    try {
      await ref.read(dailyLogProvider.notifier).addRelaxationSession();
      if (mounted) showClaySnack(context, 'Nicely done. Session logged.');
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Exercises.byId(widget.exerciseId);
    if (exercise == null) {
      return const ClayPage(
        title: 'Exercise',
        children: [
          EmptyState(icon: Icons.search_off_rounded, title: 'Not found', message: 'This exercise is unavailable.'),
        ],
      );
    }
    return ClayPage(
      title: exercise.title,
      subtitle: '${exercise.summary} About ${exercise.minutes} minutes.',
      children: [
        if (exercise.kind == ExerciseKind.pacedBreathing)
          _BreathingPacer(exercise: exercise, onComplete: _complete)
        else
          _StepGuide(exercise: exercise, onComplete: _complete),
        const SizedBox(height: Gap.xl),
        if (_finished)
          const SafetyPanel(
            title: 'Well done',
            body:
                'Regular short practice tends to help more than occasional long sessions. Relaxation supports wellbeing but does not treat every cause of sexual difficulties.',
          ),
        Text(
          'Stop if you feel dizzy or uncomfortable. Breathing should feel easy and natural.',
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

class _BreathingPacer extends StatefulWidget {
  const _BreathingPacer({required this.exercise, required this.onComplete});
  final Exercise exercise;
  final VoidCallback onComplete;

  @override
  State<_BreathingPacer> createState() => _BreathingPacerState();
}

class _BreathingPacerState extends State<_BreathingPacer> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Timer? _ticker;
  int _elapsed = 0;
  bool _running = false;

  int get _cycle => widget.exercise.inhaleSeconds + widget.exercise.exhaleSeconds;
  int get _total => widget.exercise.minutes * 60;
  bool get _inhaling => (_elapsed % _cycle) < widget.exercise.inhaleSeconds;
  int get _phaseRemaining =>
      _inhaling ? widget.exercise.inhaleSeconds - (_elapsed % _cycle) : _cycle - (_elapsed % _cycle);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.exercise.inhaleSeconds),
    );
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      _anim.stop();
      setState(() => _running = false);
      return;
    }
    if (_elapsed >= _total) _elapsed = 0;
    setState(() => _running = true);
    _animatePhase();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final wasInhaling = _inhaling;
      setState(() => _elapsed++);
      if (_elapsed >= _total) {
        _ticker?.cancel();
        _anim.stop();
        setState(() => _running = false);
        HapticFeedback.mediumImpact();
        widget.onComplete();
        return;
      }
      if (wasInhaling != _inhaling) {
        HapticFeedback.lightImpact();
        _animatePhase();
      }
    });
  }

  void _animatePhase() {
    if (_inhaling) {
      _anim.duration = Duration(seconds: widget.exercise.inhaleSeconds);
      _anim.forward(from: 0);
    } else {
      _anim.duration = Duration(seconds: widget.exercise.exhaleSeconds);
      _anim.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final remaining = _total - _elapsed;
    final label = !_running && _elapsed == 0 ? 'Ready' : (_inhaling ? 'Breathe in' : 'Breathe out');
    return Column(
      children: [
        const SizedBox(height: Gap.lg),
        SizedBox.square(
          dimension: 260,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final scale = reduceMotion ? 1.0 : 0.62 + 0.38 * Curves.easeInOut.transform(_anim.value);
              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox.square(
                    dimension: 240,
                    child: ClaySurface(
                      color: clay.tone(ClayTone.teal).fill,
                      radius: 120,
                      depth: 1.5,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Semantics(
                          liveRegion: true,
                          label: _running ? '$label, $_phaseRemaining' : label,
                          child: ExcludeSemantics(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: context.text.titleLarge!.copyWith(color: clay.tone(ClayTone.teal).onFill),
                                ),
                                if (_running)
                                  Text(
                                    '$_phaseRemaining',
                                    style: context.text.displaySmall!.copyWith(color: clay.tone(ClayTone.teal).onFill),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Gap.lg),
        Text(
          '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')} remaining',
          style: context.text.titleMedium,
        ),
        const SizedBox(height: Gap.sm),
        Text(
          'In through your nose for ${widget.exercise.inhaleSeconds}, out through your mouth for ${widget.exercise.exhaleSeconds}.',
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Gap.xl),
        ClayButton(
          label: _running ? 'Pause' : (_elapsed == 0 ? 'Start' : 'Resume'),
          icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onPressed: _toggle,
        ),
      ],
    );
  }
}

class _StepGuide extends StatefulWidget {
  const _StepGuide({required this.exercise, required this.onComplete});
  final Exercise exercise;
  final VoidCallback onComplete;

  @override
  State<_StepGuide> createState() => _StepGuideState();
}

class _StepGuideState extends State<_StepGuide> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final steps = widget.exercise.steps;
    final last = _step == steps.length - 1;
    final tone = context.clay.tone(widget.exercise.tone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Step ${_step + 1} of ${steps.length}', style: context.text.labelMedium),
        const SizedBox(height: Gap.md),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 180),
          child: ClaySurface(
            color: tone.fill,
            depth: 1.3,
            padding: const EdgeInsets.all(Gap.xl),
            child: Semantics(
              liveRegion: true,
              child: Text(steps[_step], style: context.text.titleLarge!.copyWith(color: tone.onFill, height: 1.4)),
            ),
          ),
        ),
        const SizedBox(height: Gap.xl),
        Row(
          children: [
            Expanded(
              child: ClayButton(
                label: 'Back',
                variant: ClayButtonVariant.quiet,
                onPressed: _step == 0 ? null : () => setState(() => _step--),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              flex: 2,
              child: ClayButton(
                label: last ? 'Finish' : 'Next',
                icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onPressed: () {
                  if (last) {
                    widget.onComplete();
                  } else {
                    setState(() => _step++);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
