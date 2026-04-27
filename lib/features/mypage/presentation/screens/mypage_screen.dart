import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/nsg_dialog.dart';
import 'package:nsg_mobile/core/components/profile_header.dart';
import 'package:nsg_mobile/features/auth/data/auth_service.dart';
import 'package:nsg_mobile/features/mypage/presentation/providers/mypage_provider.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mypageProvider);

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _Card(
                child: userAsync.when(
                  data: (user) => ProfileHeader(
                    generation: user.displayName,
                    detail: user.cohortLabel,
                  ),
                  loading: () => const _ProfileSkeleton(),
                  error: (_, __) =>
                      const ProfileHeader(generation: '-', detail: '-'),
                ),
              ),
              const SizedBox(height: 20),
              _MenuCard(
                icon: Symbols.logout,
                label: '로그아웃',
                onTap: () => _onLogout(context),
              ),
              const SizedBox(height: 8),
              _MenuCard(
                icon: Symbols.block,
                label: '회원탈퇴',
                onTap: () => _onWithdraw(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await NsgDialog.show(
      context,
      title: '로그아웃',
      content: '기기내 계정에서 로그아웃 할 수 있습니다.\n다음 접속 시 다시 로그인을 해야합니다.\n로그아웃 하시겠어요?',
      cancelLabel: '취소',
      confirmLabel: '로그아웃',
    );
    if (confirmed == true) {
      await AuthService.logout();
      if (context.mounted) context.go('/');
    }
  }

  Future<void> _onWithdraw(BuildContext context) async {
    final confirmed = await NsgDialog.show(
      context,
      title: '회원탈퇴',
      content: '모든 계정에서 정보가 사라지게 됩니다.\n다음 접속 시 다시 회원가입 해야합니다.\n회원탈퇴 하시겠어요?',
      cancelLabel: '취소',
      confirmLabel: '탈퇴',
    );
    if (confirmed == true) {
      await AuthService.logout();
      if (context.mounted) context.go('/');
    }
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 24, backgroundColor: NsgColor.black100),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: NsgColor.black100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: NsgColor.black100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: NsgColor.black50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: NsgColor.black800),
            const SizedBox(width: 10),
            Text(label, style: NsgTextStyle.body2),
          ],
        ),
      ),
    );
  }
}
