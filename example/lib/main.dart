import 'package:ffi_zxing/camera/CameraPreview.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ffi_zxing/ffi_zxing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                Container(
                  width: 500,
                  height: 500,
                  color: Colors.red,
                  child: const ZxingCameraPreview(),)
                ,
              
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                
              
              ],
            ),
          ),
      ),
    );
  }
}
