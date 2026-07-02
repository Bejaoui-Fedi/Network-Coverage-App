import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Carte'),
    _NavItem(icon: Icons.table_rows_outlined, activeIcon: Icons.table_rows_rounded, label: 'Liste'),
  ];

  final List<Widget> _pages = const [
    DashboardScreen(),
    MapScreen(),
    ListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : const Color(0xFFE8EBF0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top AppBar
          _buildTopBar(context, isDark),

          // Body
          Expanded(
            child: Row(
              children: [
                if (isDesktop)
                  Container(
                    width: 76,
                    decoration: BoxDecoration(
                      color: sidebarBg,
                      border: Border(right: BorderSide(color: borderColor)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ...List.generate(_navItems.length, (i) {
                          final item = _navItems[i];
                          final isSelected = _selectedIndex == i;
                          return _buildSidebarItem(
                            icon: isSelected ? item.activeIcon : item.icon,
                            label: item.label,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedIndex = i),
                          );
                        }),
                      ],
                    ),
                  ),

                // Page content
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _buildBottomNav(context, isDark, borderColor),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.primaryOrange,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          // Logo mini
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/orange_logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Orange DRS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.white,
              size: 22,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'Paramètres',
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryOrange.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppTheme.primaryOrange
                  : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryOrange
                    : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
