import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/core/layout/main_layout.dart';
import 'package:nsg_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:nsg_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:nsg_mobile/features/major/presentation/screens/major_screen.dart';
import 'package:nsg_mobile/features/map/presentation/screens/map_screen.dart';
import 'package:nsg_mobile/features/mypage/presentation/screens/mypage_screen.dart';
import 'package:nsg_mobile/features/share/presentation/screens/share_screen.dart';
import 'package:nsg_mobile/features/write/presentation/screens/write_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/write',
              builder: (context, state) => const WriteScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/share',
              builder: (context, state) => const ShareScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/major',
              builder: (context, state) => const MajorScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mypage',
              builder: (context, state) => const MypageScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
