import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';
import 'service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? videoController;

  final service = HttpService();
  final resolutionPresets = ResolutionPreset.values;
  bool canTake = true;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  void startTimer() {
    const oneSec = Duration(seconds: 2);
    Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (canTake) {
          canTake = false;
          XFile? file = await takePicture();
          if (file != null) {
            await service.sendImage(File(file.path));
            canTake = true;
          }
        }
      },
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      log('Error occurred while taking picture: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      controller!.setFocusMode(FocusMode.auto);
      controller!.setFlashMode(FlashMode.off);
      startTimer();
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller!),
    );
  }
}
