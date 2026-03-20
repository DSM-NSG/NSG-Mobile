import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/router/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
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
