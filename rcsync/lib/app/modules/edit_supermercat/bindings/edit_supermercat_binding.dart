import 'package:get/get.dart';

import '../controllers/edit_supermercat_controller.dart';

class EditSupermercatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditSupermercatController>(
      () => EditSupermercatController(),
    );
  }
}
