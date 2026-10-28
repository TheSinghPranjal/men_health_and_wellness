/// All route paths in one place. Paths contain only content identifiers
/// (article/topic ids) — never answers, results or notes.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const emergency = '/emergency';

  // Tab roots
  static const home = '/home';
  static const learn = '/learn';
  static const health = '/health';
  static const progress = '/progress';
  static const profile = '/profile';

  // Full-screen detail routes (above the tab bar)
  static String article(String id) => '/article/$id';
  static String category(String name) => '/learn/category/$name';
  static const search = '/search';
  static const myths = '/learn/myths';
  static const bookmarks = '/learn/bookmarks';

  static String topic(String id) => '/health/topic/$id';
  static String reflection(String id) => '/reflection/$id';
  static const reflectionHistory = '/health/history';
  static String exercise(String id) => '/exercise/$id';
  static const clinicianPrep = '/clinician-prep';
  static const experiment = '/experiment';

  static const checkIn = '/check-in';
  static const checkInHistory = '/progress/check-ins';
  static const habitNew = '/habit';
  static String habitEdit(String id) => '/habit?id=$id';
  static const habits = '/progress/habits';

  static const privacy = '/profile/privacy';
  static const reminders = '/profile/reminders';
  static const tracking = '/profile/tracking';
  static const goals = '/profile/goals';
  static const about = '/profile/about';
}
