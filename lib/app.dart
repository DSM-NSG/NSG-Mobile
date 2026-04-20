import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/router/router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'NSG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LINESeedKR',
        scaffoldBackgroundColor: NsgColor.background,
        colorScheme: ColorScheme.fromSeed(seedColor: NsgColor.orange400),
      ),
      routerConfig: router,
    );
  }
}