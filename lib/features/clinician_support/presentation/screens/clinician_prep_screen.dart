import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/clay_tokens.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/clay_buttons.dart';
import '../../../../core/widgets/clay_components.dart';
import '../../../../core/widgets/clay_surface.dart';
import '../../domain/clinician_prep.dart';
import '../controllers/clinician_prep_controller.dart';

class ClinicianPrepScreen extends ConsumerWidget {
  const ClinicianPrepScreen({super.key});

  Future<void> _copy(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Copy your notes?',
      message:
          'Your notes will be copied to the clipboard so you can paste them where you choose. Other apps may be able to read the clipboard.',
      confirmLabel: 'Copy',
    );
    if (!ok) return;
    await Clipboard.setData(ClipboardData(text: ref.read(clinicianPrepProvider).toShareableText()));
    if (context.mounted) showClaySnack(context, 'Copied to clipboard');
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Clear checklist?',
      message: 'All ticks and notes will be deleted from this device.',
      confirmLabel: 'Clear',
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(clinicianPrepProvider.notifier).clear();
    } catch (e) {
      if (context.mounted) showClaySnack(context, userMessageFor(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clinicianPrepProvider);
    return ClayPage(
      title: 'Appointment checklist',
      subtitle: 'Note what you want to cover. Everything stays encrypted on this device.',
      children: [
        const SafetyPanel(
          title: 'Clinicians discuss this every day',
          body: 'Sexual health concerns are a routine part of medical care. Being specific helps them help you.',
        ),
        for (final section in ClinicianPrepContent.sections) _SectionCard(section: section, state: state),
        const SizedBox(height: Gap.md),
        ClayButton(label: 'Copy notes to share', icon: Icons.copy_rounded, onPressed: () => _copy(context, ref)),
        const SizedBox(height: Gap.md),
        ClayButton(
          label: 'Clear checklist',
          variant: ClayButtonVariant.quiet,
          icon: Icons.delete_outline_rounded,
          onPressed: () => _clear(context, ref),
        ),
      ],
    );
  }
}

class _SectionCard extends ConsumerStatefulWidget {
  const _SectionCard({required this.section, required this.state});
  final PrepSection section;
  final ClinicianPrepState state;

  @override
  ConsumerState<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends ConsumerState<_SectionCard> {
  late final TextEditingController _notes = TextEditingController(text: widget.state.notes[widget.section.id] ?? '');
  Timer? _debounce;

  @override
  void didUpdateWidget(covariant _SectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stored = widget.state.notes[widget.section.id] ?? '';
    // Reflect external clears without fighting the user's typing.
    if (stored.isEmpty && _notes.text.isNotEmpty && _debounce?.isActive != true) _notes.clear();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _notes.dispose();
    super.dispose();
  }

  void _onNoteChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      ref.read(clinicianPrepProvider.notifier).setNote(widget.section.id, text).catchError((Object e) {
        if (mounted) showClaySnack(context, userMessageFor(e));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: ClaySurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.title, style: context.text.titleMedium!.weight(800)),
            const SizedBox(height: Gap.sm),
            for (final item in s.items)
              CheckboxListTile(
                value: widget.state.checked.contains('${s.id}.${item.id}'),
                onChanged: (_) =>
                    ref.read(clinicianPrepProvider.notifier).toggle('${s.id}.${item.id}').catchError((Object e) {
                      if (context.mounted) showClaySnack(context, userMessageFor(e));
                    }),
                title: Text(item.label, style: context.text.bodyMedium),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            const SizedBox(height: Gap.sm),
            TextField(
              controller: _notes,
              onChanged: _onNoteChanged,
              maxLines: 3,
              minLines: 1,
              maxLength: 600,
              decoration: InputDecoration(hintText: s.notesHint, labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
    );
  }
}
