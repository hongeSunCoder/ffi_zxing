import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:ffi_zxing/camera/flow_data_model.dart';
import 'package:ffi_zxing/camera/image_converter.dart';

import 'ffi_zxing_bindings_generated.dart';

// 818 count completer map is memory over?

SendPort? _helperIsolateSendPort;
zxingProcessCameraImage(CameraImage image, double cropPercent) async {
  final int requestId = nextScanRequestId++;
  final ScanRequest request = ScanRequest(
      id: requestId,
      imageBytes: await convertImage(image),
      width: image.width,
      height: image.height,
      cropSize: (min(image.width, image.height) * cropPercent).round());

  // final Completer<CodeResult> completer = Completer<CodeResult>();

  // tempScanRequests[requestId] = 1;
  // scanRequests[requestId] = completer;

  print("scanRequests length: ${scanRequests.length}");

  // print("tempScanRequests length: ${tempScanRequests.length}");

  _helperIsolateSendPort ??= await scanHelperIsolateSendPort;

  // _helperIsolateSendPort?.send(requestId);
  _helperIsolateSendPort?.send(request);

  // return completer.future;
}

void zxingProcessDispose() {
  if (_helperIsolateSendPort != null) {
    _helperIsolateSendPort = null;
  }
}

const String _libName = 'ffi_zxing';

/// The dynamic library in which the symbols for [FfiZxingBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FFIZxingGeneratedBindings generatedBindings =
    FFIZxingGeneratedBindings(_dylib);
