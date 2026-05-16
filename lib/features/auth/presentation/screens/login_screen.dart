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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _repo = AuthRepositoryImpl();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'driver';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

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

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

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
        // ← رسالة موحدة: بيانات غير صحيحة
        _showErrorDialog(l.wrongCredentials, l.wrongCredentialsMsg);
        return;
      }

      final userByPassword = userByIdNumber
          .where((u) => u['password'] == password)
          .toList();
      if (userByPassword.isEmpty) {
        // ← رسالة موحدة: بيانات غير صحيحة
        _showErrorDialog(l.wrongCredentials, l.wrongCredentialsMsg);
        return;
      }

      final mockUser = userByPassword.first;
      if (mockUser['role'] != _selectedRole) {
        // ← نفس رسالة بيانات غير صحيحة بدل كشف نوع المستخدم
        _showErrorDialog(l.wrongCredentials, l.wrongCredentialsMsg);
        return;
      }

      final UserEntity user = await _repo.login(
        idNumber: idNumber,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;

      switch (user.role) {
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
      builder: (ctx) => Directionality(
        textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: _isDark ? AppColors.surface : Colors.white,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = l.isArabic;
    final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: _isDark
            ? AppColors.background
            : AppColors.backgroundLight,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingLarge(context),
                  vertical: AppDimensions.spacingMedium(context),
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.04),
                          _buildLogo(),
                          SizedBox(
                            height: AppDimensions.spacingXLarge(context),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              AppDimensions.spacingLarge(context),
                            ),
                            decoration: BoxDecoration(
                              color: _isDark ? AppColors.surface : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _isDark
                                    ? Colors.white.withOpacity(0.07)
                                    : Colors.black.withOpacity(0.06),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isRtl
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.waving_hand_rounded,
                                      color: AppColors.primary,
                                      size: AppDimensions.iconSmall(context),
                                    ),
                                    SizedBox(
                                      width: AppDimensions.spacingXSmall(
                                        context,
                                      ),
                                    ),
                                    Text(
                                      l.welcome,
                                      style: GoogleFonts.cairo(
                                        color: _isDark
                                            ? AppColors.textSecondary
                                            : AppColors.textSecondaryLight,
                                        fontSize: AppDimensions.fontSmall(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: AppDimensions.spacingXSmall(context),
                                ),
                                Align(
                                  alignment: isRtl
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Text(
                                    l.loginSubtitle,
                                    style: GoogleFonts.cairo(
                                      color: _isDark
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimaryLight,
                                      fontSize: AppDimensions.fontXLarge(
                                        context,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: AppDimensions.spacingLarge(context),
                                ),

                                // ── رقم الهوية ─────
                                _buildLabel(l.idNumber, Icons.badge_outlined),
                                SizedBox(
                                  height: AppDimensions.spacingXSmall(context),
                                ),
                                TextFormField(
                                  controller: _userCtrl,
                                  textAlign: TextAlign.left,
                                  textDirection: TextDirection.ltr,
                                  keyboardType: TextInputType.number,
                                  maxLength: 9,
                                  style: GoogleFonts.cairo(
                                    color: _isDark
                                        ? AppColors.textPrimary
                                        : Colors.black87,
                                    fontSize: AppDimensions.fontMedium(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l.idNumber,
                                    hintTextDirection: TextDirection.rtl,
                                    counterText: '',
                                    filled: true,
                                    fillColor: _isDark
                                        ? AppColors.inputFill
                                        : AppColors.inputFillLight,
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: AppColors.primary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return l.enterId;
                                    if (v.length != 9) return l.id9Digits;
                                    if (!RegExp(r'^\d{9}$').hasMatch(v))
                                      return l.idNumbersOnly;
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: AppDimensions.spacingMedium(context),
                                ),

                                // ── كلمة المرور ────
                                _buildLabel(l.password, Icons.lock_outline),
                                SizedBox(
                                  height: AppDimensions.spacingXSmall(context),
                                ),
                                TextFormField(
                                  controller: _passCtrl,
                                  textAlign: TextAlign.left,
                                  textDirection: TextDirection.ltr,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.cairo(
                                    color: _isDark
                                        ? AppColors.textPrimary
                                        : Colors.black87,
                                    fontSize: AppDimensions.fontMedium(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l.password,
                                    hintTextDirection: TextDirection.rtl,
                                    filled: true,
                                    fillColor: _isDark
                                        ? AppColors.inputFill
                                        : AppColors.inputFillLight,
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
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return l.enterPassword;
                                    if (v.length < 6) return l.passwordMin6;
                                    if (!RegExp(
                                      r'[!@#\$%^&*(),.?":{}|<>_\-]',
                                    ).hasMatch(v))
                                      return l.passwordSymbol;
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: AppDimensions.spacingMedium(context),
                                ),

                                // ── نوع المستخدم ───
                                _buildLabel(l.userType, Icons.people_outline),
                                SizedBox(
                                  height: AppDimensions.spacingXSmall(context),
                                ),
                                _buildRoleCards(),
                                SizedBox(
                                  height: AppDimensions.spacingLarge(context),
                                ),

                                // ── زر الدخول ──────
                                SizedBox(
                                  width: double.infinity,
                                  height: AppDimensions.buttonHeight(context),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 6,
                                      shadowColor: AppColors.primary
                                          .withOpacity(0.5),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: AppColors.background,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.login_rounded,
                                                color: AppColors.background,
                                                size: AppDimensions.iconSmall(
                                                  context,
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    AppDimensions.spacingXSmall(
                                                      context,
                                                    ),
                                              ),
                                              Text(
                                                l.loginBtn,
                                                style: GoogleFonts.cairo(
                                                  color: AppColors.background,
                                                  fontSize:
                                                      AppDimensions.fontLarge(
                                                        context,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingSmall(context)),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              l.forgotPassword,
                              style: GoogleFonts.cairo(
                                color: _isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                                fontSize: AppDimensions.fontMedium(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.04),
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.09),
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.18),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                width: AppDimensions.logoWidthSmall(context),
                height: AppDimensions.logoWidthSmall(context) * 0.75,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 86,
                  height: 86,
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
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
        Text(
          l.stationName,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
            fontSize: AppDimensions.fontSmall(context),
          ),
        ),
        SizedBox(height: AppDimensions.spacingXSmall(context)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Text(
            l.appName,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontXSmall(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ── Label: AlignmentDirectional.centerStart = يمين RTL / يسار LTR
  Widget _buildLabel(String text, IconData icon) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: _isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              fontSize: AppDimensions.fontSmall(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقات نوع المستخدم
  // Directionality(rtl) تعكس ترتيب Row تلقائياً → سائق يمين، أمن يسار
  Widget _buildRoleCards() {
    final roles = [
      {
        'key': 'driver',
        'label': l.driver,
        'icon': Icons.directions_bus_rounded,
      },
      {
        'key': 'supervisor',
        'label': l.supervisor,
        'icon': Icons.assignment_outlined,
      },
      {'key': 'security', 'label': l.security, 'icon': Icons.shield_outlined},
    ];

    return Row(
      children: roles.map((role) {
        final key = role['key'] as String;
        final label = role['label'] as String;
        final icon = role['icon'] as IconData;
        final isSelected = _selectedRole == key;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (_isDark
                          ? AppColors.inputFill
                          : AppColors.inputFillLight),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (_isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.08)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: AppDimensions.iconLarge(context),
                    color: isSelected
                        ? AppColors.background
                        : (_isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: AppDimensions.fontSmall(context),
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.background
                          : (_isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
