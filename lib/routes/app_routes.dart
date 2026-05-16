import 'package:flutter/material.dart';

import '../presentation/payments_screen/payments_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String profileScreen = '/profile-screen';
  static const String paymentsScreen = '/payments-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SignUpLoginScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    profileScreen: (context) => const ProfileScreen(),
    paymentsScreen: (context) => const PaymentsScreen(),
  };
}
