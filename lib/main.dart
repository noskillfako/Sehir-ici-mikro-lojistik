import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_database_service.dart';
import 'services/session_service.dart';
import 'views/auth/login_view.dart';
import 'views/courier/courier_pool_view.dart';
import 'views/customer/customer_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive veritabanını ve kutuları başlat
  final dbService = HiveDatabaseService();
  await dbService.initDatabase();

  runApp(const RouteDuckApp());
}

class RouteDuckApp extends StatefulWidget {
  const RouteDuckApp({super.key});

  @override
  State<RouteDuckApp> createState() => _RouteDuckAppState();
}

class _RouteDuckAppState extends State<RouteDuckApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  Widget _determineInitialView() {
    final session = SessionService();

    if (session.isLoggedIn && session.getCurrentUserId() != null) {
      final role = session.getActiveRole();
      if (role == AppConstants.roleCourier) {
        return CourierPoolView(onToggleTheme: _toggleTheme);
      } else {
        return CustomerHomeView(onToggleTheme: _toggleTheme);
      }
    }

    return LoginView(onToggleTheme: _toggleTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RouteDuck - Şehir İçi Mikro Lojistik',
      debugShowCheckedModeBanner: false,
      theme: RouteDuckTheme.lightTheme,
      darkTheme: RouteDuckTheme.darkTheme,
      themeMode: _themeMode,
      home: _determineInitialView(),
    );
  }
}
