import 'package:get/get.dart';
import 'package:rcsync/app/modules/user_stats/controllers/user_stats_controller.dart';

class UserStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserStatsController>(() => UserStatsController());
  }
}
