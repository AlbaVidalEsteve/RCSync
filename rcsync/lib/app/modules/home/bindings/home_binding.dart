import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../results/controllers/results_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../admin_dashboard/controllers/admin_dashboard_controller.dart';

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