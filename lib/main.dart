import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/routes.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Try to initialize Supabase if credentials exist
  const envUrl = String.fromEnvironment('SUPABASE_URL');
  const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final supabaseUrl = envUrl.isNotEmpty ? envUrl : (prefs.getString('supabase_url') ?? '');
  final supabaseAnonKey = envAnonKey.isNotEmpty ? envAnonKey : (prefs.getString('supabase_anon_key') ?? '');
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint("Failed to initialize Supabase: $e");
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NetworkCoverageApp(),
    ),
  );
}

class NetworkCoverageApp extends ConsumerWidget {
  const NetworkCoverageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Orange DRS - Couverture Réseau',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
