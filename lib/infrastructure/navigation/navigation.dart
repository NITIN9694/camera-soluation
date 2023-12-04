

import 'package:camerasoluation/presentation/home/home_binding.dart';
import 'package:flutter/animation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../../presentation/custom_camera/custom_camera_binding.dart';
import '../../presentation/custom_camera/custom_camera_page.dart';


import '../../presentation/home/home_page.dart';
import 'routes.dart';

class AppPages {
  static List<GetPage> pageList = [

    GetPage(
        name: Routes.home,
        page: () =>   const HomePage(),
        binding: HomeBinding(),
    ),
 

    GetPage(
        name: Routes.customCamera,
        page: () =>  const CustomCamera(),
        binding: CustomCameraBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),


  ];
}
