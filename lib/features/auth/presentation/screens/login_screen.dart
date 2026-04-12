// features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../driver/presentation/screens/driver_home_screen.dart';
import '../../../supervisor/presentation/screens/supervisor_main_navigation.dart';
import '../../../security/presentation/screens/security_main_navigation.dart';
import '../../../shared/presentation/widgets/main_navigation.dart';
import '../../domain/entities/user_entity.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _repo = AuthRepositoryImpl();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'driver';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  Map<String, String> get _roles => {
    'driver': l.driver,
    'supervisor': l.supervisor,
    'security': l.security,
  };

  final List<Map<String, String>> _mockUsers = [
    {
      'idNumber': '409581394',
      'password': 'Aa@2003178',
      'role': 'driver',
      'name': 'عبدالرحمن أبو سيف',
      'lineFrom': 'الخليل',
      'lineTo': 'دورا',
    },
    {
      'idNumber': '112233445',
      'password': 'Mm@112233445',
      'role': 'supervisor',
      'name': 'محمد رامي إبراهيم عودة',
      'lineFrom': 'الخليل',
      'lineTo': 'دورا',
    },
    {
      'idNumber': '998877665',
      'password': 'Ss@98765',
      'role': 'security',
      'name': 'أحمد سامي محمود خالد',
      'lineFrom': 'الخليل',
      'lineTo': 'دورا',
    },
  ];

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final idNumber = _userCtrl.text.trim();
      final password = _passCtrl.text.trim();

      final userByIdNumber = _mockUsers
          .where((u) => u['idNumber'] == idNumber)
          .toList();
      if (userByIdNumber.isEmpty) {
        _showErrorDialog(l.wrongCredentials, l.wrongCredentialsMsg);
        return;
      }

      final userByPassword = userByIdNumber
          .where((u) => u['password'] == password)
          .toList();
      if (userByPassword.isEmpty) {
        _showErrorDialog(l.wrongCredentials, l.wrongCredentialsMsg);
        return;
      }

      final mockUser = userByPassword.first;
      if (mockUser['role'] != _selectedRole) {
        _showErrorDialog(l.wrongRole, l.wrongRoleMsg);
        return;
      }

      final UserEntity user = await _repo.login(
        idNumber: idNumber,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;

      switch (user.role) {
        // ── السائق ──────────────────────────────────────────────────────
        case 'driver':
          await SessionManager.saveSession(
            idNumber: idNumber,
            name: mockUser['name']!,
            role: 'driver',
            lineFrom: mockUser['lineFrom']!,
            lineTo: mockUser['lineTo']!,
            password: password,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainNavigation(
                homeScreen: DriverHomeScreen(
                  driverName: mockUser['name']!,
                  idNumber: idNumber,
                  lineFrom: mockUser['lineFrom']!,
                  lineTo: mockUser['lineTo']!,
                ),
                driverName: mockUser['name']!,
                idNumber: idNumber,
                role: 'driver',
                currentPassword: password,
              ),
            ),
          );
          break;

        // ── المشرف → SupervisorMainNavigation ──────────────────────────
        case 'supervisor':
          await SessionManager.saveSession(
            idNumber: idNumber,
            name: mockUser['name']!,
            role: 'supervisor',
            lineFrom: mockUser['lineFrom']!,
            lineTo: mockUser['lineTo']!,
            password: password,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SupervisorMainNavigation(
                supervisorName: mockUser['name']!,
                idNumber: idNumber,
              ),
            ),
          );
          break;

        // ── الأمن → SecurityMainNavigation (بدون permissions) ──────────
        case 'security':
          await SessionManager.saveSession(
            idNumber: idNumber,
            name: mockUser['name']!,
            role: 'security',
            lineFrom: mockUser['lineFrom']!,
            lineTo: mockUser['lineTo']!,
            password: password,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SecurityMainNavigation(
                securityName: mockUser['name']!,
                idNumber: idNumber,
              ),
            ),
          );
          break;
      }
    } catch (e) {
      _showErrorDialog(l.unexpectedError, l.tryAgain);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
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
          Icons.error_outline,
          color: Colors.redAccent,
          size: AppDimensions.iconXLarge(context),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontMedium(context),
            height: 1.6,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXLarge(context),
                vertical: AppDimensions.spacingSmall(context),
              ),
            ),
            child: Text(
              l.ok,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textAlign = l.isArabic ? TextAlign.right : TextAlign.left;
    final textDir = l.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.spacingLarge(context)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: l.isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.spacingXLarge(context)),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: AppDimensions.logoWidthSmall(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingLarge(context)),
                Text(
                  l.welcome,
                  textAlign: textAlign,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontTitle(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l.loginSubtitle,
                  textAlign: textAlign,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingLarge(context)),
                // رقم الهوية
                TextFormField(
                  controller: _userCtrl,
                  textAlign: textAlign,
                  textDirection: textDir,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l.idNumber,
                    counterText: '',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.enterId;
                    if (v.length != 9) return l.id9Digits;
                    if (!RegExp(r'^\d{9}$').hasMatch(v)) return l.idNumbersOnly;
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                // كلمة المرور
                TextFormField(
                  controller: _passCtrl,
                  textAlign: textAlign,
                  textDirection: textDir,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l.password,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        size: AppDimensions.iconMedium(context),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.enterPassword;
                    if (v.length < 6) return l.passwordMin6;
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v))
                      return l.passwordSymbol;
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                // نوع المستخدم
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  iconEnabledColor: AppColors.primary,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l.userType,
                    prefixIcon: const Icon(
                      Icons.people_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  items: _roles.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, textAlign: textAlign),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                SizedBox(height: AppDimensions.spacingLarge(context)),
                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius(context),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.background,
                          )
                        : Text(
                            l.loginBtn,
                            style: GoogleFonts.cairo(
                              color: AppColors.background,
                              fontSize: AppDimensions.fontLarge(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      l.forgotPassword,
                      style: GoogleFonts.cairo(
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontMedium(context),
                      ),
                    ),
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
