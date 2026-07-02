import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final settings = ref.watch(settingsProvider);
  
  if (settings.isSupabaseConfigured) {
    try {
      // If we already initialized supabase, we can just return the client.
      // But if URL/Key changes, we might need a new instance.
      // For simplicity in this app, we assume if it's configured, it's initialized.
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }
  return null;
});
