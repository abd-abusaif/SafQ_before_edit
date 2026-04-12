// features/supervisor/presentation/screens/supervisor_notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/rejected_vehicle_notification_entity.dart';

class SupervisorNotificationsScreen extends StatefulWidget {
  const SupervisorNotificationsScreen({super.key});

  @override
  State<SupervisorNotificationsScreen> createState() =>
      _SupervisorNotificationsScreenState();
}

class _SupervisorNotificationsScreenState
    extends State<SupervisorNotificationsScreen> {
  final _repo = SupervisorRepositoryImpl();
  List<RejectedVehicleNotificationEntity> _notifications = [];
  bool _isLoading = true;
  String _idNumber = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
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

  Future<void> _markHandled(RejectedVehicleNotificationEntity n) async {
    final confirmed = await showDialog<bool>(
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
          'تأكيد التعامل',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Text(
          'هل تم التعامل مع مركبة ${n.driverName}؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontMedium(context),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
              ),
            ),
            child: Text('تم', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.markVehicleHandled(n.id);
      await _loadData();
    }
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
          'الإشعارات',
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
                left: AppDimensions.spacingSmall(context),
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
                  'مرفوض: $_pendingCount',
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
                            'لا توجد إشعارات حالياً',
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
                      itemBuilder: (_, i) => _buildCard(_notifications[i]),
                    ),
            ),
    );
  }

  Widget _buildCard(RejectedVehicleNotificationEntity n) {
    final handled = n.isHandled;
    final borderColor = handled
        ? Colors.green.withOpacity(0.5)
        : Colors.redAccent.withOpacity(0.6);
    final headerBg = handled
        ? Colors.green.withOpacity(0.08)
        : Colors.redAccent.withOpacity(0.08);
    final statusColor = handled ? Colors.green : Colors.redAccent;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رأس الإشعار
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
                Text(
                  n.entryTime,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      handled ? 'تم التعامل ✓' : 'محظورة - يحتاج تدخل',
                      style: GoogleFonts.cairo(
                        color: statusColor,
                        fontSize: AppDimensions.fontXSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Icon(
                      handled ? Icons.check_circle : Icons.block,
                      color: statusColor,
                      size: AppDimensions.iconSmall(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // التفاصيل
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _row(Icons.person_outline, 'السائق', n.driverName),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 14,
                ),
                _row(Icons.directions_car_outlined, 'المركبة', n.vehiclePlate),
                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: 14,
                ),
                _row(Icons.route_outlined, 'الخط', n.lineName),
                if (!handled) ...[
                  SizedBox(height: AppDimensions.spacingMedium(context)),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight(context) * 0.8,
                    child: ElevatedButton.icon(
                      onPressed: () => _markHandled(n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius(context),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: AppDimensions.iconSmall(context),
                      ),
                      label: Text(
                        'تم التعامل مع المركبة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimensions.fontSmall(context),
                        ),
                      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontSmall(context),
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
