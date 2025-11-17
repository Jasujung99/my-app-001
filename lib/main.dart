// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/router.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/theme/app_theme.dart'; // AppTheme 임포트

void main() async {
  // 앱을 실행하기 전에 Flutter 엔진과 위젯 트리를 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase를 초기화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'BookTalk City',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter(authService).router, 
        );
      },
    );
  }
}
