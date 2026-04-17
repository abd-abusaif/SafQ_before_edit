// features/shared/presentation/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';

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
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
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
              onPressed: () => Navigator.pop(ctx),
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
      ),
    );
    if (mounted) Navigator.pop(context, _newCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = l.isArabic;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
          ),
          title: Text(
            l.changePassword,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: AppDimensions.spacingMedium(context)),
                _buildField(
                  controller: _currentCtrl,
                  label: l.currentPassword,
                  hint: l.currentPassHint,
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.enterCurrentPass;
                    if (v != widget.currentPassword) return l.wrongCurrentPass;
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                _buildField(
                  controller: _newCtrl,
                  label: l.newPassword,
                  hint: l.newPassHint,
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.enterNewPass;
                    if (v.length < 6) return l.passMin6;
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v))
                      return l.passSymbol;
                    if (v == widget.currentPassword) return l.passSame;
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                _buildField(
                  controller: _confirmCtrl,
                  label: l.confirmPassword,
                  hint: l.confirmPassHint,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.confirmPass;
                    if (v != _newCtrl.text) return l.passNoMatch;
                    return null;
                  },
                ),
                SizedBox(height: AppDimensions.spacingXLarge(context)),
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
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: l.isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontSmall(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.spacingXSmall(context)),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
          textDirection: TextDirection.ltr, // كلمة المرور دائماً LTR
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontMedium(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black38,
              fontSize: AppDimensions.fontSmall(context),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                size: AppDimensions.iconMedium(context),
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
