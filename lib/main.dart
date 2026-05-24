import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripsy/core/theme/theme.dart';
import 'package:tripsy/core/config/env.dart';
import 'package:tripsy/core/services/supabase_service.dart';
import 'package:tripsy/features/auth/presentation/splash_onboarding_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment credentials from .env asset
  await Env.load();

  final supabaseUrl = Env.get('SUPABASE_URL');
  final supabaseAnonKey = Env.get('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      // Initialize SupabaseService with the live client credentials
      SupabaseService.instance.initializeSupabase(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      // Failed to initialize, will rely on user configurations
    }
  }

  runApp(
    const ProviderScope(
      child: TripsyApp(),
    ),
  );
}

class TripsyApp extends StatelessWidget {
  const TripsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripsy',
      debugShowCheckedModeBanner: false,
      theme: TripsyTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
