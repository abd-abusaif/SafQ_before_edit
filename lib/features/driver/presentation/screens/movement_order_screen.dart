// features/driver/presentation/screens/movement_order_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../domain/entities/movement_order_entity.dart';

class MovementOrderScreen extends StatefulWidget {
  final String idNumber;

  const MovementOrderScreen({super.key, required this.idNumber});

  @override
  State<MovementOrderScreen> createState() => _MovementOrderScreenState();
}

class _MovementOrderScreenState extends State<MovementOrderScreen> {
  final _repo = DriverRepositoryImpl();
  MovementOrderEntity? _order;
  bool _isLoading = true;
  bool _isDeletingAll = false; // زر الـ AppBar — حذف الكل
  bool _isDeletingOne = false; // زر داخل الكارد — حذف هذا الأمر

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
      final order = await _repo.getMovementOrder(widget.idNumber);
      if (mounted) setState(() => _order = order);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── حذف جميع أوامر الحركة (زر AppBar) ───────────────────────────────────
  Future<void> _confirmDeleteAll() async {
    final confirmed = await _showDeleteDialog(
      title: l.translate('delete_all_orders'),
      message: l.translate('delete_all_orders_confirm'),
    );
    if (confirmed == true && mounted) {
      setState(() => _isDeletingAll = true);
      try {
        await _repo.clearMovementOrder(widget.idNumber);
        if (mounted) {
          setState(() => _order = null);
          _showSnack(l.translate('all_orders_deleted'));
        }
      } finally {
        if (mounted) setState(() => _isDeletingAll = false);
      }
    }
  }

  // ── حذف هذا الأمر فقط (زر داخل الكارد) ─────────────────────────────────
  Future<void> _confirmDeleteOne(MovementOrderEntity order) async {
    final confirmed = await _showDeleteDialog(
      title: l.translate('delete_order'),
      message: l.translate('delete_order_confirm'),
    );
    if (confirmed == true && mounted) {
      setState(() => _isDeletingOne = true);
      try {
        await _repo.clearMovementOrder(widget.idNumber);
        if (mounted) {
          setState(() => _order = null);
          _showSnack(l.translate('order_deleted'));
        }
      } finally {
        if (mounted) setState(() => _isDeletingOne = false);
      }
    }
  }

