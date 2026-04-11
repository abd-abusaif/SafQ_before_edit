import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/queue_entry_entity.dart';

class QueueItemWidget extends StatelessWidget {
  final QueueEntryEntity entry;
  final bool isCurrentDriver;

  const QueueItemWidget({
    super.key,
    required this.entry,
    required this.isCurrentDriver,
  });

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFFEB3B);
      case 3:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final positionColor = _getPositionColor(entry.queuePosition);
    final l = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXSmall(context),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
        vertical: AppDimensions.spacingMedium(context),
      ),
      decoration: BoxDecoration(
        color: isCurrentDriver
            ? AppColors.primary.withOpacity(0.15)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(
          color: isCurrentDriver
              ? AppColors.primary
              : isDark
              ? Colors.white12
              : Colors.black12,
          width: isCurrentDriver ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // ← رقم الدور (ثابت يسار دائماً)
          Text(
            '${entry.queuePosition}',
            style: GoogleFonts.cairo(
              color: positionColor,
              fontSize: AppDimensions.fontXLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppDimensions.spacingMedium(context)),

          // ← اسم الخط
          Expanded(
            child: Text(
              '${entry.lineFrom} – ${entry.lineTo}',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontMedium(context),
                fontWeight: isCurrentDriver
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingMedium(context)),

          // ← الوقت
          Column(
            crossAxisAlignment: l.isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                entry.entryTime,
                style: GoogleFonts.cairo(
                  color: isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
              if (entry.exitTime != null)
                Text(
                  entry.exitTime!,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
