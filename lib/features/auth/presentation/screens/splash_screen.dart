import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/presentation/screens/driver_home_screen.dart';
import '../../../supervisor/presentation/screens/supervisor_home_screen.dart';
import '../../../security/presentation/screens/security_home_screen.dart';
import '../../../shared/presentation/widgets/main_navigation.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () => _checkSession());
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final session = await SessionManager.getSession();

    if (session != null) {
      final role = session['role']!;
      Widget homeScreen;

      switch (role) {
        case 'driver':
          homeScreen = DriverHomeScreen(
            driverName: session['name']!,
            idNumber: session['idNumber']!,
            lineFrom: session['lineFrom']!,
            lineTo: session['lineTo']!,
          );
          break;
        case 'supervisor':
          homeScreen = SupervisorHomeScreen(
            supervisorName: session['name']!,
            idNumber: session['idNumber']!,
          );
          break;
        case 'security':
          homeScreen = SecurityHomeScreen(
            securityName: session['name']!,
            idNumber: session['idNumber']!,
          );
          break;
        default:
          homeScreen = DriverHomeScreen(
            driverName: session['name']!,
            idNumber: session['idNumber']!,
            lineFrom: session['lineFrom']!,
            lineTo: session['lineTo']!,
          );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(
            homeScreen: homeScreen,
            driverName: session['name']!,
            idNumber: session['idNumber']!,
            role: role,
            currentPassword: session['currentPassword']!,
          ),
        ),
      );
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context); // ← الترجمة

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: AppDimensions.logoWidth(context),
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                Text(
                  l.stationName, // ← محطة بلدية الخليل / Hebron Central Bus Station
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontMedium(context),
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
