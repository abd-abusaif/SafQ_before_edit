// features/supervisor/presentation/screens/supervisor_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../shared/presentation/screens/change_password_screen.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/supervisor_entity.dart';
import '../../../../main.dart';

class SupervisorProfileScreen extends StatefulWidget {
  final String supervisorName;
  final String idNumber;

  const SupervisorProfileScreen({
    super.key,
    required this.supervisorName,
    required this.idNumber,
  });

  @override
  State<SupervisorProfileScreen> createState() =>
      _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen> {
  final _repo = SupervisorRepositoryImpl();
  SupervisorProfileEntity? _profile;
  bool _isLoading = true;
  String _currentPassword = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) _currentPassword = session['currentPassword'] ?? '';
      final profile = await _repo.getProfile(widget.idNumber);
      setState(() => _profile = profile);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String get _initials {
    final parts = widget.supervisorName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return parts.first[0];
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
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            l.personalPage,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
                  child: Column(
                    children: [
                      SizedBox(height: AppDimensions.spacingSmall(context)),
                      _buildAvatarSection(),
                      SizedBox(height: AppDimensions.spacingLarge(context)),
                      _buildInfoCard(),
                      SizedBox(height: AppDimensions.spacingLarge(context)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final isDark = SafQApp.of(context)?.isDark ?? true;
    final size = AppDimensions.avatarLarge(context);
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.2),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Text(
              _initials,
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: AppDimensions.fontXLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
        Text(
          widget.supervisorName,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontLarge(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.spacingXSmall(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium(context),
            vertical: AppDimensions.spacingXSmall(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Text(
            l.supervisor,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium(context)),

        // زر تعديل كلمة المرور
        _buildActionButton(
          icon: Icons.lock_reset,
          label: l.editPassword,
          onTap: () async {
            final np = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePasswordScreen(
                  idNumber: widget.idNumber,
                  currentPassword: _currentPassword,
                ),
              ),
            );
            if (np != null && mounted) setState(() => _currentPassword = np);
          },
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),

        // زر تبديل الثيم
        _buildActionButton(
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          label: isDark ? l.switchLight : l.switchDark,
          onTap: () => SafQApp.of(context)?.toggleTheme(),
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),

        // زر تغيير اللغة
        _buildActionButton(
          icon: Icons.language,
          label: l.switchLanguage,
          onTap: () {
            final newLang = l.isArabic ? 'en' : 'ar';
            SafQApp.of(context)?.changeLanguage(newLang);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium(context),
          vertical: AppDimensions.spacingXSmall(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.iconSmall(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: AppDimensions.fontSmall(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس البطاقة
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius(context)),
                topRight: Radius.circular(AppDimensions.cardRadius(context)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: AppDimensions.iconMedium(context),
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Text(
                  l.translate('personal_info'),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _infoRow(
                  Icons.person,
                  l.translate('name_label'),
                  _profile?.fullName ?? widget.supervisorName,
                ),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 20,
                ),
                _infoRow(
                  Icons.badge_outlined,
                  l.translate('id_label'),
                  _profile?.idNumber ?? widget.idNumber,
                ),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 20,
                ),
                _infoRow(
                  Icons.phone_outlined,
                  l.translate('phone_info_label'),
                  _profile?.phone ?? '---',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final isRtl = l.isArabic;
    // القيم الرقمية (أرقام هاتف، هوية) تُعرض باتجاه LTR دائماً
    final isNumericValue = RegExp(r'^[\d\s\+\-\.]+$').hasMatch(value.trim());

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary.withOpacity(0.7),
          size: AppDimensions.iconSmall(context),
        ),
        SizedBox(width: AppDimensions.spacingXSmall(context)),
        Expanded(
          flex: 2,
          child: Text(
            label,
            textAlign: isRtl ? TextAlign.start : TextAlign.start,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontXSmall(context),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Directionality(
            textDirection: isNumericValue
                ? TextDirection.ltr
                : (isRtl ? TextDirection.rtl : TextDirection.ltr),
            child: Text(
              value,
              textAlign: isNumericValue
                  ? (isRtl ? TextAlign.right : TextAlign.left)
                  : (isRtl ? TextAlign.end : TextAlign.start),
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontSmall(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
