import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/core/components/elevated_button.dart';
import 'package:nsg_mobile/features/auth/data/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    setState(() => _isLoggedIn = isLoggedIn);

    if (isLoggedIn) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/share');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/logo.svg',
                  width: 250,
                ),
              ),
            ),
            if (_isLoggedIn == false)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: NsgElevatedButton(
                  text: '로그인',
                  onTap: () => context.go('/login'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
