import 'package:flutter/material.dart';

import '../presentation/home_screen/home_screen.dart';
import '../presentation/trips_screen/trips_screen.dart';
import '../presentation/payments_screen/payments_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/driver_dashboard/driver_dashboard.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String homeScreen = '/home-screen';
  static const String tripsScreen = '/trips-screen';
  static const String profileScreen = '/profile-screen';
  static const String paymentsScreen = '/payments-screen';
  static const String driverDashboard = '/driver-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SignUpLoginScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    homeScreen: (context) => const HomeScreen(),
    tripsScreen: (context) => const TripsScreen(),
    profileScreen: (context) => const ProfileScreen(),
    paymentsScreen: (context) => const PaymentsScreen(),
    driverDashboard: (context) => const DriverDashboardScreen(),
  };
}
