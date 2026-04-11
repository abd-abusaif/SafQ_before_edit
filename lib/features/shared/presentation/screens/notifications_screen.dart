import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'الإشعارات',
          style: GoogleFonts.cairo(
            color: isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: isDark ? AppColors.textSecondary : Colors.black26,
              size: AppDimensions.iconXLarge(context) * 1.5,
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            Text(
              'لا توجد إشعارات حالياً',
              style: GoogleFonts.cairo(
                color: isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontMedium(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
