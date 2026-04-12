// features/supervisor/presentation/screens/supervisor_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'الصفحة الشخصية',
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
            'مشرف خط',
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium(context)),
        // تعديل كلمة المرور
        TextButton.icon(
          onPressed: () async {
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
          icon: Icon(
            Icons.lock_reset,
            color: AppColors.primary,
            size: AppDimensions.iconSmall(context),
          ),
          label: Text(
            'تعديل كلمة المرور',
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.08),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingXSmall(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
        // تبديل الثيم
        GestureDetector(
          onTap: () => SafQApp.of(context)?.toggleTheme(),
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
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.primary,
                  size: AppDimensions.iconSmall(context),
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Text(
                  isDark ? 'التحويل للفاتح' : 'التحويل للداكن',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.end,
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'المعلومات الشخصية',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: AppDimensions.iconMedium(context),
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
                  'الاسم',
                  _profile?.fullName ?? widget.supervisorName,
                ),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 20,
                ),
                _infoRow(
                  Icons.badge_outlined,
                  'رقم الهوية',
                  _profile?.idNumber ?? widget.idNumber,
                ),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 20,
                ),
                _infoRow(
                  Icons.phone_outlined,
                  'رقم الهاتف',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontMedium(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontXSmall(context),
              ),
            ),
            SizedBox(width: AppDimensions.spacingXSmall(context)),
            Icon(
              icon,
              color: AppColors.primary.withOpacity(0.7),
              size: AppDimensions.iconSmall(context),
            ),
          ],
        ),
      ],
    );
  }
}
