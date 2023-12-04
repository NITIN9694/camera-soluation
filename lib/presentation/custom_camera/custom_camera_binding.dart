import 'package:get/get.dart';

import 'custom_camera_controller.dart';

class CustomCameraBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => CustomCameraCreatePostController());

  }

}