// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:rcsync/app/modules/event_detail/views/event_details_view.dart';
import 'package:rcsync/app/modules/home/bindings/home_binding.dart';
import 'package:rcsync/app/modules/home/views/home_screen.dart';
import 'package:rcsync/app/modules/login/bindings/login_binding.dart';
import 'package:rcsync/app/modules/login/views/login_view.dart';
import 'package:rcsync/app/modules/profile/bindings/profile_binding.dart';
import 'package:rcsync/app/modules/profile/views/profile_view.dart';
import 'package:rcsync/app/modules/register/bindings/register_binding.dart';
import 'package:rcsync/app/modules/register/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EVENT_DETAIL,
      page: () => const EventDetailScreen(),
    ),
  ];
}
