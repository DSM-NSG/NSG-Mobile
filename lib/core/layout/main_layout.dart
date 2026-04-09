import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/core/layout/bottom_nav_bar.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

// 공유 탭 인덱스
const _shareTabIndex = 2;

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NsgBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // 같은 탭을 다시 누르면 해당 탭의 초기 화면으로 이동
          if (index == navigationShell.currentIndex) {
            // 공유 탭: 검색 상태 리셋
            if (index == _shareTabIndex) {
              ref.read(shareProvider.notifier).closeSearch();
            }
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
