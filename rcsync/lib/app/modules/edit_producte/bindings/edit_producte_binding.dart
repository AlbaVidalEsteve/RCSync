import 'package:get/get.dart';

import '../controllers/edit_producte_controller.dart';

class EditProducteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProducteController>(
      () => EditProducteController(),
    );
  }
}
