import 'package:get/get.dart';

import '../controllers/add_supermercat_controller.dart';

class AddSupermercatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddSupermercatController>(
      () => AddSupermercatController(),
    );
  }
}
