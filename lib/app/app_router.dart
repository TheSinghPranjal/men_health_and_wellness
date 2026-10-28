import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/clinician_support/presentation/screens/clinician_prep_screen.dart';
import '../features/clinician_support/presentation/screens/emergency_screen.dart';
import '../features/daily_log/presentation/screens/check_in_screens.dart';
import '../features/education/presentation/screens/article_screen.dart';
import '../features/education/presentation/screens/learn_screen.dart';
import '../features/education/presentation/screens/search_screen.dart';
import '../features/exercises/presentation/screens/exercise_screen.dart';
import '../features/experiment/presentation/screens/experiment_screen.dart';
import '../features/habits/presentation/screens/habit_screens.dart';
import '../features/health_hub/presentation/screens/health_hub_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/reflections/presentation/screens/reflection_screen.dart';
import '../features/settings/presentation/controllers/preferences_controller.dart';
import '../features/settings/presentation/screens/privacy_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/reminders_about_screens.dart';
import 'app_shell.dart';
import 'route_names.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod -> Listenable so redirects re-run when onboarding
  // completes or all data is deleted.
  final refresh = ValueNotifier<bool>(ref.read(preferencesProvider).onboardingComplete);
  ref.listen(preferencesProvider.select((p) => p.onboardingComplete), (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  GoRoute detail(String path, Widget Function(GoRouterState s) build) =>
      GoRoute(path: path, parentNavigatorKey: _rootKey, builder: (_, s) => build(s));

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final done = ref.read(preferencesProvider).onboardingComplete;
      final loc = state.matchedLocation;
      if (!done && loc != Routes.onboarding && loc != Routes.emergency) return Routes.onboarding;
      if (done && loc == Routes.onboarding) return Routes.home;
      return null;
    },
    errorBuilder: (_, _) => const _NotFound(),
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.learn, builder: (_, _) => const LearnScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.health, builder: (_, _) => const HealthHubScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.progress, builder: (_, _) => const ProgressScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      detail(Routes.emergency, (_) => const EmergencyScreen()),
      detail('/article/:id', (s) => ArticleScreen(articleId: s.pathParameters['id']!)),
      detail('/learn/category/:name', (s) => CategoryScreen(categoryName: s.pathParameters['name']!)),
      detail(Routes.search, (_) => const SearchScreen()),
      detail(Routes.myths, (_) => const MythsScreen()),
      detail(Routes.bookmarks, (_) => const BookmarksScreen()),
      detail('/health/topic/:id', (s) => TopicScreen(topicId: s.pathParameters['id']!)),
      detail('/reflection/:id', (s) => ReflectionScreen(reflectionId: s.pathParameters['id']!)),
      detail(Routes.reflectionHistory, (_) => const ReflectionHistoryScreen()),
      detail('/exercise/:id', (s) => ExerciseScreen(exerciseId: s.pathParameters['id']!)),
      detail(Routes.clinicianPrep, (_) => const ClinicianPrepScreen()),
      detail(Routes.experiment, (_) => const ExperimentScreen()),
      detail(Routes.checkIn, (_) => const CheckInScreen()),
      detail(Routes.checkInHistory, (_) => const CheckInHistoryScreen()),
      detail(Routes.habitNew, (s) => HabitEditScreen(habitId: s.uri.queryParameters['id'])),
      detail(Routes.habits, (_) => const HabitsScreen()),
      detail(Routes.privacy, (_) => const PrivacyScreen()),
      detail(Routes.reminders, (_) => const RemindersScreen()),
      detail(Routes.tracking, (_) => const TrackingScreen()),
      detail(Routes.goals, (_) => const GoalsScreen()),
      detail(Routes.about, (_) => const AboutScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(onPressed: () => context.go(Routes.home), child: const Text('Page not found — go home')),
    ),
  );
}
