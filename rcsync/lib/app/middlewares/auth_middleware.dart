import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rcsync/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final isLoggedIn = supabase.auth.currentUser != null;

    if (!isLoggedIn) {
      final publicRoutes = [
        Routes.LOGIN,
        Routes.REGISTER,
        Routes.SPLASH,
      ];
      if (!publicRoutes.contains(route)) {
        return const RouteSettings(name: Routes.LOGIN);
      }
    }
    if (isLoggedIn && (route == Routes.LOGIN || route == Routes.REGISTER)) {
      return const RouteSettings(name: Routes.HOME);
    }
    return null;
  }
}
