import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SuvidhaApp());
}

class SuvidhaApp extends StatelessWidget {
  const SuvidhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (context) => ApiService(authService: context.read<AuthService>())),
      ],
      child: MaterialApp(
        title: 'Suvidha',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}