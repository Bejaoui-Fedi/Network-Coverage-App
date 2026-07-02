import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/settings_repository.dart';

// Provider pour SharedPreferences (sera surchargé dans main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

class SettingsNotifier extends Notifier<SettingsState> {
  late SettingsRepository _repository;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return SettingsState(
      supabaseUrl: _repository.getSupabaseUrl(),
      supabaseAnonKey: _repository.getSupabaseAnonKey(),
      isDarkMode: _repository.getIsDarkMode(),
    );
  }

  Future<void> updateSupabaseCredentials(String url, String anonKey) async {
    await _repository.saveSupabaseUrl(url);
    await _repository.saveSupabaseAnonKey(anonKey);
    state = state.copyWith(supabaseUrl: url, supabaseAnonKey: anonKey);
  }

  Future<void> toggleTheme() async {
    final newMode = !state.isDarkMode;
    await _repository.saveIsDarkMode(newMode);
    state = state.copyWith(isDarkMode: newMode);
  }
}

class SettingsState {
  final String? supabaseUrl;
  final String? supabaseAnonKey;
  final bool isDarkMode;

  SettingsState({
    this.supabaseUrl,
    this.supabaseAnonKey,
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool? isDarkMode,
  }) {
    return SettingsState(
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  bool get isSupabaseConfigured =>
      supabaseUrl != null &&
      supabaseUrl!.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey!.isNotEmpty;
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
