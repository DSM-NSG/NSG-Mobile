import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/core/layout/main_layout.dart';
import 'package:nsg_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:nsg_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:nsg_mobile/features/major/presentation/screens/major_post_list_screen.dart';
import 'package:nsg_mobile/features/major/presentation/screens/major_screen.dart';
import 'package:nsg_mobile/features/map/presentation/screens/map_screen.dart';
import 'package:nsg_mobile/features/mypage/presentation/screens/mypage_screen.dart';
import 'package:nsg_mobile/features/share/presentation/screens/post_detail_screen.dart';
import 'package:nsg_mobile/features/share/presentation/screens/post_list_screen.dart';
import 'package:nsg_mobile/features/share/presentation/screens/share_screen.dart';
import 'package:nsg_mobile/features/write/presentation/screens/write_post_screen.dart';
import 'package:nsg_mobile/features/write/presentation/screens/write_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainLayout(navigationShell: navigationShell),

        branches: [
          /// MAP
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (_, __) => const MapScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/write',
                builder: (_, __) => const WriteScreen(),
                routes: [
                  GoRoute(
                    path: 'place',
                    builder: (_, __) => const WritePostScreen(type: 'place'),
                  ),
                  GoRoute(
                    path: 'dormitory',
                    builder: (_, __) => const WritePostScreen(type: 'dormitory'),
                  ),
                  GoRoute(
                    path: 'school',
                    builder: (_, __) => const WritePostScreen(type: 'school'),
                  ),
                  GoRoute(
                    path: 'major',
                    builder: (_, __) => const WritePostScreen(type: 'major'),
                  ),
                  GoRoute(
                    path: 'etc',
                    builder: (_, __) => const WritePostScreen(type: 'etc'),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/share',
                builder: (_, __) => const ShareScreen(),
                routes: [
                  GoRoute(
                    path: 'popular',
                    builder: (_, __) =>
                    const PostListScreen(type: PostListType.popular),
                  ),

                  GoRoute(
                    path: 'post/:postId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => PostDetailScreen(
                      postId: state.pathParameters['postId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/major',
                builder: (_, __) => const MajorScreen(),
                routes: [
                  GoRoute(
                    path: 'popular',
                    builder: (_, __) => const MajorPostListScreen(type: MajorPostListType.popular),
                  ),
                  GoRoute(
                    path: 'recent',
                    builder: (_, __) => const MajorPostListScreen(type: MajorPostListType.recent),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (_, __) => const MypageScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});