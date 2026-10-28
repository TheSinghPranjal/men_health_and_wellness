import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../../education/presentation/widgets/article_widgets.dart';
import '../../../education/presentation/widgets/topic_layout.dart';
import '../../../home/presentation/home_art.dart';
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
    final clay = context.clay;
    final labelStyle = context.text.titleMedium!.weight(800);
    return HeroHeaderPage(
      title: editing ? 'Edit habit' : 'New habit',
      subtitle: 'Build small habits for a healthier, stronger you.',
      art: const GoalArt(),
      children: [
        if (!editing) ...[
          Text('Start from an idea', style: labelStyle),
          const SizedBox(height: Gap.md),
          ClayGrid(
            minTileHeight: 0,
            children: [
              for (final t in HabitTemplate.all)
                _TemplateTile(template: t, selected: _title.text == t.title, onTap: () => _applyTemplate(t)),
            ],
          ),
          const SizedBox(height: Gap.xl),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Title', style: labelStyle),
              const SizedBox(height: Gap.sm),
              TextFormField(
                controller: _title,
                maxLength: Habit.maxTitle,
                validator: HabitValidator.title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Brisk walk',
                  prefixIcon: Icon(Icons.edit_outlined, color: clay.textSecondary),
                ),
              ),
              const SizedBox(height: Gap.md),
              Text('Description (optional)', style: labelStyle),
              const SizedBox(height: Gap.sm),
              TextFormField(
                controller: _description,
                maxLength: Habit.maxDescription,
                validator: HabitValidator.description,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Add more details about your habit…',
                  prefixIcon: Icon(Icons.description_outlined, color: clay.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        Text('Which days?', style: labelStyle),
        const SizedBox(height: Gap.xs),
        Text('Select the days you want to follow this habit.', style: context.text.bodySmall),
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
          tone: ClayTone.lavender,
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
          tone: ClayTone.blue,
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
        _PrimaryActionButton(label: editing ? 'Save changes' : 'Create habit', loading: _saving, onPressed: _save),
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

/// Tinted tile for a habit idea; selected when the form holds its title.
class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.selected, required this.onTap});
  final HabitTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final clay = context.clay;
    final pair = clay.tone(template.tone);
    return ClaySurface(
      color: Color.lerp(pair.fill, clay.surface, selected ? 0.15 : 0.55),
      selected: selected,
      depth: selected ? 0.9 : 0.6,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
      onTap: onTap,
      semanticLabel: '${template.title}. ${template.benefit}${selected ? ', selected' : ''}',
      child: Row(
        children: [
          TopicBadge(icon: template.icon, tone: template.tone, size: 38, round: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.title, style: context.text.titleSmall!.weight(800)),
                Text(template.benefit, style: context.text.bodySmall),
              ],
            ),
          ),
          if (selected) Icon(Icons.check_circle_rounded, color: clay.accent, size: 22),
        ],
      ),
    );
  }
}

/// Full-width deep teal call to action with a trailing arrow.
class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.loading, required this.onPressed});
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  static const _teal = Color(0xFF1E6E66);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: ClaySurface(
        color: _teal,
        radius: 24,
        depth: 1,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        onTap: loading ? null : onPressed,
        semanticLabel: label,
        child: Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.titleMedium!.copyWith(color: Colors.white).weight(800),
              ),
            ),
            SizedBox.square(
              dimension: 24,
              child: loading
                  ? const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)
                  : const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
