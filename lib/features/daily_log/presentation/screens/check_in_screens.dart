import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../shared/models/enums.dart';
import '../../../settings/presentation/controllers/preferences_controller.dart';
import '../../domain/daily_log.dart';
import '../controllers/daily_log_controller.dart';

/// Optional daily check-in. Shows only the fields the user chose to track
/// (all of them if tracking hasn't been configured yet).
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, this.day});
  final DateTime? day;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  late DailyLog _log;
  late final TextEditingController _minutes;
  late final TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _log = ref.read(dailyLogProvider.notifier).forDay(widget.day ?? ref.read(clockProvider)());
    _minutes = TextEditingController(text: _log.exerciseMinutes?.toString() ?? '');
    _note = TextEditingController(text: _log.note ?? '');
  }

  @override
  void dispose() {
    _minutes.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final minutes = int.tryParse(_minutes.text.trim());
    final note = _note.text.trim();
    try {
      await ref
          .read(dailyLogProvider.notifier)
          .save(_log.copyWith(exerciseMinutes: () => minutes, note: () => note.isEmpty ? null : note));
      if (mounted) {
        showClaySnack(context, 'Check-in saved');
        context.pop();
      }
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    bool show(TrackedMetric m) => prefs.trackedMetrics.isEmpty || prefs.trackedMetrics.contains(m);
    final isToday = DateUtils.isSameDay(_log.day, ref.read(clockProvider)());

    return ClayPage(
      title: isToday ? 'Today\'s check-in' : DateFormat.yMMMEd().format(_log.day),
      subtitle: 'All optional and self-rated. Skip anything you like.',
      children: [
        if (show(TrackedMetric.energy))
          ScaleSelector(
            label: 'Energy',
            value: _log.energy,
            lowLabel: 'Drained',
            highLabel: 'Energised',
            optional: true,
            onChanged: (v) => setState(() => _log = _log.copyWith(energy: () => v)),
          ),
        if (show(TrackedMetric.stress))
          ScaleSelector(
            label: 'Stress',
            value: _log.stress,
            lowLabel: 'Calm',
            highLabel: 'Very stressed',
            optional: true,
            onChanged: (v) => setState(() => _log = _log.copyWith(stress: () => v)),
          ),
        if (show(TrackedMetric.sleep))
          ScaleSelector(
            label: 'Sleep quality last night',
            value: _log.sleepQuality,
            lowLabel: 'Poor',
            highLabel: 'Great',
            optional: true,
            onChanged: (v) => setState(() => _log = _log.copyWith(sleepQuality: () => v)),
          ),
        ScaleSelector(
          label: 'Mood',
          value: _log.mood,
          lowLabel: 'Low',
          highLabel: 'Good',
          optional: true,
          onChanged: (v) => setState(() => _log = _log.copyWith(mood: () => v)),
        ),
        if (show(TrackedMetric.desire))
          ScaleSelector(
            label: 'Desire (private reflection)',
            value: _log.desire,
            lowLabel: 'Low',
            highLabel: 'High',
            optional: true,
            onChanged: (v) => setState(() => _log = _log.copyWith(desire: () => v)),
          ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (show(TrackedMetric.exercise))
                TextFormField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  validator: DailyLogValidator.exerciseMinutes,
                  decoration: const InputDecoration(labelText: 'Active minutes today (optional)', suffixText: 'min'),
                ),
              const SizedBox(height: Gap.lg),
              TextFormField(
                controller: _note,
                maxLength: DailyLog.maxNoteLength,
                validator: DailyLogValidator.note,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Private note (optional)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        const SafetyPanel(
          title: 'Ratings are personal',
          body:
              'These numbers are your own impressions, useful for spotting patterns. They are not clinical measurements.',
        ),
        ClayButton(label: 'Save check-in', icon: Icons.check_rounded, loading: _saving, onPressed: _save),
      ],
    );
  }
}

class CheckInHistoryScreen extends ConsumerWidget {
  const CheckInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(sortedDailyLogsProvider);
    final f = DateFormat.yMMMEd();
    return ClayPage(
      title: 'Check-in history',
      subtitle: 'Tap to edit. Swipe or use the bin to delete.',
      children: [
        if (logs.isEmpty)
          const EmptyState(
            icon: Icons.edit_note_rounded,
            title: 'No check-ins yet',
            message: 'Your entries will appear here.',
          ),
        for (final log in logs)
          Dismissible(
            key: ValueKey(log.key),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => showConfirmDialog(
              context,
              title: 'Delete this entry?',
              message: 'This check-in will be permanently deleted.',
              confirmLabel: 'Delete',
              destructive: true,
            ),
            onDismissed: (_) => ref.read(dailyLogProvider.notifier).delete(log.key).catchError((Object e) {
              if (context.mounted) showClaySnack(context, userMessageFor(e));
            }),
            background: const SizedBox.shrink(),
            child: ClayListTile(
              title: f.format(log.day),
              subtitle: _summary(log),
              icon: Icons.edit_note_rounded,
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CheckInScreen(day: log.day))),
              trailing: IconButton(
                tooltip: 'Delete entry',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Delete this entry?',
                    message: 'This check-in will be permanently deleted.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (!ok) return;
                  try {
                    await ref.read(dailyLogProvider.notifier).delete(log.key);
                  } catch (e) {
                    if (context.mounted) showClaySnack(context, userMessageFor(e));
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  String _summary(DailyLog l) => [
    if (l.energy != null) 'Energy ${l.energy}',
    if (l.stress != null) 'Stress ${l.stress}',
    if (l.sleepQuality != null) 'Sleep ${l.sleepQuality}',
    if (l.mood != null) 'Mood ${l.mood}',
    if ((l.exerciseMinutes ?? 0) > 0) '${l.exerciseMinutes} active min',
    if (l.relaxationSessions > 0) '${l.relaxationSessions} relaxation',
  ].join(' · ').ifEmpty('Note only');
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
