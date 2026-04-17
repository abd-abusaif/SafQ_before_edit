// features/supervisor/presentation/screens/supervisor_permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/supervisor_permission_entity.dart';

class SupervisorPermissionsScreen extends StatefulWidget {
  const SupervisorPermissionsScreen({super.key});

  @override
  State<SupervisorPermissionsScreen> createState() =>
      _SupervisorPermissionsScreenState();
}

class _SupervisorPermissionsScreenState
    extends State<SupervisorPermissionsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = SupervisorRepositoryImpl();
  late final TabController _tabs;

  List<SupervisorPermissionEntity> _pending = [];
  List<SupervisorPermissionEntity> _archived = [];
  bool _isLoading = true;
  String _idNumber = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) _idNumber = session['idNumber'] ?? '';
      final results = await Future.wait([
        _repo.getPendingPermissions(_idNumber),
        _repo.getArchivedPermissions(_idNumber),
      ]);
      setState(() {
        _pending = results[0] as List<SupervisorPermissionEntity>;
        _archived = results[1] as List<SupervisorPermissionEntity>;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(SupervisorPermissionEntity p) async {
    await _repo.approvePermission(p.id);
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            '${l.translate('approved_snack')} ${p.driverName}',
            textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _showRejectDialog(SupervisorPermissionEntity p) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius(context),
            ),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          title: Text(
            l.translate('reject_permission'),
            textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: l.isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                l.translate('reject_reason_hint'),
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontSmall(context),
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall(context)),
              TextField(
                controller: ctrl,
                textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
                textDirection: l.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                maxLines: 3,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontSmall(context),
                ),
                decoration: InputDecoration(
                  hintText: l.translate('reject_reason_example'),
                  hintStyle: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black38,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l.cancel,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius(context),
                  ),
                ),
              ),
              child: Text(
                l.translate('send'),
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      final note = ctrl.text.trim().isEmpty
          ? l.translate('no_pending_permissions')
          : ctrl.text.trim();
      await _repo.rejectPermission(p.id, note);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              '${l.translate('rejected_snack')} ${p.driverName}',
              textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approved = _archived.where((p) => p.status == 'approved').toList();
    final rejected = _archived.where((p) => p.status == 'rejected').toList();

    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          title: Text(
            l.translate('permissions_center'),
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: _isDark
                ? AppColors.textSecondary
                : Colors.black54,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontXSmall(context),
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_pending.isNotEmpty) ...[
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_pending.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingXSmall(context)),
                    ],
                    Text(l.translate('pending_tab')),
                  ],
                ),
              ),
              Tab(text: l.translate('approved_tab')),
              Tab(text: l.translate('rejected_tab')),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                controller: _tabs,
                children: [
                  _buildPendingList(),
                  _buildArchivedList(approved, isApproved: true),
                  _buildArchivedList(rejected, isApproved: false),
                ],
              ),
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: _isDark ? AppColors.textSecondary : Colors.black26,
              size: AppDimensions.iconXLarge(context) * 1.5,
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            Text(
              l.translate('no_pending_permissions'),
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
        itemCount: _pending.length,
        itemBuilder: (_, i) => _buildPendingCard(_pending[i]),
      ),
    );
  }

  Widget _buildPendingCard(SupervisorPermissionEntity p) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(
            Icons.access_time,
            l.translate('pending_status'),
            p.permissionType,
            Colors.orange,
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _detailRow(
                  Icons.person_outline,
                  l.translate('driver_name_label'),
                  p.driverName,
                ),
                _divider(),
                _detailRow(
                  Icons.directions_car_outlined,
                  l.translate('vehicle_num_label'),
                  p.vehiclePlate,
                ),
                _divider(),
                _detailRow(
                  Icons.route_outlined,
                  l.translate('line_label'),
                  p.lineName,
                ),
                _divider(),
                _detailRow(
                  Icons.timer_outlined,
                  l.translate('duration_label'),
                  p.duration,
                ),
                _divider(),
                _detailRow(
                  Icons.calendar_today_outlined,
                  l.translate('request_date_label'),
                  p.requestDate,
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRejectDialog(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius(context),
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: AppDimensions.iconSmall(context),
                        ),
                        label: Text(
                          l.translate('reject_btn'),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontSmall(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingSmall(context)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approve(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius(context),
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppDimensions.iconSmall(context),
                        ),
                        label: Text(
                          l.translate('approve_btn'),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontSmall(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedList(
    List<SupervisorPermissionEntity> list, {
    required bool isApproved,
  }) {
    final color = isApproved ? Colors.green : Colors.redAccent;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color.withOpacity(0.4),
              size: AppDimensions.iconXLarge(context) * 1.5,
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            Text(
              isApproved
                  ? l.translate('no_approved_permissions')
                  : l.translate('no_rejected_permissions'),
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildArchivedCard(list[i], color),
      ),
    );
  }

  Widget _buildArchivedCard(SupervisorPermissionEntity p, Color color) {
    final isApproved = p.status == 'approved';
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(
            isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
            isApproved
                ? l.translate('approved_status')
                : l.translate('rejected_status'),
            p.permissionType,
            color,
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _detailRow(
                  Icons.person_outline,
                  l.translate('driver_name_label'),
                  p.driverName,
                ),
                _divider(),
                _detailRow(
                  Icons.directions_car_outlined,
                  l.translate('vehicle_num_label'),
                  p.vehiclePlate,
                ),
                _divider(),
                _detailRow(
                  Icons.route_outlined,
                  l.translate('line_label'),
                  p.lineName,
                ),
                _divider(),
                _detailRow(
                  Icons.timer_outlined,
                  l.translate('duration_label'),
                  p.duration,
                ),
                if (!isApproved && p.rejectionNote != null) ...[
                  _divider(),
                  _detailRow(
                    Icons.edit_note,
                    l.translate('rejection_note_label'),
                    p.rejectionNote!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(IconData icon, String status, String type, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingSmall(context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.cardRadius(context)),
          topRight: Radius.circular(AppDimensions.cardRadius(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppDimensions.iconSmall(context)),
              SizedBox(width: AppDimensions.spacingXSmall(context)),
              Text(
                status,
                style: GoogleFonts.cairo(
                  color: color,
                  fontSize: AppDimensions.fontXSmall(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            type,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontMedium(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    final isRtl = l.isArabic;
    final isNumeric = RegExp(r'^[\d\s\+\-\.\/]+$').hasMatch(value.trim());
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXSmall(context),
      ),
      child: Row(
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
      ),
    );
  }

  Widget _divider() =>
      Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 14);
}
