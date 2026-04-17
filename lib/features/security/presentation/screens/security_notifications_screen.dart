// features/security/presentation/screens/security_notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../domain/entities/security_vehicle_entity.dart';

class SecurityNotificationsScreen extends StatefulWidget {
  const SecurityNotificationsScreen({super.key});

  @override
  State<SecurityNotificationsScreen> createState() =>
      _SecurityNotificationsScreenState();
}

class _SecurityNotificationsScreenState
    extends State<SecurityNotificationsScreen> {
  final _repo = SecurityRepositoryImpl();
  List<SecurityVehicleEntity> _notifications = [];
  bool _isLoading = true;
  String _idNumber = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);
  int get _pendingCount => _notifications.where((n) => !n.isHandled).length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) _idNumber = session['idNumber'] ?? '';
      final list = await _repo.getRejectedNotifications(_idNumber);
      setState(() => _notifications = list);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            l.notificationsTitle,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          actions: [
            if (_pendingCount > 0)
              Padding(
                padding: EdgeInsets.only(
                  left: l.isArabic ? AppDimensions.spacingSmall(context) : 0,
                  right: l.isArabic ? 0 : AppDimensions.spacingSmall(context),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSmall(context),
                    vertical: AppDimensions.spacingXSmall(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l.translate('needs_attention_count')} $_pendingCount',
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontSize: AppDimensions.fontXSmall(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              color: _isDark
                                  ? AppColors.textSecondary
                                  : Colors.black26,
                              size: AppDimensions.iconXLarge(context) * 1.5,
                            ),
                            SizedBox(
                              height: AppDimensions.spacingMedium(context),
                            ),
                            Text(
                              l.translate('rejected_vehicle_notification'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: _isDark
                                    ? AppColors.textSecondary
                                    : Colors.black54,
                                fontSize: AppDimensions.fontMedium(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(
                          AppDimensions.spacingMedium(context),
                        ),
                        itemCount: _notifications.length,
                        itemBuilder: (_, i) =>
                            _buildNotificationCard(_notifications[i]),
                      ),
              ),
      ),
    );
  }

  Widget _buildNotificationCard(SecurityVehicleEntity n) {
    final handled = n.isHandled;
    final borderColor = handled
        ? Colors.green.withOpacity(0.5)
        : Colors.redAccent.withOpacity(0.6);
    final headerBg = handled
        ? Colors.green.withOpacity(0.08)
        : Colors.redAccent.withOpacity(0.08);
    final statusColor = handled ? Colors.green : Colors.redAccent;
    final statusLabel = handled
        ? '${l.translate('handled_status')} \u2713'
        : l.translate('needs_intervention');
    final statusIcon = handled ? Icons.check_circle : Icons.error_outline;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius(context)),
                topRight: Radius.circular(AppDimensions.cardRadius(context)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // الوقت - LTR دائماً
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    n.entryTime,
                    style: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                        color: statusColor,
                        fontSize: AppDimensions.fontXSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: AppDimensions.iconSmall(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _row(
                  Icons.person_outline,
                  l.translate('driver_label'),
                  n.driverName,
                ),
                _divider(),
                _row(
                  Icons.directions_car_outlined,
                  l.translate('vehicle_label'),
                  n.vehiclePlate,
                ),
                _divider(),
                _row(
                  Icons.route_outlined,
                  l.translate('line_route_label'),
                  '${n.lineFrom} - ${n.lineTo}',
                ),
                if (n.rejectionReason != null) ...[
                  _divider(),
                  _row(
                    Icons.info_outline,
                    l.translate('rejection_reason_label'),
                    n.rejectionReason!,
                  ),
                ],
                if (handled) ...[
                  SizedBox(height: AppDimensions.spacingSmall(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingSmall(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context) * 0.7,
                      ),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          color: Colors.green,
                          size: AppDimensions.iconSmall(context),
                        ),
                        SizedBox(width: AppDimensions.spacingXSmall(context)),
                        Text(
                          l.translate('handled_by_supervisor'),
                          style: GoogleFonts.cairo(
                            color: Colors.green,
                            fontSize: AppDimensions.fontXSmall(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    final isRtl = l.isArabic;
    final isNumeric = RegExp(r'^[\d\s\+\-\. ]+$').hasMatch(value.trim());
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
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontXSmall(context),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Directionality(
            textDirection: isNumeric
                ? TextDirection.ltr
                : (isRtl ? TextDirection.rtl : TextDirection.ltr),
            child: Text(
              value,
              textAlign: isNumeric
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

  Widget _divider() =>
      Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 14);
}
