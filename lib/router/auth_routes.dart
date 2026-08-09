import 'package:go_router/go_router.dart';

import 'package:gym_app/features/auth/presentation/components/loading.dart';
import 'package:gym_app/features/auth/presentation/pages/auth_page.dart';
import 'package:gym_app/features/main/presentation/pages/main_page.dart';

final authRoutes = <GoRoute>[
  GoRoute(
    path: '/loading',
    builder: (context, state) => const LoadingScreen(),
  ),

  GoRoute(
    path: '/auth',
    builder: (context, state) => const AuthPage(),
  ),

  GoRoute(
    path: '/',
    builder: (context, state) => const MainPage(),
  ),
];
