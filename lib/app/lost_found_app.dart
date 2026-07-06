import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/auth/views/auth_wrapper.dart';
import '../features/lost_found/data/lost_found_repository.dart';
import '../features/lost_found/data/supabase_lost_found_repository.dart';

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    this.repository,
    this.bypassAuth = false,
  });

  final LostFoundRepository? repository;
  final bool bypassAuth;

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF04756F),
      brightness: Brightness.light,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Lost and Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      home: AuthWrapper(
        repository: repository ?? SupabaseLostFoundRepository(),
        bypassAuth: bypassAuth,
      ),
    );
  }
}
