import 'package:go_router/go_router.dart';
import '../features/auth/presentation/page/auth_page.dart';
import '../features/auth/presentation/page/register_page.dart';
import '../features/home/presentations/pages/home_page.dart';
import '../splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomePage(),
    ),
  ],
);
