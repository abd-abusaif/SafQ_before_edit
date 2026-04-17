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
  OwnerInfoEntity? _ownerInfo;
  VehicleInfoEntity? _vehicleInfo;
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

      final results = await Future.wait([
        _repo.getDriverInfo(widget.idNumber),
        _repo.getLineInfo(widget.idNumber),
        _repo.getOwnerInfo(widget.idNumber),
        _repo.getVehicleInfo(widget.idNumber),
      ]);

      setState(() {
        _driverInfo = results[0] as DriverInfoEntity;
        _lineInfo = results[1] as LineInfoEntity;
        _ownerInfo = results[2] as OwnerInfoEntity;
        _vehicleInfo = results[3] as VehicleInfoEntity;
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

  /// تنسيق التاريخ بصيغة YYYY/MM/DD
  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
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

                    // 1. المعلومات الشخصية
                    if (_driverInfo != null)
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
                          if (_driverInfo!.phone2 != null &&
                              _driverInfo!.phone2!.isNotEmpty)
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

                    // 2. بيانات الخط
                    if (_lineInfo != null)
                      _buildSectionCard(
                        title: l.lineInfo,
                        icon: Icons.route_outlined,
                        color: const Color(0xFF81C784),
                        items: [
                          _InfoItem(
                            icon: Icons.tag,
                            label: l.lineNumber,
                            value: _lineInfo!.lineNumber,
                          ),
                          _InfoItem(
                            icon: Icons.swap_horiz,
                            label: l.lineFromTo,
                            value:
                                '${_lineInfo!.lineFrom} ← ${_lineInfo!.lineTo}',
                          ),
                          _InfoItem(
                            icon: Icons.map_outlined,
                            label: l.lineRoute,
                            value: _lineInfo!.route,
                          ),
                          _InfoItem(
                            icon: Icons.attach_money,
                            label: l.passengerFare,
                            value: _lineInfo!.passengerFare,
                          ),
                        ],
                      ),

                    SizedBox(height: AppDimensions.spacingMedium(context)),

                    // 3. بيانات المالك
                    if (_ownerInfo != null)
                      _buildSectionCard(
                        title: l.ownerInfo,
                        icon: Icons.business_outlined,
                        color: const Color(0xFFFFB74D),
                        items: [
                          _InfoItem(
                            icon: Icons.person,
                            label: l.ownerName,
                            value: _ownerInfo!.ownerName,
                          ),
                          _InfoItem(
                            icon: Icons.badge_outlined,
                            label: l.ownerId,
                            value: _ownerInfo!.ownerId,
                          ),
                          _InfoItem(
                            icon: Icons.phone_outlined,
                            label: l.ownerPhone,
                            value: _ownerInfo!.ownerPhone,
                          ),
                        ],
                      ),

                    SizedBox(height: AppDimensions.spacingMedium(context)),

                    // 4. بيانات المركبة
                    if (_vehicleInfo != null)
                      _buildSectionCard(
                        title: l.vehicleInfo,
                        icon: Icons.directions_bus_outlined,
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
                            icon: Icons.numbers_outlined,
                            label: l.chassisNumber,
                            value: _vehicleInfo!.chassisNumber,
                          ),
                          _InfoItem(
                            icon: Icons.numbers_outlined,
                            label: l.chassisConfirm,
                            value: _vehicleInfo!.chassisNumber,
                          ),
                          _InfoItem(
                            icon: Icons.factory_outlined,
                            label: l.company,
                            value: _vehicleInfo!.company,
                          ),
                          _InfoItem(
                            icon: Icons.directions_car,
                            label: l.model,
                            value: _vehicleInfo!.model,
                          ),
                          _InfoItem(
                            icon: Icons.calendar_today,
                            label: l.productionYear,
                            value: _vehicleInfo!.productionYear,
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
                          // ★ تاريخ انتهاء السماح بالتحميل (بدلاً من مسموح/ممنوع)
                          _InfoItem(
                            icon: Icons.local_shipping_outlined,
                            label: 'تاريخ انتهاء السماح بالتحميل',
                            value: _vehicleInfo!.loadingAllowedUntil,
                            isDate: true,
                            isLoadingDate: true,
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
            _roleLabel,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium(context)),
        _buildActionButton(
          icon: Icons.lock_reset,
          label: l.editPassword,
          onTap: () async {
            final newPass = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => ChangePasswordScreen(
                  idNumber: widget.idNumber,
                  currentPassword: _currentPassword,
                ),
              ),
            );
            if (newPass != null && mounted) {
              setState(() => _currentPassword = newPass);
            }
          },
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
        _buildActionButton(
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          label: isDark ? l.switchLight : l.switchDark,
          onTap: () => SafQApp.of(context)?.toggleTheme(),
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
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
        children: [
          // ── رأس البطاقة ───────────────────────
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
            child: Directionality(
              textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: AppDimensions.iconMedium(context),
                  ),
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: color,
                        fontSize: AppDimensions.fontMedium(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── محتوى البطاقة ─────────────────────
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
                        color: _isDark ? Colors.white12 : Colors.black12,
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

  // ═══════════════════════════════════════════════════════════════════════════
  //  صف معلومات — تصميم ثابت ومتين
  //  البنية (RTL): [أيقونة] [label] ............... [value] [شارة حالة]
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInfoRow(_InfoItem item, Color sectionColor) {
    bool isExpired = false;
    bool isNearExpiry = false;
    int daysLeft = 0;

    if (item.isDate) {
      try {
        final date = DateTime.parse(item.value);
        final diff = date.difference(DateTime.now()).inDays;
        daysLeft = diff;
        isExpired = diff < 0;
        isNearExpiry = item.isLoadingDate
            ? (diff >= 0 && diff <= 3)
            : (diff >= 0 && diff <= 15);
      } catch (_) {}
    }

    final displayValue = item.isDate ? _formatDate(item.value) : item.value;

    final valueColor =
        item.customColor ??
        (isExpired
            ? Colors.redAccent
            : isNearExpiry
            ? Colors.orange
            : _isDark
            ? AppColors.textPrimary
            : Colors.black87);

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // الأيقونة
          Icon(
            item.icon,
            color: sectionColor.withOpacity(0.7),
            size: AppDimensions.iconSmall(context),
          ),
          SizedBox(width: AppDimensions.spacingSmall(context)),

          // الـ label
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontXSmall(context),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingSmall(context)),

          // القيمة
          Expanded(
            flex: 3,
            child: _buildValueContent(
              displayValue: displayValue,
              item: item,
              valueColor: valueColor,
              isExpired: isExpired,
              isNearExpiry: isNearExpiry,
              daysLeft: daysLeft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueContent({
    required String displayValue,
    required _InfoItem item,
    required Color valueColor,
    required bool isExpired,
    required bool isNearExpiry,
    required int daysLeft,
  }) {
    // حقل تاريخ التحميل: تاريخ + شارة حالة
    if (item.isLoadingDate) {
      final badgeColor = isExpired
          ? Colors.redAccent
          : isNearExpiry
          ? Colors.orange
          : Colors.green;

      final badgeText = isExpired
          ? l.expiredLabel
          : 'متبقي ${daysLeft.abs()} ${l.dayLabel}';

      return Column(
        crossAxisAlignment: l.isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayValue,
            textAlign: l.isArabic ? TextAlign.end : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: badgeColor,
              fontSize: AppDimensions.fontSmall(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: badgeColor.withOpacity(0.5),
                width: 0.8,
              ),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.cairo(
                color: badgeColor,
                fontSize: AppDimensions.fontXSmall(context) * 0.9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    // باقي الحقول — نص عادي
    return Text(
      displayValue,
      textAlign: l.isArabic ? TextAlign.end : TextAlign.start,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: GoogleFonts.cairo(
        color: valueColor,
        fontSize: AppDimensions.fontSmall(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isDate;
  final bool isLoadingDate;
  final Color? customColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isDate = false,
    this.isLoadingDate = false,
    this.customColor,
  });
}
