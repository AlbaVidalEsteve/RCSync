import 'package:get/get.dart';
import '../controllers/championship_form_controller.dart';

class ChampionshipFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChampionshipFormController>(() => ChampionshipFormController());
  }
}
