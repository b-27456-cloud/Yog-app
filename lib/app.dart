import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/camera/camera_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/pose_detail/pose_detail_screen.dart';
import 'features/session/session_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/auth/auth_provider.dart';
import 'features/explore/pose_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/audio/music_service.dart';

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
      pageBuilder: (context, state) {
        final difficulty = state.uri.queryParameters['difficulty'];
        return _buildPageWithTransition(ExploreScreen(initialDifficulty: difficulty), state);
      },
    ),
    GoRoute(
      path: '/camera',
      pageBuilder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
        final poseId = extra['poseId'] as String? ?? 'warrior_2';
        return MaterialPage(
          fullscreenDialog: true,
          child: CameraScreen(poseId: poseId),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(const ProfileScreen(), state),
    ),
    GoRoute(
      path: '/pose-detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPageWithTransition(PoseDetailScreen(poseId: id), state);
      },
    ),
    GoRoute(
      path: '/session',
      pageBuilder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
        final poseId = extra['poseId'] as String? ?? 'warrior_2';
        return MaterialPage(
          fullscreenDialog: true,
          child: SessionScreen(poseId: poseId),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildPageWithTransition(const SettingsScreen(), state),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(const AchievementsScreen(), state),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _buildPageWithTransition(const NotificationsScreen(), state),
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

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      MusicService.instance.stop();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      MusicService.instance.pause();
    } else if (state == AppLifecycleState.resumed) {
      MusicService.instance.resume();
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PoseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return WillPopScope(
            onWillPop: () => _showExitDialog(context),
            child: MaterialApp.router(
              title: 'YogaAI',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
