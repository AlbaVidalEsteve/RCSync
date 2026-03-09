import 'package:get/get.dart';

import '../controllers/add_producte_controller.dart';

class AddProducteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProducteController>(
      () => AddProducteController(),
    );
  }
}
