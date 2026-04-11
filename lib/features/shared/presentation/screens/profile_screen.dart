import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/data/repositories/driver_profile_repository_impl.dart';
import '../../../driver/domain/entities/driver_profile_entity.dart';
import 'change_password_screen.dart';
import '../../../../main.dart';

class ProfileScreen extends StatefulWidget {
  final String driverName;
  final String idNumber;
  final String role;
  final String currentPassword;

  const ProfileScreen({
    super.key,
    required this.driverName,
    required this.idNumber,
    required this.role,
    required this.currentPassword,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = DriverProfileRepositoryImpl();

  DriverInfoEntity? _driverInfo;
  LineInfoEntity? _lineInfo;
  VehicleInfoEntity? _vehicleInfo;
  bool _isLoading = true;
  String _currentPassword = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context); // ← الترجمة

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
      final results = await Future.wait([
        _repo.getDriverInfo(widget.idNumber),
        _repo.getLineInfo(widget.idNumber),
        _repo.getVehicleInfo(widget.idNumber),
      ]);
      setState(() {
        _driverInfo = results[0] as DriverInfoEntity;
        _lineInfo = results[1] as LineInfoEntity;
        _vehicleInfo = results[2] as VehicleInfoEntity;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String get _initials {
    final parts = widget.driverName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return parts.first[0];
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'driver':
        return l.driver;
      case 'supervisor':
        return l.supervisor;
      case 'security':
        return l.security;
      default:
        return widget.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l.personalPage,
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

                    // ← 1. معلومات السائق
                    _buildSectionCard(
                      title: l.driverInfo,
                      icon: Icons.person_outline,
                      color: AppColors.primary,
                      items: [
                        _InfoItem(
                          icon: Icons.person,
                          label: l.fullName,
                          value: _driverInfo!.fullName,
                        ),
                        _InfoItem(
                          icon: Icons.badge_outlined,
                          label: l.idNumberLabel,
                          value: _driverInfo!.idNumber,
                        ),
                        _InfoItem(
                          icon: Icons.phone_outlined,
                          label: l.phone1,
                          value: _driverInfo!.phone1,
                        ),
                        if (_driverInfo!.phone2 != null)
                          _InfoItem(
                            icon: Icons.phone_outlined,
                            label: l.phone2,
                            value: _driverInfo!.phone2!,
                          ),
                        _InfoItem(
                          icon: Icons.credit_card,
                          label: l.licenseNumber,
                          value: _driverInfo!.licenseNumber,
                        ),
                        _InfoItem(
                          icon: Icons.star_outline,
                          label: l.licenseGrade,
                          value: _driverInfo!.licenseGrade,
                        ),
                        _InfoItem(
                          icon: Icons.calendar_today,
                          label: l.licenseExpiry,
                          value: _driverInfo!.licenseExpiry,
                          isDate: true,
                        ),
                        _InfoItem(
                          icon: Icons.medical_services_outlined,
                          label: l.medicalExpiry,
                          value: _driverInfo!.medicalExpiry,
                          isDate: true,
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingMedium(context)),

                    // ← 2. معلومات الخط
                    _buildSectionCard(
                      title: l.lineInfo,
                      icon: Icons.route_outlined,
                      color: const Color(0xFF81C784),
                      items: [
                        _InfoItem(
                          icon: Icons.tag,
                          label: l.lineNumber,
                          value:
                              '${l.translate('line_label')} ${_lineInfo!.lineNumber} : ${_lineInfo!.lineName}',
                        ),
                        _InfoItem(
                          icon: Icons.attach_money,
                          label: l.passengerFare,
                          value: _lineInfo!.passengerFare,
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spacingMedium(context)),

                    // ← 3. معلومات المركبة
                    _buildSectionCard(
                      title: l.vehicleInfo,
                      icon: Icons.directions_car_outlined,
                      color: const Color(0xFF4FC3F7),
                      items: [
                        _InfoItem(
                          icon: Icons.confirmation_number_outlined,
                          label: l.vehicleNumber,
                          value: _vehicleInfo!.vehicleNumber,
                        ),
                        _InfoItem(
                          icon: Icons.qr_code,
                          label: l.vehicleCode,
                          value: _vehicleInfo!.vehicleCode,
                        ),
                        _InfoItem(
                          icon: Icons.directions_bus_outlined,
                          label: l.model,
                          value: _vehicleInfo!.model,
                        ),
                        _InfoItem(
                          icon: Icons.drive_eta_outlined,
                          label: l.driverType,
                          value: _vehicleInfo!.driverType,
                        ),
                        _InfoItem(
                          icon: Icons.event_seat_outlined,
                          label: l.seats,
                          value: _vehicleInfo!.seats,
                        ),
                        _InfoItem(
                          icon: Icons.calendar_today,
                          label: l.operationExpiry,
                          value: _vehicleInfo!.operationExpiry,
                          isDate: true,
                        ),
                        _InfoItem(
                          icon: Icons.calendar_today,
                          label: l.vehicleLicExpiry,
                          value: _vehicleInfo!.vehicleLicExpiry,
                          isDate: true,
                        ),
                        _InfoItem(
                          icon: Icons.security_outlined,
                          label: l.insuranceExpiry,
                          value: _vehicleInfo!.insuranceExpiry,
                          isDate: true,
                        ),
                        if (_vehicleInfo!.chassisNumber != null)
                          _InfoItem(
                            icon: Icons.numbers_outlined,
                            label: l.chassisNumber,
                            value: _vehicleInfo!.chassisNumber!,
                          ),
                      ],
                    ),
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
          widget.driverName,
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
            _roleLabel,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium(context)),

        // ← زر تعديل كلمة المرور
        _buildActionButton(
          icon: Icons.lock_reset,
          label: l.editPassword,
          onTap: () async {
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
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),

        // ← زر Dark/Light mode
        _buildActionButton(
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          label: isDark ? l.switchLight : l.switchDark,
          onTap: () => SafQApp.of(context)?.toggleTheme(),
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),

        // ← زر تغيير اللغة ✅
        _buildActionButton(
          icon: Icons.language,
          label: l.switchLanguage, // ← "English" أو "عربي"
          onTap: () {
            final newLang = l.isArabic ? 'en' : 'ar';
            SafQApp.of(context)?.changeLanguage(newLang);
          },
        ),
      ],
    );
  }

  // ← Widget موحد للأزرار
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
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
              mainAxisAlignment: l.isArabic
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!l.isArabic) ...[
                  Icon(
                    icon,
                    color: color,
                    size: AppDimensions.iconMedium(context),
                  ),
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                ],
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: color,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (l.isArabic) ...[
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                  Icon(
                    icon,
                    color: color,
                    size: AppDimensions.iconMedium(context),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    _buildInfoRow(entry.value, color),
                    if (!isLast)
                      Divider(
                        color: _isDark ? Colors.white38 : Colors.black12,
                        height: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item, Color color) {
    bool isExpired = false;
    bool isNearExpiry = false;

    if (item.isDate) {
      try {
        final date = DateTime.parse(item.value);
        final diff = date.difference(DateTime.now()).inDays;
        isExpired = diff < 0;
        isNearExpiry = diff >= 0 && diff <= 30;
      } catch (_) {}
    }

    final valueColor = isExpired
        ? Colors.redAccent
        : isNearExpiry
        ? Colors.orange
        : _isDark
        ? AppColors.textPrimary
        : Colors.black87;

    // ← اتجاه الصف حسب اللغة
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ← القيمة (يسار في العربي، يمين في الإنجليزي)
        if (!l.isArabic)
          Row(
            children: [
              if (isExpired || isNearExpiry) ...[
                Icon(
                  Icons.warning_amber_rounded,
                  color: isExpired ? Colors.redAccent : Colors.orange,
                  size: AppDimensions.iconSmall(context),
                ),
                SizedBox(width: AppDimensions.spacingXSmall(context)),
              ],
              Text(
                item.value,
                style: GoogleFonts.cairo(
                  color: valueColor,
                  fontSize: AppDimensions.fontMedium(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

        // ← الـ label والأيقونة
        Row(
          children: [
            if (l.isArabic) ...[
              Text(
                item.label,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
              SizedBox(width: AppDimensions.spacingSmall(context)),
              Icon(
                item.icon,
                color: color.withOpacity(0.7),
                size: AppDimensions.iconSmall(context),
              ),
            ] else ...[
              Icon(
                item.icon,
                color: color.withOpacity(0.7),
                size: AppDimensions.iconSmall(context),
              ),
              SizedBox(width: AppDimensions.spacingSmall(context)),
              Text(
                item.label,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
            ],
          ],
        ),

        // ← القيمة في العربي (يسار)
        if (l.isArabic)
          Row(
            children: [
              if (isExpired || isNearExpiry) ...[
                Icon(
                  Icons.warning_amber_rounded,
                  color: isExpired ? Colors.redAccent : Colors.orange,
                  size: AppDimensions.iconSmall(context),
                ),
                SizedBox(width: AppDimensions.spacingXSmall(context)),
              ],
              Text(
                item.value,
                style: GoogleFonts.cairo(
                  color: valueColor,
                  fontSize: AppDimensions.fontMedium(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isDate;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isDate = false,
  });
}
