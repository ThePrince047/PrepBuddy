import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/mcq/presentation/screens/mcq_topics_screen.dart';
import '../../features/mcq/presentation/screens/mcq_test_configurator.dart';
import '../../features/mcq/presentation/screens/mcq_test_engine.dart';
import '../../features/mcq/presentation/screens/mcq_results_screen.dart';
import '../../features/dsa/presentation/screens/dsa_topics_screen.dart';
import '../../features/dsa/presentation/screens/dsa_problem_list_screen.dart';
import '../../features/dsa/presentation/screens/dsa_problem_detail_screen.dart';
import '../../features/study_materials/presentation/screens/study_materials_screen.dart';
import '../../features/study_materials/presentation/screens/study_material_detail_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ── Main ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),

      // ── MCQ ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/mcq',
        builder: (context, state) => const McqTopicsScreen(),
        routes: [
          GoRoute(
            path: 'config',
            builder: (context, state) {
              final topic = state.extra as String;
              return McqTestConfigurator(topic: topic);
            },
          ),
          GoRoute(
            path: 'engine',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return McqTestEngine(
                topic: args['topic'] as String,
                count: args['count'] as int,
                mode: args['mode'] as String,
              );
            },
          ),
          GoRoute(
            path: 'results',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return McqResultsScreen(
                topic: args['topic'] as String,
                total: args['total'] as int,
                correct: args['correct'] as int,
                wrong: args['wrong'] as int,
                skipped: args['skipped'] as int,
                mode: args['mode'] as String,
                questions: (args['questions'] as List).cast<Map<String, dynamic>>(),
                selectedAnswers: (args['selectedAnswers'] as Map).map(
                  (k, v) => MapEntry(k as int, v as int),
                ),
              );
            },
          ),
        ],
      ),

      // ── DSA ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/dsa',
        builder: (context, state) => const DsaTopicsScreen(),
        routes: [
          GoRoute(
            path: 'list',
            builder: (context, state) {
              final category = state.extra as String;
              return DsaProblemListScreen(category: category);
            },
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final id = state.extra.toString();
              return DsaProblemDetailScreen(problemId: id);
            },
          ),
        ],
      ),

      // ── Study Materials ───────────────────────────────────────────────────
      GoRoute(
        path: '/study',
        builder: (context, state) => const StudyMaterialsScreen(),
      ),
      GoRoute(
        path: '/study/detail',
        builder: (context, state) {
          final id = state.extra as int;
          return StudyMaterialDetailScreen(materialId: id);
        },
      ),
    ],
  );
}
