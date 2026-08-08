import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const IntelligenceApp());

class IntelligenceApp extends StatelessWidget {
  const IntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        fontFamily: 'Inter',
      ),
      home: const ChatScreen(),
    );
  }
}
