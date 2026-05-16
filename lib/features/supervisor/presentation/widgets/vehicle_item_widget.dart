// features/supervisor/presentation/widgets/vehicle_item_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';

class VehicleItemWidget extends StatelessWidget {
  final SupervisorVehicleEntity vehicle;
  final VoidCallback? onException;

  const VehicleItemWidget({super.key, required this.vehicle, this.onException});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    // اللون يُحدَّد بثلاث حالات:
    // استثناء → أخضر | مقبول → أخضر | مرفوض → أحمر
    final isGreen = vehicle.isException || vehicle.isApproved;
    final color = isGreen ? Colors.green : Colors.redAccent;
    final statusLabel = vehicle.isException
        ? l.translate('exception_badge')
        : vehicle.isApproved
        ? l.translate('approved')
        : l.translate('rejected');
    final statusIcon = isGreen
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── صف المعلومات الرئيسية ──────────────────────
          Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الحالة — يسار
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                  if (!isGreen && vehicle.rejectionReason != null)
                    Text(
                      vehicle.rejectionReason!,
                      style: GoogleFonts.cairo(
                        color: Colors.redAccent.withOpacity(0.7),
                        fontSize: AppDimensions.fontXSmall(context),
                      ),
                    ),
                ],
              ),
              // المعلومات — يمين
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vehicle.driverName,
                    style: GoogleFonts.cairo(
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                      fontSize: AppDimensions.fontMedium(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXSmall(context)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      vehicle.vehiclePlate,
                      style: GoogleFonts.cairo(
                        color: isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontXSmall(context),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingXSmall(context)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${vehicle.lineFrom} - ${vehicle.lineTo}',
                        style: GoogleFonts.cairo(
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.black54,
                          fontSize: AppDimensions.fontXSmall(context),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSmall(context)),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          vehicle.entryTime,
                          style: GoogleFonts.cairo(
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.black54,
                            fontSize: AppDimensions.fontXSmall(context),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSmall(context)),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '#${vehicle.queuePosition}',
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontSize: AppDimensions.fontXSmall(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── زر الاستثناء (يظهر فقط إذا لم يكن مستثنى بعد) ─────────────
          if (onException != null && !vehicle.isException) ...[
            SizedBox(height: AppDimensions.spacingSmall(context)),
            Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
            SizedBox(height: AppDimensions.spacingSmall(context)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onException,
                icon: Icon(
                  Icons.star_outline,
                  color: Colors.orange,
                  size: AppDimensions.iconSmall(context),
                ),
                label: Text(
                  l.translate('exception_btn'),
                  style: GoogleFonts.cairo(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius(context),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingSmall(context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
