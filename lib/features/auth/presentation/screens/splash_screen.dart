// features/auth/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/presentation/screens/driver_home_screen.dart';
import '../../../shared/presentation/widgets/main_navigation.dart';
import '../../../supervisor/presentation/screens/supervisor_main_navigation.dart';
import '../../../security/presentation/screens/security_main_navigation.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final session = await SessionManager.getSession();

    if (session != null) {
      final role = session['role']!;
      final name = session['name']!;
      final idNumber = session['idNumber']!;
      final currentPassword = session['currentPassword'] ?? '';

      if (!mounted) return;

      switch (role) {
        // ── السائق → MainNavigation ───────────────────────────────────────
        case 'driver':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainNavigation(
                homeScreen: DriverHomeScreen(
                  driverName: name,
                  idNumber: idNumber,
                  lineFrom: session['lineFrom'] ?? '',
                  lineTo: session['lineTo'] ?? '',
                ),
                driverName: name,
                idNumber: idNumber,
                role: role,
                currentPassword: currentPassword,
              ),
            ),
          );
          break;

        // ── المشرف → SupervisorMainNavigation ────────────────────────────
        case 'supervisor':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SupervisorMainNavigation(
                supervisorName: name,
                idNumber: idNumber,
              ),
            ),
          );
          break;

        // ── الأمن → SecurityMainNavigation ───────────────────────────────
        case 'security':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SecurityMainNavigation(
                securityName: name,
                idNumber: idNumber,
              ),
            ),
          );
          break;

        default:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x0AFFB800),
                      ),
                    ),
                    Container(
                      width: 155,
                      height: 155,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x17FFB800),
                      ),
                    ),
                    Container(
                      width: 128,
                      height: 128,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x2EFFB800),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: AppDimensions.logoWidth(context),
                        height: AppDimensions.logoWidth(context) * 0.75,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: AppColors.primary,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'SafQ',
                              style: GoogleFonts.cairo(
                                color: AppColors.background,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                Text(
                  l.stationName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSmall(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingXSmall(context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    l.appName,
                    style: GoogleFonts.cairo(
                      color: AppColors.primary,
                      fontSize: AppDimensions.fontSmall(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXLarge(context)),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
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
