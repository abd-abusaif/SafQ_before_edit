// features/security/presentation/screens/security_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../domain/entities/security_vehicle_entity.dart';

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
    for (final t in _approvedTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _repo.getVehicles(widget.idNumber);
      setState(() => _vehicles = vehicles);
      for (final v in vehicles) {
        if (v.isApproved) _startApprovedTimer(v);
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
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'مقبول: ${_vehicles.where((v) => v.isApproved).length}',
                                style: GoogleFonts.cairo(
                                  color: Colors.green,
                                  fontSize: AppDimensions.fontXSmall(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'حالة المركبات',
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      color: _isDark
                                          ? AppColors.textSecondary
                                          : Colors.black26,
                                      size:
                                          AppDimensions.iconXLarge(context) *
                                          1.5,
                                    ),
                                    SizedBox(
                                      height: AppDimensions.spacingMedium(
                                        context,
                                      ),
                                    ),
                                    Text(
                                      'لا توجد مركبات حالياً',
                                      style: GoogleFonts.cairo(
                                        color: _isDark
                                            ? AppColors.textSecondary
                                            : Colors.black54,
                                        fontSize: AppDimensions.fontMedium(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMedium(context),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildVehicleCard(_vehicles[index]),
                                childCount: _vehicles.length,
                              ),
                            ),
                          ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final size = AppDimensions.avatarSmall(context);
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
            width: size,
            height: size,
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

  Widget _buildVehicleCard(SecurityVehicleEntity v) {
    final color = v.isApproved ? Colors.green : Colors.redAccent;
    final statusLabel = v.isApproved ? 'مقبول' : 'مرفوض';
    final statusIcon = v.isApproved
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          // رأس البطاقة
          Container(
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
                    Icon(
                      statusIcon,
                      color: color,
                      size: AppDimensions.iconSmall(context),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                        color: color,
                        fontSize: AppDimensions.fontSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  v.driverName,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // التفاصيل
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#${v.queuePosition}',
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontSize: AppDimensions.fontSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingSmall(context)),
                    Text(
                      v.entryTime,
                      style: GoogleFonts.cairo(
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontXSmall(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      v.vehiclePlate,
                      style: GoogleFonts.cairo(
                        color: _isDark ? AppColors.textPrimary : Colors.black87,
                        fontSize: AppDimensions.fontSmall(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${v.lineFrom} - ${v.lineTo}',
                      style: GoogleFonts.cairo(
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontXSmall(context),
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
}
