import 'package:get/get.dart';

import 'package:rcsync/app/modules/home/controllers/home_controller.dart';
import 'package:rcsync/app/modules/results/controllers/results_controller.dart';
import 'package:rcsync/app/modules/profile/controllers/profile_controller.dart';
import 'package:rcsync/app/modules/admin_dashboard/controllers/admin_dashboard_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
    );
    Get.lazyPut<ResultsController>(
          () => ResultsController(),
    );
    Get.lazyPut<AdminDashboardController>(
          () => AdminDashboardController(),
    );
  }
}