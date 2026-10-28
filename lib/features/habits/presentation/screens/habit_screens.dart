import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/habit.dart';
import '../controllers/habit_controllers.dart';
import '../widgets/habit_widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final active = habits.where((h) => h.active).toList();
    final paused = habits.where((h) => !h.active).toList();
    return ClayPage(
      title: 'Habits',
      subtitle: 'Small routines that support your wellbeing. Missing a day is fine.',
      actions: [
        ClayIconButton(icon: Icons.add_rounded, tooltip: 'New habit', onPressed: () => context.push(Routes.habitNew)),
      ],
      children: [
        if (habits.isEmpty)
          EmptyState(
            icon: Icons.add_task_rounded,
            title: 'No habits yet',
            message: 'Start with one small, realistic routine.',
            action: 'Create a habit',
            onAction: () => context.push(Routes.habitNew),
          ),
        for (final h in active) HabitCard(habit: h),
        if (paused.isNotEmpty) ...[const SectionHeader('Paused'), for (final h in paused) HabitCard(habit: h)],
      ],
    );
  }
}

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, this.habitId});
  final String? habitId;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late Set<int> _weekdays;
  TimeOfDay? _reminder;
  late DateTime _startDate;
  bool _active = true;
  bool _saving = false;
  String? _daysError;
  Habit? _existing;

  @override
  void initState() {
    super.initState();
    _existing = widget.habitId == null
        ? null
        : ref.read(habitsProvider).where((h) => h.id == widget.habitId).firstOrNull;
    final h = _existing;
    _title = TextEditingController(text: h?.title ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _weekdays = {...(h?.weekdays ?? Habit.allDays)};
    _reminder = h?.reminder;
    _startDate = h?.startDate ?? Dates.dayOf(ref.read(clockProvider)());
    _active = h?.active ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _applyTemplate(HabitTemplate t) {
    setState(() {
      _title.text = t.title;
      _description.text = t.description;
      _weekdays = {...t.weekdays};
    });
  }

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  Future<void> _pickStart() async {
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _startDate = Dates.dayOf(picked));
  }

  Future<void> _save() async {
    if (_saving) return;
    final formOk = _formKey.currentState!.validate();
    setState(() => _daysError = HabitValidator.weekdays(_weekdays));
    if (!formOk || _daysError != null) return;
    setState(() => _saving = true);
    final habit = Habit(
      id: _existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      description: _description.text.trim(),
      weekdays: _weekdays,
      reminder: _reminder,
      startDate: _startDate,
      active: _active,
    );
    try {
      await ref.read(habitsProvider.notifier).save(habit);
      if (mounted) context.pop();
    } on PlatformFeatureException catch (e) {
      if (mounted) {
        showClaySnack(context, e.userMessage);
        context.pop();
      }
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete habit?',
      message: 'The habit and its history will be permanently deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(habitsProvider.notifier).delete(_existing!.id);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    return ClayPage(
      title: editing ? 'Edit habit' : 'New habit',
      children: [
        if (!editing) ...[
          Text('Start from an idea', style: context.text.titleMedium),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final t in HabitTemplate.all)
                ClayChoiceChip(
                  label: t.title,
                  icon: t.icon,
                  selected: _title.text == t.title,
                  onTap: () => _applyTemplate(t),
                ),
            ],
          ),
          const SizedBox(height: Gap.xl),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                maxLength: Habit.maxTitle,
                validator: HabitValidator.title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: Gap.sm),
              TextFormField(
                controller: _description,
                maxLength: Habit.maxDescription,
                validator: HabitValidator.description,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        Text('Which days?', style: context.text.titleMedium),
        const SizedBox(height: Gap.md),
        WeekdayPicker(
          selected: _weekdays,
          onToggle: (d) => setState(() {
            _weekdays.contains(d) ? _weekdays.remove(d) : _weekdays.add(d);
            _daysError = null;
          }),
        ),
        if (_daysError != null) ...[
          const SizedBox(height: Gap.sm),
          Text(_daysError!, style: context.text.bodySmall!.copyWith(color: context.clay.critical)),
        ],
        const SizedBox(height: Gap.xl),
        ClayListTile(
          title: 'Reminder',
          subtitle: _reminder == null ? 'Off' : 'At ${_reminder!.format(context)} · discreet wording',
          icon: Icons.notifications_none_rounded,
          onTap: _pickReminder,
          trailing: _reminder == null
              ? null
              : IconButton(
                  tooltip: 'Remove reminder',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(() => _reminder = null),
                ),
        ),
        ClayListTile(
          title: 'Start date',
          subtitle: DateFormat.yMMMd().format(_startDate),
          icon: Icons.event_rounded,
          onTap: _pickStart,
        ),
        ClaySurface(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: Text('Active', style: context.text.titleMedium),
            subtitle: Text('Pause any time without losing history.', style: context.text.bodySmall),
          ),
        ),
        const SizedBox(height: Gap.xl),
        ClayButton(
          label: editing ? 'Save changes' : 'Create habit',
          icon: Icons.check_rounded,
          loading: _saving,
          onPressed: _save,
        ),
        if (editing) ...[
          const SizedBox(height: Gap.md),
          ClayButton(
            label: 'Delete habit',
            variant: ClayButtonVariant.quiet,
            icon: Icons.delete_outline_rounded,
            onPressed: _delete,
          ),
        ],
      ],
    );
  }
}
