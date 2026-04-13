import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/core/layout/bottom_nav_bar.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

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
          if (index == _shareTabIndex) {
            ref.read(shareProvider.notifier).closeSearch();
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
