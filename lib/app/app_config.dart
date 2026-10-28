/// Central, compile-time product configuration.
///
/// Branding and feature availability live here so they can be changed
/// without touching feature code.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.tagline,
    required this.contentLocale,
    this.enableReminders = true,
    this.enableAppLock = true,
    this.enablePersonalExperiment = true,
    this.enableAiAssistant = false,
    this.enableCloudSync = false,
  });

  final String appName;
  final String tagline;
  final String contentLocale;

  final bool enableReminders;
  final bool enableAppLock;
  final bool enablePersonalExperiment;

  /// Later-phase features. Not implemented in this release; flags exist so
  /// the UI never advertises them while they are off.
  final bool enableAiAssistant;
  final bool enableCloudSync;

  static const standard = AppConfig(
    appName: 'VitalMen',
    tagline: 'Private, evidence-based sexual wellness',
    contentLocale: 'en',
  );

  /// The single disclaimer string reused across onboarding, articles and
  /// reflection results.
  static const disclaimer =
      'This app provides educational and wellness information. It does not '
      'diagnose medical conditions or replace professional care.';
}
