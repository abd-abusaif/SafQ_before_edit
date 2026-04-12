// features/shared/presentation/widgets/main_navigation.dart
//
// NOTE: This file is used only for the DRIVER role.
// Supervisor uses SupervisorMainNavigation.
// Security uses SecurityMainNavigation.
// Both are defined in their own feature folders.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/permissions_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/presentation/screens/violations_screen.dart';

class MainNavigation extends StatefulWidget {
  final Widget homeScreen;
  final String driverName;
  final String idNumber;
  final String role;
  final String currentPassword;

  const MainNavigation({
    super.key,
    required this.homeScreen,
    required this.driverName,
    required this.idNumber,
    required this.role,
    required this.currentPassword,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final List<_NavItem> _navItems;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  bool get _isDriver => widget.role == 'driver';

  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();

    // ── Screens ────────────────────────────────────────────────────────────
    _screens = [
      widget.homeScreen, // 0 - Home
      const NotificationsScreen(), // 1 - Notifications
      ProfileScreen(
        // 2 - Profile
        driverName: widget.driverName,
        idNumber: widget.idNumber,
        role: widget.role,
        currentPassword: widget.currentPassword,
      ),
      const PermissionsScreen(), // 3 - Permissions (driver only)
      if (_isDriver) const ViolationsScreen(), // 4 - Violations (driver only)
    ];

    // ── Nav Items ──────────────────────────────────────────────────────────
    _navItems = [
      _NavItem(icon: Icons.home_rounded, label: () => l.home),
      _NavItem(
        icon: Icons.notifications_outlined,
        label: () => l.notifications,
      ),
      _NavItem(icon: Icons.person_outline, label: () => l.profile),
      _NavItem(icon: Icons.lock_clock_outlined, label: () => l.permissions),
      if (_isDriver)
        _NavItem(icon: Icons.gavel_outlined, label: () => l.violations),
    ];
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        icon: Icon(
          Icons.logout,
          color: Colors.redAccent,
          size: AppDimensions.iconXLarge(context),
        ),
        title: Text(
          l.logoutConfirm,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Text(
          l.logoutQuestion,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontMedium(context),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.cancel,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await SessionManager.clearSession();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
              ),
            ),
            child: Text(
              l.logout,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: _isDark ? Colors.white12 : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSmall(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            child: Directionality(
              textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ..._navItems.asMap().entries.map(
                    (e) => _buildNavItem(e.key, e.value.icon, e.value.label()),
                  ),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSmall(context),
          vertical: AppDimensions.spacingSmall(context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.background
                  : _isDark
                  ? AppColors.textSecondary
                  : Colors.black54,
              size: AppDimensions.iconMedium(context),
            ),
            SizedBox(height: AppDimensions.spacingXSmall(context)),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected
                    ? AppColors.background
                    : _isDark
                    ? AppColors.textSecondary
                    : Colors.black54,
                fontSize: AppDimensions.fontXSmall(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return GestureDetector(
      onTap: _onLogout,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSmall(context),
          vertical: AppDimensions.spacingSmall(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: AppDimensions.iconMedium(context),
            ),
            SizedBox(height: AppDimensions.spacingXSmall(context)),
            Text(
              l.logout,
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: AppDimensions.fontXSmall(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String Function() label;
  const _NavItem({required this.icon, required this.label});
}
