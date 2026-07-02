import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _supabaseUrlKey = 'supabase_url';
  static const String _supabaseAnonKeyKey = 'supabase_anon_key';
  static const String _isDarkModeKey = 'is_dark_mode';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  String? getSupabaseUrl() {
    final stored = _prefs.getString(_supabaseUrlKey);
    if (stored != null && stored.isNotEmpty) return stored;
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    return envUrl.isNotEmpty ? envUrl : null;
  }

  Future<void> saveSupabaseUrl(String url) async {
    await _prefs.setString(_supabaseUrlKey, url);
  }

  String? getSupabaseAnonKey() {
    final stored = _prefs.getString(_supabaseAnonKeyKey);
    if (stored != null && stored.isNotEmpty) return stored;
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return envKey.isNotEmpty ? envKey : null;
  }

  Future<void> saveSupabaseAnonKey(String key) async {
    await _prefs.setString(_supabaseAnonKeyKey, key);
  }



  bool getIsDarkMode() {
    return _prefs.getBool(_isDarkModeKey) ?? false;
  }

  Future<void> saveIsDarkMode(bool isDarkMode) async {
    await _prefs.setBool(_isDarkModeKey, isDarkMode);
  }
}