  Future<bool?> _showDeleteDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
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
          icon: Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
            size: AppDimensions.iconXLarge(context),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontMedium(context),
              height: 1.6,
            ),
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
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontSmall(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          msg,
          style: GoogleFonts.cairo(color: Colors.white),
          textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  void _showDetails(MovementOrderEntity order) {
    final color = order.isException ? Colors.orange : AppColors.primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingMedium(context),
            AppDimensions.spacingSmall(context),
            AppDimensions.spacingMedium(context),
            AppDimensions.spacingXLarge(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(
                    bottom: AppDimensions.spacingMedium(context),
                  ),
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: l.isArabic
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: l.isArabic
                    ? [
                        Text(
                          l.translate('movement_order_title'),
                          style: GoogleFonts.cairo(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontLarge(context),
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacingSmall(context)),
                        Icon(
                          Icons.directions_bus,
                          color: color,
                          size: AppDimensions.iconMedium(context),
                        ),
                      ]
                    : [
                        Icon(
                          Icons.directions_bus,
                          color: color,
                          size: AppDimensions.iconMedium(context),
                        ),
                        SizedBox(width: AppDimensions.spacingSmall(context)),
                        Text(
                          l.translate('movement_order_title'),
                          style: GoogleFonts.cairo(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontLarge(context),
                          ),
                        ),
                      ],
              ),
              if (order.isException) ...[
                SizedBox(height: AppDimensions.spacingSmall(context)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingXSmall(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius(context),
                    ),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: l.isArabic
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: l.isArabic
                        ? [
                            Text(
                              l.translate('exception_badge'),
                              style: GoogleFonts.cairo(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.fontXSmall(context),
                              ),
                            ),
                            SizedBox(
                              width: AppDimensions.spacingXSmall(context),
                            ),
                            Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                              size: AppDimensions.iconSmall(context),
                            ),
                          ]
                        : [
                            Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                              size: AppDimensions.iconSmall(context),
                            ),
                            SizedBox(
                              width: AppDimensions.spacingXSmall(context),
                            ),
                            Text(
                              l.translate('exception_badge'),
                              style: GoogleFonts.cairo(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.fontXSmall(context),
                              ),
                            ),
                          ],
                  ),
                ),
              ],
              SizedBox(height: AppDimensions.spacingMedium(context)),
              Divider(
                color: _isDark ? Colors.white12 : Colors.black12,
                height: 1,
              ),
              SizedBox(height: AppDimensions.spacingMedium(context)),
              _detailRow(
                Icons.confirmation_number_outlined,
                l.translate('permit_vehicle'),
                order.vehicleNumber,
                color,
                isLtr: true,
              ),
              _sheetDivider(),
              _detailRow(
                Icons.tag,
                l.translate('order_line_number'),
                order.lineNumber,
                color,
                isLtr: true,
              ),
              _sheetDivider(),
              _detailRow(
                Icons.route_outlined,
                l.translate('line_from_to'),
                '${order.lineFrom} ← ${order.lineTo}',
                color,
              ),
              _sheetDivider(),
              _detailRow(
                Icons.calendar_today_outlined,
                l.translate('departure_date'),
                order.departureDate,
                color,
                isLtr: true,
              ),
              _sheetDivider(),
              _detailRow(
                Icons.access_time_outlined,
                l.translate('departure_time'),
                order.departureTime,
                color,
                isLtr: true,
              ),
              SizedBox(height: AppDimensions.spacingMedium(context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            l.translate('movement_order_title'),
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          // ── زر الـ AppBar: حذف جميع أوامر الحركة ────────────────────────
          actions: _order != null
              ? [
                  IconButton(
                    onPressed: _isDeletingAll ? null : _confirmDeleteAll,
                    tooltip: l.translate('delete_all_orders'),
                    icon: _isDeletingAll
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.delete_sweep_outlined,
                            color: Colors.redAccent,
                          ),
                  ),
                ]
              : null,
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
                  child: _order == null
                      ? _buildNoOrder()
                      : _buildCompactCard(_order!),
                ),
              ),
      ),
    );
  }

  Widget _buildNoOrder() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXLarge(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              color: _isDark ? AppColors.textSecondary : Colors.black26,
              size: AppDimensions.iconXLarge(context) * 1.5,
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            Text(
              l.translate('no_movement_order'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall(context)),
            Text(
              l.translate('no_movement_order_msg'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black45,
                fontSize: AppDimensions.fontMedium(context),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(MovementOrderEntity order) {
    final color = order.isException ? Colors.orange : AppColors.primary;

    return Column(
      children: [
        // ── الكارد الرئيسي ────────────────────────────────────────────────
        GestureDetector(
          onTap: () => _showDetails(order),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius(context),
              ),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // رأس الكارد
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingSmall(context),
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                      topRight: Radius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            color: color,
                            size: AppDimensions.iconSmall(context),
                          ),
                          SizedBox(width: AppDimensions.spacingXSmall(context)),
                          Text(
                            l.translate('movement_order_title'),
                            style: GoogleFonts.cairo(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: AppDimensions.fontSmall(context),
                            ),
                          ),
                        ],
                      ),
                      if (order.isException)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSmall(context),
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            l.translate('exception_badge'),
                            style: GoogleFonts.cairo(
                              color: Colors.orange,
                              fontSize: AppDimensions.fontXSmall(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.chevron_right,
                          color: color,
                          size: AppDimensions.iconSmall(context),
                        ),
                    ],
                  ),
                ),
                // معلومات مختصرة
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingMedium(context),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              order.departureTime,
                              style: GoogleFonts.cairo(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.fontLarge(context),
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              order.departureDate,
                              style: GoogleFonts.cairo(
                                color: _isDark
                                    ? AppColors.textSecondary
                                    : Colors.black54,
                                fontSize: AppDimensions.fontXSmall(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              order.vehicleNumber,
                              style: GoogleFonts.cairo(
                                color: _isDark
                                    ? AppColors.textPrimary
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.fontMedium(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.lineFrom} ← ${order.lineTo}',
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

                // ── زر حذف هذا الأمر — داخل الكارد في الأسفل ──────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.06),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                      bottomRight: Radius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.redAccent.withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _isDeletingOne
                        ? null
                        : () => _confirmDeleteOne(order),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingSmall(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            AppDimensions.cardRadius(context),
                          ),
                          bottomRight: Radius.circular(
                            AppDimensions.cardRadius(context),
                          ),
                        ),
                      ),
                    ),
                    icon: _isDeletingOne
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: AppDimensions.iconSmall(context),
                          ),
                    label: Text(
                      l.translate('delete_order'),
                      style: GoogleFonts.cairo(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontSmall(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor, {
    bool isLtr = false,
  }) {
    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: AppDimensions.iconSmall(context)),
        SizedBox(width: AppDimensions.spacingSmall(context)),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontXSmall(context),
          ),
        ),
      ],
    );
    final valueWidget = isLtr
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontMedium(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Text(
            value,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontMedium(context),
              fontWeight: FontWeight.bold,
            ),
          );

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: l.isArabic
          ? [valueWidget, labelWidget]
          : [labelWidget, valueWidget],
    );
  }

  Widget _sheetDivider() => Divider(
    color: _isDark ? Colors.white12 : Colors.black12,
    height: AppDimensions.spacingMedium(context) * 2,
  );
}
