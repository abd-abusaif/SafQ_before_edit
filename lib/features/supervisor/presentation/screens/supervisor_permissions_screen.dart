// features/supervisor/presentation/screens/supervisor_permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
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
            'تم قبول إذن ${p.driverName}',
            textAlign: TextAlign.right,
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
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text(
          'رفض الإذن',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'اكتب سبب الرفض للسائق:',
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontSmall(context),
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall(context)),
            TextField(
              controller: ctrl,
              textAlign: TextAlign.right,
              maxLines: 3,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontSmall(context),
              ),
              decoration: InputDecoration(
                hintText: 'مثال: لا يوجد سائق بديل...',
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
              'إلغاء',
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
            child: Text('إرسال', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final note = ctrl.text.trim().isEmpty
          ? 'لا يوجد سبب محدد'
          : ctrl.text.trim();
      await _repo.rejectPermission(p.id, note);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'تم رفض إذن ${p.driverName}',
              textAlign: TextAlign.right,
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'مركز الأذونات',
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
                  const Text('انتظار'),
                ],
              ),
            ),
            const Tab(text: 'موافق عليها'),
            const Tab(text: 'مرفوضة'),
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
    );
  }

  // ── قيد الانتظار ─────────────────────────────────────────────────────────
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
              'لا توجد أذونات معلقة',
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رأس البطاقة
          _cardHeader(
            Icons.access_time,
            'قيد الانتظار',
            p.permissionType,
            Colors.orange,
          ),
          // التفاصيل
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _detailRow(Icons.person_outline, 'اسم السائق', p.driverName),
                _divider(),
                _detailRow(
                  Icons.directions_car_outlined,
                  'رقم المركبة',
                  p.vehiclePlate,
                ),
                _divider(),
                _detailRow(Icons.route_outlined, 'الخط', p.lineName),
                _divider(),
                _detailRow(Icons.timer_outlined, 'المدة', p.duration),
                _divider(),
                _detailRow(
                  Icons.calendar_today_outlined,
                  'تاريخ الطلب',
                  p.requestDate,
                ),
                SizedBox(height: AppDimensions.spacingMedium(context)),
                // أزرار القبول/الرفض
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
                          'رفض',
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
                          'قبول',
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

  // ── الأرشيف (موافق/مرفوض) ────────────────────────────────────────────────
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
                  ? 'لا توجد أذونات موافق عليها'
                  : 'لا توجد أذونات مرفوضة',
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _cardHeader(
            isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
            isApproved ? 'موافق عليه' : 'مرفوض',
            p.permissionType,
            color,
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _detailRow(Icons.person_outline, 'اسم السائق', p.driverName),
                _divider(),
                _detailRow(
                  Icons.directions_car_outlined,
                  'رقم المركبة',
                  p.vehiclePlate,
                ),
                _divider(),
                _detailRow(Icons.route_outlined, 'الخط', p.lineName),
                _divider(),
                _detailRow(Icons.timer_outlined, 'المدة', p.duration),
                if (!isApproved && p.rejectionNote != null) ...[
                  _divider(),
                  _detailRow(Icons.edit_note, 'ملاحظة الرفض', p.rejectionNote!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── مساعدات ──────────────────────────────────────────────────────────────
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
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXSmall(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontSmall(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingSmall(context)),
          Row(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Widget _divider() =>
      Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 14);
}
