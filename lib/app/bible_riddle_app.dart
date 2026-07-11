import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_controller.dart';
import 'game_screens.dart';

class BibleRiddleApp extends ConsumerWidget {
  const BibleRiddleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible Riddle',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB08A31),
          brightness: Brightness.light,
          surface: const Color(0xFFFFF8E7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFCF4),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6B45C),
          brightness: Brightness.dark,
        ),
      ),
      home: !state.loaded
          ? const SplashScreen()
          : state.onboarded
              ? const HomeScreen()
              : const OnboardingScreen(),
    );
  }
}
