import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/auth/login_page.dart';

void main() {
  runApp(const MiniEWalletApp());
}

class MiniEWalletApp extends StatelessWidget {
  const MiniEWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E Pay',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF151816),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1D211E),
          primary: Color(0xFF54D9A3),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
