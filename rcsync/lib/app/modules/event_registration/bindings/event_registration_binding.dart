import 'package:get/get.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/modules/profile/controllers/profile_controller.dart';
import 'package:rcsync/app/modules/event_registration/controllers/event_registration_controller.dart';

class EventRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    if (!Get.isRegistered<EventDetailsController>()) {
      Get.put(EventDetailsController());
    }

    Get.lazyPut<EventRegistrationController>(
          () => EventRegistrationController(),
    );
  }
}