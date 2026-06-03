import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/camera/camera_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/pose_detail/pose_detail_screen.dart';
import 'features/session/session_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/data/poses_data.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildPageWithTransition(const SplashScreen(), state),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildPageWithTransition(const OnboardingScreen(), state),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithTransition(const LoginScreen(), state),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildPageWithTransition(const RegisterScreen(), state),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPageWithTransition(const HomeScreen(), state),
    ),
    GoRoute(
      path: '/explore',
      pageBuilder: (context, state) => _buildPageWithTransition(const ExploreScreen(), state),
    ),
    GoRoute(
      path: '/camera',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: CameraScreen(),
      ),
    ),
    GoRoute(
      path: '/progress',
      pageBuilder: (context, state) => _buildPageWithTransition(const ProgressScreen(), state),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(const ProfileScreen(), state),
    ),
    GoRoute(
      path: '/pose-detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'];
        final pose = posesData.firstWhere((p) => p.id == id, orElse: () => posesData.first);
        return _buildPageWithTransition(PoseDetailScreen(pose: pose), state);
      },
    ),
    GoRoute(
      path: '/session',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: SessionScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildPageWithTransition(const SettingsScreen(), state),
    ),
  ],
);

CustomTransitionPage _buildPageWithTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YogaAI',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
