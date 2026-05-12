import 'package:get/get.dart';
import 'package:rcsync/app/modules/pilot_detail/controllers/pilot_detail_controller.dart';

class PilotDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilotDetailController>(() => PilotDetailController());
  }
}
