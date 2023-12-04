import 'package:camerasoluation/infrastructure/theme/text.theme.dart';
import 'package:camerasoluation/presentation/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';


class HomePage extends GetView<HomeController>{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     backgroundColor: Colors.indigoAccent,
     body: Center(

       child: InkWell(
         onTap: (){
           controller.onTapCamera();
         },
         child: Container(
           height: Get.height/11,
           margin: EdgeInsets.symmetric(horizontal: 20),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20)

           ),
           child: Center(
             child:  Center(
                child: Text("Camera",
                style: boldTextStyle(fontSize: dimen16, color: Colors.black),
                ),
              ),
           ),
         ),
       ),
     ),
   );

  }

}