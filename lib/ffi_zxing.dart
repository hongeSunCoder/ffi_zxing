import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi_zxing/camera/data_model.dart';
import 'package:ffi_zxing/camera/image_converter.dart';

import 'ffi_zxing_bindings_generated.dart';

// 818 count completer map is memory over?

SendPort? _helperIsolateSendPort;
Future<CodeResult> zxingProcessCameraImage(
    CameraImage image, double cropPercent) async {
  final int requestId = nextScanRequestId++;
  final ScanRequest request = ScanRequest(
      id: requestId,
      imageBytes: await convertImage(image),
      width: image.width,
      height: image.height,
      cropSize: (min(image.width, image.height) * cropPercent).round());

  final Completer<CodeResult> completer = Completer<CodeResult>();

  scanRequests[requestId] = completer;

  print("scanRequests length: ${scanRequests.length}");

  _helperIsolateSendPort ??= await scanHelperIsolateSendPort;

  // _helperIsolateSendPort?.send(requestId);
  _helperIsolateSendPort?.send(request);

  return completer.future;
}

void zxingProcessDispose() {
  if (_helperIsolateSendPort != null) {
    _helperIsolateSendPort = null;
  }
}

int nextScanRequestId = 0;

final Map<int, Completer<CodeResult>> scanRequests =
    <int, Completer<CodeResult>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> scanHelperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is ScanResponse) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<CodeResult> completer = scanRequests[data.id]!;
        scanRequests.remove(data.id);

        // print("scanRequests: ${scanRequests.length}");
        completer.complete(data.codeResult);
        return;
      }
      if (data is int) {
        scanRequests.remove(data);
        print(
            "return request $data message from helper isolate, scanRequest length: ${scanRequests.length}");

        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        // On the helper isolate listen to requests and respond to them.
        if (data is ScanRequest) {
          // final int result = generatedBindings.sum_long_running(data.a, data.b);

          Pointer<Char> imageBytesPointer = data.imageBytes.allocatePointer();
          // max 1583
          final CodeResult result = generatedBindings.zxingRead(
              imageBytesPointer, data.width, data.height, data.cropSize);

          final ScanResponse response =
              ScanResponse(id: data.id, codeResult: result);
          print("request ${data.id} from main isolate, sending back...");

          calloc.free(imageBytesPointer);

          sendPort.send(response);
          return;
        }
        if (data is int) {
          print("get request $data from main isolate, sending back...");
          sendPort.send(data);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

    // Send the the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();

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
