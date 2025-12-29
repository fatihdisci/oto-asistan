import 'package:flutter/material.dart';
import '../presentation/views/auth/login_screen.dart';
import '../presentation/views/auth/register_screen.dart';
import '../presentation/views/main_bottom_nav_screen.dart';
import '../presentation/views/onboarding/onboarding_screen.dart';
import '../presentation/views/onboarding/add_vehicle_wizard_screen.dart';
import '../presentation/views/garage/service_history_screen.dart';
import '../presentation/views/garage/add_service_log_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String addVehicle = '/add-vehicle';
  static const String serviceHistory = '/service-history';
  static const String addServiceLog = '/add-service-log';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const MainBottomNavScreen());
      case addVehicle:
        return MaterialPageRoute(builder: (_) => const AddVehicleWizardScreen());
      case serviceHistory:
        final vehicle = settings.arguments;
        return MaterialPageRoute(builder: (_) => ServiceHistoryScreen(vehicle: vehicle));
      case addServiceLog:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddServiceLogScreen(
            vehicleId: args?['vehicleId'] ?? '',
            vehiclePlate: args?['vehiclePlate'] ?? '',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Sayfa bulunamadı'))),
        );
    }
  }
}