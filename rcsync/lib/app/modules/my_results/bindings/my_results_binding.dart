import 'package:get/get.dart';
import 'package:rcsync/app/modules/my_results/controllers/my_results_controller.dart';

class MyResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyResultsController>(() => MyResultsController());
  }
}
