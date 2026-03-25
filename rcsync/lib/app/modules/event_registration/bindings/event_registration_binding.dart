import 'package:get/get.dart';
import 'package:rcsync/app/modules/event_detail/controllers/event_details_controller.dart';
import 'package:rcsync/app/modules/profile/controllers/profile_controller.dart';
import 'package:rcsync/app/modules/event_registration/controllers/event_registration_controller.dart';

class EventRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Aseguramos que ProfileController existe.
    // Si el usuario no ha entrado al perfil antes, GetX lo crea ahora.
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    // 2. Aseguramos que EventDetailsController existe.
    if (!Get.isRegistered<EventDetailsController>()) {
      Get.put(EventDetailsController());
    }

    // 3. Inyectamos nuestro controlador de inscripción
    Get.lazyPut<EventRegistrationController>(
          () => EventRegistrationController(),
    );
  }
}