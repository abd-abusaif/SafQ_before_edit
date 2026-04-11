import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../domain/entities/security_vehicle_entity.dart';
import '../widgets/security_vehicle_item_widget.dart';

class SecurityHomeScreen extends StatefulWidget {
  final String securityName;
  final String idNumber;

  const SecurityHomeScreen({
    super.key,
    required this.securityName,
    required this.idNumber,
  });

  @override
  State<SecurityHomeScreen> createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen> {
  final _repo = SecurityRepositoryImpl();

  List<SecurityVehicleEntity> _vehicles = [];
  bool _isLoading = true;
  final Map<String, Timer> _approvedTimers = {};

  String get _firstName => widget.securityName.trim().split(' ').first;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final timer in _approvedTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _repo.getVehicles(widget.idNumber);
      setState(() => _vehicles = vehicles);
      for (final vehicle in vehicles) {
        if (vehicle.isApproved) _startApprovedTimer(vehicle);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startApprovedTimer(SecurityVehicleEntity vehicle) {
    final elapsed = DateTime.now().difference(vehicle.entryDateTime);
    final remaining = const Duration(minutes: 1) - elapsed;
    if (remaining.isNegative) {
      _removeVehicle(vehicle.id);
      return;
    }
    _approvedTimers[vehicle.id] = Timer(remaining, () {
      _removeVehicle(vehicle.id);
    });
  }

  void _removeVehicle(String vehicleId) {
    if (mounted) {
      setState(() {
        _vehicles.removeWhere((v) => v.id == vehicleId);
        _approvedTimers.remove(vehicleId);
      });
    }
  }

  Future<void> _onHandled(SecurityVehicleEntity vehicle) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        icon: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: AppDimensions.iconXLarge(context),
        ),
        title: Text(
          'تأكيد الإتمام',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        content: Text(
          'هل تم التعامل مع حالة ${vehicle.driverName}؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontMedium(context),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.markAsHandled(vehicle.id);
              _removeVehicle(vehicle.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius(context),
                ),
              ),
            ),
            child: Text(
              'تم',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.spacingMedium(context),
                          AppDimensions.spacingLarge(context),
                          AppDimensions.spacingMedium(context),
                          AppDimensions.spacingSmall(context),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingSmall(context),
                                vertical: AppDimensions.spacingXSmall(context),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'مرفوض: ${_vehicles.where((v) => !v.isApproved).length}',
                                style: GoogleFonts.cairo(
                                  color: Colors.redAccent,
                                  fontSize: AppDimensions.fontXSmall(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'حالة المركبات',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                color: _isDark
                                    ? AppColors.textPrimary
                                    : Colors.black87,
                                fontSize: AppDimensions.fontLarge(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _vehicles.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(
                                AppDimensions.spacingXLarge(context),
                              ),
                              child: Center(
                                child: Text(
                                  'لا توجد مركبات حالياً',
                                  style: GoogleFonts.cairo(
                                    color: _isDark
                                        ? AppColors.textSecondary
                                        : Colors.black54,
                                    fontSize: AppDimensions.fontMedium(context),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMedium(context),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final vehicle = _vehicles[index];
                                return SecurityVehicleItemWidget(
                                  vehicle: vehicle,
                                  onHandled: vehicle.isApproved
                                      ? null
                                      : () => _onHandled(vehicle),
                                );
                              }, childCount: _vehicles.length),
                            ),
                          ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.2),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                _getInitials(widget.securityName),
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontSize: AppDimensions.fontMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            'أهلاً $_firstName',
            textAlign: TextAlign.right,
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
}
