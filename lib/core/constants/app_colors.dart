import 'package:flutter/material.dart';

class AppColors {
  // ← اللون الرئيسي للتطبيق (أصفر SafQ)
  static const Color primary = Color(0xFFFFB800);

  // ← Dark Theme — مبني على #3C6DB7
  static const Color background = Color(0xFF1A2A4A); // ← داكن أزرق عميق
  static const Color surface = Color(0xFF1F3560); // ← أزرق متوسط داكن
  static const Color inputFill = Color(0xFF243D70); // ← أزرق للحقول
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xAAFFFFFF); // ← أبيض شفاف
  static const Color textHint = Color(0x80FFFFFF); // ← أكثر شفافية

  // ← Light Theme
  static const Color backgroundLight = Color(0xFFF0F4FF); // ← أزرق فاتح جداً
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1A2A4A);
  static const Color textSecondaryLight = Color(0xFF4A6080);
  static const Color inputFillLight = Color(0xFFF5F8FF);

  // ← دوال تعيد اللون المناسب حسب الـ theme
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? background
      : backgroundLight;

  static Color surf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surface : surfaceLight;

  static Color textMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textPrimary
      : textPrimaryLight;

  static Color textSub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textSecondary
      : textSecondaryLight;

  static Color input(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? inputFill
      : inputFillLight;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white12
      : Colors.black12;
}
