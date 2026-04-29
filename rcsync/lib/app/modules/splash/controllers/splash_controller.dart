import 'package:get/get.dart';
import 'package:rcsync/app/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    Get.offAllNamed(Routes.HOME);
  }
}
