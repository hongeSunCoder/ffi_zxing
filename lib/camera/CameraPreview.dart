import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ffi_zxing/ffi_zxing.dart';
import 'package:ffi_zxing/ffi_zxing_bindings_generated.dart';
import 'package:flutter/material.dart';

class ZxingCameraPreview extends StatefulWidget {
  const ZxingCameraPreview({super.key});

  @override
  State<StatefulWidget> createState() => _ZxingCameraPreviewState();
}

class _ZxingCameraPreviewState extends State<ZxingCameraPreview> {
  CameraController? controller;
  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  bool _isProcessing = false;
  processCameraImage(CameraImage image) async {
    if (_isProcessing) {
      return;
    }
    _isProcessing = true;
    CodeResult result = await zxingProcessCameraImage(image, 0.5);
    if (result.isValid == 1) {
      print("scan result: ${result.text}");
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
    }

    _isProcessing = false;
  }

  initAsyncState() async {
    availableCameras().then((descriptions) async {
      if (descriptions.isEmpty) {
        return;
      }

      if (controller != null) {
        await controller!.dispose();
      }

      controller = CameraController(descriptions.first, ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.yuv420
              : ImageFormatGroup.bgra8888);

      try {
        await controller?.initialize();

        controller?.startImageStream(processCameraImage);
      } on CameraException catch (e) {
        print("MyCamera error: $e");
      }

      controller!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    return CameraPreview(
      controller!,
      child: const Text(
        "this is camera",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
