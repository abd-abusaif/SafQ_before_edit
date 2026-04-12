// features/security/presentation/screens/security_main_navigation.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/session_manager.dart';
import 'security_home_screen.dart';
import 'security_notifications_screen.dart';
import 'security_profile_screen.dart';

class SecurityMainNavigation extends StatefulWidget {
  final String securityName;
  final String idNumber;

  const SecurityMainNavigation({
    super.key,
    required this.securityName,
    required this.idNumber,
  });

  @override
  State<SecurityMainNavigation> createState() => _SecurityMainNavigationState();
}

class _SecurityMainNavigationState extends State<SecurityMainNavigation> {
  int _currentIndex = 0;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SecurityHomeScreen(
        securityName: widget.securityName,
        idNumber: widget.idNumber,
      ),
      const SecurityNotificationsScreen(),
      SecurityProfileScreen(
        securityName: widget.securityName,
        idNumber: widget.idNumber,
      ),
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
          'تسجيل الخروج',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Text(
          'هل تريد تسجيل الخروج؟',
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
              'إلغاء',
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
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
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.white)),
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
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.home_rounded, 'الرئيسية'),
                  _navItem(1, Icons.notifications_outlined, 'الإشعارات'),
                  _navItem(2, Icons.person_outline, 'حسابي'),
                  _logoutItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSmall(context),
          vertical: AppDimensions.spacingSmall(context),
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
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
                color: selected
                    ? AppColors.background
                    : _isDark
                    ? AppColors.textSecondary
                    : Colors.black54,
                fontSize: AppDimensions.fontXSmall(context),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutItem() {
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
              'خروج',
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
