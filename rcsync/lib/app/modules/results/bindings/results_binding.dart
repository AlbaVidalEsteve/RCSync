import 'package:get/get.dart';
import 'package:rcsync/app/modules/results/controllers/results_controller.dart';

class ResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultsController>(() => ResultsController());
  }
}