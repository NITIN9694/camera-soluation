import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_svg/svg.dart';
import 'package:camerasoluation/res.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import 'custom_camera_controller.dart';

class CustomCamera
    extends GetView<CustomCameraCreatePostController> {
  const CustomCamera({super.key});


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.willPopCallback,
      child: Scaffold(
        body: Obx(() => controller.isFirst.value
            ? Container(
                height: Get.height,
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              )
            :Stack(
          children: [
            getWidget(context),
            Positioned(
              top: 40,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: ColorsTheme.colWhite, shape: BoxShape.circle),
                  child: Icon(
                    size: 30,
                    Icons.arrow_back,
                    color: ColorsTheme.colBlack,
                  ),),
              ),
            ),
          ],
        )),
      ),
    );
  }

  getWidget(context) {
    if (controller.isPage.value == 1) {
      return controller.isCameraPreview.value
          ? cameraCapturedWidget(context)
          : videoRecordingWidget(context);
    } else {
      return previewWidget(context);
    }
  }

  cameraCapturedWidget(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          width: Get.width,
          height: Get.height,
          child: FutureBuilder(
            future: controller.initializeCameraController,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Transform.scale(
                  scale: 1.0,
                  child: AspectRatio(
                      aspectRatio:
                          1 / controller.cameraController.value.aspectRatio,
                      child: CameraPreview(controller.cameraController)),
                );
              } else {
                return SizedBox(
                  height: Get.height,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        Positioned(
                bottom: Get.height / 5.5,
                left: Get.width / 4,
                right: Get.width / 4,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  alignment: Alignment.center,
                  child: Text(
                    "Don’t shake the camera".tr,
                    style: regularTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colWhite),
                  ),
                )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              padding: const EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  controller.isPage.value = 2;
                  controller.onTapClickImage();
                },
                child: Image.asset(
                  Res.icImageCapture,
                  height: 80,
                ),
              ),
            )),
        Positioned(
            left: 30,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  controller.onTapGalleryForImage();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: SvgPicture.asset(
                    Res.icGallary,
                    height: 50,
                  ),
                ),
              ),
            )),
        Positioned.fill(
          bottom: 3,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.white,
                height: 1.2,
                width: 72,
              ),
            ),
          ),
        ),
        Positioned(
            right: 30,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  controller.isCameraPreview.value = false;
                  controller.seconds.value;
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: SvgPicture.asset(
                    Res.icVideo,
                    height: 50,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  videoRecordingWidget(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          width: Get.width,
          height: Get.height,
          child: FutureBuilder(
            future: controller.initializeCameraController,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Transform.scale(
                  scale: 1.0,
                  child: AspectRatio(
                      aspectRatio:
                          1 / controller.cameraController.value.aspectRatio,
                      child: CameraPreview(controller.cameraController)),
                );
              } else {
                return SizedBox(
                  height: Get.height,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        Positioned(
            left: 20,
            right: 20,
            bottom: 150,
            child: SizedBox(
              height: 82,
              width: 82,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.imageVideoFileList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        controller.imageSelectedIndex.value = index;
                      },
                      child: Obx(() => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: controller
                                          .imageVideoFileList[index].type == "image"
                                  ? Image.file(
                                      File(controller
                                          .imageVideoFileList[index].file!),
                                      fit: BoxFit.fill,
                                      height: 82,
                                      width: 82,
                                    )
                                  : SvgPicture.asset(
                                      Res.icCategoryPlaceholder,
                                      height: 82,
                                      width: 82,
                                    ),
                            ),
                          )),
                    );
                  }),
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              padding: const EdgeInsets.only(left: 15, right: 15),
              alignment: Alignment.center,
              child: InkWell(
                  onTap: () {
                    if (controller.isVideoRecording.value) {
                      if (controller.isVideoPause.value) {
                        //resume
                        controller.resumeVideoRecording();
                      } else {
                        //pause
                        controller.pauseVideoRecording();
                      }
                    } else {
                      controller.startVideoRecording();
                    }
                  },
                  child: Obx(
                    () => getRecordingIcons(),
                  )),
            )),
        Positioned(
            top: 50,
            left: Get.width / 2.6,
            child: Container(
              decoration: BoxDecoration(
                  color: ColorsTheme.colFF2828,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              alignment: Alignment.center,
              child: Obx(() => Text(
                    controller.formtedTime(
                        timeInSecond: controller.seconds.value),
                    style: regularTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colWhite),
                  )),
            )),
        Positioned(
            left: 30,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: InkWell(
                  onTap: () {
                    controller.onTapGalleryForVideo();
                  },
                  child: Obx(
                    () => !controller.isVideoRecording.value
                        ? Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: SvgPicture.asset(
                              Res.icGallary,
                              height: 50,
                            ),
                          )
                        : Container(),
                  )),
            )),
        Positioned.fill(
          bottom: 3,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.white,
                height: 1.2,
                width: 72,
              ),
            ),
          ),
        ),
        Positioned(
            right: 30,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Obx(() => InkWell(
                    onTap: () {
                      if(controller.isVideoRecording.value){
                        print("stopVideoRecording calling");
                        controller.isFirst.value = true;
                        controller.stopVideoRecording();
                      }
                      controller.isCameraPreview.value = true;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: SvgPicture.asset(
                        controller.isVideoRecording.value
                            ? Res.icStop
                            : Res.icCamera,
                        height: 50,
                      ),
                    ),
                  )),
            )),
      ],
    );
  }

  getRecordingIcons(){
    if(controller.isVideoRecording.value){
      if (controller.isVideoPause.value) {
        //resume
        return SvgPicture.asset(
          Res.icRecodingPlay,
          height: 80,
        );
      } else {
        //pause
        return SvgPicture.asset(
          Res.icPause,
          height: 80,
        );
      }
    }else{
      return SvgPicture.asset(
        Res.icRecording,
        height: 80,
      );
    }
  }

  previewWidget(context) {
    controller.imageSelectedIndex.value = controller.imageVideoFileList.length-1==controller.imageSelectedIndex.value?controller.imageSelectedIndex.value:0;
    return controller.imageVideoFileList.isEmpty?Container():Stack(
      children: [
        Obx(
          () => SizedBox(
            height: Get.height,
            width: Get.width,
            child: controller
                        .imageVideoFileList[controller.imageSelectedIndex.value]
                        .type ==
                    'image'
                ? Image.file(
                    File(controller
                        .imageVideoFileList[controller.imageSelectedIndex.value]
                        .file!),
                    fit: BoxFit.fill,
                  )
                : controller.isVideoInitialize.value
                    ? AspectRatio(
                        aspectRatio:
                        controller
                            .imageVideoFileList[controller.imageSelectedIndex.value].videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(controller
                            .imageVideoFileList[controller.imageSelectedIndex.value].videoPlayerController!),
                      )
                    : const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator()),
                      ),
          ),
        ),

        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: MediaQuery.of(context).size.height / 6,
              width: 90,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      if(controller.imageVideoFileList[controller.imageSelectedIndex.value].type=="video"){
                        if(controller.imageVideoFileList[controller.imageSelectedIndex.value].videoPlayerController!.value.isPlaying){
                          controller.pauseVideo();
                          controller.isVideoPlaying.value = false;
                        }
                      }
                      controller.imageVideoFileList.clear();

                      controller.isPage.value = 1;
                    },
                    child: Image.asset(
                      Res.icImageCancel,
                      height: 50,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      //goto create post page
                      controller.toCreatePost();
                    },
                    child: Image.asset(
                      Res.icImageDone,
                      height: 50,
                    ),
                  ),
                ],
              ),
            )),
        controller
            .imageVideoFileList[controller.imageSelectedIndex.value]
            .type ==
            'video'?Center(
          child: InkWell(
            onTap: () {
              if(controller
                  .imageVideoFileList[controller.imageSelectedIndex.value]
                  .videoPlayerController!.value.isPlaying){
                controller.pauseVideo();
                controller.isVideoPlaying.value = false;
              }else{
                controller.playVideo();
                controller.isVideoPlaying.value = true;
              }
            },
            child: Obx(() => SvgPicture.asset(
              controller.isVideoPlaying.value?Res.icPause:Res.icVideoPlay,
              height: 50,
            )),
          ),
        ):Container()
      ],
    );
  }
}
