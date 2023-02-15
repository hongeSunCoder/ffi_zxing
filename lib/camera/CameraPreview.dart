import 'package:camera/camera.dart';
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

  initAsyncState() async {
    availableCameras().then((descriptions) async {
      if (descriptions.isEmpty) {
        return;
      }

      controller = CameraController(descriptions.first, ResolutionPreset.max);

      try {
        await controller?.initialize();
      } on CameraException catch (e) {
        print(e);
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

    if (controller == null) {
      return Container();
    }
    return CameraPreview(controller!, child:const Text("this is camera"),);
  }
}