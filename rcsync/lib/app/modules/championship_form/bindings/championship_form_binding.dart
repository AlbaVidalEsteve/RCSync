import 'package:get/get.dart';
import 'package:rcsync/app/modules/championship_form/controllers/championship_form_controller.dart';

class ChampionshipFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChampionshipFormController>(() => ChampionshipFormController());
  }
}
