import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../infrastructure/preference/snackbar.util.dart';


class CustomCameraCreatePostController extends GetxController {

  List<CameraDescription> cameras = [];
  late CameraController cameraController;
  late Future<void> initializeCameraController;
  var isFlashOn = false.obs;
  var imageVideoFileList = <Filetype>[].obs;
  var isFirst = true.obs;
  var screenType = '';
  var isFrontCamera = true.obs;
  var imageSelectedIndex = 0.obs;
  var isPage = 1.obs;
  var compressImageFile = ''.obs;
  var isCameraPreview = true.obs;

  //video player
  var isVideoClicked = false.obs;
  var isVideoRecording = false.obs;
  var isVideoPause = false.obs;
  Timer? videoTimer;
  var seconds = 0.obs;
  var isVideoInitialize = false.obs;
  var isVideoPlaying = false.obs;
  var  isRunning = false.obs;


  @override
  void onInit() {
    cameras = Get.arguments['cameras'];
    initializeCamera();

    Future.delayed(const Duration(milliseconds: 100), () {
      isFirst.value = false;
    });
    super.onInit();
  }

  @override
  void dispose() {
    print("dispose calling");
    cameraController.dispose();
    disposeVideoController();
    super.dispose();
  }


  @override
  void onClose() {
    super.onClose();
    print("close calling");
  }

