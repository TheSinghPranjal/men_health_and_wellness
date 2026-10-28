import 'package:flutter/foundation.dart';

@immutable
class PrepItem {
  const PrepItem(this.id, this.label);
  final String id;
  final String label;
}

@immutable
class PrepSection {
  const PrepSection({required this.id, required this.title, required this.items, this.notesHint});
  final String id;
  final String title;
  final List<PrepItem> items;
  final String? notesHint;
}

/// Content of the appointment checklist. The app helps you organise what to
/// say; it does not order or interpret tests.
abstract final class ClinicianPrepContent {
  static const sections = <PrepSection>[
    PrepSection(
      id: 'symptoms',
      title: 'Your concern',
      notesHint: 'e.g. started around March, happens most times, not when alone…',
      items: [
        PrepItem('onset', 'When it started, and whether it began suddenly or gradually'),
        PrepItem('frequency', 'How often it happens'),
        PrepItem('context', 'Whether it happens in all situations or only some'),
        PrepItem('impact', 'How it affects you and any partner'),
      ],
    ),
    PrepSection(
      id: 'medicines',
      title: 'Medicines & supplements',
      notesHint: 'List names (and doses if you know them)',
      items: [
        PrepItem('prescriptions', 'All prescription medicines, including any recent changes'),
        PrepItem('otc', 'Over-the-counter medicines'),
        PrepItem('supplements', 'Supplements, herbal or "enhancement" products'),
        PrepItem('substances', 'Alcohol, smoking, vaping or recreational drugs'),
      ],
    ),
    PrepSection(
      id: 'history',
      title: 'Health background',
      notesHint: 'Conditions, past surgery, family history…',
      items: [
        PrepItem('bp', 'Blood pressure history'),
        PrepItem('glucose', 'Diabetes or blood sugar results'),
        PrepItem('cholesterol', 'Cholesterol results'),
        PrepItem('heart', 'Heart conditions or chest pain on exertion'),
        PrepItem('sleepStress', 'Sleep, stress and mood'),
      ],
    ),
    PrepSection(
      id: 'goals',
      title: 'Your goals',
      notesHint: 'What would a good outcome look like for you?',
      items: [
        PrepItem('fertility', 'Whether you are hoping to have children (affects hormone treatment choices)'),
        PrepItem('preferences', 'Treatments you are open to, or would rather avoid'),
      ],
    ),
    PrepSection(
      id: 'questions',
      title: 'Questions you could ask',
      notesHint: 'Add your own questions',
      items: [
        PrepItem('causes', '"What might be contributing to this?"'),
        PrepItem(
          'tests',
          '"Are any tests appropriate for me, such as blood pressure, blood sugar, cholesterol or hormones?"',
        ),
        PrepItem('options', '"What are my treatment options, and their pros and cons?"'),
        PrepItem('meds', '"Could any of my current medicines be involved?"'),
        PrepItem('referral', '"Would a specialist or therapist be helpful?"'),
      ],
    ),
  ];
}

@immutable
class ClinicianPrepState {
  const ClinicianPrepState({this.checked = const {}, this.notes = const {}});
  final Set<String> checked;
  final Map<String, String> notes;

  ClinicianPrepState toggle(String itemKey) => ClinicianPrepState(
    checked: checked.contains(itemKey) ? ({...checked}..remove(itemKey)) : {...checked, itemKey},
    notes: notes,
  );

  ClinicianPrepState withNote(String sectionId, String text) =>
      ClinicianPrepState(checked: checked, notes: {...notes, sectionId: text});

  /// Plain-text summary for the user to share on their own terms.
  String toShareableText() {
    final buffer = StringBuffer('Appointment notes\n');
    for (final s in ClinicianPrepContent.sections) {
      buffer.writeln('\n${s.title}');
      for (final i in s.items) {
        if (checked.contains('${s.id}.${i.id}')) buffer.writeln('• ${i.label}');
      }
      final note = notes[s.id]?.trim();
      if (note != null && note.isNotEmpty) buffer.writeln('Notes: $note');
    }
    return buffer.toString().trim();
  }

  Map<String, dynamic> toJson() => {'_v': 1, 'checked': checked.toList(), 'notes': notes};

  factory ClinicianPrepState.fromJson(Map<String, dynamic> json) => ClinicianPrepState(
    checked: (json['checked'] as List?)?.whereType<String>().toSet() ?? const {},
    notes: (json['notes'] as Map?)?.map((k, v) => MapEntry(k as String, v as String)) ?? const {},
  );
}
