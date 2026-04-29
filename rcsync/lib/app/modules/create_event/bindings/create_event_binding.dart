import 'package:get/get.dart';
import 'package:rcsync/app/modules/create_event/controllers/create_event_controller.dart';

class CreateEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateEventController>(() => CreateEventController());
  }
}