  Future<void> initializeCamera() async {
    // Switch between front and rear cameras
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh,
    );
    initializeCameraController = cameraController.initialize();
  }

  onTapClickImage() async {
    isFirst.value = true;
    try {
      final XFile image = await cameraController.takePicture();
      //imagePath.value = image.path;
      compressImageFile.value = await compressImage(image.path, "image");
      imageVideoFileList
          .add(Filetype(file: compressImageFile.value, type: "image"));
      Future.delayed(const Duration(milliseconds: 1), () {
        isFirst.value = false;
      });

      // Use the captured image
      print('Image captured: ${image.path}');
    } catch (e) {
      isFirst.value = false;
      print('Error capturing image: $e');
    }
  }

  onTapFlashOn() {
    isFlashOn.value = true;
    cameraController.setFlashMode(FlashMode.torch);
  }

  onTapFlashOff() {
    isFlashOn.value = false;
    cameraController.setFlashMode(FlashMode.off);
  }

  toggleCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    initializeCamera();
  }

  onTapGalleryForImage() async {
    try {
      var picker = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 60);
      if (picker != null && (picker.path.isNotEmpty)) {
        /* imageFile.value = picker.path;*/
        //isFirst.value = true;
        compressImageFile.value = picker.path;
        imageVideoFileList
            .add(Filetype(file: compressImageFile.value, type: 'image'));
        isPage.value = 2;
        Future.delayed(const Duration(milliseconds: 100), () {
          isFirst.value = false;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          isFirst.value = false;
        });
      }
    } catch (e) {
      Future.delayed(const Duration(seconds: 1), () {
        isFirst.value = false;
      });
    }
  }

  compressImage(imagePath, type) async {
    try {
      final dir = Directory.systemTemp;
      String targetPath;
      if (type == "image") {
        targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
      } else {
        targetPath =
            "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";
      }

      var compressedFile = await FlutterImageCompress.compressAndGetFile(
          imagePath, targetPath,
          quality: 90);
      print(compressedFile != null ? compressedFile.path : '');
      return compressedFile != null ? compressedFile.path : imagePath;
    } catch (e) {
      return imagePath;
    }
  }

  //Video section

  startVideoRecording() async {
    print("video start");
    //isVideoPause.value = false;
    isVideoRecording.value = true;
    if (!cameraController.value.isInitialized) {
      SnackBarUtil.showSuccess(message: 'Error: ${'select a camera first.'}');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }
    try {
      startTimer();
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  stopVideoRecording() async {
    print("video stopVideoRecording");
    if (!cameraController.value.isRecordingVideo) {}
    try {
      isCameraPreview.value = true;
      isVideoRecording.value = false;
      isVideoPause.value = false;
      isPage.value = 2;
      completeTimer();
      XFile file = await cameraController.stopVideoRecording();
      compressImageFile.value = await compressImage(file.path, "video");
      imageVideoFileList.add(Filetype(
          file: compressImageFile.value,
          type: "video",));
      imageVideoFileList.refresh();
      if (imageVideoFileList.isNotEmpty) {
        imageSelectedIndex.value = imageVideoFileList.length-1;
        initializeVideo();
        isFirst.value = false;
      }
      print("sklfdjsfj${compressImageFile.value}");

    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  pauseVideoRecording() async {
    print("video pauseVideoRecording");
    if (!cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      isVideoPause.value = true;
      pauseTimer();
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  resumeVideoRecording() async {
    print("video resumeVideoRecording");
    if (!cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      isVideoPause.value = false;
      startTimer();
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    SnackBarUtil.showSuccess(message: 'Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  onTapGalleryForVideo() async {
    print("onTapGalleryForVideo");
    try {
      var picker = await ImagePicker().pickVideo(
          source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
      if (picker != null && (picker.path.isNotEmpty)) {
        isFirst.value = true;
        isPage.value = 2;
        compressImageFile.value = picker.path;
        print("onTapGalleryForVideo${compressImageFile.value}");
        imageVideoFileList
            .add(Filetype(file: compressImageFile.value, type: 'video',));
        imageVideoFileList.refresh();
        print('updated videos: ${imageVideoFileList}');
        if (imageVideoFileList.isNotEmpty) {
          imageSelectedIndex.value = imageVideoFileList.length-1;
          initializeVideo();
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          isFirst.value = false;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          isFirst.value = false;
        });
      }
    } catch (e) {
      Future.delayed(const Duration(seconds: 1), () {
        isFirst.value = false;
      });
    }
  }


  //Timers
  void startTimer() {
    if (!isRunning.value) {
      videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if(seconds.value==120){
          seconds.value = 0;
          stopVideoRecording();
        }else{
          isRunning.value = true;
          seconds.value += 1;
        }
      });
    }
  }

  void pauseTimer() {
    if (isRunning.value) {
      videoTimer!.cancel();
      isRunning.value = false;
    }
  }

  void completeTimer() {
    if (isRunning.value) {
      videoTimer!.cancel();
        seconds.value = 0;
      isRunning.value = false;
      }
  }

  formtedTime({required int timeInSecond}) {
    print('formated time$timeInSecond');
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  //video player

  initializeVideo() {
    try {
      if (imageVideoFileList[imageSelectedIndex.value].type == "video") {
        imageVideoFileList[imageSelectedIndex.value].videoPlayerController =
            VideoPlayerController.file(
                File(imageVideoFileList[imageSelectedIndex.value].file!))
              ..initialize().then((value) {
                isVideoInitialize.value = true;
                imageVideoFileList.refresh();
              });
      }
    } catch (e) {
      print("video player error$e");
    }
  }

  playVideo() {
    if(imageVideoFileList[imageSelectedIndex.value].type=='video'){
      if(!imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.value.isPlaying){
        imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.play();
      }
    }
  }

  pauseVideo() {
    if(imageVideoFileList[imageSelectedIndex.value].type=='video'){
      if(imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.value.isPlaying){
        imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.pause();
      }
    }

  }

  disposeVideoController() {
    if(imageVideoFileList[imageSelectedIndex.value].type=='video'){
      imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.pause();
      imageVideoFileList[imageSelectedIndex.value].videoPlayerController!.dispose();
    }
  }



  toCreatePost() async {
   Get.back();
  }

  Future<bool> willPopCallback() async {
    if( initializeCameraController!=null){
      cameraController.dispose();
    }
    if(isVideoInitialize.value){
      disposeVideoController();
    }
    Get.back();
    return Future.value(true); // return true if the route to be popped
  }
}

class Filetype {
  String? file;
  String? type;
  VideoPlayerController? videoPlayerController;

  Filetype(
      {required this.file, required this.type, this.videoPlayerController});
}
