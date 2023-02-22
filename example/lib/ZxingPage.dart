import 'package:ffi_zxing/camera/CameraPreview.dart';
import 'package:flutter/material.dart';

class ZxingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ZxingPageState();
}

class _ZxingPageState extends State<ZxingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZxingCameraPreview(),
    );
  }
}
