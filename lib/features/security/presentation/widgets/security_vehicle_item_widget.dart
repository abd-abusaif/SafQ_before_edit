import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/security_vehicle_entity.dart';

class SecurityVehicleItemWidget extends StatelessWidget {
  final SecurityVehicleEntity vehicle;
  final VoidCallback? onHandled;

  const SecurityVehicleItemWidget({
    super.key,
    required this.vehicle,
    this.onHandled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = vehicle.isApproved ? Colors.green : Colors.redAccent;
    final statusLabel = vehicle.isApproved ? 'مقبول' : 'مرفوض';
    final statusIcon = vehicle.isApproved
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
          // ← Header
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
                  vehicle.driverName,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ← التفاصيل
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${vehicle.queuePosition}',
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontSize: AppDimensions.fontSmall(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacingSmall(context)),
                        Text(
                          vehicle.entryTime,
                          style: GoogleFonts.cairo(
                            color: isDark
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
                          vehicle.vehiclePlate,
                          style: GoogleFonts.cairo(
                            color: isDark
                                ? AppColors.textPrimary
                                : Colors.black87,
                            fontSize: AppDimensions.fontSmall(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${vehicle.lineFrom} - ${vehicle.lineTo}',
                          style: GoogleFonts.cairo(
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.black54,
                            fontSize: AppDimensions.fontXSmall(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ← سبب الرفض + زر اكتمل
                if (!vehicle.isApproved && vehicle.rejectionReason != null) ...[
                  SizedBox(height: AppDimensions.spacingSmall(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSmall(context),
                      vertical: AppDimensions.spacingXSmall(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context) * 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          vehicle.rejectionReason!,
                          style: GoogleFonts.cairo(
                            color: Colors.redAccent,
                            fontSize: AppDimensions.fontXSmall(context),
                          ),
                        ),
                        SizedBox(width: AppDimensions.spacingXSmall(context)),
                        Icon(
                          Icons.info_outline,
                          color: Colors.redAccent,
                          size: AppDimensions.iconSmall(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacingSmall(context)),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight(context) * 0.8,
                    child: ElevatedButton.icon(
                      onPressed: onHandled,
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
                        'تم التعامل مع الحالة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: AppDimensions.fontSmall(context),
                          fontWeight: FontWeight.bold,
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
}
