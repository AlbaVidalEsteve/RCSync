// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:supabase_notes/app/modules/add_producte/bindings/add_producte_binding.dart';
import 'package:supabase_notes/app/modules/add_producte/views/add_producte_view.dart';
import 'package:supabase_notes/app/modules/add_supermercat/bindings/add_supermercat_binding.dart';
import 'package:supabase_notes/app/modules/add_supermercat/views/add_supermercat_view.dart';
import 'package:supabase_notes/app/modules/edit_producte/bindings/edit_producte_binding.dart';
import 'package:supabase_notes/app/modules/edit_producte/views/edit_producte_view.dart';
import 'package:supabase_notes/app/modules/edit_supermercat/bindings/edit_supermercat_binding.dart';
import 'package:supabase_notes/app/modules/edit_supermercat/views/edit_supermercat_view.dart';
import 'package:supabase_notes/app/modules/home/bindings/home_binding.dart';
import 'package:supabase_notes/app/modules/list/bindings/list_binding.dart';
import 'package:supabase_notes/app/modules/list/views/list_view.dart';
import 'package:supabase_notes/app/modules/home/views/home_view.dart';
import 'package:supabase_notes/app/modules/login/bindings/login_binding.dart';
import 'package:supabase_notes/app/modules/login/views/login_view.dart';
import 'package:supabase_notes/app/modules/profile/bindings/profile_binding.dart';
import 'package:supabase_notes/app/modules/profile/views/profile_view.dart';
import 'package:supabase_notes/app/modules/register/bindings/register_binding.dart';
import 'package:supabase_notes/app/modules/register/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LIST,
      page: () => ListProductesView(),
      binding: ListBinding(),
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
      name: _Paths.ADD_PRODUCTE,
      page: () => AddProducteView(),
      binding: AddProducteBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PRODUCTE,
      page: () => EditProducteView(),
      binding: EditProducteBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_SUPERMERCAT,
      page: () => EditSupermercatView(),
      binding: EditSupermercatBinding(),
    ),
    GetPage(
      name: _Paths.ADD_SUPERMERCAT,
      page: () => AddSupermercatView(),
      binding: AddSupermercatBinding(),
    ),

  ];
}
