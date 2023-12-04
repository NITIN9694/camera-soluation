import 'package:camerasoluation/infrastructure/navigation/routes.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
class HomeController extends GetxController{

  onTapCamera()async{
    var cameras =await  availableCameras();
    Get.toNamed(Routes.customCamera,arguments: {"cameras":cameras});
  }
}