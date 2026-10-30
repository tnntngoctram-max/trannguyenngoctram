import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_settings.dart';
import 'screens/auth/login_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeSettings(),
      child: const MyApp(),
    ),
  );
}

/// Entry point (Điều hướng theo Role với Theme Provider)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSettings = Provider.of<ThemeSettings>(context);

    return MaterialApp(
      title: 'Hệ thống Điểm danh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSettings.primaryColor,
          primary: themeSettings.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.backgroundColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: themeSettings.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeSettings.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: const BorderSide(color: AppConstants.secondaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: const BorderSide(color: AppConstants.secondaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            borderSide: BorderSide(color: themeSettings.primaryColor, width: 2),
          ),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(themeSettings.fontScale),
          ),
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}
