import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String idNumber;
  final String currentPassword;

  const ChangePasswordScreen({
    super.key,
    required this.idNumber,
    required this.currentPassword,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _savedPassword = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context); // ← الترجمة

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final session = await SessionManager.getSession();
    if (session != null && mounted) {
      setState(() {
        _savedPassword = session['currentPassword'] ?? '';
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // ← عند ربط الـ API استبدل بـ:
      // await http.post(
      //   Uri.parse('$baseUrl/api/auth/change-password'),
      //   headers: {'Authorization': 'Bearer $token'},
      //   body: {
      //     'id_number':    widget.idNumber,
      //     'old_password': _oldPassCtrl.text.trim(),
      //     'new_password': _newPassCtrl.text.trim(),
      //   },
      // );

      await Future.delayed(const Duration(seconds: 1));
      await SessionManager.updatePassword(_newPassCtrl.text.trim());

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius(context),
            ),
            side: const BorderSide(color: Colors.green, width: 1),
          ),
          icon: Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: AppDimensions.iconXLarge(context),
          ),
          title: Text(
            l.passwordChanged,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          content: Text(
            l.passwordChangedMsg,
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
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, _newPassCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
    } catch (e) {
      _showErrorDialog(l.unexpectedErr);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
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
          l.error,
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
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textAlign = l.isArabic ? TextAlign.right : TextAlign.left;
    final textDir = l.isArabic ? TextDirection.rtl : TextDirection.ltr;
    final crossAxis = l.isArabic
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l.changePassword,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            l.isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            size: AppDimensions.iconMedium(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacingLarge(context)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: crossAxis,
            children: [
              SizedBox(height: AppDimensions.spacingMedium(context)),
              Center(
                child: Container(
                  width: AppDimensions.avatarLarge(context),
                  height: AppDimensions.avatarLarge(context),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    color: AppColors.primary,
                    size: AppDimensions.iconXLarge(context),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacingLarge(context)),

              // ← كلمة المرور الحالية
              _buildLabel(l.currentPassword),
              SizedBox(height: AppDimensions.spacingSmall(context)),
              TextFormField(
                controller: _oldPassCtrl,
                obscureText: _obscureOld,
                textAlign: textAlign,
                textDirection: textDir,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontMedium(context),
                ),
                decoration: InputDecoration(
                  hintText: l.currentPassHint,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      size: AppDimensions.iconMedium(context),
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l.enterCurrentPass;
                  if (v != _savedPassword) return l.wrongCurrentPass;
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingMedium(context)),

              // ← كلمة المرور الجديدة
              _buildLabel(l.newPassword),
              SizedBox(height: AppDimensions.spacingSmall(context)),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                textAlign: textAlign,
                textDirection: textDir,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontMedium(context),
                ),
                decoration: InputDecoration(
                  hintText: l.newPassHint,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      size: AppDimensions.iconMedium(context),
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l.enterNewPass;
                  if (v.length < 6) return l.passMin6;
                  if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v))
                    return l.passSymbol;
                  if (v == _savedPassword) return l.passSame;
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingMedium(context)),

              // ← تأكيد كلمة المرور
              _buildLabel(l.confirmPassword),
              SizedBox(height: AppDimensions.spacingSmall(context)),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                textAlign: textAlign,
                textDirection: textDir,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontMedium(context),
                ),
                decoration: InputDecoration(
                  hintText: l.confirmPassHint,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      size: AppDimensions.iconMedium(context),
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l.confirmPass;
                  if (v != _newPassCtrl.text) return l.passNoMatch;
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingXLarge(context)),

              // ← زر الحفظ
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSave,
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
                          l.save,
                          style: GoogleFonts.cairo(
                            color: AppColors.background,
                            fontSize: AppDimensions.fontLarge(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.cairo(
        color: _isDark ? AppColors.textSecondary : Colors.black54,
        fontSize: AppDimensions.fontSmall(context),
      ),
    );
  }
}
