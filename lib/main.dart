import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_manager.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafQApp());
}

class SafQApp extends StatefulWidget {
  const SafQApp({super.key});

  static _SafQAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SafQAppState>();

  @override
  State<SafQApp> createState() => _SafQAppState();
}

class _SafQAppState extends State<SafQApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar'); // ← الافتراضي عربي

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // ← تحميل الـ Theme
    final isDark = prefs.getBool('isDark') ?? true;

    // ← تحميل اللغة المحفوظة
    // إذا ما في لغة محفوظة → نشوف لغة الجهاز
    final savedLang = prefs.getString('language');
    Locale locale;
    if (savedLang != null) {
      locale = Locale(savedLang);
    } else {
      // ← تلقائي من لغة الجهاز
      final deviceLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      locale = deviceLang == 'ar' ? const Locale('ar') : const Locale('en');
    }

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _locale = locale;
    });
  }

  // ← تغيير الـ Theme
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = _themeMode == ThemeMode.dark;
    await prefs.setBool('isDark', !isDark);
    setState(() => _themeMode = isDark ? ThemeMode.light : ThemeMode.dark);
  }

  // ← تغيير اللغة
  Future<void> changeLanguage(String langCode) async {
    await LanguageManager.saveLanguage(langCode);
    setState(() => _locale = Locale(langCode));
  }

  bool get isDark => _themeMode == ThemeMode.dark;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafQ',
      debugShowCheckedModeBanner: false,

      // ← Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // ← Localization
      locale: _locale,
      supportedLocales: const [
        Locale('ar'), // ← عربي
        Locale('en'), // ← إنجليزي
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate, // ← ترجماتنا
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ← Routes
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const LoginScreen(),
      },
    );
  }
}
