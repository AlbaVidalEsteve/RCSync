import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../results/controllers/results_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Agregamos ProfileController aquí para que esté disponible cuando se cargue la Home
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
    Get.lazyPut<ResultsController>(
      () => ResultsController(),
    );
  }
}
