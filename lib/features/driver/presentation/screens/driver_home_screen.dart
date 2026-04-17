import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../data/repositories/driver_profile_repository_impl.dart';
import '../../domain/entities/queue_entry_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../widgets/queue_item_widget.dart';

class DriverHomeScreen extends StatefulWidget {
  final String driverName;
  final String idNumber;
  final String lineFrom;
  final String lineTo;

  const DriverHomeScreen({
    super.key,
    required this.driverName,
    required this.idNumber,
    required this.lineFrom,
    required this.lineTo,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _repo = DriverRepositoryImpl();
  final _profileRepo = DriverProfileRepositoryImpl();

  List<QueueEntryEntity> _queueList = [];
  QueueEntryEntity? _myEntry;
  VehicleInfoEntity? _vehicleInfo;
  DriverInfoEntity? _driverInfo;

  bool _isLoading = true;
  bool _isRegistered = true;
  bool _hasBlockViolation = false;
  String _rejectionReason = '';

  /// عدد الخانات المسموح بالتحميل من API
  int _allowedSlots = 3;

  Timer? _refreshTimer;
  Timer? _countdownTimer;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadData(),
    );
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repo.getQueueList(),
        _repo.getMyQueueEntry(widget.idNumber),
        _profileRepo.getVehicleInfo(widget.idNumber),
        _profileRepo.getDriverInfo(widget.idNumber),
        _repo.getAllowedSlots(),
      ]);

      final allList = results[0] as List<QueueEntryEntity>;
      final filtered = allList
          .where(
            (e) => e.lineFrom == widget.lineFrom && e.lineTo == widget.lineTo,
          )
          .toList();
      final myEntry = results[1] as QueueEntryEntity?;
      final vehicleInfo = results[2] as VehicleInfoEntity;
      final driverInfo = results[3] as DriverInfoEntity;
      final allowedSlots = results[4] as int;

      setState(() {
        _hasBlockViolation = false;
        _isRegistered = true;
        _rejectionReason = '';
        _allowedSlots = allowedSlots;
        _queueList = _isRegistered ? filtered : [];
        _myEntry = _isRegistered ? myEntry : null;
        _vehicleInfo = vehicleInfo;
        _driverInfo = driverInfo;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── حساب الوقت المتبقي لتاريخ التحميل ───────────
  String _loadingCountdown(DateTime validity) {
    final diff = validity.difference(DateTime.now());
    if (diff.isNegative) return l.expiredLabel;
    if (diff.inDays > 0) return 'متبقي ${diff.inDays} ${l.dayLabel}';
    if (diff.inHours > 0) return 'متبقي ${diff.inHours} ${l.hourLabel}';
    return 'متبقي ${diff.inMinutes} ${l.minuteLabel}';
  }

  bool _isLoadingExpiringSoon(DateTime validity) {
    final hours = validity.difference(DateTime.now()).inHours;
    return hours <= 24 && hours >= 0;
  }

  bool _isLoadingExpired(DateTime validity) => DateTime.now().isAfter(validity);

  int _daysRemaining(String dateStr) {
    try {
      return DateTime.parse(dateStr).difference(DateTime.now()).inDays;
    } catch (_) {
      return 999;
    }
  }

  bool get _operatingLicenseExpired =>
      _vehicleInfo != null && _daysRemaining(_vehicleInfo!.operationExpiry) < 0;

  bool get _vehicleLicenseExpired =>
      _vehicleInfo != null &&
      _daysRemaining(_vehicleInfo!.vehicleLicExpiry) < 0;

  bool get _canRegisterQueue =>
      !_operatingLicenseExpired &&
      !_vehicleLicenseExpired &&
      (_vehicleInfo?.loadingAllowed ?? true);

  /// هل الدور الحالي ضمن الخانات المسموح بالتحميل؟
  bool get _isInAllowedSlot =>
      _myEntry != null && _myEntry!.queuePosition <= _allowedSlots;

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return parts.first[0];
  }

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
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),

                    // تنبيه المخالفة
                    if (_hasBlockViolation)
                      SliverToBoxAdapter(child: _buildViolationWarning()),

                    // تنبيه حظر تسجيل الدور
                    if (!_canRegisterQueue)
                      SliverToBoxAdapter(child: _buildRegisterBlockedBanner()),

                    // بطاقة الدور الرئيسية
                    if (_isRegistered)
                      SliverToBoxAdapter(child: _buildInfoCard()),

                    if (!_isRegistered)
                      SliverToBoxAdapter(child: _buildRejectedCard()),

                    // بانر تاريخ التحميل المسموح
                    if (_isRegistered && _myEntry?.loadingValidityDate != null)
                      SliverToBoxAdapter(child: _buildLoadingValidityBanner()),

                    // تنبيهات الرخص
                    SliverToBoxAdapter(child: _buildLicenseWarnings()),

                    // عنوان حالة الدور
                    if (_isRegistered)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppDimensions.spacingMedium(context),
                            AppDimensions.spacingLarge(context),
                            AppDimensions.spacingMedium(context),
                            AppDimensions.spacingSmall(context),
                          ),
                          child: Text(
                            l.queueStatus,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(
                              color: _isDark
                                  ? AppColors.textPrimary
                                  : Colors.black87,
                              fontSize: AppDimensions.fontLarge(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // قائمة الدور
                    if (_isRegistered)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMedium(context),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entry = _queueList[index];
                            return QueueItemWidget(
                              entry: entry,
                              isCurrentDriver:
                                  entry.queuePosition ==
                                  _myEntry?.queuePosition,
                              allowedSlots: _allowedSlots,
                            );
                          }, childCount: _queueList.length),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  الهيدر
  // ═══════════════════════════════════════════════
  Widget _buildHeader() {
    final firstName =
        _driverInfo?.firstName ?? widget.driverName.split(' ').first;
    final avatarSize = AppDimensions.avatarSmall(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الأيقونة على الشمال
          _buildAvatar(avatarSize),
          // الترحيب والاسم على اليمين
          Text(
            '${l.welcomeUser} $firstName',
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.2),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Center(
        child: Text(
          _getInitials(widget.driverName),
          style: GoogleFonts.cairo(
            color: AppColors.primary,
            fontSize: AppDimensions.fontMedium(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  بطاقة الدور الرئيسية
  //  - رقم الدور يتلوّن أخضر إذا ضمن الخانات المسموحة
  //  - وقت الدخول من RFID
  // ═══════════════════════════════════════════════
  Widget _buildInfoCard() {
    final positionColor = _isInAllowedSlot ? Colors.green : AppColors.primary;

    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingMedium(context),
                AppDimensions.spacingMedium(context),
                AppDimensions.spacingMedium(context),
                AppDimensions.spacingSmall(context),
              ),
              child: Row(
                children: [
                  _buildCardLabel(l.queueNumber),
                  _buildDividerVertical(),
                  _buildCardLabel(l.queueTime),
                ],
              ),
            ),
            Divider(
              color: _isDark ? Colors.white12 : Colors.black12,
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingMedium(context),
                AppDimensions.spacingSmall(context),
                AppDimensions.spacingMedium(context),
                AppDimensions.spacingMedium(context),
              ),
              child: Row(
                children: [
                  // رقم الدور — أخضر إذا ضمن المسموح
                  Expanded(
                    child: Text(
                      '${_myEntry?.queuePosition ?? '-'}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: positionColor,
                        fontSize: AppDimensions.fontXLarge(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDividerVertical(),
                  // وقت دخول المركبة (RFID) فقط
                  Expanded(
                    child: Text(
                      _myEntry?.entryTime ?? '-',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: _isDark ? AppColors.textPrimary : Colors.black87,
                        fontSize: AppDimensions.fontLarge(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  بانر تاريخ التحميل المسموح
  // ═══════════════════════════════════════════════
  Widget _buildLoadingValidityBanner() {
    final validity = _myEntry!.loadingValidityDate!;
    final expired = _isLoadingExpired(validity);
    final soon = _isLoadingExpiringSoon(validity);

    // يظهر دائماً (ليس فقط عند الانتهاء القريب)
    final color = expired
        ? Colors.redAccent
        : soon
        ? Colors.orange
        : AppColors.primary;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(
              expired ? Icons.error_rounded : Icons.calendar_today_rounded,
              color: color,
              size: AppDimensions.iconSmall(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expired ? l.loadingValidityExpired : l.loadingValidity,
                    style: GoogleFonts.cairo(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontSmall(context),
                    ),
                  ),
                  Text(
                    _formatDate(validity.toIso8601String().split('T').first),
                    style: GoogleFonts.cairo(
                      color: color,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  Text(
                    _loadingCountdown(validity),
                    style: GoogleFonts.cairo(
                      color: color.withOpacity(0.8),
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  تنبيهات الرخص — بدون إيموجي — RTL
  // ═══════════════════════════════════════════════
  Widget _buildLicenseWarnings() {
    if (_vehicleInfo == null && _driverInfo == null) {
      return const SizedBox.shrink();
    }

    final List<_LicenseItem> items = [];

    if (_vehicleInfo != null) {
      items.add(
        _LicenseItem(
          label: l.operatingLicense,
          days: _daysRemaining(_vehicleInfo!.operationExpiry),
          dateStr: _vehicleInfo!.operationExpiry,
        ),
      );
      items.add(
        _LicenseItem(
          label: l.vehicleLicWarn,
          days: _daysRemaining(_vehicleInfo!.vehicleLicExpiry),
          dateStr: _vehicleInfo!.vehicleLicExpiry,
        ),
      );
    }
    if (_driverInfo != null) {
      items.add(
        _LicenseItem(
          label: l.driverLicWarn,
          days: _daysRemaining(_driverInfo!.licenseExpiry),
          dateStr: _driverInfo!.licenseExpiry,
        ),
      );
    }

    final warnings = items.where((i) => i.days <= 15).toList();
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: warnings.map((item) {
            final expired = item.days < 0;
            final color = expired ? Colors.redAccent : Colors.orange;
            final remainingText = expired
                ? l.licenseExpiredWarn
                : 'متبقي ${item.days.abs()} ${l.dayLabel}';

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: AppDimensions.spacingXSmall(context),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMedium(context),
                vertical: AppDimensions.spacingSmall(context),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
                border: Border.all(color: color.withOpacity(0.6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // يسار: "متبقي X يوم" أو "منتهية الصلاحية"
                  Text(
                    remainingText,
                    style: GoogleFonts.cairo(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  // يمين: اسم الرخصة
                  Text(
                    item.label,
                    style: GoogleFonts.cairo(
                      color: color,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  بانر حظر تسجيل الدور
  // ═══════════════════════════════════════════════
  Widget _buildRegisterBlockedBanner() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1.5),
      ),
      child: Text(
        l.registerBlocked,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: AppDimensions.fontSmall(context),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  تنبيه المخالفة
  // ═══════════════════════════════════════════════
  Widget _buildViolationWarning() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        0,
      ),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(
              Icons.block,
              color: Colors.redAccent,
              size: AppDimensions.iconLarge(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Expanded(
              child: Text(
                l.violationBlockWarn,
                style: GoogleFonts.cairo(
                  color: Colors.redAccent,
                  fontSize: AppDimensions.fontSmall(context),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  بطاقة الرفض
  // ═══════════════════════════════════════════════
  Widget _buildRejectedCard() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      padding: EdgeInsets.all(AppDimensions.spacingLarge(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.redAccent,
            size: AppDimensions.iconXLarge(context),
          ),
          SizedBox(height: AppDimensions.spacingSmall(context)),
          Text(
            l.rejectedQueue,
            style: GoogleFonts.cairo(
              color: Colors.redAccent,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacingSmall(context)),
          Text(
            _rejectionReason.isNotEmpty ? _rejectionReason : l.rejectedMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontMedium(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────
  Widget _buildCardLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: _isDark ? AppColors.textSecondary : Colors.black54,
          fontSize: AppDimensions.fontXSmall(context),
        ),
      ),
    );
  }

  Widget _buildCardValue(String text, {bool isSmall = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: _isDark ? AppColors.textPrimary : Colors.black87,
          fontSize: isSmall
              ? AppDimensions.fontSmall(context)
              : AppDimensions.fontXLarge(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDividerVertical() {
    return Container(
      width: 0.5,
      height: AppDimensions.spacingXLarge(context),
      color: _isDark ? Colors.white12 : Colors.black12,
    );
  }
}

// helper data class
class _LicenseItem {
  final String label;
  final int days;
  final String dateStr;
  const _LicenseItem({
    required this.label,
    required this.days,
    required this.dateStr,
  });
}
