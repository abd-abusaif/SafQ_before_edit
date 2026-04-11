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

// ── بيانات المركبات المسجّلة دخولاً ────────────────
class _EnteredVehicle {
  final String vehicleNumber;
  final String entryTime;
  const _EnteredVehicle(this.vehicleNumber, this.entryTime);
}

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

  // ── Timers ─────────────────────────────────────────
  Timer? _refreshTimer;
  Timer? _countdownTimer;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  // ── Mock: المركبات المسجّلة دخولاً ───────────────
  final List<_EnteredVehicle> _enteredVehicles = const [
    _EnteredVehicle('أ ب ت 001', '6:30 ص'),
    _EnteredVehicle('ح خ د 202', '6:45 ص'),
    _EnteredVehicle('ر ز س 303', '7:00 ص'),
    _EnteredVehicle('ش ص ض 404', '7:10 ص'),
    _EnteredVehicle('ر ح ن 123', '7:20 ص'),
  ];

  // ── Mock: خانات شاغرة ────────────────────────────
  final int _availableSlots = 3;

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

      setState(() {
        _hasBlockViolation = false;
        _isRegistered = true;
        _rejectionReason = '';
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
    if (diff.inDays > 0)
      return '${l.dayLabel.split(' ')[0] == 'متبقي' ? '' : ''}متبقي ${diff.inDays} ${l.dayLabel}';
    if (diff.inHours > 0) return 'متبقي ${diff.inHours} ${l.hourLabel}';
    return 'متبقي ${diff.inMinutes} ${l.minuteLabel}';
  }

  bool _isLoadingExpiringSoon(DateTime validity) {
    final hours = validity.difference(DateTime.now()).inHours;
    return hours <= 24 && hours >= 0;
  }

  bool _isLoadingExpired(DateTime validity) => DateTime.now().isAfter(validity);

  // ── منطق تنبيه الرخص (15 يوماً) ─────────────────
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return parts.first[0];
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

                    // ⛔ تنبيه المخالفة
                    if (_hasBlockViolation)
                      SliverToBoxAdapter(child: _buildViolationWarning()),

                    // ⛔ تنبيه حظر تسجيل الدور
                    if (!_canRegisterQueue)
                      SliverToBoxAdapter(child: _buildRegisterBlockedBanner()),

                    // ── بطاقة الدور ─────────────────────────────
                    if (_isRegistered)
                      SliverToBoxAdapter(child: _buildInfoCard()),

                    if (!_isRegistered)
                      SliverToBoxAdapter(child: _buildRejectedCard()),

                    // ── تنبيه تاريخ التحميل ──────────────────────
                    if (_isRegistered && _myEntry?.loadingValidityDate != null)
                      SliverToBoxAdapter(child: _buildLoadingValidityBanner()),

                    // ── تنبيهات الرخص (تظهر فقط قبل 15 يوماً) ──
                    SliverToBoxAdapter(child: _buildLicenseWarnings()),

                    // ── إذن الحركة ───────────────────────────────
                    if (_availableSlots > 0)
                      SliverToBoxAdapter(child: _buildMovementPermitCard()),

                    // ── المركبات المسجّلة دخولاً ─────────────────
                    SliverToBoxAdapter(child: _buildEnteredVehiclesCard()),

                    // ── عنوان حالة الدور ─────────────────────────
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
                            textAlign: l.isArabic
                                ? TextAlign.right
                                : TextAlign.left,
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

                    // ── قائمة الدور ──────────────────────────────
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
  //  الهيدر — الاسم الأول فقط
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
          if (!l.isArabic) _buildAvatar(avatarSize),
          Text(
            '${l.welcomeUser} $firstName',
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (l.isArabic) _buildAvatar(avatarSize),
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
  // ═══════════════════════════════════════════════
  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
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
                _buildDividerVertical(),
                _buildCardLabel(l.queueReg),
              ],
            ),
          ),
          Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingSmall(context),
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingMedium(context),
            ),
            child: Row(
              children: [
                _buildCardValue('${_myEntry?.queuePosition ?? '-'}'),
                _buildDividerVertical(),
                _buildCardValue(
                  '${_myEntry?.entryTime ?? '-'} –\n${_myEntry?.exitTime ?? '-'}',
                  isSmall: true,
                ),
                _buildDividerVertical(),
                _buildCardValue('${_myEntry?.registrationNumber ?? '-'}'),
              ],
            ),
          ),
        ],
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

    if (!expired && !soon) return const SizedBox.shrink();

    final color = expired ? Colors.redAccent : Colors.orange;
    final label = expired ? l.loadingValidityExpired : l.loadingValidity;

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
      child: Row(
        mainAxisAlignment: l.isArabic
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!l.isArabic) ...[
            Icon(
              expired ? Icons.error_rounded : Icons.warning_amber_rounded,
              color: color,
              size: AppDimensions.iconSmall(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: l.isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
                Text(
                  _loadingCountdown(validity),
                  style: GoogleFonts.cairo(
                    color: color,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
              ],
            ),
          ),
          if (l.isArabic) ...[
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Icon(
              expired ? Icons.error_rounded : Icons.warning_amber_rounded,
              color: color,
              size: AppDimensions.iconSmall(context),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  تنبيهات الرخص — تظهر فقط قبل 15 يوماً
  // ═══════════════════════════════════════════════
  Widget _buildLicenseWarnings() {
    if (_vehicleInfo == null && _driverInfo == null)
      return const SizedBox.shrink();

    final List<Widget> warnings = [];

    void addWarning(String label, int days) {
      if (days > 15) return;
      final expired = days < 0;
      final color = expired ? Colors.redAccent : Colors.orange;
      final text = expired
          ? l.licenseExpiredWarn
          : '${l.dayLabel.contains('يوم') ? 'متبقي' : 'Remaining'} ${days.abs()} ${l.dayLabel}';

      warnings.add(
        Container(
          margin: EdgeInsets.only(bottom: AppDimensions.spacingXSmall(context)),
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
              Text(
                text,
                style: GoogleFonts.cairo(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: color,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_vehicleInfo != null) {
      addWarning(
        l.operatingLicense,
        _daysRemaining(_vehicleInfo!.operationExpiry),
      );
      addWarning(
        l.vehicleLicWarn,
        _daysRemaining(_vehicleInfo!.vehicleLicExpiry),
      );
    }
    if (_driverInfo != null) {
      addWarning(l.driverLicWarn, _daysRemaining(_driverInfo!.licenseExpiry));
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      child: Column(children: warnings),
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
  //  بطاقة إذن الحركة
  // ═══════════════════════════════════════════════
  Widget _buildMovementPermitCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← زر إنشاء الإذن
          ElevatedButton.icon(
            onPressed: () => _showPermitDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMedium(context),
                vertical: AppDimensions.spacingSmall(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
              ),
            ),
            icon: Icon(
              Icons.article_outlined,
              size: AppDimensions.iconSmall(context),
            ),
            label: Text(
              l.generatePermit,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontSmall(context),
              ),
            ),
          ),

          // ← عدد الخانات الشاغرة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l.movementPermit,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontSmall(context),
                ),
              ),
              Row(
                children: [
                  Text(
                    '$_availableSlots',
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontSize: AppDimensions.fontXLarge(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingXSmall(context)),
                  Text(
                    l.availableSlots,
                    style: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  قائمة المركبات المسجّلة دخولاً
  // ═══════════════════════════════════════════════
  Widget _buildEnteredVehiclesCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingXSmall(context),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            child: Text(
              l.enteredVehicles,
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
          Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 1),
          ..._enteredVehicles.map(
            (v) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMedium(context),
                vertical: AppDimensions.spacingSmall(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    v.entryTime,
                    style: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  Text(
                    v.vehicleNumber,
                    style: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textPrimary : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.fontMedium(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Dialogs
  // ═══════════════════════════════════════════════
  void _showPermitDialog() {
    final vehicle = _vehicleInfo;
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius(context),
            ),
            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
          ),
          title: Text(
            l.movementPermit,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _permitRow(
                l.permitVehicle,
                vehicle?.vehicleNumber ?? widget.idNumber,
              ),
              _permitRow(l.permitExitTime, _nowTime()),
              _permitRow(l.permitExitGate, 'المخرج الرئيسي'),
              _permitRow(l.permitLicenseNum, vehicle?.vehicleCode ?? '-'),
              _permitRow(l.permitDestination, widget.lineTo),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius(context),
                  ),
                ),
              ),
              child: Text(
                l.close,
                style: GoogleFonts.cairo(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permitRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXSmall(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontSmall(context),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontXSmall(context),
            ),
          ),
        ],
      ),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final p = now.hour >= 12 ? 'م' : 'ص';
    return '$h:$m $p';
  }

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
      child: Row(
        mainAxisAlignment: l.isArabic
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!l.isArabic) ...[
            Icon(
              Icons.block,
              color: Colors.redAccent,
              size: AppDimensions.iconLarge(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
          ],
          Expanded(
            child: Text(
              l.violationBlockWarn,
              textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: AppDimensions.fontSmall(context),
                height: 1.6,
              ),
            ),
          ),
          if (l.isArabic) ...[
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Icon(
              Icons.block,
              color: Colors.redAccent,
              size: AppDimensions.iconLarge(context),
            ),
          ],
        ],
      ),
    );
  }

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
