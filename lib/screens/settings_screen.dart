import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isFirstSetup;
  const SettingsScreen({super.key, this.isFirstSetup = false});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = ref.read(settingsProvider);
      final url = settings.supabaseUrl ?? '';
      final anonKey = settings.supabaseAnonKey ?? '';
      await ref.read(settingsProvider.notifier).updateSupabaseCredentials(url, anonKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres sauvegardés.')),
        );
        context.go('/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D27) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Déconnexion', 
          style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        content: Text('Voulez-vous retourner à l\'écran de connexion ?',
          style: TextStyle(color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
            child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: const Text('Déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: widget.isFirstSetup
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/main'),
              ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 40.0 : 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.settings_suggest_rounded, 
                    size: 56, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 32),

                // Card content
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E3247) : const Color(0xFFE8EBF0),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  padding: EdgeInsets.all(isWide ? 32 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Général', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),

                      // Mode Sombre
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          title: Text('Mode Sombre', 
                            style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                          secondary: Icon(
                            settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                          activeColor: Theme.of(context).colorScheme.primary,
                          value: settings.isDarkMode,
                          onChanged: (val) => ref.read(settingsProvider.notifier).toggleTheme(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Base de données Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: settings.isSupabaseConfigured
                              ? Colors.green.withOpacity(isDark ? 0.15 : 0.1)
                              : Colors.red.withOpacity(isDark ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: settings.isSupabaseConfigured
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              settings.isSupabaseConfigured ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: settings.isSupabaseConfigured ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Base de données',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: settings.isSupabaseConfigured ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    settings.isSupabaseConfigured ? 'Connectée et synchronisée' : 'Non configurée',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: settings.isSupabaseConfigured ? Colors.green.shade600 : Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSettings,
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Sauvegarder les paramètres'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                          label: const Text('Déconnexion', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
