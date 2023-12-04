
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sizer/sizer.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/theme.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: GetMaterialApp(
          initialRoute: Routes.home,
          getPages: AppPages.pageList,
          debugShowCheckedModeBanner: false,
          theme: themeData,
          builder: (context, Widget? child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.1),
              child: child!,
            );
          },

        ),
      );
    });
  }
}
