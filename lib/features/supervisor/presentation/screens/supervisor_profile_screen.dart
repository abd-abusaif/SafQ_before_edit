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
      if (session != null) {
        _currentPassword = session['currentPassword'] ?? '';
      }
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
        title: Text(
          'الصفحة الشخصية',
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                    SizedBox(height: AppDimensions.spacingMedium(context)),
                    _buildLinesCard(),
                    SizedBox(height: AppDimensions.spacingLarge(context)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    final isDark = SafQApp.of(context)?.isDark ?? true;
    final avatarSize = AppDimensions.avatarLarge(context);

    return Column(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
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

        // ← زر تعديل كلمة المرور
        TextButton.icon(
          onPressed: () async {
            final newPassword = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePasswordScreen(
                  idNumber: widget.idNumber,
                  currentPassword: _currentPassword,
                ),
              ),
            );
            if (newPassword != null && mounted) {
              setState(() => _currentPassword = newPassword);
            }
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

        // ← زر Dark/Light mode
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
          _buildCardHeader(
            'معلومات المشرف',
            Icons.person_outline,
            AppColors.primary,
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.person,
                  'الاسم الرباعي',
                  _profile?.fullName ?? '',
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 16,
                ),
                _buildInfoRow(
                  Icons.badge_outlined,
                  'رقم الهوية',
                  _profile?.idNumber ?? '',
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 16,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'رقم الهاتف',
                  _profile?.phone ?? '',
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 16,
                ),
                _buildInfoRow(
                  Icons.door_front_door_outlined,
                  'اسم البوابة',
                  _profile?.gateName ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesCard() {
    final lines = _profile?.lines ?? [];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCardHeader(
            'الخطوط المسؤول عنها',
            Icons.route_outlined,
            const Color(0xFF4FC3F7),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingSmall(context),
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingXSmall(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${lines.length} خطوط',
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium(context),
              0,
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingMedium(context),
            ),
            itemCount: lines.length,
            separatorBuilder: (_, _) => Divider(
              color: _isDark ? Colors.white38 : Colors.black12,
              height: 16,
            ),
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: AppDimensions.avatarSmall(context) * 0.65,
                    height: AppDimensions.avatarSmall(context) * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4FC3F7).withOpacity(0.15),
                      border: Border.all(
                        color: const Color(0xFF4FC3F7).withOpacity(0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF4FC3F7),
                          fontSize: AppDimensions.fontXSmall(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        lines[index],
                        style: GoogleFonts.cairo(
                          color: _isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                          fontSize: AppDimensions.fontMedium(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSmall(context)),
                      Icon(
                        Icons.route_outlined,
                        color: const Color(0xFF4FC3F7),
                        size: AppDimensions.iconSmall(context),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingSmall(context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.cardRadius(context)),
          topRight: Radius.circular(AppDimensions.cardRadius(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: AppDimensions.fontMedium(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppDimensions.spacingSmall(context)),
          Icon(icon, color: color, size: AppDimensions.iconMedium(context)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
            SizedBox(width: AppDimensions.spacingSmall(context)),
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
