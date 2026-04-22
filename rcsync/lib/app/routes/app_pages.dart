// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:rcsync/app/modules/home/bindings/home_binding.dart';
import 'package:rcsync/app/modules/home/views/home_screen.dart';
import 'package:rcsync/app/modules/login/bindings/login_binding.dart';
import 'package:rcsync/app/modules/login/views/login_view.dart';
import 'package:rcsync/app/modules/profile/bindings/profile_binding.dart';
import 'package:rcsync/app/modules/profile/views/profile_view.dart';
import 'package:rcsync/app/modules/register/bindings/register_binding.dart';
import 'package:rcsync/app/modules/register/views/register_view.dart';
import 'package:rcsync/app/modules/event_detail/bindings/event_details_binding.dart';
import 'package:rcsync/app/modules/event_detail/views/event_details_view.dart';
import 'package:rcsync/app/modules/event_registration/bindings/event_registration_binding.dart';
import 'package:rcsync/app/modules/event_registration/views/event_registration_view.dart';
import 'package:rcsync/app/modules/create_event/bindings/create_event_binding.dart';
import 'package:rcsync/app/modules/create_event/views/create_event_view.dart';
import 'package:rcsync/app/modules/championship_form/bindings/championship_form_binding.dart';
import 'package:rcsync/app/modules/championship_form/views/championship_form_view.dart';
import 'package:rcsync/app/modules/splash/bindings/splash_binding.dart';
import 'package:rcsync/app/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
      page: () => const EventDetailsView(),
      binding: EventDetailsBinding(),
    ),
    GetPage(
      name: _Paths.EVENT_REGISTRATION,
      page: () => const EventRegistrationView(),
      binding: EventRegistrationBinding(),
    ),

    // RUTAS DE GESTIÓN
    GetPage(
      name: _Paths.CREATE_EVENT,
      page: () => const CreateEventView(),
      binding: CreateEventBinding(),
    ),
    GetPage(
      name: Routes.CREATE_CHAMPIONSHIP,
      page: () => const ChampionshipFormView(),
      binding: ChampionshipFormBinding(),
    ),
  ];
}
