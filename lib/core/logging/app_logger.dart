import 'package:flutter/foundation.dart';

/// Minimal structured logger.
///
/// Rules: log event names and counts only — never answers, notes, search
/// text or other user content. Output is suppressed in release builds.
abstract final class AppLogger {
  static void info(String event, [Map<String, Object?> fields = const {}]) => _emit('INFO', event, fields);

  static void warn(String event, [Map<String, Object?> fields = const {}]) => _emit('WARN', event, fields);

  /// Records the error *type* only; messages may contain user data.
  static void error(String event, Object error, [StackTrace? stack]) {
    _emit('ERROR', event, {'type': error.runtimeType.toString()});
    if (kDebugMode && stack != null) debugPrintStack(stackTrace: stack, maxFrames: 8);
  }

  static void _emit(String level, String event, Map<String, Object?> fields) {
    if (!kDebugMode) return;
    final extra = fields.isEmpty ? '' : ' ${fields.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
    debugPrint('[$level] $event$extra');
  }
}
