import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi_zxing/ffi_zxing.dart';
import 'package:ffi_zxing/ffi_zxing_bindings_generated.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class ScanRequest {
  final int id;
  final Uint8List imageBytes;
  final int width;
  final int height;
  final int cropSize;

  ScanRequest(
      {required this.id,
      required this.imageBytes,
      required this.width,
      required this.height,
      required this.cropSize});
}

class ScanResponse {
  final int id;

  final CodeResult codeResult;

  ScanResponse({required this.id, required this.codeResult});
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

          // final CodeResult result = generatedBindings.zxingRead(
          //     data.imageBytes.allocatePointer(),
          //     data.width,
          //     data.height,
          //     data.cropSize);

          // final ScanResponse response =
          //     ScanResponse(id: data.id, codeResult: r.ref);
          print("waht the funk");
          sendPort.send(1);
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

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Char> allocatePointer() {
    final Pointer<Int8> blob = calloc<Int8>(length);
    final Int8List blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob.cast<Char>();
  }
}
