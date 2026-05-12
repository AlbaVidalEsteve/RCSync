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
import 'package:rcsync/app/modules/forgot_password/bindings/forgot_password_binding.dart';
import 'package:rcsync/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:rcsync/app/modules/reset_password/bindings/reset_password_binding.dart';
import 'package:rcsync/app/modules/reset_password/views/reset_password_view.dart';
import 'package:rcsync/app/modules/pilot_detail/bindings/pilot_detail_binding.dart';
import 'package:rcsync/app/modules/pilot_detail/views/pilot_detail_view.dart';
import 'package:rcsync/app/modules/my_results/bindings/my_results_binding.dart';
import 'package:rcsync/app/modules/my_results/views/my_results_view.dart';
import 'package:rcsync/app/modules/user_stats/bindings/user_stats_binding.dart';
import 'package:rcsync/app/modules/user_stats/views/user_stats_view.dart';
import 'package:rcsync/app/middlewares/auth_middleware.dart';

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
      name: _Paths.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.EVENT_DETAIL,
      page: () => const EventDetailsView(),
      binding: EventDetailsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.EVENT_REGISTRATION,
      page: () => const EventRegistrationView(),
      binding: EventRegistrationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CREATE_EVENT,
      page: () => const CreateEventView(),
      binding: CreateEventBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.CREATE_CHAMPIONSHIP,
      page: () => const ChampionshipFormView(),
      binding: ChampionshipFormBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.PILOT_DETAIL,
      page: () => const PilotDetailView(),
      binding: PilotDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.MY_RESULTS,
      page: () => const MyResultsView(),
      binding: MyResultsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.USER_STATS,
      page: () => const UserStatsView(),
      binding: UserStatsBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}