import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'models/user.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/create_mission_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const WakaApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',         builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home',     builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/driver',   builder: (_, __) => const DriverHomeScreen()),
    GoRoute(path: '/missions', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/create-mission',
      builder: (context, state) {
        final service = state.extra as String?;
        return CreateMissionScreen(initialService: service);
      },
    ),
  ],
);

class WakaApp extends StatelessWidget {
  const WakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Waka',
      debugShowCheckedModeBanner: false,
      theme: WakaTheme.theme,
      routerConfig: _router,
    );
  }
}
