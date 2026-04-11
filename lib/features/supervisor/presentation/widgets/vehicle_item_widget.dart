import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';

class VehicleItemWidget extends StatelessWidget {
  final SupervisorVehicleEntity vehicle;

  const VehicleItemWidget({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = vehicle.isApproved ? Colors.green : Colors.redAccent;
    final statusLabel = vehicle.isApproved ? 'موجود' : 'مرفوض';
    final statusIcon = vehicle.isApproved
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← الحالة (يسار)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              if (!vehicle.isApproved && vehicle.rejectionReason != null)
                Text(
                  vehicle.rejectionReason!,
                  style: GoogleFonts.cairo(
                    color: Colors.redAccent.withOpacity(0.7),
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
            ],
          ),

          // ← المعلومات (يمين)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
              Text(
                vehicle.vehiclePlate,
                style: GoogleFonts.cairo(
                  color: isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
              SizedBox(height: AppDimensions.spacingXSmall(context)),
              Row(
                children: [
                  Text(
                    '${vehicle.lineFrom} - ${vehicle.lineTo}',
                    style: GoogleFonts.cairo(
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                  Text(
                    vehicle.entryTime,
                    style: GoogleFonts.cairo(
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                  Text(
                    '#${vehicle.queuePosition}',
                    style: GoogleFonts.cairo(
                      color: AppColors.primary,
                      fontSize: AppDimensions.fontXSmall(context),
                      fontWeight: FontWeight.bold,
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
}
