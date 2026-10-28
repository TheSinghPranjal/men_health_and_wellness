import 'package:flutter/foundation.dart';

import '../../../core/utils/dates.dart';

/// One optional, subjective check-in per day. All ratings are 1–5 and
/// self-reported; none of them is a clinical measure.
@immutable
class DailyLog {
  const DailyLog({
    required this.day,
    this.energy,
    this.stress,
    this.sleepQuality,
    this.mood,
    this.desire,
    this.exerciseMinutes,
    this.relaxationSessions = 0,
    this.note,
  });

  static const maxNoteLength = 500;

  final DateTime day;
  final int? energy;
  final int? stress;
  final int? sleepQuality;
  final int? mood;
  final int? desire;
  final int? exerciseMinutes;
  final int relaxationSessions;
  final String? note;

  String get key => Dates.key(day);

  bool get hasRatings => energy != null || stress != null || sleepQuality != null || mood != null || desire != null;
  bool get isEmpty => !hasRatings && (exerciseMinutes ?? 0) == 0 && relaxationSessions == 0 && (note?.isEmpty ?? true);

  DailyLog copyWith({
    int? Function()? energy,
    int? Function()? stress,
    int? Function()? sleepQuality,
    int? Function()? mood,
    int? Function()? desire,
    int? Function()? exerciseMinutes,
    int? relaxationSessions,
    String? Function()? note,
  }) => DailyLog(
    day: day,
    energy: energy != null ? energy() : this.energy,
    stress: stress != null ? stress() : this.stress,
    sleepQuality: sleepQuality != null ? sleepQuality() : this.sleepQuality,
    mood: mood != null ? mood() : this.mood,
    desire: desire != null ? desire() : this.desire,
    exerciseMinutes: exerciseMinutes != null ? exerciseMinutes() : this.exerciseMinutes,
    relaxationSessions: relaxationSessions ?? this.relaxationSessions,
    note: note != null ? note() : this.note,
  );

  Map<String, dynamic> toJson() => {
    '_v': 1,
    'day': key,
    'energy': energy,
    'stress': stress,
    'sleepQuality': sleepQuality,
    'mood': mood,
    'desire': desire,
    'exerciseMinutes': exerciseMinutes,
    'relaxationSessions': relaxationSessions,
    'note': note,
  };

  static DailyLog? fromJson(Map<String, dynamic> json) {
    try {
      int? rating(String k) {
        final v = json[k];
        return v is int && v >= 1 && v <= 5 ? v : null;
      }

      return DailyLog(
        day: Dates.parseKey(json['day'] as String),
        energy: rating('energy'),
        stress: rating('stress'),
        sleepQuality: rating('sleepQuality'),
        mood: rating('mood'),
        desire: rating('desire'),
        exerciseMinutes: json['exerciseMinutes'] as int?,
        relaxationSessions: (json['relaxationSessions'] as int?) ?? 0,
        note: json['note'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Validation for check-in input. Returns an error message or null.
abstract final class DailyLogValidator {
  static String? exerciseMinutes(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = int.tryParse(raw.trim());
    if (v == null) return 'Enter a whole number of minutes';
    if (v < 0) return 'Minutes cannot be negative';
    if (v > 1440) return 'That is more minutes than there are in a day';
    return null;
  }

  static String? note(String? raw) {
    if (raw != null && raw.length > DailyLog.maxNoteLength) {
      return 'Keep notes under ${DailyLog.maxNoteLength} characters';
    }
    return null;
  }
}
