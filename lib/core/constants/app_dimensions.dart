import 'package:flutter/material.dart';

class AppDimensions {
  static double _w(BuildContext context) => MediaQuery.of(context).size.width;
  static double _h(BuildContext context) => MediaQuery.of(context).size.height;

  // ← أحجام النصوص (مع حد أقصى وأدنى)
  static double fontXSmall(BuildContext context) =>
      (_w(context) * 0.028).clamp(10.0, 13.0);
  static double fontSmall(BuildContext context) =>
      (_w(context) * 0.032).clamp(12.0, 15.0);
  static double fontMedium(BuildContext context) =>
      (_w(context) * 0.036).clamp(13.0, 16.0);
  static double fontLarge(BuildContext context) =>
      (_w(context) * 0.045).clamp(16.0, 20.0);
  static double fontXLarge(BuildContext context) =>
      (_w(context) * 0.055).clamp(20.0, 26.0);
  static double fontTitle(BuildContext context) =>
      (_w(context) * 0.065).clamp(24.0, 32.0);

  // ← أحجام الأيقونات
  static double iconSmall(BuildContext context) =>
      (_w(context) * 0.040).clamp(14.0, 18.0);
  static double iconMedium(BuildContext context) =>
      (_w(context) * 0.055).clamp(18.0, 24.0);
  static double iconLarge(BuildContext context) =>
      (_w(context) * 0.080).clamp(28.0, 36.0);
  static double iconXLarge(BuildContext context) =>
      (_w(context) * 0.120).clamp(40.0, 56.0);

  // ← المسافات
  static double spacingXSmall(BuildContext context) =>
      (_w(context) * 0.015).clamp(4.0, 8.0);
  static double spacingSmall(BuildContext context) =>
      (_w(context) * 0.020).clamp(6.0, 12.0);
  static double spacingMedium(BuildContext context) =>
      (_w(context) * 0.040).clamp(14.0, 20.0);
  static double spacingLarge(BuildContext context) =>
      (_w(context) * 0.060).clamp(20.0, 28.0);
  static double spacingXLarge(BuildContext context) =>
      (_w(context) * 0.080).clamp(28.0, 40.0);

  // ← الـ Padding
  static EdgeInsets paddingAll(BuildContext context) =>
      EdgeInsets.all(spacingMedium(context));
  static EdgeInsets paddingHorizontal(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: spacingMedium(context));
  static EdgeInsets paddingVertical(BuildContext context) =>
      EdgeInsets.symmetric(vertical: spacingSmall(context));

  // ← الـ Avatar
  static double avatarSmall(BuildContext context) =>
      (_w(context) * 0.105).clamp(36.0, 48.0);
  static double avatarLarge(BuildContext context) =>
      (_w(context) * 0.220).clamp(80.0, 100.0);

  // ← الكاردز
  static double cardRadius(BuildContext context) =>
      (_w(context) * 0.040).clamp(12.0, 18.0);
  static double buttonHeight(BuildContext context) =>
      (_h(context) * 0.065).clamp(48.0, 60.0);

  // ← حجم الشاشة
  static double logoWidth(BuildContext context) =>
      (_w(context) * 0.500).clamp(120.0, 200.0);
  static double logoWidthSmall(BuildContext context) =>
      (_w(context) * 0.320).clamp(100.0, 140.0);
}
